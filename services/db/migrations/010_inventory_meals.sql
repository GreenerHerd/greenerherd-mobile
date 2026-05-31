-- Farm feed & medical inventory, meal mixes, usage tracking (harness 02_DATA_MODELS)

ALTER TABLE feed_inventory_items
  ADD COLUMN IF NOT EXISTS source_type TEXT NOT NULL DEFAULT 'CUSTOM'
    CHECK (source_type IN ('STANDARD', 'MARKETPLACE', 'CUSTOM')),
  ADD COLUMN IF NOT EXISTS feed_product_number INT,
  ADD COLUMN IF NOT EXISTS marketplace_product_id TEXT,
  ADD COLUMN IF NOT EXISTS feed_type TEXT
    CHECK (feed_type IS NULL OR feed_type IN ('FODDER', 'CONCENTRATE', 'ADDITIVE', 'CUSTOM')),
  ADD COLUMN IF NOT EXISTS unit_cost NUMERIC(12, 4),
  ADD COLUMN IF NOT EXISTS currency TEXT NOT NULL DEFAULT 'SAR',
  ADD COLUMN IF NOT EXISTS purchased_volume_kg NUMERIC(12, 3),
  ADD COLUMN IF NOT EXISTS supplier_name TEXT,
  ADD COLUMN IF NOT EXISTS supplier_phone TEXT,
  ADD COLUMN IF NOT EXISTS supplier_notes TEXT,
  ADD COLUMN IF NOT EXISTS custom_nutrition JSONB NOT NULL DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS weekly_usage_kg NUMERIC(12, 3) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS notes TEXT;

CREATE TABLE IF NOT EXISTS medical_inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  medicine_type TEXT NOT NULL DEFAULT 'GENERAL',
  purpose TEXT,
  quantity NUMERIC(12, 3) NOT NULL DEFAULT 0,
  unit TEXT NOT NULL DEFAULT 'unit'
    CHECK (unit IN ('kg', 'litre', 'unit', 'dose')),
  unit_cost NUMERIC(12, 4),
  currency TEXT NOT NULL DEFAULT 'SAR',
  purchased_volume NUMERIC(12, 3),
  batch_number TEXT,
  expiry_date DATE,
  reorder_threshold NUMERIC(12, 3) NOT NULL DEFAULT 0,
  weekly_usage NUMERIC(12, 3) NOT NULL DEFAULT 0,
  supplier_name TEXT,
  supplier_phone TEXT,
  supplier_notes TEXT,
  source_type TEXT NOT NULL DEFAULT 'CUSTOM'
    CHECK (source_type IN ('STANDARD', 'MARKETPLACE', 'CUSTOM')),
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_medical_inventory_farm
  ON medical_inventory_items (farm_id)
  WHERE is_active;

CREATE TABLE IF NOT EXISTS meal_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_meal_types_farm ON meal_types (farm_id) WHERE is_active;

CREATE TABLE IF NOT EXISTS meal_ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_type_id UUID NOT NULL REFERENCES meal_types (id) ON DELETE CASCADE,
  feed_inventory_item_id UUID NOT NULL REFERENCES feed_inventory_items (id) ON DELETE RESTRICT,
  amount_kg NUMERIC(12, 3) NOT NULL CHECK (amount_kg > 0),
  sort_order INT NOT NULL DEFAULT 0,
  UNIQUE (meal_type_id, feed_inventory_item_id)
);

CREATE TABLE IF NOT EXISTS group_feeding_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  group_id TEXT NOT NULL,
  meal_type_id UUID REFERENCES meal_types (id) ON DELETE SET NULL,
  recorded_date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_weight_kg NUMERIC(12, 3) NOT NULL CHECK (total_weight_kg > 0),
  per_head_kg NUMERIC(12, 3),
  head_count INT,
  notes TEXT,
  recorded_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_group_feeding_group_date
  ON group_feeding_records (group_id, recorded_date DESC);

CREATE TABLE IF NOT EXISTS inventory_usage_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  feed_inventory_item_id UUID NOT NULL REFERENCES feed_inventory_items (id) ON DELETE CASCADE,
  delta_kg NUMERIC(12, 3) NOT NULL,
  reason TEXT NOT NULL
    CHECK (reason IN ('PURCHASE', 'FEEDING', 'ADJUSTMENT', 'WASTE')),
  group_id TEXT,
  meal_type_id UUID REFERENCES meal_types (id) ON DELETE SET NULL,
  feeding_record_id UUID REFERENCES group_feeding_records (id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inventory_usage_item_date
  ON inventory_usage_log (feed_inventory_item_id, created_at DESC);
