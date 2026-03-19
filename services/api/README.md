# API Service

Place your backend API Dockerfile and source code in this directory.

## Getting started

1. Add a `Dockerfile` here (multi-stage builds recommended).
2. Uncomment the `api` service block in the root `docker-compose.yml`.
3. Run `make build && make up` from the repository root.

## Example Dockerfile (Node.js)

```dockerfile
# --- build stage ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
RUN npm run build

# --- runtime stage ---
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 8000
CMD ["node", "dist/index.js"]
```
