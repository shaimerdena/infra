# GitLab Runner Setup

Automated deployment, registration, verification and cleanup
of a self-hosted GitLab Runner using Docker and systemd.

## Requirements

- Linux host with systemd
- Docker Engine
- GitLab group
- GitLab API token
- curl
- jq
- Python 3
- sudo privileges

## Project structure

- `scripts/runner_config.sh` — shared configuration
- `scripts/install_gitlab_runner.sh` — installation
- `scripts/register_gitlab_runner.sh` — GitLab API registration
- `scripts/verify_gitlab_runner.sh` — registration verification
- `scripts/cleanup.sh` — resource cleanup
- `systemd/gitlab-runner.service` — systemd unit
- `.gitlab-ci.yml` — test pipeline
- `Makefile` — management commands

## Installation

Clone the repository:

```bash
git clone <repository-url>
cd gitlab-runner
```

Install Docker and required dependencies before continuing.

Run:
```bash
make install
```

## Registration
Create a GitLab API token with the permissions required
to create and manage group runners.

Export the token:
```bash
export GITLAB_API_TOKEN="your-api-token"
```

Register the runner:
```bash
make register GROUP_URL=https://gitlab.com/your-group
```

The API token is used only by the host-side registration
and cleanup scripts. It is not passed to CI jobs.

## Verification
Check the runner:
```bash
make verify
```

Check the container:
```bash
make status
```

View recent logs:
```bash
make logs
```

## CI Pipeline
The pipeline uses the local-docker tag.

It executes:
```bash
echo "[${CI_RUNNER_ID}] hello, devops."
```

Compare the ID in the job log with the runner_id
stored in .state/runner.json.

## Cleanup
Export the API token if it is not already available:

```bash
export GITLAB_API_TOKEN="your-api-token"
```

Run:
```bash
make cleanup
```

The cleanup script removes only resources created
for this GitLab Runner setup.


---

## How to run the project

The following steps will guide you through the process of setting up and running the GitLab Runner project. Make sure you have all the requirements installed and configured before proceeding:

1. Install GitLab Runner
```bash
make install
```
2. Provide GitLab API credential
```bash
export GITLAB_API_TOKEN="your-api-token"
```
3. Register runner for your group
```bash
make register GROUP_URL=https://gitlab.com/your-group
```
4. Verify local registration
```bash
make verify
```
5. Check container
```bash
make status
```
6. View logs
```bash
make logs
```
7. Cleanup resources
```bash
make cleanup
```