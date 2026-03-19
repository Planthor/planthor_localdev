-- =============================================================================
-- Planthor — Database initialisation script
-- =============================================================================
-- This script runs automatically when the PostgreSQL container starts for the
-- first time (via /docker-entrypoint-initdb.d).
-- Add any DDL or seed data here that should be present in every fresh
-- local development database.
-- =============================================================================

-- Example: enable useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Add your table definitions or seed data below this line.
