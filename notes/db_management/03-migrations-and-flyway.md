# Database Migrations and Flyway

## 1. Why Database Migrations Matter

An application's database schema changes as the application evolves. New
features may require new tables, columns, indexes, constraints or
database functions. Existing objects may also need to be modified or
removed.

In a team environment, several developers may change the schema at the
same time. Without a controlled process, environments can become
inconsistent:

-   A developer's local database may have a different schema from
    testing.
-   Changes may be applied in the wrong order.
-   A deployment may expect a column that does not exist yet.
-   It may be unclear which changes have already been applied.
-   Reconstructing a database's schema history can become difficult.

A **database migration** is a managed change to the database schema or
database objects. Migration files describe changes in a way that can be
tracked and applied consistently.

## 2. Migration Files

Migration tools commonly store migration scripts in a source-controlled
directory.

A versioned migration naming convention used by Flyway is:

``` text
V<version>__<description>.sql
```

For example:

``` text
V1__create_users.sql
V2__add_email_to_users.sql
V3__create_products.sql
```

The filename communicates the migration's version and purpose. The SQL
file contains the database change.

A migration history in source control makes schema changes reviewable
alongside application code. It also allows different environments to
apply the same ordered changes.

### Applied Migrations Should Be Immutable

Once a versioned migration has been applied to a shared database, its
contents should generally not be edited.

If a later change is required, create a new migration instead. This
preserves the historical sequence and avoids environments having
different interpretations of the same migration version.

## 3. Flyway

Flyway is a database migration and versioning tool. It helps manage
schema changes by discovering migration files, comparing them with the
database's migration history and applying migrations that have not yet
been executed.

A simplified workflow is:

1.  Read configuration and locate migration files.
2.  Connect to the target database.
3.  Inspect the schema history.
4.  Validate migration state where requested or required by the
    operation.
5.  Apply pending migrations in the appropriate order.
6.  Record migration metadata in the schema history table.

Flyway does not replace SQL knowledge. Developers still write the SQL
that describes each database change.

## 4. Flyway Schema History

Flyway maintains a special history table, commonly named:

``` text
flyway_schema_history
```

The table records metadata about migrations that have been applied.

Common fields include:

| Field | Purpose | 
| ----- | ----- | 
| `installed_rank` | Order in which migrations were installed | 
| `version` | Version associated with a versioned migration | 
| `description` | Human-readable migration description | 
| `type` | Migration type | 
| `script` | Script name | 
| `checksum` | Checksum used to detect changes | 
| `installed_on` | Installation timestamp | 
| `success` | Whether the migration succeeded | 

The schema history table allows Flyway to distinguish migrations that
have already been applied from migrations that are still pending.

### Checksums

A checksum is a value calculated from migration content. Flyway uses
checksums to help detect changes to migration files that have already
been applied.

If a previously applied versioned migration is modified, its checksum
may no longer match the value recorded in the schema history. Validation
can then report a mismatch.

This is one reason applied versioned migrations should be treated as
immutable.

## 5. Migration Types

Flyway uses different migration types for different purposes.

### Versioned Migrations

Versioned migrations have a version and are applied in version order.

Naming pattern:

``` text
V1__create_users.sql
V2__add_email.sql
V3__create_products.sql
```

They are suitable for changes that should be applied once in a defined
sequence, such as creating a table or adding a column.

A versioned migration should not be edited after it has been applied to
a shared environment. A subsequent change should be represented by a new
version.

### Repeatable Migrations

Repeatable migrations use the `R__` prefix and do not have a version
number.

Example:

``` text
R__create_active_users_view.sql
```

Flyway can reapply a repeatable migration when its checksum changes.
Repeatable migrations are commonly used for database objects whose
definitions are maintained as a whole, such as views and certain
functions or procedures.

They are normally applied after pending versioned migrations during a
migration run.

### Undo Migrations

Undo migrations use a `U` prefix and are intended to reverse the effects
of a corresponding versioned migration.

For example, an undo migration might remove an object created by a
versioned migration.

Undo migrations are not a substitute for a carefully designed recovery
strategy. Their availability depends on the Flyway edition and feature
set; they are not available in every edition, including the standard
Community feature set.

For many production workflows, forward-fix migrations are preferred: a
new migration corrects the schema while preserving a clear history of
changes.

## 6. Flyway Configuration

Flyway can be configured through configuration files, command-line
options and environment variables.

A TOML configuration file can define named environments and connection
settings.

Example structure:

``` toml
[environments.development]
url = "jdbc:postgresql://localhost:5432/appdb"
schemas = ["public"]
connectRetries = 10
connectRetriesInterval = 5
```

The exact supported configuration properties and syntax depend on the
Flyway version.

### JDBC URL

A PostgreSQL JDBC URL commonly follows this structure:

``` text
jdbc:postgresql://HOST:PORT/DATABASE
```

Parts:

-   `jdbc:postgresql`: identifies the JDBC driver/database type.
-   `HOST`: database server hostname or IP address.
-   `PORT`: database listener port.
-   `DATABASE`: database name.

JDBC is the Java Database Connectivity API. Flyway uses a database
driver to communicate with the target database.

### Environments

Named environments allow different connection settings for development,
testing, staging and production.

Credentials should be managed securely. Avoid committing real passwords,
tokens or production secrets into source control. Use an appropriate
secret-management mechanism or protected environment variables.

### Schemas

A PostgreSQL schema is a namespace inside a database. It groups database
objects such as tables, views, functions and sequences.

A database can contain multiple schemas. Flyway's schema-related
settings determine which schemas it manages and where its schema history
is maintained, depending on configuration.

### Connection Retries

Connection retry settings allow Flyway to retry when a database is
temporarily unavailable.

This can be useful when the database is still starting. Retries do not
replace proper service readiness checks, dependency management or useful
error handling.

## 7. Core Flyway Commands

### `migrate`

The `migrate` command applies pending migrations found in the configured
migration locations.

At a high level, Flyway:

1.  Connects to the database.
2.  Checks migration history.
3.  Identifies pending migrations.
4.  Applies them in order.
5.  Records their results in the schema history table.

Running `migrate` again does not normally reapply already successful
versioned migrations.

### `validate`

The `validate` command checks whether migration files and the database's
recorded migration history are consistent.

Validation includes checks such as comparing checksums and detecting
missing or changed migration files.

It is important not to describe `validate` as a general SQL syntax
checker. It does not guarantee that every SQL statement will execute
successfully against the target database. Database-specific syntax and
runtime errors may only become apparent when a migration is actually
executed.

### Related Commands

Depending on the Flyway version and edition, other useful commands can
include:

-   `info`: shows migration status and history information.
-   `clean`: drops objects in configured schemas; dangerous and
    generally inappropriate for production.
-   `repair`: adjusts schema history metadata in specific recovery
    situations; it does not undo schema changes.
-   `baseline`: records an existing database as a starting point for
    migration management.

Always check the documentation for the installed Flyway version and
edition before relying on a command or feature.

## 8. Flyway in a Containerized Workflow

Flyway can run as a separate process or container that connects to a
PostgreSQL service.

A typical architecture contains:

``` text
Application / deployment pipeline
              |
              v
        Flyway process
              |
              v
         PostgreSQL
```

In a containerized environment, Flyway needs:

-   Network connectivity to PostgreSQL.
-   A valid JDBC URL.
-   Appropriate credentials.
-   The PostgreSQL JDBC driver.
-   Access to the migration files.
-   Correct migration configuration.

The database should be ready to accept connections before Flyway
attempts to migrate it. Container start order alone does not necessarily
guarantee database readiness.

## 9. Migrations in CI/CD

Database migrations are often integrated into a deployment pipeline.

A simplified process is:

1.  A developer adds a migration file to version control.
2.  The change is reviewed and merged.
3.  CI validates the repository and migration state where appropriate.
4.  A deployment stage connects to the target database.
5.  Flyway applies pending migrations.
6.  The application is deployed or made active according to the release
    strategy.

Migration order and application compatibility matter. For example,
removing a column before all running application versions stop using it
can cause failures.

A common safer approach is an expand-and-contract strategy:

-   **Expand:** add new structures while keeping the old application
    compatible.
-   **Migrate:** move application behaviour or data to the new
    structure.
-   **Contract:** remove obsolete structures after they are no longer
    used.

## 10. Key Takeaways

-   Migrations provide a controlled, repeatable history of database
    changes.
-   Flyway discovers migration files and tracks applied changes in
    `flyway_schema_history`.
-   Versioned migrations are ordered and should be treated as immutable
    after application.
-   Repeatable migrations can be reapplied when their contents change.
-   Undo migrations are edition-dependent and should not be assumed to
    be available.
-   Checksums help detect changes to previously applied migrations.
-   `migrate` applies pending migrations; `validate` checks consistency
    with migration history.
-   Flyway can be integrated into containerized deployments and CI/CD
    pipelines.
-   Database schema changes must remain compatible with application
    deployment and rollback strategies.
