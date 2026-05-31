-- Extended breed reference data from Breed Information.xlsx

ALTER TABLE breeds
  ADD COLUMN IF NOT EXISTS origin TEXT,
  ADD COLUMN IF NOT EXISTS primary_purpose TEXT,
  ADD COLUMN IF NOT EXISTS color TEXT,
  ADD COLUMN IF NOT EXISTS milk_production_kg_year TEXT,
  ADD COLUMN IF NOT EXISTS heat_tolerance TEXT,
  ADD COLUMN IF NOT EXISTS disease_resistance TEXT,
  ADD COLUMN IF NOT EXISTS birth_ease TEXT,
  ADD COLUMN IF NOT EXISTS feed_efficiency TEXT,
  ADD COLUMN IF NOT EXISTS temperament TEXT,
  ADD COLUMN IF NOT EXISTS adult_male_weight_kg TEXT,
  ADD COLUMN IF NOT EXISTS adult_female_weight_kg TEXT,
  ADD COLUMN IF NOT EXISTS adaptability TEXT,
  ADD COLUMN IF NOT EXISTS longevity_years TEXT,
  ADD COLUMN IF NOT EXISTS height_male_cm TEXT,
  ADD COLUMN IF NOT EXISTS height_female_cm TEXT,
  ADD COLUMN IF NOT EXISTS known_for TEXT;

CREATE TABLE IF NOT EXISTS breed_weight_by_age (
  breed_id UUID NOT NULL REFERENCES breeds (id) ON DELETE CASCADE,
  sex TEXT NOT NULL CHECK (sex IN ('MALE', 'FEMALE')),
  age_months INT NOT NULL CHECK (age_months IN (1, 4, 9, 15, 21, 24)),
  weight_kg NUMERIC(8, 2) NOT NULL,
  PRIMARY KEY (breed_id, sex, age_months)
);

CREATE INDEX IF NOT EXISTS idx_breed_weight_breed ON breed_weight_by_age (breed_id);
