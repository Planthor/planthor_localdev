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
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

# -----------------------------------------------------------------------------
# Validation / CI
# -----------------------------------------------------------------------------

.PHONY: validate
validate: ## Validate config files (docker-compose syntax, JSON, env-var coverage)
	@echo "▶ docker compose config …"
	@$(COMPOSE) config --quiet
	@echo "  ✅ docker-compose.yml is valid"
	@echo ""
	@echo "▶ keycloak/realm-export.json …"
	@python3 -c "import json,sys; json.load(open('keycloak/realm-export.json')); print('  ✅ keycloak/realm-export.json is valid JSON')"
	@echo ""
	@echo "▶ Checking all env vars in docker-compose.yml are documented in .env.example …"
	@python3 scripts/validate_env_vars.py

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
reset: ## ⚠️  Stop containers AND delete all volumes (wipes database + Keycloak data)
	$(COMPOSE) down -v

# -----------------------------------------------------------------------------
# Building / pulling
# -----------------------------------------------------------------------------

.PHONY: build
build: ## Build / rebuild all service images
	$(COMPOSE) build

.PHONY: pull
pull: ## Pull latest images from registries (including GHCR webapp image)
	$(COMPOSE) pull

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
	$(COMPOSE) exec postgres psql -U keycloak -d keycloak

.PHONY: db-reset
db-reset: ## Drop and recreate the Keycloak database (triggers re-import of realm)
	$(COMPOSE) exec postgres psql -U keycloak -d postgres \
		-c "DROP DATABASE IF EXISTS keycloak;" \
		-c "CREATE DATABASE keycloak;"
	@echo "✅  Keycloak database recreated. Restart keycloak to re-import the realm."

# -----------------------------------------------------------------------------
# Keycloak helpers
# -----------------------------------------------------------------------------

.PHONY: keycloak-logs
keycloak-logs: ## Tail Keycloak logs only
	$(COMPOSE) logs -f keycloak

.PHONY: keycloak-restart
keycloak-restart: ## Restart the Keycloak container
	$(COMPOSE) restart keycloak

.PHONY: keycloak-open
keycloak-open: ## Open Keycloak admin console in the default browser
	@KC_PORT=$${KEYCLOAK_PORT:-8080}; \
	echo "Opening http://localhost:$$KC_PORT ..."; \
	open "http://localhost:$$KC_PORT" 2>/dev/null || xdg-open "http://localhost:$$KC_PORT" 2>/dev/null || echo "Visit: http://localhost:$$KC_PORT"


