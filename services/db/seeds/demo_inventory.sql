-- Demo feed inventory for integration testing (optional; skipped when rows already exist).
-- Matches in-memory seed used by gh-api-inventory BDD (farm id farm-1 for JWT tests).

INSERT INTO feed_inventory_items (
  id,
  farm_id,
  name,
  source_type,
  feed_product_number,
  feed_type,
  quantity_kg,
  purchased_volume_kg,
  unit_cost,
  currency,
  supplier_name,
  weekly_usage_kg,
  reorder_threshold_kg,
  is_active
)
SELECT
  'a0000000-0000-4000-8000-000000000001'::uuid,
  f.id,
  'Alfalfa hay (mid-bloom)',
  'STANDARD',
  1001,
  'FODDER',
  120,
  500,
  1.8,
  'SAR',
  'Local Fodder Co.',
  200,
  200,
  TRUE
FROM farms f
WHERE f.id::text = 'farm-1' OR f.name ILIKE '%alfalah%'
LIMIT 1
ON CONFLICT (id) DO NOTHING;

INSERT INTO feed_inventory_items (
  id,
  farm_id,
  name,
  source_type,
  marketplace_product_id,
  feed_type,
  quantity_kg,
  purchased_volume_kg,
  unit_cost,
  currency,
  weekly_usage_kg,
  reorder_threshold_kg,
  is_active
)
SELECT
  'a0000000-0000-4000-8000-000000000002'::uuid,
  f.id,
  'Barley concentrate',
  'MARKETPLACE',
  'mp-barley-01',
  'CONCENTRATE',
  80,
  200,
  2.1,
  'SAR',
  110,
  110,
  TRUE
FROM farms f
WHERE f.id::text = 'farm-1' OR f.name ILIKE '%alfalah%'
LIMIT 1
ON CONFLICT (id) DO NOTHING;
