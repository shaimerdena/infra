#!/usr/bin/env bash

set -u

SCRIPT_DIR="/opt/postgres-custom/scripts"
TIMEOUT=60
INTERVAL=2
ELAPSED=0

while (( ELAPSED < TIMEOUT )); do
    if timeout 5 "$SCRIPT_DIR/health-check.sh"; then
        echo "PostgreSQL became ready after ${ELAPSED}s"
        exit 0
    fi

    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "ERROR: PostgreSQL did not become ready within ${TIMEOUT}s"
exit 1
