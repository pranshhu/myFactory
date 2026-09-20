# Project code runs in Docker, never on the host. See the docker-dev skill for the rules.
# Compose names the project after this folder, so every worktree (.worktrees/CRM-14)
# gets its own containers, network and volumes.

# The project's definition of green: lint with complexity budgets, typecheck, tests.
CHECK ?= echo "Set CHECK in the Makefile (lint + typecheck + tests)" >&2; exit 1
# The port the app service listens on inside its container.
PORT ?= 3000

.PHONY: up down check shell logs url

up:
	docker compose up -d --build --wait

down:
	docker compose down -v --remove-orphans

check:
	docker compose run --rm app sh -c '$(CHECK)'

shell:
	docker compose run --rm app sh

logs:
	docker compose logs -f --tail=100

url:
	@echo "http://localhost:$$(docker compose port app $(PORT) | sed 's/.*://')"
