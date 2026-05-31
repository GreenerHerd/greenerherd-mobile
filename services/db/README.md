# GreenerHerd PostgreSQL

Shared database for `gh-api-farms`, `gh-api-people`, and `gh-api-animals`.

## Quick start

```bash
cd services/db
cp .env.example .env
npm install
npm run db:up          # Docker Postgres on localhost:5432
npm run db:setup       # migrate + seed (breeds, countries, currencies)
```

Export the URL for API services:

```bash
export DATABASE_URL=postgres://greenerherd:greenerherd@localhost:5432/greenerherd
export JWT_SECRET=dev-secret-change-me
```

Start services (each loads reference breeds from DB when `DATABASE_URL` is set):

```bash
cd ../gh-api-farms && npm install && npm run dev
cd ../gh-api-people && npm install && npm run dev
cd ../gh-api-animals && npm install && npm run dev
```

## Layout

| Path | Purpose |
|------|---------|
| `migrations/001_reference.sql` | DDL: `breeds`, `countries`, `currencies` |
| `migrations/002_domain.sql` | DDL: farms, users, animals, groups, access |
| `migrations/004_feed_products.sql` | DDL: global feed nutrition catalogue (`product_number` 1001+) |
| `migrations/013_feed_product_eligibility_rules.sql` | DDL: eligibility rules child table (multiple rules per product) |
| `migrations/012_marketplace_feed_products.sql` | DDL: marketplace supplier listings (`prod_id` 3001+) |
| `migrations/005_feed_indicative_pricing.sql` | DDL: `feed_indicative_prices` (`price_number` 2001+), `feed_fx_rates` |
| `migrations/006_nutrition_requirements.sql` | DDL: nutrition requirement profiles |
| `migrations/007_notification_tasks.sql` | DDL: notification definitions, user prefs, `farm_tasks` |
| `migrations/011_reference_translations.sql` | DDL: `breed_trans`, `feed_product_trans`, `country_trans` (names per locale) |
| `seeds/breeds.sql` | DML: breeds + characteristics (from Excel; regenerate with extract script) |
| `seeds/breed_weights.sql` | DML: indicative weights by sex and age (1–24+ months) |
| `seeds/countries_currencies.sql` | DML: countries and currencies |
| `seeds/feed_products.sql` | DML: nutrition catalogue (61 products; TRUNCATE + INSERT for fresh seeds) |
| `seeds/feed_product_eligibility_rules.sql` | DML: eligibility rules (74 rows; one per spreadsheet species/limit row) |
| `seeds/upload_standard_feed_products.sql` | DML: idempotent upload of products + rules (`product_number` 1001+, `rule_number` 5001+) |
| `seeds/marketplace_feed_products.sql` | DML: marketplace listings (TRUNCATE + INSERT; from xlsx or utility SQL fallback) |
| `seeds/upload_marketplace_feed_products.sql` | DML: idempotent upload of marketplace listings (`prod_id` 3001+; upsert on `marketplace_product_id`) |
| `seeds/feed_indicative_prices.sql` | DML: indicative $/kg by country (61 rows; separate table) |
| `seeds/feed_fx_rates.sql` | DML: FX reference for pricing sheet |
| `seeds/nutrition_requirements.sql` | DML: nutrition profiles from requirements xlsx |
| `seeds/notification_task_definitions.sql` | DML: notification / task catalogue (61 go-live tasks) |
| `seeds/demo_inventory.sql` | DML: optional demo alfalfa + barley rows for `farm-1` integration tests |
| `sources/Generic_Products_Nutrition_Combined.xlsx` | Feed nutrition source |
| `sources/Generic_Products_Indicative_Pricing.xlsx` | Indicative pricing source (updated independently) |
| `sources/Notification_Events.xlsx` | Notification / recommended-task catalogue |
| `sources/Livestock_Nutrition_Requirements.xlsx` | Nutrition requirements (copy from Documents) |
| `sources/Sheep_Characteristics.xlsx` | Sheep breed characteristics (origin, purpose, lambing ease, etc.) |
| `scripts/extract_breeds_from_xlsx.py` | Regenerate breed seeds from Excel sources |
| `scripts/migrate.ts` | Apply migrations in order (tracked in `schema_migrations`) |
| `scripts/seed.ts` | Run all `seeds/*.sql` |
| `scripts/reset.ts` | Drop/recreate `public` schema (destructive) |

## Scripts

| Command | Description |
|---------|-------------|
| `npm run db:up` | Start Postgres via Docker Compose |
| `npm run db:down` | Stop Postgres |
| `npm run db:migrate` | Apply pending migrations |
| `npm run db:seed` | Load reference DML |
| `npm run db:setup` | `migrate` + `seed` |
| `npm run db:reset` | Wipe schema, then run `db:setup` |
| `npm run db:extract-feeds` | Regenerate `feed_products.sql`, `feed_product_eligibility_rules.sql`, upload DML, mobile JSON |
| `npm run db:extract-pricing` | Regenerate `feed_indicative_prices.sql` + FX rates |
| `npm run db:extract-feed-catalog` | Both extract scripts |
| `npm run db:extract-marketplace` | Regenerate `marketplace_feed_products.sql` + mobile JSON |
| `npm run db:extract-notifications` | Regenerate notification seed + `assets/data/notification_task_definitions.json` |

## Service behaviour

- **`DATABASE_URL` set** → PostgreSQL repositories; breeds loaded into memory at startup (`BreedCatalog`).
- **`DATABASE_URL` unset** → in-memory stores (used by Cucumber BDD; no Docker required).

Breeds API (no auth): `GET http://localhost:3002/api/v1/reference/breeds?species=SHEEP`

Health checks report `storage` and `breeds_loaded` when using Postgres (92 breeds after full Excel import: 26 cattle, 36 goat, 30 sheep).

### Refresh breeds from Excel

```bash
cd services/db
npm run db:extract-breeds
# Or with explicit paths:
# python3 scripts/extract_breeds_from_xlsx.py \
#   "$HOME/Documents/Obsidian/GreenerHerd/Breed Information.xlsx" \
#   --sheep-chars sources/Sheep_Characteristics.xlsx
npm run db:reset && npm run db:setup
```

Sheep characteristics come from `sources/Sheep_Characteristics.xlsx` (weights still from `Breed Information.xlsx` → Sheep Weights old).

## Catalog translations (separate language tables)

Reference display names live in `*_trans` tables, not on the main product/breed rows:

| Table | Keys | Locales |
|-------|------|---------|
| `breed_trans` | `breed_id` | `en`, `ar`, `fr`, `ur` |
| `feed_product_trans` | `product_id` | `en`, `ar`, `fr`, `ur` |
| `country_trans` | `country_code` | `en`, `ar` |

Migration `011_reference_translations.sql` backfills from legacy `name_ar` / `name_fr` / `name_ur` columns. APIs accept `?locale=ar` on `/api/v1/reference/breeds` and `/api/v1/reference/feeds`.

Refresh mobile bundled JSON after seed changes:

```bash
python3 scripts/export_catalog_names_json.py
```
