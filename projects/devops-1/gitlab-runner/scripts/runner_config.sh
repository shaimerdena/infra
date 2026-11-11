# runner_config.sh
#!/usr/bin/env bash

# Project paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

# Docker configuration
RUNNER_CONTAINER="gitlab-runner"
RUNNER_IMAGE="gitlab/gitlab-runner:v18.10.1"
RUNNER_VOLUME="gitlab-runner-config"
DEFAULT_JOB_IMAGE="alpine:3.21"

# GitLab Runner configuration
RUNNER_TAG="local-docker"
RUNNER_DESCRIPTION="local-gitlab-runner"

# Local state
STATE_DIR="$PROJECT_DIR/.state"
STATE_FILE="$STATE_DIR/runner.json"

# Systemd
SERVICE_NAME="gitlab-runner.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

# Logging helpers
log() {
    echo "[INFO] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

die() {
    error "$*"
    exit 1
}

# Dependency check
require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "Required command not found: $1"
}

# Docker access check
require_docker() {
    require_command docker

    docker info >/dev/null 2>&1 ||
        die "Cannot access Docker. Check that Docker is running and your user has permission."
}