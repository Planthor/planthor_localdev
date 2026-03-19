# Web Service

Place your frontend web application Dockerfile and source code in this directory.

## Getting started

1. Add a `Dockerfile` here (multi-stage builds recommended).
2. Uncomment the `web` service block in the root `docker-compose.yml`.
3. Run `make build && make up` from the repository root.

## Example Dockerfile (Next.js)

```dockerfile
# --- dependencies stage ---
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# --- build stage ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# --- runtime stage ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
```
