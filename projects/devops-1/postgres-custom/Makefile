
.PHONY: build create install start stop restart status logs test

IMAGE = postgres-custom:17
CONTAINER = postgres-db
VOLUME = postgres-data
SERVICE = postgresql

build:
	docker build -t $(IMAGE) .

create:
	@if docker container inspect $(CONTAINER) >/dev/null 2>&1; then \
		echo "Container $(CONTAINER) already exists; leaving it unchanged."; \
	else \
		test -f .env || (echo "Missing .env. Run: cp .env.example .env, then set a strong password."; exit 1); \
		docker volume create $(VOLUME); \
		docker create \
			--name $(CONTAINER) \
			--restart=no \
			--env-file .env \
			-p 127.0.0.1:5432:5432 \
			-v $(VOLUME):/var/lib/postgresql/data \
			$(IMAGE); \
	fi

install: build create
	sudo bash scripts/install.sh

start:
	sudo systemctl start $(SERVICE)

stop:
	sudo systemctl stop $(SERVICE)

restart:
	sudo systemctl restart $(SERVICE)

status:
	systemctl status $(SERVICE) --no-pager

logs:
	sudo tail -n 50 /var/log/postgresql/output.log /var/log/postgresql/error.log

test:
	sudo bash /opt/postgres-custom/scripts/health-check.sh