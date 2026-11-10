# Database Performance, Scaling and Backup

## 1. Understanding Database Performance

Database performance describes how efficiently a database processes
requests and transactions while using available resources.

Performance is influenced by several factors:

-   SQL query design and execution plans.
-   Index structures.
-   Memory and caching.
-   CPU and storage performance.
-   Network latency.
-   Number of concurrent connections.
-   Transaction patterns and workload characteristics.

Optimizing one factor does not guarantee that the entire system will
become faster. Performance work should begin with measurement and an
understanding of the workload.

## 2. Performance Metrics

Several metrics describe different aspects of system performance.

| Metric | Meaning |
| --- | --- |
| **Latency** | Time taken for an operation or request to complete |
| **Throughput** | Amount of work completed per unit of time |
| **RPS** | Requests processed per second |
| **TPS** | Transactions processed per second |
| **Error rate** | Proportion of requests or operations that fail |
| **Concurrency** | Number of operations or requests active at the same time |

RPS and TPS are related but not interchangeable. One application request
may execute multiple SQL statements or transactions. The exact
relationship depends on application design.

High concurrency can expose bottlenecks that are not visible during a
single-user test. A useful performance test should represent realistic
query patterns, data volume and concurrency.

## 3. Query Execution and Measurement

A query's execution time depends on the work PostgreSQL must perform to
produce its result.

For example, a query that filters a large table by a user identifier may
need to examine many rows if no useful index exists.

PostgreSQL provides tools for examining query plans:

-   `EXPLAIN` displays the planner's estimated execution plan.
-   `EXPLAIN ANALYZE` executes the statement and reports actual
    execution information alongside the plan.

`EXPLAIN ANALYZE` really executes the query. For statements that modify
data, this means the changes can occur unless the operation is wrapped
in a transaction and rolled back where appropriate.

Important plan concepts include:

-   **Sequential Scan:** reads table pages and checks rows against the
    query condition.
-   **Index Scan:** uses an index to locate matching rows and then
    accesses table data as needed.
-   **Bitmap Scan:** combines index information to identify table pages
    efficiently.
-   **Execution Time:** reported time for execution, excluding some
    client-side and network costs.

The planner chooses a plan based on estimated costs and statistics. An
index is not guaranteed to be used: for a query returning a large
proportion of a table, a sequential scan may be cheaper.

## 4. Query Optimization

Query optimization aims to reduce unnecessary work and resource
consumption.

Useful principles include:

-   Retrieve only the columns required rather than selecting every
    column by default.
-   Filter rows as early and precisely as the query semantics allow.
-   Use joins and predicates that match the intended relationships.
-   Avoid repeated work when results can be reused safely.
-   Inspect query plans instead of guessing how the database executes a
    query.
-   Measure before and after changes using comparable data and
    conditions.

Network transfer also matters. Returning fewer rows and fewer
unnecessary columns can reduce the amount of data transferred between
the database and application.

## 5. Caching

Caching stores reusable data in a faster-access location to avoid
repeatedly retrieving or computing it.

### Cache Hits and Misses

-   **Cache hit:** requested data is found in the cache.
-   **Cache miss:** requested data is not found and must be retrieved or
    computed elsewhere.

A common measure is the cache hit ratio:

\[ `\text{Hit Ratio}`{=tex} = `\frac{\text{Cache Hits}}`{=tex}
{`\text{Cache Hits}`{=tex}+`\text{Cache Misses}`{=tex}}
`\times 100`{=tex}% \]

A high hit ratio can be beneficial when the workload repeatedly accesses
the same data. However, the ratio alone does not prove that the
application is fast: cache size, data access patterns, latency and the
cost of misses also matter.

### PostgreSQL Memory Caching

PostgreSQL uses `shared_buffers` as its shared buffer cache for database
pages. The operating system also maintains a filesystem cache.

`pg_prewarm` is a PostgreSQL extension that can load relation data into
PostgreSQL buffers or the operating system cache, depending on the
selected mode.

### External Caching

An external in-memory data store such as Redis can be used to cache
application data.

A simplified cache-aside flow is:

1.  The application checks the cache.
2.  If the data is present, the application returns it.
3.  If the data is absent, the application retrieves it from the
    database.
4.  The application stores the result in the cache for later use.

Caching introduces a consistency problem: cached data can become stale.
Cache invalidation, expiration and update strategies must be designed
according to the application's requirements.

## 6. Database Indexing

An **index** is a database structure that helps locate rows without
examining every row in a table.

Indexes can improve data retrieval, sorting and some join operations.
They also require storage and maintenance.

### B-tree Index

B-tree is PostgreSQL's default index method and is suitable for many
common operations, including:

-   Equality comparisons.
-   Range comparisons.
-   Ordered retrieval.
-   Prefix searches under supported conditions.

A B-tree index is a balanced tree structure that allows the database to
locate values without scanning the entire index linearly.

### Other Index Methods

PostgreSQL supports several index methods for different data and query
patterns:

| Method | Typical use | 
| ----- | ----- | 
| **B-tree** | General equality, range and ordering operations | 
| **Hash** | Equality comparisons | 
| **GIN** | Composite values such as arrays and JSONB containment/search | 
| **GiST** | Extensible indexing for spatial, geometric and other complex data types | 
| **BRIN** | Very large tables where values correlate with physical row order | 

The appropriate index type depends on the operators used by the queries
and the characteristics of the data.

### Choosing Columns to Index

Consider indexes on columns frequently used in:

-   `WHERE` conditions.
-   `JOIN` conditions.
-   `ORDER BY` operations.
-   Other query patterns supported by the chosen index type.

Selectivity describes how effectively a condition filters rows. A
condition that matches a small fraction of a table is generally more
selective than one that matches most rows.

High selectivity can make an index useful, but selectivity is not the
only factor. Table size, data distribution, query shape and estimated
costs all matter.

Primary key and unique constraints automatically create supporting
unique indexes in PostgreSQL. Foreign key declarations do not
automatically create an index on the referencing columns, so such
indexes may need to be considered separately.

### Composite Indexes

A composite index contains more than one column.

For example, an index on `(customer_id, created_at)` may support queries
that filter by customer and then by a date range.

For B-tree indexes, column order matters. The leading columns are
particularly important: an index on `(customer_id, created_at)` is
generally most useful for conditions that constrain `customer_id`,
optionally followed by conditions on `created_at`.

Do not assume that a composite index is equivalent to separate indexes
on each column. Choose index definitions based on actual query patterns.

### Index Trade-offs

Indexes are not free.

They: - Consume disk space. - Add work to inserts, deletes and
updates. - Require maintenance. - Can increase write latency. - May be
unused or redundant.

The goal is not to maximize the number of indexes. The goal is to create
the indexes that provide a measurable benefit for important workloads.

## 7. Scaling

Scaling increases a system's ability to handle a growing workload.

### Vertical Scaling (Scale Up)

Vertical scaling increases the resources of an existing server, such as:

-   CPU capacity.
-   RAM.
-   Storage capacity or performance.

Advantages: - Often simpler than distributing a database workload. - May
require fewer application architecture changes. - Can be a practical
first response to resource constraints.

Limitations: - Hardware and platform limits exist. - Larger machines can
become disproportionately expensive. - A single server can remain a
single point of failure.

### Horizontal Scaling (Scale Out)

Horizontal scaling adds servers or nodes and distributes workload or
data across them.

Potential advantages: - Capacity can grow by adding nodes. - Workloads
can be distributed. - Properly designed systems can improve fault
tolerance and availability.

Challenges: - More complex architecture and operations. - Data
distribution and consistency must be addressed. - Applications may need
changes to understand routing, replicas or partitions.

Adding more PostgreSQL servers does not automatically distribute writes
across them. Different techniques solve different problems:

-   **Replication:** maintains copies of data on other servers.
-   **Read replicas:** can serve suitable read workloads.
-   **Sharding:** partitions data across multiple database nodes.

Vertical and horizontal scaling are not mutually exclusive. Real systems
may use both.

## 8. Connection Pooling

A database connection has a cost. Establishing and maintaining many
simultaneous connections consumes resources.

PostgreSQL traditionally uses a process-based server architecture in
which each client connection is served by a backend process. A large
number of concurrent connections can therefore increase memory use and
process-management overhead.

A **connection pool** maintains a limited set of database connections
and reuses them for client work.

Conceptually:

``` text
Many application clients
          |
          v
    Connection pool
          |
          v
   Limited DB connections
          |
          v
      PostgreSQL
```

Benefits include: - Reuse of established connections. - Reduced
connection establishment overhead. - Control over the number of server
connections. - More efficient handling of workloads with many
short-lived clients.

### PgBouncer

PgBouncer is a lightweight connection pooler for PostgreSQL. It sits
between applications and PostgreSQL and manages client and server
connections.

Its main pooling modes are:

| Mode | Connection assignment | 
| ----- | ----- | 
| **Session** | A server connection is assigned for the lifetime of a client session | 
| **Transaction** | A server connection is assigned for the duration of a transaction | 
| **Statement** | A server connection is released after each statement | 

Transaction pooling can support high volumes of short transactions, but
it changes connection semantics. Features that depend on session state
may not work as expected when a later transaction is assigned to a
different server connection.

Connection pooling does not create more CPU or storage capacity. It
helps manage connection overhead and use database resources more
efficiently.

## 9. Database Backup and Restore

A **backup** is a copy of database information that can be used for
recovery, migration or archival purposes. **Restore** is the process of
rebuilding database objects and data from a backup.

Backups help protect against: - Accidental deletion or modification. -
Hardware and storage failures. - Data corruption. - Operational
mistakes. - Migration or infrastructure changes.

A backup strategy should define retention, storage location, access
controls and recovery objectives. Backups should also be tested: a
backup that has never been restored is not a proven recovery plan.

### pg_dump

`pg_dump` is PostgreSQL's logical backup utility for a single database.

It can export database objects and data in different formats, including:

-   Plain SQL.
-   Custom archive.
-   Directory archive.
-   Tar archive.

The **directory format** stores the archive as a directory containing
multiple files. It supports parallel dump jobs.

### pg_restore

`pg_restore` restores archives produced in formats supported by the
utility, such as custom, directory and tar formats.

It supports options for selecting objects and restoring in parallel.

A plain SQL dump is normally executed using `psql`, rather than
`pg_restore`.

### Logical Backup vs Physical Backup

`pg_dump` creates a logical backup of database objects and data. It is
not a byte-for-byte copy of the PostgreSQL data directory or an entire
server installation.

Physical backup methods operate at the level of database files and WAL
and are used for different recovery scenarios, including point-in-time
recovery.

## 10. Key Takeaways

-   Measure latency, throughput, concurrency and errors to understand
    performance.
-   Use `EXPLAIN` and `EXPLAIN ANALYZE` to inspect query execution.
-   Caching reduces repeated work but introduces freshness and
    invalidation concerns.
-   Indexes speed up suitable reads but add storage and
    write-maintenance costs.
-   Vertical scaling increases one server's resources; horizontal
    scaling adds nodes.
-   Connection pooling manages connection overhead; it does not create
    additional compute capacity.
-   `pg_dump` creates logical backups, while `pg_restore` restores
    supported archive formats.
-   A reliable backup strategy must include retention and tested
    recovery.
