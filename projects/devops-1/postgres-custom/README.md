# PostgreSQL Container Managed by systemd

## Overview

This project runs PostgreSQL 17 in a Docker container managed by systemd. It provides persistent database storage, health monitoring, automatic recovery, and log rotation.

## Features

- PostgreSQL 17 running in a Docker container.
- Persistent Docker volume for database data.
- Non-root PostgreSQL process running as `devopfall2026_user` (UID/GID 1001).
- systemd service management with automatic restart after unexpected failures.
- PostgreSQL readiness check during service startup.
- Periodic health checks using `SELECT 1`.
- Recovery after three consecutive health-check failures.
- Separate standard output and error logs.
- Daily log rotation with up to seven archived logs and compression.

## Requirements

- Linux system with systemd.
- Docker Engine.
- GNU Make.
- `logrotate`.
- `sudo` privileges.

The installation script expects Docker to be available as `/usr/bin/docker`.

## Project Structure

```text
postgres-custom/
├── Dockerfile
├── Makefile
├── README.md
├── .env.example
├── .gitignore
├── scripts/
│   ├── health-check.sh
│   ├── install.sh
│   ├── monitor-postgresql.sh
│   └── wait-for-postgresql.sh
└── systemd/
    ├── postgresql.service
    ├── postgresql-health.service
    ├── postgresql-health.timer
    ├── postgresql-log-rotate.service
    ├── postgresql-log-rotate.timer
    └── postgresql-logrotate.conf
```

## Installation

### 1. Configure environment variables

Create a local environment file:

```bash
cp .env.example .env
```

Edit `.env` and set a strong password:

```dotenv
POSTGRES_USER=postgres
POSTGRES_DB=postgres
POSTGRES_PASSWORD=your_strong_password
```

Do not commit `.env` to version control. It is excluded by `.gitignore`.

### 2. Build and install

Run the following command from the project directory:

```bash
make install
```

This builds the Docker image, creates the container and persistent volume if necessary, and installs the systemd units, scripts, and log rotation configuration.

The installation script uses `/opt/postgres-custom` for installed project files and enables the PostgreSQL service and scheduled timers.

### 3. Start PostgreSQL

```bash
sudo systemctl start postgresql
```

Check its status:

```bash
sudo systemctl status postgresql --no-pager
```

## Service Management

Start PostgreSQL:

```bash
make start
```

Stop PostgreSQL:

```bash
make stop
```

Restart PostgreSQL:

```bash
make restart
```

Check status:

```bash
make status
```

The Docker container uses `--restart=no` so that systemd manages its restart policy. Stopping the service with `systemctl stop` is an intentional stop and should not trigger an automatic restart.

## Health Monitoring

The health-check script executes:

```sql
SELECT 1;
```

The startup readiness script waits up to 60 seconds for PostgreSQL to become ready.

The health-monitoring timer runs approximately every 30 seconds. After three consecutive failed checks, the monitor requests a systemd restart. A successful health check resets the failure counter.

Run a manual health check:

```bash
make test
```

Check the timer:

```bash
systemctl status postgresql-health.timer --no-pager
```

## Persistent Storage

Database files are stored in the Docker volume `postgres-data`, mounted at:

```text
/var/lib/postgresql/data
```

The volume persists independently of the container lifecycle. Do not remove the volume when restarting or reinstalling the service if the database contents must be preserved.

## Logging and Log Rotation

The service writes logs to:

- `/var/log/postgresql/output.log`
- `/var/log/postgresql/error.log`

Log rotation is configured in:

```text
/etc/logrotate.d/postgresql-custom
```

The configuration specifies daily rotation, up to seven archived logs, compression, date-based archive names, and `copytruncate`.

Check the log rotation timer:

```bash
systemctl status postgresql-log-rotate.timer --no-pager
```

Inspect recent logs:

```bash
make logs
```

Check the log rotation configuration without changing files:

```bash
sudo logrotate -d /etc/logrotate.d/postgresql-custom
```

## Troubleshooting

Inspect the PostgreSQL service:

```bash
sudo systemctl status postgresql --no-pager -l
sudo journalctl -u postgresql -n 50 --no-pager
```

Inspect health-check logs:

```bash
sudo journalctl -u postgresql-health.service -n 50 --no-pager
```

Check the container:

```bash
sudo docker ps -a
sudo docker logs --tail 50 postgres-db
```

Run the health check directly:

```bash
sudo bash /opt/postgres-custom/scripts/health-check.sh
```

## Security Notes

- Use a strong database password.
- Keep `.env` out of version control.
- The PostgreSQL container runs as a non-root user.
- The database port is published on `127.0.0.1:5432`, limiting access to the local machine.
- Keep the persistent volume when database data must be retained.

## Important Notes

- The installation script requires an existing Docker container named `postgres-db`.
- If the container already exists, the Makefile leaves it unchanged. Changing `.env` does not automatically reinitialize an existing database.
- This project uses systemd for container recovery; Docker's automatic restart policy is disabled.
- The health-check and log-rotation timers are separate systemd units.

## License

Add the applicable license information if this project is distributed publicly.