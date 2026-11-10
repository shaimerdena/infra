# Database Replication and High Availability

## 1. Availability and Data Protection

A database can fail for many reasons:

-   Hardware or storage failure.
-   Operating system or process crash.
-   Network interruption.
-   Resource exhaustion.
-   Software defects or operational mistakes.

Two important concerns must be considered separately:

-   **Availability:** whether clients can access the database when they
    need it.
-   **Durability:** whether committed data remains safely stored.

A database may become temporarily unavailable while its data remains
intact. Conversely, a database may be online while some data has been
corrupted or deleted.

Backup and restore, replication and high availability address related
but different aspects of resilience.

## 2. Database Replication

Replication maintains copies of database changes on one or more
additional database servers.

In a common primary/replica architecture:

-   **Primary:** the main database server that accepts write operations.
-   **Replica:** a server that receives changes from the primary and
    maintains a copy of the data.

A simplified architecture:

``` text
              Application
                   |
                   v
                Primary
                /     \
               v       v
          Replica A  Replica B
```

Replicas can support recovery after a primary failure and may also serve
suitable read workloads.

Replication alone does not guarantee automatic failover. A system still
needs to detect failures, decide which replica should become primary,
promote it safely and redirect clients.

## 3. PostgreSQL Write-Ahead Logging

PostgreSQL uses **Write-Ahead Logging (WAL)** to support durability and
replication.

WAL records describe changes that need to be made to database files. The
key principle is that the relevant WAL information is written before
corresponding data pages are considered safely written to their final
data-file locations.

In streaming replication, a standby server receives WAL records from the
primary and replays them to keep its database state up to date.

This is the foundation for PostgreSQL physical streaming replication.

## 4. Asynchronous Replication

With asynchronous replication, the primary does not wait for a replica
to confirm receipt or application of the latest changes before
acknowledging a transaction to the client.

A simplified sequence:

1.  The client submits a transaction.
2.  The primary commits the transaction.
3.  WAL changes are sent to replicas.
4.  Replicas receive and replay the changes.

Advantages: - Lower commit latency than synchronous replication in many
environments. - The primary does not need to wait for replica
acknowledgement. - Can be useful when replicas are geographically
distant or network latency is significant.

Risk: - If the primary fails before recent WAL changes reach a replica,
a promoted replica may be missing recently committed transactions.

### Replication Lag

**Replication lag** is the delay between changes being committed on the
primary and those changes being received or replayed by a replica.

Lag can occur because of network delays, replica workload, storage
performance or other bottlenecks.

A replica that is behind the primary may return stale data if used for
reads.

## 5. Synchronous Replication

With synchronous replication, the primary waits for acknowledgement from
one or more configured synchronous standbys before completing the commit
acknowledgement to the client.

This can reduce the risk of losing recently committed transactions if
the primary fails, provided the required synchronous standby has
acknowledged the relevant WAL and the failover process is correctly
designed.

The exact acknowledgement level matters.

In PostgreSQL, synchronous replication acknowledgement is based on WAL
status. Depending on `synchronous_commit` configuration, the primary may
wait for a standby to receive WAL, flush it to durable storage, or
replay it.

Receiving or flushing WAL is not necessarily the same as applying the
changes to visible table rows on the standby.

Advantages: - Stronger protection against losing acknowledged changes
than asynchronous replication, under the configured acknowledgement
guarantees. - Useful where data loss tolerance is very low.

Trade-offs: - Commit latency increases because the primary waits for a
standby acknowledgement. - Network and standby availability affect write
availability. - If the required synchronous standby is unavailable,
commits may wait or block depending on configuration.

## 6. Synchronous vs Asynchronous Replication

| Characteristic | Asynchronous | Synchronous |
| ----- | ----- | ----- |
| **Waits for standby acknowledgement** | No | Yes, according to configuration |
| **Commit latency** | Usually lower | Usually higher |
| **Risk of losing recent acknowledged changes after primary failure** | Higher | Lower under the configured guarantees |
| **Dependence on standby response for commit** | No | Yes |
| **Typical trade-off** | Performance and availability | Stronger replication acknowledgement |

Neither mode removes the need for backups. Replication can copy unwanted
changes as well as wanted ones. For example, an accidental deletion or
logical corruption can propagate to replicas.

## 7. High Availability (HA)

**High Availability (HA)** describes an architecture designed to keep a
service accessible despite failures of individual components.

A database HA design may include:

-   A primary database server.
-   One or more replicas.
-   Health monitoring.
-   Failure detection.
-   A failover manager or orchestration mechanism.
-   A way to redirect client connections.
-   Procedures to prevent two servers from accepting writes as primary
    at the same time.

HA is not a single feature. It is a coordinated system of detection,
decision-making, promotion and traffic redirection.

### Failover

**Failover** is the process of moving service responsibility from a
failed or unavailable primary to a suitable standby.

A simplified failover sequence:

1.  Monitoring detects that the primary is unhealthy.
2.  The HA system determines whether the failure is real and whether
    promotion is safe.
3.  A replica is selected and promoted to primary.
4.  Client traffic is redirected to the new primary.
5.  The failed server is repaired and reintroduced safely, if
    appropriate.

Failover design must consider data loss, replication lag, split-brain
risk and the time required to restore service.

### Split Brain

Split brain occurs when multiple nodes believe they are the active
primary and accept conflicting writes.

This can lead to divergent database histories and difficult recovery. HA
systems need reliable coordination, fencing or other safeguards to
prevent this situation.

## 8. Virtual IP (VIP)

A **Virtual IP (VIP)** is an IP address that can be assigned or moved
between network nodes. Clients can connect to a stable address rather
than being configured with the physical address of a particular database
server.

For example:

``` text
Primary:  10.0.0.11
Replica:  10.0.0.12
VIP:      10.0.0.20
```

Clients connect to the VIP. If the primary fails and the replica is
promoted, the VIP can be moved to the new primary.

Benefits: - Provides a stable network endpoint. - Reduces the need to
change client connection settings during failover. - Separates the
client-facing address from the physical address of a database node.

A VIP does not perform replication, detect failures or promote replicas
by itself. Those responsibilities belong to monitoring and HA
components.

### VIP Management

On Linux, a tool such as Keepalived can manage virtual IP movement using
VRRP. A database HA manager may coordinate promotion and integrate with
the mechanism that moves the VIP.

A working design must ensure that the VIP is assigned only to the
correct active node.

## 9. Proxy and VIP

A proxy and a VIP are different components.

-   A **proxy** accepts client connections and forwards them to a
    backend according to its routing rules.
-   A **VIP** is a network address that can be assigned to an active
    node or service endpoint.

A proxy may provide connection routing, health-aware backend selection
or other traffic-management features. A VIP provides a stable address at
the network layer.

They can be used together, but one does not automatically replace the
other.

## 10. Replication, Backup and HA Work Together

These mechanisms solve different problems:

| Mechanism | Main purpose | 
| ----- | ----- | 
| **Backup** | Preserve recoverable copies of data | 
| **Restore** | Recover data from a backup | 
| **Replication** | Maintain additional copies of database changes | 
| **Failover** | Move service responsibility to another node | 
| **VIP or proxy** | Redirect clients to an available endpoint | 
| **Monitoring** | Detect health and availability problems | 

A resilient database architecture commonly combines these mechanisms.

For example: - Replication can reduce recovery time after a primary
failure. - Failover can promote a suitable replica. - A VIP or proxy can
redirect clients. - Backups can recover from accidental deletion,
corruption or other events that replication may reproduce.

## 11. Key Takeaways

-   Availability and durability are related but distinct requirements.
-   Replication maintains copies of database changes on other servers.
-   Asynchronous replication usually has lower commit latency but can
    lose recent changes after a primary failure.
-   Synchronous replication waits for configured standby acknowledgement
    and trades some latency for stronger protection.
-   Replication lag means a replica may be behind the primary.
-   HA requires monitoring, safe promotion, traffic redirection and
    split-brain prevention.
-   A VIP provides a stable address; it does not perform failover logic
    by itself.
-   Replication is not a replacement for backup and tested restore
    procedures.
