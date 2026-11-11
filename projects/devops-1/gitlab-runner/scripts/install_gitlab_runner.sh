# install_gitlab_runner.sh
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/runner_config.sh"

log "Starting GitLab Runner installation..."

# 1. Check dependencies
require_command systemctl
require_command sudo
require_command cmp
require_docker

# 2. Pull the explicitly versioned image
log "Pulling GitLab Runner image: $RUNNER_IMAGE"
docker pull "$RUNNER_IMAGE"

# 3. Create persistent configuration volume if necessary
if ! docker volume inspect "$RUNNER_VOLUME" >/dev/null 2>&1; then
    log "Creating persistent volume: $RUNNER_VOLUME"
    docker volume create "$RUNNER_VOLUME" >/dev/null
else
    log "Persistent volume already exists. Keeping it."
fi

# 4. Create the container only if it does not exist
if docker container inspect "$RUNNER_CONTAINER" >/dev/null 2>&1; then
    log "Existing runner container found. Checking configuration..."

    EXISTING_IMAGE="$(docker inspect --format '{{.Config.Image}}' "$RUNNER_CONTAINER")"
    EXISTING_RESTART_POLICY="$(docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' "$RUNNER_CONTAINER")"

    EXISTING_CONFIG_VOLUME="$(
        docker inspect --format \
        '{{range .Mounts}}{{if eq .Destination "/etc/gitlab-runner"}}{{.Name}}{{end}}{{end}}' \
        "$RUNNER_CONTAINER"
    )"

    HAS_DOCKER_SOCKET="$(
        docker inspect --format \
        '{{range .Mounts}}{{if eq .Destination "/var/run/docker.sock"}}{{.Source}}{{end}}{{end}}' \
        "$RUNNER_CONTAINER"
    )"

    [[ "$EXISTING_IMAGE" == "$RUNNER_IMAGE" ]] ||
        die "Existing container uses an unexpected image: $EXISTING_IMAGE"

    [[ "$EXISTING_RESTART_POLICY" == "no" ]] ||
        die "Existing container must use Docker restart policy 'no'."

    [[ "$EXISTING_CONFIG_VOLUME" == "$RUNNER_VOLUME" ]] ||
        die "Existing container does not use the expected configuration volume."

    [[ "$HAS_DOCKER_SOCKET" == "/var/run/docker.sock" ]] ||
        die "Existing container does not have the expected Docker socket mount."

    log "Existing container configuration is valid."
else
    log "Creating GitLab Runner container..."

    docker create \
        --name "$RUNNER_CONTAINER" \
        --restart=no \
        --volume "$RUNNER_VOLUME:/etc/gitlab-runner" \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        "$RUNNER_IMAGE" >/dev/null

    log "Runner container created."
fi

# 5. Validate systemd unit file
UNIT_SOURCE="$PROJECT_DIR/systemd/$SERVICE_NAME"

[[ -f "$UNIT_SOURCE" ]] ||
    die "Systemd unit file not found: $UNIT_SOURCE"

# 6. Install or update systemd unit only when changed
UNIT_CHANGED=false

if [[ ! -f "$SERVICE_FILE" ]] || ! cmp -s "$UNIT_SOURCE" "$SERVICE_FILE"; then
    log "Installing updated systemd unit..."

    sudo install -m 644 "$UNIT_SOURCE" "$SERVICE_FILE"
    sudo systemctl daemon-reload

    UNIT_CHANGED=true
else
    log "Systemd unit is already up to date."
fi

# 7. Enable service at boot
sudo systemctl enable "$SERVICE_NAME"

# 8. Start or restart service when necessary
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    if [[ "$UNIT_CHANGED" == "true" ]]; then
        log "Unit file changed. Restarting GitLab Runner service..."
        sudo systemctl restart "$SERVICE_NAME"
    else
        log "GitLab Runner service is already running. No restart needed."
    fi
else
    if [[ "$(docker inspect -f '{{.State.Running}}' "$RUNNER_CONTAINER")" == "true" ]]; then
        log "Stopping manually running container..."
        docker stop --time 30 "$RUNNER_CONTAINER" >/dev/null
    fi

    log "Starting GitLab Runner through systemd..."
    sudo systemctl start "$SERVICE_NAME"
fi

# 9. Verify service status
if ! sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    sudo systemctl status "$SERVICE_NAME" --no-pager >&2 || true
    die "GitLab Runner systemd service failed to start."
fi

log "GitLab Runner installation completed successfully."