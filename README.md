# planthor_localdev

Local development environment for the **Planthor** platform, orchestrated with
[Docker Compose](https://docs.docker.com/compose/).

---

## Prerequisites

| Tool | Minimum version | Install guide |
|------|----------------|---------------|
| Docker Desktop (or Docker Engine + Compose plugin) | 24.x | https://docs.docker.com/get-docker/ |
| GNU Make | any | comes with most Unix systems; on Windows use WSL 2 or Git Bash |

---

## Quick start

```bash
# 1. Clone the repository
git clone https://github.com/Planthor/planthor_localdev.git
cd planthor_localdev

# 2. Create your local .env file (edit the values if needed)
make setup
# -- or manually: cp .env.example .env

# 3. Start all infrastructure services
make up
# -- or: docker compose up -d

# 4. Verify everything is running
make ps

# 5. Tail all service logs (Ctrl-C to stop)
make logs
```

That's it! The following services are now available on your machine:

| Service | URL / address | Credentials (default) |
|---------|---------------|-----------------------|
| PostgreSQL | `localhost:5432` | user `planthor`, password `changeme_local`, db `planthor_dev` |
| Redis | `localhost:6379` | no password by default |
| MailHog SMTP | `localhost:1025` | — |
| MailHog Web UI | http://localhost:8025 | — |

---

## Common tasks

```bash
make up            # Start all services in the background
make down          # Stop containers (volumes/data preserved)
make reset         # ⚠️  Stop containers AND delete volumes (wipes database)
make build         # Rebuild service images
make logs          # Tail logs for all services
make ps            # Show container status

make db-shell      # Open psql inside the postgres container
make db-reset      # Drop and recreate the database
make redis-cli     # Open redis-cli inside the redis container
make redis-flush   # Flush all Redis keys

make help          # List all available targets
```

---

## Project structure

```
planthor_localdev/
├── docker-compose.yml        # Core service definitions
├── .env.example              # Template — copy to .env and customise
├── Makefile                  # Developer shortcuts
├── scripts/
│   └── db/
│       └── init/             # SQL run on first postgres start
│           └── 001_init.sql
├── services/
│   ├── api/                  # Add your backend Dockerfile here
│   └── web/                  # Add your frontend Dockerfile here
└── .github/
    └── copilot-instructions.md   # Context for GitHub Copilot
```

---

## Adding a new application service

1. **Create a Dockerfile** inside `services/<service-name>/`:
   ```
   services/api/Dockerfile
   services/web/Dockerfile
   ```

2. **Uncomment (or add) the service block** in `docker-compose.yml`.
   The `api` and `web` service stubs are already included as commented
   examples at the bottom of the file.

3. **Add environment variables** to `.env.example` with sensible defaults.

4. **Rebuild and start**:
   ```bash
   make build
   make up
   ```

---

## Environment variables

All configurable values are documented in [`.env.example`](.env.example).
Copy it to `.env` before the first run:

```bash
cp .env.example .env
```

> **Never commit `.env`** — it is listed in `.gitignore`.

---

## GitHub Copilot

This repository includes a
[`.github/copilot-instructions.md`](.github/copilot-instructions.md) file that
gives Copilot context about the project structure and conventions, so it can
provide more accurate suggestions.

Useful Copilot prompts for this repo:

- *"Add a `worker` service to docker-compose.yml that depends on postgres and redis."*
- *"Generate a multi-stage Dockerfile for a Node.js 20 API in services/api/."*
- *"Write a SQL migration to create a `plants` table."*
- *"Add a `make migrate` target that runs migrations inside the api container."*

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Port already in use | Change the host port in `.env` (e.g. `POSTGRES_PORT=5433`) |
| Containers fail to start | Run `make logs` and check for error messages |
| Database data is stale | Run `make reset` to wipe volumes and start fresh |
| `make: command not found` | Use `docker compose` commands directly, or install Make |
