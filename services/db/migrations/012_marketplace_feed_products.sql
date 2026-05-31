-- Marketplace feed listings (supplier-specific products; separate from feed_products catalogue)

CREATE TABLE IF NOT EXISTS marketplace_feed_products (
  id UUID PRIMARY KEY,
  prod_id INT NOT NULL UNIQUE,
  marketplace_product_id TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_ar TEXT,
  feed_type TEXT NOT NULL CHECK (feed_type IN ('FODDER', 'CONCENTRATE', 'ADDITIVE')),
  supplier_name TEXT NOT NULL,
  supplier_email TEXT,
  supplier_phone TEXT,
  supplier_address TEXT,
  country_code CHAR(2) NOT NULL,
  currency CHAR(3) NOT NULL,
  price_per_kg NUMERIC(12, 4) NOT NULL,
  min_order_kg NUMERIC(12, 2),
  pack_size_kg NUMERIC(12, 2),
  standard_product_number INT REFERENCES feed_products (product_number),
  dm_percent NUMERIC(6, 2),
  cp_percent NUMERIC(6, 2),
  nem_mcal_kg NUMERIC(8, 4),
  ndf_percent NUMERIC(6, 2),
  in_stock BOOLEAN NOT NULL DEFAULT TRUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  source TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_marketplace_feed_products_country
  ON marketplace_feed_products (country_code, feed_type)
  WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_marketplace_feed_products_supplier
  ON marketplace_feed_products (supplier_name)
  WHERE is_active;

COMMENT ON TABLE marketplace_feed_products IS
  'Country-specific marketplace feed listings from suppliers; prod_id is the stable numeric key (3001+)';

CREATE TABLE IF NOT EXISTS marketplace_feed_product_trans (
  product_id UUID NOT NULL REFERENCES marketplace_feed_products (id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('en', 'ar', 'fr', 'ur')),
  name TEXT NOT NULL,
  PRIMARY KEY (product_id, locale)
);

CREATE INDEX IF NOT EXISTS idx_marketplace_feed_product_trans_locale
  ON marketplace_feed_product_trans (locale);
