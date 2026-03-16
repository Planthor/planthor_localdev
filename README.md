# planthor_localdev

Local development environment for the **Planthor** platform, orchestrated with
[Docker Compose](https://docs.docker.com/compose/).

---

## What runs locally

| Service | URL | Purpose |
|---------|-----|---------|
| **Keycloak** | http://localhost:8080 | Identity & access management (auth provider) |
| **PlanthorWebApp** | http://localhost:3000 | SvelteKit frontend (pulled from GHCR) |
| **PostgreSQL** | `localhost:5432` | Database for Keycloak |

---

## Prerequisites

| Tool | Minimum version | Notes |
|------|----------------|-------|
| Docker Desktop (or Docker Engine + Compose plugin) | 24.x | https://docs.docker.com/get-docker/ |
| GNU Make | any | Optional — all targets have `docker compose` equivalents |

If the `ghcr.io/planthor/planthorwebapp` image is **private**, authenticate first:

```bash
docker login ghcr.io -u <your-github-username> -p <your-personal-access-token>
```

---

## Quick start

```bash
# 1. Clone the repository
git clone https://github.com/Planthor/planthor_localdev.git
cd planthor_localdev

# 2. Create your local .env file
make setup
# -- or manually: cp .env.example .env

# 3. Start all services
make up

# 4. Check everything is healthy
make ps

# 5. Tail logs (Ctrl-C to stop)
make logs
```

Services start in order: **postgres → keycloak → webapp**.
Keycloak takes ~60 s on first boot to initialise; the webapp waits for it.

---

## Keycloak

### Admin console

Open http://localhost:8080 in your browser.

Default credentials (set in `.env`):

| Field | Default value |
|-------|---------------|
| Username | `admin` |
| Password | `admin` |

### Pre-configured realm

A `planthor` realm is automatically imported from
[`keycloak/realm-export.json`](keycloak/realm-export.json) on the **first** startup.
It includes:

- **Client** `planthor` (PKCE enabled, secret `Planthor@123` — **local dev only, never use in production**)
- **Test user** `testuser@planthor.local` / `Test@1234` — **local dev only**

To re-import (e.g. after changing the JSON):

```bash
make reset   # wipes postgres volume — realm reimported on next `make up`
make up
```

### OIDC endpoints (for reference)

```
Authorization:  http://localhost:8080/realms/planthor/protocol/openid-connect/auth
Token:          http://localhost:8080/realms/planthor/protocol/openid-connect/token
JWKS:           http://localhost:8080/realms/planthor/protocol/openid-connect/certs
Discovery:      http://localhost:8080/realms/planthor/.well-known/openid-configuration
```

---

## PlanthorWebApp image

The webapp image is defined in `.env`:

```dotenv
WEBAPP_IMAGE=ghcr.io/planthor/planthorwebapp:main
```

**When the image name or tag changes** in the `PlanthorWebApp` repository,
update `WEBAPP_IMAGE` in your `.env` (and in `.env.example` for the team) and run:

```bash
make pull   # pull the updated image
make up     # restart the webapp container
```

> ⚠️ **Auth server URL note**: The compiled SvelteKit image uses
> `$env/static/private` values baked in **at build time**. The `PlanthorWebApp`
> source currently hardcodes `https://localhost:5001` (an earlier Identity Server)
> as the auth endpoint. This is a **known issue** — the app source needs to be
> updated to use the Keycloak OIDC endpoints listed above, and a new image built
> and published to GHCR before auth flows will work end-to-end with this setup.

---

## Common commands

```bash
make up                 # Start all services
make down               # Stop containers (data preserved)
make reset              # Wipe all volumes (fresh Keycloak DB)
make pull               # Pull latest images from registries
make logs               # Tail all service logs
make ps                 # Show container status

make keycloak-logs      # Tail Keycloak logs only
make keycloak-restart   # Restart Keycloak
make keycloak-open      # Open admin console in browser

make db-shell           # psql into the postgres container
make db-reset           # Drop+recreate Keycloak database

make help               # List all targets
```

---

## Project structure

```
planthor_localdev/
├── docker-compose.yml          # Service definitions
├── .env.example                # Template — copy to .env and customise
├── Makefile                    # Developer shortcuts
├── keycloak/
│   └── realm-export.json       # Planthor realm auto-imported on first Keycloak start
├── scripts/
│   └── db/init/                # SQL run on first postgres start (currently empty)
├── services/
│   ├── api/                    # Placeholder for a future backend service
│   └── web/                    # Placeholder for local frontend builds
└── .github/
    └── copilot-instructions.md # Context for GitHub Copilot
```

---

## Environment variables

All configurable values are documented in [`.env.example`](.env.example).

| Variable | Default | Description |
|----------|---------|-------------|
| `WEBAPP_IMAGE` | `ghcr.io/planthor/planthorwebapp:main` | **Update when image name/tag changes** |
| `KEYCLOAK_VERSION` | `26.0` | Keycloak image version |
| `KEYCLOAK_ADMIN` | `admin` | Keycloak admin username |
| `KEYCLOAK_ADMIN_PASSWORD` | `admin` | Keycloak admin password |
| `BASE_URL` | `http://localhost:3000` | Public URL of the webapp (used for auth callbacks) |
| `POSTGRES_PASSWORD` | `keycloak_local` | Postgres password (Keycloak DB) |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `webapp` exits with connection error | Keycloak is still starting — wait ~60 s, or `make restart` |
| Keycloak realm not imported | Run `make reset && make up` to wipe and reimport |
| Port already in use | Change the conflicting port in `.env` (e.g. `KEYCLOAK_PORT=8181`) |
| `docker login` required | `docker login ghcr.io -u <user> -p <PAT>` |
| Auth redirects to wrong host | The image has auth URLs baked in at build time — see the note in the PlanthorWebApp section above |

---

## GitHub Copilot

This repository includes
[`.github/copilot-instructions.md`](.github/copilot-instructions.md)
with project context so Copilot gives better suggestions. See that file for
useful prompts.
