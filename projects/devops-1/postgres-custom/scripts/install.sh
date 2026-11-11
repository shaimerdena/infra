#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="/opt/postgres-custom"
SYSTEMD_DIR="/etc/systemd/system"
LOG_DIR="/var/log/postgresql"

if [[ $EUID -ne 0 ]]; then
    echo "Run with: sudo bash scripts/install.sh"
    exit 1
fi

command -v docker >/dev/null || {
    echo "ERROR: Docker is not installed."
    exit 1
}

docker info >/dev/null

docker container inspect postgres-db >/dev/null 2>&1 || {
    echo "ERROR: Container postgres-db does not exist. Run 'make create' first."
    exit 1
}

echo "Installing PostgreSQL systemd project..."

install -d -m 755 "$INSTALL_DIR/scripts" "$INSTALL_DIR/systemd"

install -m 755 "$REPO_DIR/scripts/health-check.sh" \
    "$REPO_DIR/scripts/monitor-postgresql.sh" \
    "$REPO_DIR/scripts/wait-for-postgresql.sh" \
    "$INSTALL_DIR/scripts/"

install -m 644 "$REPO_DIR/systemd/postgresql.service" \
    "$REPO_DIR/systemd/postgresql-health.service" \
    "$REPO_DIR/systemd/postgresql-health.timer" \
    "$REPO_DIR/systemd/postgresql-log-rotate.service" \
    "$REPO_DIR/systemd/postgresql-log-rotate.timer" \
    "$INSTALL_DIR/systemd/"

install -m 644 "$REPO_DIR/systemd/postgresql.service" \
    "$SYSTEMD_DIR/postgresql.service"
install -m 644 "$REPO_DIR/systemd/postgresql-health.service" \
    "$SYSTEMD_DIR/postgresql-health.service"
install -m 644 "$REPO_DIR/systemd/postgresql-health.timer" \
    "$SYSTEMD_DIR/postgresql-health.timer"
install -m 644 "$REPO_DIR/systemd/postgresql-log-rotate.service" \
    "$SYSTEMD_DIR/postgresql-log-rotate.service"
install -m 644 "$REPO_DIR/systemd/postgresql-log-rotate.timer" \
    "$SYSTEMD_DIR/postgresql-log-rotate.timer"

install -d -m 755 "$LOG_DIR"
touch "$LOG_DIR/output.log" "$LOG_DIR/error.log"
chown root:root "$LOG_DIR/output.log" "$LOG_DIR/error.log"
chmod 640 "$LOG_DIR/output.log" "$LOG_DIR/error.log"

install -m 644 "$REPO_DIR/systemd/postgresql-logrotate.conf" \
    /etc/logrotate.d/postgresql-custom

systemctl daemon-reload
systemctl enable postgresql.service
systemctl enable postgresql-health.timer
systemctl enable --now postgresql-log-rotate.timer

echo "Installation completed."
echo "Start PostgreSQL with: sudo systemctl start postgresql"
echo "Check status with:     sudo systemctl status postgresql"