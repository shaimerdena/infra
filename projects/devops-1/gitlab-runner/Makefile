SHELL := /bin/bash

PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: help install register status logs verify cleanup

help:
	@echo "GitLab Runner management"
	@echo ""
	@echo "Available targets:"
	@echo "  make install                  Install GitLab Runner"
	@echo "  make register GROUP_URL=URL   Register runner for a GitLab group"
	@echo "  make status                   Show runner container status"
	@echo "  make logs                     Show recent runner logs"
	@echo "  make verify                   Verify local runner registration"
	@echo "  make cleanup                  Remove runner and related resources"
	@echo ""
	@echo "Registration requires GITLAB_API_TOKEN environment variable."

install:
	@bash "$(PROJECT_DIR)scripts/install_gitlab_runner.sh"

register:
	@test -n "$(GROUP_URL)" || { echo "Usage: make register GROUP_URL=https://gitlab.com/group" >&2; exit 1; }
	@bash "$(PROJECT_DIR)scripts/register_gitlab_runner.sh" "$(GROUP_URL)"

status:
	@docker inspect gitlab-runner >/dev/null 2>&1 || { echo "GitLab Runner container does not exist. Run make install first." >&2; exit 1; }
	@docker ps -a --filter "name=^/gitlab-runner$$" \
		--format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

logs:
	@docker inspect gitlab-runner >/dev/null 2>&1 || { echo "GitLab Runner container does not exist. Run make install first." >&2; exit 1; }
	@docker logs --tail 100 gitlab-runner

verify:
	@bash "$(PROJECT_DIR)scripts/verify_gitlab_runner.sh"

cleanup:
	@bash "$(PROJECT_DIR)scripts/cleanup.sh"