-- Core domain tables (single DB, service-owned tables)

CREATE TABLE IF NOT EXISTS farms (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  owner_user_id TEXT NOT NULL,
  country CHAR(2) NOT NULL,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION,
  preferred_currency CHAR(3) NOT NULL,
  housing_type TEXT NOT NULL CHECK (housing_type IN ('INDOOR_FANS', 'INDOOR_SHADE', 'PASTURE')),
  preferred_lang TEXT NOT NULL CHECK (preferred_lang IN ('EN', 'AR', 'UR', 'FR')),
  onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS farm_species (
  id UUID PRIMARY KEY,
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  species TEXT NOT NULL CHECK (species IN ('CATTLE', 'GOAT', 'SHEEP')),
  purpose TEXT NOT NULL CHECK (purpose IN ('MILK', 'MEAT', 'BOTH')),
  UNIQUE (farm_id, species)
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  preferred_lang TEXT NOT NULL DEFAULT 'EN' CHECK (preferred_lang IN ('EN', 'AR', 'UR', 'FR')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS farm_users (
  id UUID PRIMARY KEY,
  farm_id TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users (id),
  farm_role TEXT NOT NULL CHECK (farm_role IN ('OWNER', 'MANAGER', 'FARM_HAND', 'VET')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_active_at TIMESTAMPTZ,
  UNIQUE (farm_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_farm_users_farm ON farm_users (farm_id);

CREATE TABLE IF NOT EXISTS group_user_access (
  id UUID PRIMARY KEY,
  farm_id TEXT NOT NULL,
  group_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  can_manage BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (farm_id, group_id, user_id)
);

CREATE TABLE IF NOT EXISTS animal_groups (
  id UUID PRIMARY KEY,
  farm_id TEXT NOT NULL,
  species TEXT NOT NULL CHECK (species IN ('CATTLE', 'GOAT', 'SHEEP')),
  name TEXT NOT NULL,
  purpose TEXT NOT NULL CHECK (
    purpose IN ('MAINTENANCE', 'BREEDING', 'MILK', 'PREGNANT', 'SICK', 'FATTENING')
  ),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_animal_groups_farm ON animal_groups (farm_id);

CREATE TABLE IF NOT EXISTS animals (
  id UUID PRIMARY KEY,
  farm_id TEXT NOT NULL,
  group_id UUID REFERENCES animal_groups (id) ON DELETE SET NULL,
  species TEXT NOT NULL CHECK (species IN ('CATTLE', 'GOAT', 'SHEEP')),
  ear_tag TEXT,
  name TEXT,
  sex TEXT NOT NULL CHECK (sex IN ('MALE', 'FEMALE')),
  breed TEXT NOT NULL,
  breed_id UUID REFERENCES breeds (id),
  dob DATE,
  age_range TEXT CHECK (
    age_range IN ('0_3M', '3_6M', '6_12M', '1_2Y', '2_3Y', '3_5Y', '5PLUS_Y')
  ),
  current_weight_kg DOUBLE PRECISION,
  weight_indicative BOOLEAN NOT NULL DEFAULT FALSE,
  status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SOLD', 'DECEASED', 'CULLED')),
  cull_flagged BOOLEAN NOT NULL DEFAULT FALSE,
  origin TEXT NOT NULL DEFAULT 'BORN_ON_FARM' CHECK (origin IN ('BORN_ON_FARM', 'PURCHASED')),
  tags JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_animals_farm ON animals (farm_id);
CREATE INDEX IF NOT EXISTS idx_animals_farm_ear_tag ON animals (farm_id, ear_tag) WHERE ear_tag IS NOT NULL;
