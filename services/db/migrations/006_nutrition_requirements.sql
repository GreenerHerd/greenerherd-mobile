-- Nutrition requirement profiles (per animal per day) for optimizer pass 2
CREATE TABLE IF NOT EXISTS nutrition_requirement_profiles (
  id UUID PRIMARY KEY,
  profile_code TEXT NOT NULL UNIQUE,
  species TEXT NOT NULL CHECK (species IN ('CATTLE', 'GOAT', 'SHEEP')),
  production_system TEXT NOT NULL CHECK (
    production_system IN ('DAIRY', 'BEEF', 'SMALL_RUMINANT')
  ),
  life_stage TEXT NOT NULL,
  animal_class TEXT,
  body_weight_kg NUMERIC(8, 2),
  months_since_calving INT,
  dmi_kg_day NUMERIC(8, 4) NOT NULL,
  cp_percent_dm NUMERIC(6, 2),
  nel_mcal_per_kg_dm NUMERIC(6, 3),
  ndf_percent_dm NUMERIC(6, 2),
  adf_percent_dm NUMERIC(6, 2),
  ca_percent_dm NUMERIC(8, 4),
  p_percent_dm NUMERIC(8, 4),
  milk_kg_day NUMERIC(6, 2),
  tdn_kg_day NUMERIC(8, 4),
  nem_mcal_day NUMERIC(8, 4),
  neg_mcal_day NUMERIC(8, 4),
  cp_kg_day NUMERIC(8, 4),
  ca_kg_day NUMERIC(8, 6),
  p_kg_day NUMERIC(8, 6),
  fodder_percent NUMERIC(5, 2),
  concentrate_percent NUMERIC(5, 2),
  source_sheet TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_nutrition_req_species_system
  ON nutrition_requirement_profiles (species, production_system)
  WHERE is_active = TRUE;
