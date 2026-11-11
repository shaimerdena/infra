#!/usr/bin/env bash
# Removes the units and helper. Data and logs are kept unless --purge is given.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
systemctl disable --now postgresql-logrotate.timer postgresql.service 2>/dev/null || true
rm -f /etc/systemd/system/postgresql.service /etc/systemd/system/postgresql-logrotate.{service,timer}
systemctl daemon-reload
rm -f /usr/local/sbin/postgresql-ctl
rm -rf /opt/postgresql-systemd
if [ "${1:-}" = "--purge" ]; then
    rm -rf /var/lib/postgresql/data /var/log/postgresql /etc/default/postgresql-container
    docker rmi postgresql-slim:17 2>/dev/null || true
    echo "purged data, logs, config and image"
else
    echo "kept /var/lib/postgresql/data, /var/log/postgresql and /etc/default/postgresql-container"
fi
