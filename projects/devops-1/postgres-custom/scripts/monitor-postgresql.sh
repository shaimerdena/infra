#!/usr/bin/env bash

set -u
HEALTH_CHECK="/opt/postgres-custom/scripts/health-check.sh"
COUNTER_FILE="/run/postgresql-health-failures"
SERVICE="postgresql.service"
MAX_FAILURES=3

# Do not recover a service that was intentionally stopped.
if ! systemctl is-active --quiet "$SERVICE"; then
    echo "PostgreSQL service is not active; skipping health check."
    echo 0 > "$COUNTER_FILE"
    exit 0
fi

if timeout 5 "$HEALTH_CHECK"; then
    echo 0 > "$COUNTER_FILE"
    echo "Health check succeeded; failure counter reset."
    exit 0
fi

failures=0
if [[ -r "$COUNTER_FILE" ]]; then
    read -r failures < "$COUNTER_FILE" || failures=0
fi

failures=$((failures + 1))
echo "$failures" > "$COUNTER_FILE"

echo "PostgreSQL health check failed (${failures}/${MAX_FAILURES})."

if (( failures >= MAX_FAILURES )); then
    echo "Three consecutive failures. Requesting systemd recovery."
    echo 0 > "$COUNTER_FILE"
    systemctl restart "$SERVICE"
fi
