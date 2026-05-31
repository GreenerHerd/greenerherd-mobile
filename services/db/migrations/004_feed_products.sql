-- Global feed product catalogue (nutrition + eligibility rules)
CREATE TABLE IF NOT EXISTS feed_products (
  id UUID PRIMARY KEY,
  product_number INT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_ar TEXT,
  species_scope TEXT NOT NULL CHECK (
    species_scope IN ('ALL', 'CATTLE', 'GOAT', 'SHEEP', 'SMALL_RUMINANT')
  ),
  feed_type TEXT NOT NULL CHECK (feed_type IN ('FODDER', 'CONCENTRATE', 'ADDITIVE')),
  max_perc_feed NUMERIC(6, 2),
  max_perc_conc NUMERIC(6, 2),
  max_perc_weight NUMERIC(6, 2),
  max_feed_weight_kg NUMERIC(10, 2),
  production_focus TEXT CHECK (production_focus IS NULL OR production_focus IN ('DAIRY', 'MEAT')),
  sex_restriction TEXT CHECK (sex_restriction IS NULL OR sex_restriction IN ('MALE', 'FEMALE')),
  min_age_months INT,
  max_age_months INT,
  breeding_cycle TEXT,
  lactation_exclusion TEXT,
  lactation_inclusion TEXT,
  dietary_needs TEXT,
  dm_percent NUMERIC(6, 2),
  nem_mcal_kg NUMERIC(8, 4),
  neg_mcal_kg NUMERIC(8, 4),
  cp_percent NUMERIC(6, 2),
  crude_fat_percent NUMERIC(6, 2),
  ndf_percent NUMERIC(6, 2),
  adf_percent NUMERIC(6, 2),
  tdn_percent NUMERIC(6, 2),
  de_mcal_kg NUMERIC(8, 4),
  me_mcal_kg NUMERIC(8, 4),
  me_mj_kg_dm NUMERIC(8, 4),
  fiber_percent NUMERIC(6, 2),
  moisture_percent NUMERIC(6, 2),
  calcium_percent NUMERIC(8, 4),
  phosphorus_percent NUMERIC(8, 4),
  potassium_percent NUMERIC(8, 4),
  magnesium_percent NUMERIC(8, 4),
  sodium_percent NUMERIC(8, 4),
  zinc_mg_kg NUMERIC(10, 2),
  copper_mg_kg NUMERIC(10, 2),
  manganese_mg_kg NUMERIC(10, 2),
  iron_mg_kg NUMERIC(10, 2),
  selenium_mg_kg NUMERIC(10, 4),
  biotin TEXT,
  vitamin_a_iu_kg NUMERIC(12, 2),
  vitamin_b1_iu_kg NUMERIC(12, 2),
  vitamin_b2_iu_kg NUMERIC(12, 2),
  vitamin_b6_iu_kg NUMERIC(12, 2),
  vitamin_b12_iu_kg NUMERIC(12, 2),
  vitamin_d3_iu_kg NUMERIC(12, 2),
  vitamin_e_mg_kg NUMERIC(10, 2),
  source TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feed_products_species_type
  ON feed_products (species_scope, feed_type)
  WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_feed_products_product_number
  ON feed_products (product_number)
  WHERE is_active;
