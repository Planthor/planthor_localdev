# Planthor — GitHub Copilot Instructions

This file provides context for **GitHub Copilot** (and the Copilot coding agent)
when working in this repository. Keep it up to date as the project evolves.

---

## Project overview

**Planthor** is a platform for plant care management and community.
This repository (`planthor_localdev`) contains the **local development environment**
that orchestrates all Planthor services on a developer's machine using Docker Compose.

---

## Repository layout

```
planthor_localdev/
├── docker-compose.yml          # Defines all local dev services
├── .env.example                # Template for required environment variables
├── Makefile                    # Developer convenience commands
├── keycloak/
│   └── realm-export.json       # Keycloak realm auto-imported on first start
├── scripts/
│   └── db/init/                # SQL scripts executed on first DB startup
├── services/
│   ├── api/                    # Placeholder for a future backend API service
│   └── web/                    # Placeholder for local frontend builds
└── .github/
    └── copilot-instructions.md # ← you are here
```

---

## Local development stack

| Service    | Technology                        | Local port | Purpose                              |
|------------|-----------------------------------|------------|--------------------------------------|
| `postgres` | PostgreSQL 16                     | 5432       | Database for Keycloak                |
| `keycloak` | Keycloak 26                       | 8080       | Identity & access management (OIDC)  |
| `webapp`   | PlanthorWebApp (GHCR image)       | 3000       | SvelteKit frontend                   |

The webapp image is `ghcr.io/planthor/planthorwebapp` and is configured via
`WEBAPP_IMAGE` in `.env`. Update that variable when the image name or tag changes.

---

## Quick start (for new developers)

```bash
# 1. Clone the repo
git clone https://github.com/Planthor/planthor_localdev.git
cd planthor_localdev

# 2. Copy the environment template and fill in any secrets
cp .env.example .env

# 3. Start all services
make up

# 4. Check that everything is healthy
make ps

# 5. Tail the logs
make logs
```

---

## Keycloak

- Admin console: http://localhost:8080 (admin/admin by default)
- Realm `planthor` is auto-imported from `keycloak/realm-export.json`
- Client `planthor` with PKCE + secret `Planthor@123` is pre-configured
- Test user: `testuser@planthor.local` / `Test@1234`

---

## Coding conventions

- **Environment variables**: All configurable values MUST have a matching entry in
  `.env.example`. Never hard-code secrets in source files or `docker-compose.yml`.
- **WEBAPP_IMAGE**: Must be updated in `.env.example` whenever the PlanthorWebApp
  image name or tag changes in the `Planthor/PlanthorWebApp` repository.
- **Keycloak realm**: Changes to realm configuration should be exported and
  committed to `keycloak/realm-export.json` so the whole team gets the update.
- **Secrets**: Never commit `.env`. The `.gitignore` already excludes it.

---

## Adding a new service

1. Add a service block in `docker-compose.yml`.
2. Add any new environment variables to `.env.example` with sensible defaults.
3. If building locally, create `services/<service-name>/Dockerfile`.
4. Document the service in the table above.

---

## Makefile targets

| Target                | Description                                         |
|-----------------------|-----------------------------------------------------|
| `make validate`       | Validate config files (run in CI)                   |
| `make setup`          | Copy `.env.example` → `.env` (first-time only)      |
| `make up`             | Start all services in the background                |
| `make down`           | Stop containers (data preserved)                    |
| `make reset`          | Stop containers **and delete volumes** (full wipe)  |
| `make pull`           | Pull latest images (including GHCR webapp image)    |
| `make logs`           | Tail logs for all running services                  |
| `make ps`             | Show container status                               |
| `make keycloak-logs`  | Tail Keycloak logs only                             |
| `make keycloak-restart` | Restart Keycloak container                        |
| `make db-shell`       | Open a `psql` shell in the postgres container       |
| `make db-reset`       | Drop and recreate the Keycloak database             |

---

## Useful Copilot prompts

- *"Add a `worker` service to docker-compose.yml that depends on keycloak and postgres."*
- *"Update realm-export.json to add a new role called `plant-admin`."*
- *"Add a `make keycloak-export` target that exports the realm config using the Keycloak CLI."*
- *"Add a Redis service to docker-compose.yml for session caching."*
- *"Update WEBAPP_IMAGE in .env.example to use the new image tag `v1.2.0`."*

