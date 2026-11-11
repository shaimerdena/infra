#!/usr/bin/env bash
# Installs postgresql.service (+ log rotation timer). Run as root: sudo ./install.sh
# Options: --no-start  install and enable but do not start now
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
for c in docker systemctl bash timeout install; do
    command -v "$c" >/dev/null || { echo "missing required command: $c" >&2; exit 1; }
done
docker info >/dev/null 2>&1 || { echo "docker daemon is not reachable" >&2; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
CTL=/usr/local/sbin/postgresql-ctl
SRC=/opt/postgresql-systemd
ENVF=/etc/default/postgresql-container
DOCKER_BIN="$(command -v docker)"

install -d -m 0755 "$SRC"
rm -rf "$SRC/image"; cp -r "$HERE/image" "$SRC/image"
install -m 0644 "$HERE/README.md" "$SRC/README.md"
install -m 0755 "$HERE/bin/postgresql-ctl" "$CTL"

if [ ! -e "$ENVF" ]; then
    pw="$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    umask 077
    cat >"$ENVF" <<EOF
# Configuration for postgresql.service (read by systemd and postgresql-ctl)
PG_IMAGE=postgresql-slim:17
PG_CONTAINER_NAME=postgresql
PG_DATA_DIR=/var/lib/postgresql/data
PG_LOG_DIR=/var/log/postgresql
PG_UID=1001
# host:port published by the container; empty = do not publish
PG_PUBLISH=127.0.0.1:5432
POSTGRES_USER=postgres
POSTGRES_DB=postgres
POSTGRES_PASSWORD=$pw
PG_START_TIMEOUT=60
PG_HEALTH_INTERVAL=30
PG_HEALTH_TIMEOUT=5
PG_HEALTH_RETRIES=3
PG_STOP_TIMEOUT=30
PG_LOG_KEEP=7
EOF
    chmod 0600 "$ENVF"
    echo "created $ENVF (generated superuser password inside)"
fi

"$CTL" build

for u in postgresql.service postgresql-logrotate.service postgresql-logrotate.timer; do
    sed -e "s|@CTL@|$CTL|g" -e "s|@DOCKER@|$DOCKER_BIN|g" "$HERE/systemd/$u" \
        >"/etc/systemd/system/$u"
    chmod 0644 "/etc/systemd/system/$u"
done
systemctl daemon-reload
systemctl enable postgresql.service postgresql-logrotate.timer

if [ "${1:-}" != "--no-start" ]; then
    systemctl start postgresql-logrotate.timer
    systemctl start postgresql.service
    systemctl --no-pager --lines=0 status postgresql.service || true
    "$CTL" verify || echo "log verification reported a problem" >&2
fi
echo "done. Logs: /var/log/postgresql/{output,error}.log  Data: /var/lib/postgresql/data"
