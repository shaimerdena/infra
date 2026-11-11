#!/usr/bin/env bash

set -u

CONTAINER="postgres-db"
DB_USER="postgres"
DB_NAME="postgres"
TIMEOUT=5

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker command not found"
    exit 1
fi

if ! docker exec "$CONTAINER" \
    timeout "$TIMEOUT" \
    psql -U "$DB_USER" -d "$DB_NAME" \
    -tAc "SELECT 1" 2>/dev/null | grep -qx "1"; then
    echo "ERROR: PostgreSQL health check failed"
    exit 1
fi

echo "OK: PostgreSQL is healthy"