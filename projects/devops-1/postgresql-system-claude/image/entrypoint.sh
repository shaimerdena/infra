#!/bin/sh
# Container entrypoint: initialise the cluster on first start, then exec postgres
# (as PID 1) so it receives stop signals directly.
set -eu

PGDATA="${PGDATA:-/var/lib/postgresql/data/pgdata}"
export PGDATA
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-$POSTGRES_USER}"

echo "[entrypoint] running as $(id -un) (uid=$(id -u) gid=$(id -g))"
if [ "$(id -u)" -eq 0 ]; then
    echo "[entrypoint] refusing to run as root" >&2
    exit 1
fi

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    if [ -z "${POSTGRES_PASSWORD:-}" ]; then
        echo "[entrypoint] POSTGRES_PASSWORD must be set to initialise a new cluster" >&2
        exit 1
    fi
    echo "[entrypoint] initialising new cluster in $PGDATA"
    mkdir -p "$PGDATA"
    chmod 0700 "$PGDATA"
    pwfile="$(mktemp)"
    printf '%s\n' "$POSTGRES_PASSWORD" > "$pwfile"
    initdb --username="$POSTGRES_USER" --pwfile="$pwfile" \
           --auth-local=trust --auth-host=scram-sha-256 \
           --encoding=UTF8 --locale=C --no-instructions
    rm -f "$pwfile"
    {
        echo "host all all 0.0.0.0/0 scram-sha-256"
        echo "host all all ::/0 scram-sha-256"
    } >> "$PGDATA/pg_hba.conf"

    if [ "$POSTGRES_DB" != "postgres" ]; then
        pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start
        createdb -U "$POSTGRES_USER" "$POSTGRES_DB"
        pg_ctl -D "$PGDATA" -m fast -w stop
    fi
fi

echo "[entrypoint] starting postgres"
exec postgres \
    -c listen_addresses='*' \
    -c log_destination=stderr \
    -c log_line_prefix='%m [%p] %q%u@%d '
