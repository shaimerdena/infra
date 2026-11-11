# postgresql.service — PostgreSQL in Docker, managed by systemd

Works on any systemd Linux host with Docker, `bash`, and `timeout` (coreutils).
The image is a bare Alpine + PostgreSQL 17 build (about 70–90 MB; the build **fails** if it reaches 100 MB).

## Install

    sudo ./install.sh            # builds the image, installs units, enables + starts everything

Conflict note: the unit is named `postgresql.service` as required; disable any distro PostgreSQL unit of the same name first.

## Layout

| Path | Purpose |
|---|---|
| `/etc/systemd/system/postgresql.service` | the service |
| `/etc/systemd/system/postgresql-logrotate.{service,timer}` | daily log rotation |
| `/usr/local/sbin/postgresql-ctl` | helper (build, prestart, run, health, logrotate, verify) |
| `/etc/default/postgresql-container` | configuration, mode 0600 (contains the generated superuser password) |
| `/var/lib/postgresql/data` | database (host bind mount), owner UID 1001, mode 0700 |
| `/var/log/postgresql/{output,error}.log` | container stdout / stderr, dir 0750, files 0640, root |

## How each requirement is met

1. **Lifecycle** – `ExecStart` runs `postgresql-ctl run`, which runs `docker run --rm --name postgresql` in the foreground, so the service exits exactly when the container exits (systemd sees it). `ExecStop` is `docker stop --time=30`; the image's stop signal is SIGINT (PostgreSQL fast shutdown = clean checkpoint). `ExecStartPre` removes any stale container, so start/stop/restart never create duplicates. Data lives on a host bind mount, so it survives restarts and container recreation.
2. **Dependencies** – `Requires=docker.service` + `After=docker.service` and `Wants=network-online.target` + `After=network-online.target`. (`network-online.target` only reflects your network manager's wait-online setting, e.g. `systemd-networkd-wait-online` or `NetworkManager-wait-online`; it is not continuous monitoring.)
3. **Recovery** – `Restart=always`, `RestartSec=5`, `StartLimitIntervalSec=300`, `StartLimitBurst=5`. `systemctl stop` is never auto-restarted. After the limit is hit use `systemctl reset-failed postgresql`.
4. **Non-root** – the image creates `devopfall2026_user` (UID/GID 1001) and the container is started with `--user 1001:1001`; the entrypoint refuses to run as root. The data dir is chowned to 1001 with mode 0700. The container also runs `--read-only`, `--cap-drop ALL`, `no-new-privileges`.
5. **Health** – check = `docker exec … psql -c 'SELECT 1'` (must print `1`, 5 s timeout). The service is `Type=notify`: READY is sent only after the first success, with a 60 s deadline (`TimeoutStartSec=60` plus an internal deadline) after which startup fails. Afterwards a monitor checks every 30 s; after 3 consecutive failures it logs to the journal and stops the container, and systemd's `Restart=` recovers the service. The monitor lives in the service's cgroup, so it cannot start a service that was intentionally stopped.
6. **Logs** – the container's stdout and stderr are piped through two FIFOs to `output.log` / `error.log` (append mode, created if missing, existing content preserved).
7. **Rotation** – `postgresql-logrotate.timer` (daily, `Persistent=true`) runs `postgresql-ctl logrotate`: keeps 7 rotated files per stream (`.1` plain, `.2.gz`–`.7.gz`), skips missing/empty logs, serialises with `flock`. Open-fd/log-loss handling: the relay re-opens the destination *path* for every line, so a plain rename rotation is safe, no `copytruncate` window, no signal needed, and `.1` is left uncompressed for one cycle so a write in flight at rotation time is never lost.

## Operate

    systemctl start|stop|restart|status postgresql
    journalctl -u postgresql -f                # health-check and recovery messages
    sudo postgresql-ctl verify                 # stdout/stderr reach the files, before and after a rotation
    sudo postgresql-ctl health; echo $?
    systemctl list-timers postgresql-logrotate.timer
    sudo systemctl start postgresql-logrotate.service   # rotate now

Connect: `psql -h 127.0.0.1 -U postgres` with the password from `/etc/default/postgresql-container`.
Change settings in that file, then `systemctl restart postgresql`.

## Quick acceptance checks

    docker ps --filter name=postgresql              # exactly one container
    docker top postgresql -o user,uid | head        # not root (uid 1001)
    sudo kill -9 $(docker inspect -f '{{.State.Pid}}' postgresql)   # restarts after 5 s
    systemctl stop postgresql; sleep 10; systemctl is-active postgresql   # stays inactive
    docker rm -f postgresql; systemctl restart postgresql           # data still there

## Offline hosts

Build once where a registry is reachable, `docker save postgresql-slim:17 | gzip > pg.tar.gz`, then `docker load` on the target and run `install.sh` with the image already present (it rebuilds only if it can reach the registry; otherwise skip the `build` line).
