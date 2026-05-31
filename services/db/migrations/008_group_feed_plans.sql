-- Saved group feed plans from the nutrition optimizer (Phase 4)

CREATE TABLE IF NOT EXISTS group_feed_plans (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id             UUID,
  group_id            TEXT NOT NULL,
  profile_code        TEXT NOT NULL,
  head_count          INTEGER NOT NULL CHECK (head_count > 0),
  optimizer_pass      TEXT NOT NULL CHECK (optimizer_pass IN ('complete', 'partial')),
  solution            JSONB NOT NULL DEFAULT '{}',
  totals              JSONB NOT NULL DEFAULT '{}',
  nutrient_gaps       JSONB NOT NULL DEFAULT '[]',
  catalog_achievement JSONB NOT NULL DEFAULT '{}',
  cost_per_day        NUMERIC(12, 4) NOT NULL DEFAULT 0,
  cost_currency       TEXT NOT NULL DEFAULT 'USD',
  context             JSONB NOT NULL DEFAULT '{}',
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_group_feed_plans_group_active
  ON group_feed_plans (group_id, is_active)
  WHERE is_active = TRUE;
