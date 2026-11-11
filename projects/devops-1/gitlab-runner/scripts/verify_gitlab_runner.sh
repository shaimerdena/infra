# verify_gitlab_runner.sh
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/runner_config.sh"

log "Verifying GitLab Runner..."

# 1. Check required dependencies
require_command jq
require_docker

# 2. Check saved runner state
[[ -f "$STATE_FILE" ]] ||
    die "Runner state file not found. Run registration first."

jq empty "$STATE_FILE" 2>/dev/null ||
    die "Runner state file contains invalid JSON."

RUNNER_ID="$(jq -r '.runner_id // empty' "$STATE_FILE")"
GITLAB_URL="$(jq -r '.gitlab_url // empty' "$STATE_FILE")"
GROUP_ID="$(jq -r '.group_id // empty' "$STATE_FILE")"
RUNNER_TAG="$(jq -r '.tag // empty' "$STATE_FILE")"

[[ -n "$RUNNER_ID" ]] || die "Runner ID is missing from state."
[[ -n "$GITLAB_URL" ]] || die "GitLab URL is missing from state."
[[ -n "$GROUP_ID" ]] || die "Group ID is missing from state."
[[ -n "$RUNNER_TAG" ]] || die "Runner tag is missing from state."

# 3. Check runner container
docker container inspect "$RUNNER_CONTAINER" >/dev/null 2>&1 ||
    die "Runner container does not exist. Run make install first."

CONTAINER_STATUS="$(
    docker inspect --format '{{.State.Status}}' "$RUNNER_CONTAINER"
)"

[[ "$CONTAINER_STATUS" == "running" ]] ||
    die "Runner container is not running. Current status: $CONTAINER_STATUS"

# 4. Check local runner configuration
docker exec "$RUNNER_CONTAINER" \
    test -s /etc/gitlab-runner/config.toml ||
    die "Runner config.toml is missing or empty."

# 5. Verify connection to GitLab
log "Checking runner connection to GitLab..."

docker exec "$RUNNER_CONTAINER" gitlab-runner verify ||
    die "GitLab Runner verification failed."

# 6. Display verification result
log "GitLab Runner verification completed successfully."

echo "Runner ID: $RUNNER_ID"
echo "GitLab URL: $GITLAB_URL"
echo "Group ID: $GROUP_ID"
echo "Runner tag: $RUNNER_TAG"
echo "Container: $RUNNER_CONTAINER"
echo "Container status: $CONTAINER_STATUS"