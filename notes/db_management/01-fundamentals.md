# Database Fundamentals and Infrastructure

## 1. Database Management

Database management covers the processes and infrastructure required to
operate databases reliably throughout their lifecycle. A database is not
simply a place where an application stores information: it is a stateful
system that must be deployed, configured, secured, monitored, backed up,
maintained and recovered.

Common areas of database management include:

-   **Deployment:** installing and configuring a database service.
-   **Persistence:** ensuring data survives process and container
    restarts.
-   **Performance:** keeping queries and transactions efficient.
-   **Scaling:** supporting increased workloads.
-   **Backup and recovery:** protecting data and restoring it after
    failures.
-   **Schema evolution:** managing changes to tables and other database
    objects.
-   **Availability:** keeping the database accessible when components
    fail.

These areas are connected. For example, a database may be running but
still be unavailable to an application because it is not ready to accept
connections. A database may also be highly available but still
vulnerable to accidental deletion if it has no suitable backups.

## 2. Stateful and Stateless Applications

A **stateless application instance** does not depend on locally retained
state between requests. Its instances can often be replaced without
losing the application's persistent data, provided that state is stored
in an external system.

A **stateful application** maintains data or state that must survive
restarts and replacement. A database such as PostgreSQL is stateful
because it stores persistent records, indexes, transaction-related
information and database metadata.

---
| Characteristic    |	Stateless  Workload	| Stateful Workload |
|-------------------|----------------------|-------------------|
| Persistent local data |	Usually not required 	| Required or carefully managed
| Instance replacement	| Usually straightforward	| Requires data and identity considerations
| Storage lifecycle	| Often disposable	| Must outlive an individual process/container
| Examples	| Stateless API workers	| PostgreSQL, message brokers

Containerization does not make a stateful application inherently unsafe.
The important requirement is to manage persistent storage, backups,
recovery, networking and lifecycle operations correctly.

## 3. Containers and Stateful Workloads

Containers package an application and its runtime dependencies into an
isolated execution environment. They make software easier to reproduce,
distribute and run consistently.

However, containers introduce operational considerations for stateful
services:

-   **Storage:** database files must be kept in storage that survives
    container replacement.
-   **I/O performance:** storage drivers, filesystems and volume
    configuration can affect read/write performance.
-   **Networking:** container networking may add layers between clients
    and the database.
-   **Lifecycle:** stopping, replacing or recreating a container must
    not accidentally destroy persistent data.
-   **Operations:** backup, restore, upgrades, monitoring and failover
    still need explicit design.

The phrase "Docker is an anti-pattern for stateful applications" is too
broad if interpreted as an absolute rule. Containers can run databases
in production. The real question is whether the surrounding storage,
networking, orchestration and recovery design meets the workload's
requirements.

### Persistent Storage

A container's writable layer is associated with that container's
lifecycle. Removing the container can remove data stored only in that
layer.

A Docker volume provides storage managed separately from the container.
A volume can be mounted into a container at a path used by the database.

Conceptually:

``` text
Host-managed persistent volume
              |
              | mounted at
              v
Container: database data directory
```

A named volume is easier to identify and reuse than an anonymous volume.
However, a volume is not a backup: it may still be lost if the
underlying host or storage fails, or if data is deleted or corrupted.

## 4. Docker Networking for Database Services

Containers need network connectivity to communicate with other
containers, the host and external clients. Docker provides different
network drivers for different connectivity models.

### Bridge Network

A bridge network creates a private network for containers on a Docker
host.

-   Containers attached to the same user-defined bridge can communicate
    with each other.
-   Docker provides network isolation from unrelated networks.
-   Containers can generally be discovered by service or container name
    on a user-defined bridge.
-   Publishing a port makes a container service reachable through a host
    port.

Port publishing commonly uses the form:

``` text
HOST_PORT:CONTAINER_PORT
```

For example, a host port can be mapped to the port on which PostgreSQL
listens inside its container.

Bridge networking is a common default for applications composed of
multiple containers.

### Host Network

With host networking, a container shares the host's network namespace
rather than receiving an independent network namespace.

Consequences include:

-   The container uses the host's network interfaces.
-   Port publishing is not used in the usual way.
-   A service listening on a port uses that port in the host network
    namespace.
-   Network isolation between the container and host is reduced.
-   Port conflicts can occur with other host processes.

Host networking can be useful for particular performance or
network-integration requirements, but it should be selected
deliberately.

### Macvlan Network

Macvlan allows a container to appear on a physical network as a separate
network endpoint, with its own MAC address and IP address.

It can be useful when network infrastructure needs to communicate with a
container as though it were a separate device.

Considerations include:

-   The physical network and switch configuration must support the
    required behaviour.
-   IP address allocation must avoid conflicts.
-   Host-to-container communication may require additional
    configuration.
-   Macvlan does not automatically provide database replication or high
    availability.

### Network Driver Comparison

| Feature | Bridge | Host | Macvlan |
| :--- | :--- | :--- | :--- |
| **Network namespace** | Separate | Shared with host | Separate |
| **Network identity** | Docker network address | Host network identity | Own MAC/IP identity |
| **Port publishing** | Commonly used | Not used in the usual way | Usually unnecessary for LAN access |
| **Isolation** | Provides network isolation | Reduced | Separate network endpoint |
| **Typical use** | Container-to-container communication | Specific host-network requirements | Direct presence on a physical LAN |

## 5. Service Readiness and Health Checks

A running process is not necessarily ready to serve requests.

For example, a PostgreSQL container may be running while the database is
still initializing. A container can also remain running while the
database process is unable to accept connections.

A **health check** periodically executes a test and reports whether the
service appears healthy.

Common health-check settings include:

-   **Test:** the command used to check the service.
-   **Interval:** time between checks.
-   **Timeout:** maximum time allowed for one check.
-   **Retries:** number of consecutive failures before the status
    becomes unhealthy.
-   **Start period:** initial grace period during which startup failures
    are treated differently.

For PostgreSQL, `pg_isready` checks whether the server is accepting
connections. It does not prove that every application query will succeed
or that the database contains the expected data.

It is useful to distinguish:

-   **Running:** the container or process is active.
-   **Ready:** the service can accept the intended work.
-   **Healthy:** the configured health-check test is succeeding.

## 6. Linux Service Management with systemd

`systemd` is a system and service manager used by many Linux
distributions. It can start services during boot, manage dependencies,
stop services, monitor processes and apply restart policies.

A systemd unit file describes how a service should be managed. A
`.service` unit commonly contains these sections:

-   `[Unit]`: description and relationships to other units.
-   `[Service]`: process execution, user identity, restart behaviour and
    I/O handling.
-   `[Install]`: how the service is enabled in relation to system
    targets.

### Important Directives

| Directive | Purpose |
| --- | --- |
| `ExecStart=` | Command used to start the service |
| `ExecStop=` | Command used to stop the service |
| `User=` | User identity used to run the service process |
| `Restart=` | Conditions under which systemd restarts the service |
| `RestartSec=` | Delay before a restart attempt |
| `Requires=` | Adds a required unit dependency |
| `Wants=` | Adds a weaker dependency |
| `After=` | Defines ordering relative to another unit |
| `StandardOutput=` | Controls where standard output is sent |
| `StandardError=` | Controls where standard error is sent |

`Requires=` and `After=` are not interchangeable. `Requires=` expresses
a dependency relationship, while `After=` specifies ordering. A unit can
have one without the other.

`network-online.target` represents a systemd target associated with
network readiness. Its usefulness depends on the relevant wait-online
service being enabled and correctly configured. It does not guarantee
that every remote endpoint is reachable.

### Restart Behaviour

A restart policy can improve recovery from unexpected process
termination. However, restart loops must be controlled.

`RestartSec=` adds a delay before a restart. Start-rate limiting can
restrict how frequently a service is allowed to start.

An intentional `systemctl stop` should not be treated like an unexpected
crash that must immediately be undone.

### Running Services with Least Privilege

The principle of **least privilege** means that a process should have
only the permissions required for its task.

Running a service as a non-root user can reduce the impact of some
failures and compromises. However, the user must still have appropriate
access to required files, directories, sockets and devices.

Access to the Docker daemon is especially sensitive: membership in the
traditional `docker` group can effectively grant root-level control over
the host. Running a systemd unit as a non-root user does not
automatically make Docker access unprivileged.

### Standard Streams and Logs

Unix-like processes commonly use three standard file descriptors:

| Stream | File descriptor | Purpose |
| --- | --- | --- |
| `stdin` | `0` | Standard input |
| `stdout` | `1` | Normal output |
| `stderr` | `2` | Error and diagnostic output |

systemd can direct stdout and stderr to different destinations. Log
rotation is important when writing to files, because log files can grow
indefinitely.

Log rotation must be coordinated with the process that writes the logs.
Some processes keep file descriptors open after a log file has been
renamed or rotated, so the rotation strategy must account for how the
application reopens its log files.

## 7. Key Takeaways

-   Database management includes deployment, persistence, performance,
    recovery, schema changes and availability.
-   Containers can run stateful services, but persistent storage and
    recovery must be designed explicitly.
-   Bridge, host and macvlan networks provide different connectivity and
    isolation models.
-   Running does not necessarily mean ready or healthy.
-   systemd manages Linux service lifecycles; Docker manages containers.
-   Least privilege and careful log management are important operational
    practices.
