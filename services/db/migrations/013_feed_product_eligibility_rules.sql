-- Split eligibility constraints out of feed_products (one product, many rules)

CREATE TABLE IF NOT EXISTS feed_product_eligibility_rules (
  id UUID PRIMARY KEY,
  rule_number INT NOT NULL UNIQUE,
  product_id UUID NOT NULL REFERENCES feed_products (id) ON DELETE CASCADE,
  species_scope TEXT NOT NULL CHECK (
    species_scope IN ('ALL', 'CATTLE', 'GOAT', 'SHEEP', 'SMALL_RUMINANT')
  ),
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
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feed_eligibility_rules_product
  ON feed_product_eligibility_rules (product_id)
  WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_feed_eligibility_rules_species
  ON feed_product_eligibility_rules (species_scope, product_id)
  WHERE is_active;

COMMENT ON TABLE feed_product_eligibility_rules IS
  'Eligibility / inclusion limits per species and production context; multiple rules per feed_products row';

-- Nutrition catalogue only on feed_products (eligibility moved to rules table)
ALTER TABLE feed_products DROP COLUMN IF EXISTS species_scope;
ALTER TABLE feed_products DROP COLUMN IF EXISTS max_perc_feed;
ALTER TABLE feed_products DROP COLUMN IF EXISTS max_perc_conc;
ALTER TABLE feed_products DROP COLUMN IF EXISTS max_perc_weight;
ALTER TABLE feed_products DROP COLUMN IF EXISTS max_feed_weight_kg;
ALTER TABLE feed_products DROP COLUMN IF EXISTS production_focus;
ALTER TABLE feed_products DROP COLUMN IF EXISTS sex_restriction;
ALTER TABLE feed_products DROP COLUMN IF EXISTS min_age_months;
ALTER TABLE feed_products DROP COLUMN IF EXISTS max_age_months;
ALTER TABLE feed_products DROP COLUMN IF EXISTS breeding_cycle;
ALTER TABLE feed_products DROP COLUMN IF EXISTS lactation_exclusion;
ALTER TABLE feed_products DROP COLUMN IF EXISTS lactation_inclusion;
ALTER TABLE feed_products DROP COLUMN IF EXISTS dietary_needs;

DROP INDEX IF EXISTS idx_feed_products_species_type;

CREATE INDEX IF NOT EXISTS idx_feed_products_type
  ON feed_products (feed_type)
  WHERE is_active;
