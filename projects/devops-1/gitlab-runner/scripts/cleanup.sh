
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/runner_config.sh"

log "Starting GitLab Runner cleanup..."

# 1. Check dependencies
require_command systemctl
require_command sudo
require_docker

RUNNER_ID=""
GITLAB_URL=""
RUNNER_TOKEN=""

# 2. Read saved runner state
if [[ -f "$STATE_FILE" ]]; then
    require_command jq
    require_command curl

    jq empty "$STATE_FILE" 2>/dev/null ||
        die "Runner state file contains invalid JSON."

    RUNNER_ID="$(jq -r '.runner_id // empty' "$STATE_FILE")"
    GITLAB_URL="$(jq -r '.gitlab_url // empty' "$STATE_FILE")"
    RUNNER_TOKEN="$(jq -r '.runner_token // empty' "$STATE_FILE")"

    [[ -n "$RUNNER_ID" && -n "$GITLAB_URL" && -n "$RUNNER_TOKEN" ]] ||
        die "Runner state file is incomplete."

    [[ -n "${GITLAB_API_TOKEN:-}" ]] ||
        die "GITLAB_API_TOKEN is required to delete the GitLab runner."
fi

# 3. Stop and disable systemd service
if sudo systemctl cat "$SERVICE_NAME" >/dev/null 2>&1; then
    log "Stopping and disabling systemd service..."
    sudo systemctl disable --now "$SERVICE_NAME"
else
    log "Systemd service is not installed."
fi

# 4. Inspect local runner configuration
LOCAL_RUNNER_REGISTERED=false

if docker container inspect "$RUNNER_CONTAINER" >/dev/null 2>&1; then

    # Start the container if it was stopped by systemd
    if [[ "$(docker inspect -f '{{.State.Running}}' "$RUNNER_CONTAINER")" != "true" ]]; then
        log "Starting container temporarily for cleanup..."
        docker start "$RUNNER_CONTAINER" >/dev/null
    fi

    if docker exec "$RUNNER_CONTAINER" \
        test -s /etc/gitlab-runner/config.toml; then

        if [[ -z "$RUNNER_TOKEN" ]]; then
            die "Local runner configuration exists, but saved state is missing. Refusing to remove it."
        fi

        if printf '%s\n' "$RUNNER_TOKEN" |
            docker exec -i "$RUNNER_CONTAINER" sh -c '
                IFS= read -r token || exit 2
                grep -Fq -- "$token" /etc/gitlab-runner/config.toml
            '; then
            LOCAL_RUNNER_REGISTERED=true
        else
            GREP_STATUS=$?

            if [[ "$GREP_STATUS" -eq 1 ]]; then
                log "Local runner registration is already absent."
            else
                die "Could not inspect local runner configuration."
            fi
        fi
    else
        log "Local runner configuration is missing or empty."
    fi
else
    log "Runner container does not exist."
fi

# 5. Unregister local runner manager
if [[ "$LOCAL_RUNNER_REGISTERED" == "true" ]]; then
    log "Unregistering local runner manager..."

    docker exec "$RUNNER_CONTAINER" \
        gitlab-runner unregister \
        --url "$GITLAB_URL" \
        --token "$RUNNER_TOKEN" ||
        die "Could not unregister local runner manager."
else
    log "Skipping local unregister."
fi

# 6. Delete GitLab runner record
if [[ -n "$RUNNER_ID" ]]; then
    log "Deleting GitLab runner record..."

    HTTP_STATUS="$(curl --silent --show-error \
        --output /dev/null \
        --write-out '%{http_code}' \
        --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
        "$GITLAB_URL/api/v4/runners/$RUNNER_ID")" ||
        die "Could not contact GitLab API."

    if [[ "$HTTP_STATUS" != "204" && "$HTTP_STATUS" != "404" ]]; then
        die "GitLab runner deletion failed. HTTP status: $HTTP_STATUS"
    fi

    log "GitLab runner record removed or already absent."
fi

# 7. Remove dedicated container and configuration volume
if docker container inspect "$RUNNER_CONTAINER" >/dev/null 2>&1; then
    log "Removing runner container..."
    docker rm --force "$RUNNER_CONTAINER" >/dev/null
fi

if docker volume inspect "$RUNNER_VOLUME" >/dev/null 2>&1; then
    log "Removing runner configuration volume..."
    docker volume rm "$RUNNER_VOLUME" >/dev/null
fi

# 8. Remove systemd unit
if [[ -f "$SERVICE_FILE" ]]; then
    log "Removing systemd unit..."
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
fi

# 9. Remove local state
if [[ -d "$STATE_DIR" ]]; then
    log "Removing local runner state..."
    rm -rf "$STATE_DIR"
fi

log "GitLab Runner cleanup completed successfully."