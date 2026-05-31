-- Reference / master data (shared across services)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS schema_migrations (
  name TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS breeds (
  id UUID PRIMARY KEY,
  species TEXT NOT NULL CHECK (species IN ('CATTLE', 'GOAT', 'SHEEP')),
  code TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_ar TEXT,
  name_ur TEXT,
  name_fr TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (species, code)
);

CREATE INDEX IF NOT EXISTS idx_breeds_species_active ON breeds (species) WHERE is_active;

CREATE TABLE IF NOT EXISTS countries (
  iso_code CHAR(2) PRIMARY KEY,
  name_en TEXT NOT NULL,
  name_ar TEXT
);

CREATE TABLE IF NOT EXISTS currencies (
  iso_code CHAR(3) PRIMARY KEY,
  name_en TEXT NOT NULL,
  symbol TEXT
);
