# =============================================================================
# Planthor Local Dev — Makefile
# =============================================================================
# Convenience wrapper around common docker compose commands.
# Run `make help` to see available targets.
# =============================================================================

.DEFAULT_GOAL := help

COMPOSE := docker compose

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# -----------------------------------------------------------------------------
# Lifecycle
# -----------------------------------------------------------------------------

.PHONY: setup
setup: ## First-time setup: copy .env.example → .env
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅  .env created from .env.example. Edit it before starting services."; \
	else \
		echo "ℹ️   .env already exists — skipping copy."; \
	fi

.PHONY: up
up: ## Start all services in the background
	$(COMPOSE) up -d

.PHONY: down
down: ## Stop and remove containers (data volumes preserved)
	$(COMPOSE) down

.PHONY: restart
restart: ## Restart all services
	$(COMPOSE) restart

.PHONY: reset
reset: ## ⚠️  Stop containers AND delete all volumes (wipes database)
	$(COMPOSE) down -v

# -----------------------------------------------------------------------------
# Building
# -----------------------------------------------------------------------------

.PHONY: build
build: ## Build (or rebuild) all service images
	$(COMPOSE) build

.PHONY: build-no-cache
build-no-cache: ## Rebuild all service images without Docker layer cache
	$(COMPOSE) build --no-cache

# -----------------------------------------------------------------------------
# Observability
# -----------------------------------------------------------------------------

.PHONY: logs
logs: ## Tail logs for all services (Ctrl-C to stop)
	$(COMPOSE) logs -f

.PHONY: ps
ps: ## Show status of running containers
	$(COMPOSE) ps

# -----------------------------------------------------------------------------
# Database helpers
# -----------------------------------------------------------------------------

.PHONY: db-shell
db-shell: ## Open a psql shell inside the postgres container
	$(COMPOSE) exec postgres psql -U planthor -d planthor_dev

.PHONY: db-reset
db-reset: ## Drop and recreate the database (applies init scripts on next up)
	$(COMPOSE) exec postgres psql -U planthor -d postgres \
		-c "DROP DATABASE IF EXISTS planthor_dev;" \
		-c "CREATE DATABASE planthor_dev;"
	@echo "✅  Database recreated. Re-run migrations if needed."

# -----------------------------------------------------------------------------
# Redis helpers
# -----------------------------------------------------------------------------

.PHONY: redis-cli
redis-cli: ## Open a redis-cli shell inside the redis container
	$(COMPOSE) exec redis redis-cli

.PHONY: redis-flush
redis-flush: ## Flush all Redis keys (use with caution)
	$(COMPOSE) exec redis redis-cli FLUSHALL
