# Planthor — GitHub Copilot Instructions

This file provides context for **GitHub Copilot** (and the Copilot coding agent)
when working in this repository. Keep it up to date as the project evolves.

---

## Project overview

**Planthor** is a platform for [describe your product here — e.g. "plant care management and community"].
This repository (`planthor_localdev`) contains the **local development environment** configuration
that orchestrates all Planthor services on a developer's machine using Docker Compose.

---

## Repository layout

```
planthor_localdev/
├── docker-compose.yml        # Defines all local dev services
├── .env.example              # Template for required environment variables
├── Makefile                  # Developer convenience commands
├── scripts/
│   └── db/
│       └── init/             # SQL scripts executed on first DB startup
│           └── 001_init.sql
├── services/
│   ├── api/                  # Backend API service (add Dockerfile here)
│   └── web/                  # Frontend web service (add Dockerfile here)
└── .github/
    └── copilot-instructions.md   # ← you are here
```

---

## Local development stack

| Service    | Technology          | Local port | Purpose                          |
|------------|---------------------|------------|----------------------------------|
| `postgres` | PostgreSQL 16       | 5432       | Primary relational database      |
| `redis`    | Redis 7             | 6379       | Cache, sessions, and queues      |
| `mailhog`  | MailHog             | 1025/8025  | SMTP capture + web UI for emails |
| `api`      | *your framework*    | 8000       | Backend REST / GraphQL API       |
| `web`      | *your framework*    | 3000       | Frontend web application         |

---

## Quick start (for new developers)

```bash
# 1. Clone the repo
git clone https://github.com/Planthor/planthor_localdev.git
cd planthor_localdev

# 2. Copy the environment template and fill in any secrets
cp .env.example .env

# 3. Start all infrastructure services
make up          # or: docker compose up -d

# 4. Check that everything is healthy
make ps          # or: docker compose ps

# 5. Tail the logs
make logs        # or: docker compose logs -f
```

---

## Coding conventions

- **Environment variables**: All configurable values MUST have a matching entry in
  `.env.example`. Never hard-code secrets in source files or `docker-compose.yml`.
- **Dockerfile**: Each service lives in `services/<name>/` and has its own
  `Dockerfile`. Multi-stage builds are preferred to keep image sizes small.
- **SQL migrations**: Place numbered SQL files in `scripts/db/init/` for
  bootstrap DDL. Use a proper migration tool (e.g. Flyway, Alembic, golang-migrate)
  for incremental schema changes.
- **Secrets**: Never commit `.env`. The `.gitignore` already excludes it.

---

## Adding a new service

1. Create `services/<service-name>/Dockerfile`.
2. Add a service block in `docker-compose.yml` (see the commented `api` / `web`
   examples as a starting point).
3. Add any new environment variables to `.env.example` with sensible defaults.
4. Document the service in the table above.

---

## Makefile targets

| Target           | Description                                       |
|------------------|---------------------------------------------------|
| `make setup`     | Copy `.env.example` → `.env` (first-time only)    |
| `make up`        | Start all services in the background              |
| `make down`      | Stop containers (data preserved)                  |
| `make reset`     | Stop containers **and delete volumes** (wipes DB) |
| `make build`     | Build / rebuild service images                    |
| `make logs`      | Tail logs for all running services                |
| `make ps`        | Show container status                             |
| `make db-shell`  | Open a `psql` shell in the postgres container     |
| `make redis-cli` | Open a `redis-cli` shell in the redis container   |

---

## Useful Copilot prompts

When asking Copilot for help in this repo, the following prompts tend to give
good results:

- *"Add a new service called `worker` to docker-compose.yml that consumes Redis
  queues and depends on postgres."*
- *"Generate a multi-stage Dockerfile for a Node.js 20 API inside
  `services/api/`."*
- *"Write an SQL migration in `scripts/db/init/` to create a `plants` table
  with uuid primary key, name, species, and created_at."*
- *"Add a `make migrate` target to Makefile that runs database migrations inside
  the api container."*
