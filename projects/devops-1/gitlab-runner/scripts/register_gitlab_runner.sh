# register_gitlab_runner.sh
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/runner_config.sh"

# 1. Validate arguments and credentials
if [[ $# -ne 1 ]]; then
    die "Usage: $0 <GITLAB_GROUP_URL>"
fi

GROUP_URL="$1"

[[ -n "${GITLAB_API_TOKEN:-}" ]] ||
    die "GITLAB_API_TOKEN environment variable is required."

require_command curl
require_command jq
require_command python3
require_command sed
require_docker

docker container inspect "$RUNNER_CONTAINER" >/dev/null 2>&1 ||
    die "Runner container does not exist. Run make install first."

[[ "$(docker inspect -f '{{.State.Running}}' "$RUNNER_CONTAINER")" == "true" ]] ||
    die "Runner container is not running."

# 2. Prepare secure local state directory
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

# 3. Parse GitLab group URL
PARSED_URL="$(python3 - "$GROUP_URL" <<'PY'
import sys
from urllib.parse import urlsplit, unquote

url = urlsplit(sys.argv[1])

if url.scheme not in ("http", "https") or not url.netloc:
    raise SystemExit("Invalid GitLab group URL")

if url.query or url.fragment:
    raise SystemExit("Group URL must not contain query parameters or fragments")

group_path = unquote(url.path).strip("/")

if not group_path:
    raise SystemExit("Group path is missing from URL")

print(f"{url.scheme}://{url.netloc}")
print(group_path)
PY
)" || die "Could not parse GitLab group URL."

GITLAB_URL="$(printf '%s\n' "$PARSED_URL" | sed -n '1p')"
GROUP_PATH="$(printf '%s\n' "$PARSED_URL" | sed -n '2p')"

API_URL="$GITLAB_URL/api/v4"
ENCODED_GROUP_PATH="$(jq -rn --arg path "$GROUP_PATH" '$path | @uri')"

# 4. Resolve GitLab group
log "Resolving GitLab group..."

GROUP_RESPONSE="$(
    curl --silent --show-error --fail \
        --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
        "$API_URL/groups/$ENCODED_GROUP_PATH"
)" || die "Could not resolve GitLab group. Check URL and API permissions."

GROUP_ID="$(jq -r '.id // empty' <<< "$GROUP_RESPONSE")"

[[ -n "$GROUP_ID" ]] ||
    die "GitLab API did not return a group ID."

log "GitLab group resolved. Group ID: $GROUP_ID"

# 5. Handle an existing local state
if [[ -f "$STATE_FILE" ]]; then
    log "Existing runner state found."

    jq empty "$STATE_FILE" 2>/dev/null ||
        die "Runner state file contains invalid JSON."

    SAVED_RUNNER_ID="$(jq -r '.runner_id // empty' "$STATE_FILE")"
    SAVED_RUNNER_TOKEN="$(jq -r '.runner_token // empty' "$STATE_FILE")"
    SAVED_GITLAB_URL="$(jq -r '.gitlab_url // empty' "$STATE_FILE")"
    SAVED_GROUP_ID="$(jq -r '.group_id // empty' "$STATE_FILE")"

    [[ -n "$SAVED_RUNNER_ID" &&
       -n "$SAVED_RUNNER_TOKEN" &&
       -n "$SAVED_GITLAB_URL" &&
       -n "$SAVED_GROUP_ID" ]] ||
        die "Runner state file is incomplete."

    [[ "$SAVED_GITLAB_URL" == "$GITLAB_URL" ]] ||
        die "Saved runner belongs to another GitLab instance."

    [[ "$SAVED_GROUP_ID" == "$GROUP_ID" ]] ||
        die "Saved runner belongs to another GitLab group."

    if docker exec "$RUNNER_CONTAINER" \
        test -s /etc/gitlab-runner/config.toml; then

        log "Local runner configuration exists."

        docker exec "$RUNNER_CONTAINER" gitlab-runner verify ||
            die "Local runner verification failed. No new registration was created."

        log "Runner is already registered. Reusing ID: $SAVED_RUNNER_ID"
        exit 0
    fi

    log "Local configuration is missing. Restoring existing registration..."

    docker exec "$RUNNER_CONTAINER" gitlab-runner register \
        --non-interactive \
        --url "$GITLAB_URL" \
        --token "$SAVED_RUNNER_TOKEN" \
        --executor docker \
        --docker-image "$DEFAULT_JOB_IMAGE" ||
        die "Could not restore local runner registration."

    log "Existing runner registration restored."
    exit 0
fi

# 6. Refuse to create a duplicate if local config exists without state
if docker exec "$RUNNER_CONTAINER" \
    test -s /etc/gitlab-runner/config.toml; then

    die "Local runner configuration exists, but state file is missing. Refusing to create a duplicate."
fi

# 7. Check all pages of existing group runners
log "Checking existing group runners..."

PAGE=1
PER_PAGE=100

while true; do
    EXISTING_RUNNERS="$(
        curl --silent --show-error --fail \
            --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
            "$API_URL/groups/$GROUP_ID/runners?per_page=$PER_PAGE&page=$PAGE"
    )" || die "Could not check existing group runners."

    if jq -e --arg description "$RUNNER_DESCRIPTION" \
        'any(.[]; .description == $description)' \
        <<< "$EXISTING_RUNNERS" >/dev/null; then

        die "A runner with this description already exists in the group, but local state is missing. Refusing to create a duplicate."
    fi

    PAGE_SIZE="$(jq 'length' <<< "$EXISTING_RUNNERS")"

    if (( PAGE_SIZE < PER_PAGE )); then
        break
    fi

    PAGE=$((PAGE + 1))
done

# 8. Create group runner through GitLab API
log "Creating group runner through GitLab API..."

CREATE_RESPONSE="$(
    curl --silent --show-error --fail \
        --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
        --data-urlencode "runner_type=group_type" \
        --data-urlencode "group_id=$GROUP_ID" \
        --data-urlencode "description=$RUNNER_DESCRIPTION" \
        --data-urlencode "tag_list=$RUNNER_TAG" \
        --data-urlencode "run_untagged=false" \
        --data-urlencode "locked=true" \
        "$API_URL/user/runners"
)" || die "Could not create group runner. Check API token permissions."

RUNNER_ID="$(jq -r '.id // empty' <<< "$CREATE_RESPONSE")"
RUNNER_TOKEN="$(jq -r '.token // empty' <<< "$CREATE_RESPONSE")"

[[ -n "$RUNNER_ID" && -n "$RUNNER_TOKEN" ]] ||
    die "GitLab API response does not contain runner ID or authentication token."

# 9. Save runner state before local registration
TEMP_STATE="$(mktemp "$STATE_DIR/runner.XXXXXX")"

jq -n \
    --arg runner_id "$RUNNER_ID" \
    --arg runner_token "$RUNNER_TOKEN" \
    --arg gitlab_url "$GITLAB_URL" \
    --arg group_id "$GROUP_ID" \
    --arg description "$RUNNER_DESCRIPTION" \
    --arg tag "$RUNNER_TAG" \
    '{
        runner_id: $runner_id,
        runner_token: $runner_token,
        gitlab_url: $gitlab_url,
        group_id: $group_id,
        description: $description,
        tag: $tag
    }' > "$TEMP_STATE"

chmod 600 "$TEMP_STATE"
mv "$TEMP_STATE" "$STATE_FILE"

log "Runner created. ID: $RUNNER_ID"

# 10. Register local runner manager
log "Registering local runner..."

docker exec "$RUNNER_CONTAINER" gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --token "$RUNNER_TOKEN" \
    --executor docker \
    --docker-image "$DEFAULT_JOB_IMAGE" ||
    die "GitLab runner was created, but local registration failed. Run the registration script again to restore it."

log "Runner registration completed successfully."