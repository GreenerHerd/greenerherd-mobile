-- Separate translation tables for reference / lookup data (names away from main rows).

CREATE TABLE IF NOT EXISTS breed_trans (
  breed_id UUID NOT NULL REFERENCES breeds (id) ON DELETE CASCADE,
  locale CHAR(2) NOT NULL CHECK (locale IN ('en', 'ar', 'fr', 'ur')),
  name TEXT NOT NULL,
  PRIMARY KEY (breed_id, locale)
);

CREATE INDEX IF NOT EXISTS idx_breed_trans_locale ON breed_trans (locale);

CREATE TABLE IF NOT EXISTS feed_product_trans (
  product_id UUID NOT NULL REFERENCES feed_products (id) ON DELETE CASCADE,
  locale CHAR(2) NOT NULL CHECK (locale IN ('en', 'ar', 'fr', 'ur')),
  name TEXT NOT NULL,
  PRIMARY KEY (product_id, locale)
);

CREATE INDEX IF NOT EXISTS idx_feed_product_trans_locale ON feed_product_trans (locale);

CREATE TABLE IF NOT EXISTS country_trans (
  country_code CHAR(2) NOT NULL REFERENCES countries (iso_code) ON DELETE CASCADE,
  locale CHAR(2) NOT NULL CHECK (locale IN ('en', 'ar', 'fr', 'ur')),
  name TEXT NOT NULL,
  PRIMARY KEY (country_code, locale)
);

-- Backfill from legacy inline name_* columns (idempotent).
INSERT INTO breed_trans (breed_id, locale, name)
SELECT id, 'en', name_en
FROM breeds
ON CONFLICT (breed_id, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO breed_trans (breed_id, locale, name)
SELECT id, 'ar', name_ar
FROM breeds
WHERE name_ar IS NOT NULL AND TRIM(name_ar) <> ''
ON CONFLICT (breed_id, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO breed_trans (breed_id, locale, name)
SELECT id, 'fr', name_fr
FROM breeds
WHERE name_fr IS NOT NULL AND TRIM(name_fr) <> ''
ON CONFLICT (breed_id, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO breed_trans (breed_id, locale, name)
SELECT id, 'ur', name_ur
FROM breeds
WHERE name_ur IS NOT NULL AND TRIM(name_ur) <> ''
ON CONFLICT (breed_id, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO feed_product_trans (product_id, locale, name)
SELECT id, 'en', name_en
FROM feed_products
ON CONFLICT (product_id, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO feed_product_trans (product_id, locale, name)
SELECT id, 'ar', name_ar
FROM feed_products
WHERE name_ar IS NOT NULL AND TRIM(name_ar) <> ''
ON CONFLICT (product_id, locale) DO UPDATE
SET name = EXCLUDED.name;

-- Feed products: mirror English for fr/ur until dedicated translations are added.
INSERT INTO feed_product_trans (product_id, locale, name)
SELECT id, 'fr', name_en
FROM feed_products
ON CONFLICT (product_id, locale) DO NOTHING;

INSERT INTO feed_product_trans (product_id, locale, name)
SELECT id, 'ur', name_en
FROM feed_products
ON CONFLICT (product_id, locale) DO NOTHING;

INSERT INTO country_trans (country_code, locale, name)
SELECT iso_code, 'en', name_en
FROM countries
ON CONFLICT (country_code, locale) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO country_trans (country_code, locale, name)
SELECT iso_code, 'ar', name_ar
FROM countries
WHERE name_ar IS NOT NULL AND TRIM(name_ar) <> ''
ON CONFLICT (country_code, locale) DO UPDATE
SET name = EXCLUDED.name;
