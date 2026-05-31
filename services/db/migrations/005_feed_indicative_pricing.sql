-- Indicative market pricing (separate from nutrition/eligibility in feed_products)
-- Updated independently; joined to feed_products by name_en + feed_type

CREATE TABLE IF NOT EXISTS feed_fx_rates (
  country_code CHAR(2) PRIMARY KEY,
  country_name TEXT NOT NULL,
  currency_code CHAR(3) NOT NULL,
  rate_per_usd NUMERIC(18, 6) NOT NULL,
  peg_type TEXT,
  notes TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS feed_indicative_prices (
  id UUID PRIMARY KEY,
  price_number INT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_ar TEXT,
  feed_type TEXT NOT NULL CHECK (feed_type IN ('FODDER', 'CONCENTRATE', 'ADDITIVE')),
  usd_per_kg NUMERIC(12, 4),
  prices_by_country JSONB NOT NULL DEFAULT '{}'::jsonb,
  price_source TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (name_en, feed_type)
);

CREATE INDEX IF NOT EXISTS idx_feed_indicative_prices_lookup
  ON feed_indicative_prices (name_en, feed_type)
  WHERE is_active;

COMMENT ON TABLE feed_indicative_prices IS
  'Indicative $/kg by country; separate from feed_products nutrition catalogue';
COMMENT ON TABLE feed_fx_rates IS
  'FX reference rates used to derive regional indicative prices';
