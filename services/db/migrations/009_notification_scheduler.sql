-- Notification scheduler support: anchors, dedupe, feed inventory for low-stock sweeps

CREATE TABLE IF NOT EXISTS notification_trigger_anchors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  anchor_type TEXT NOT NULL,
  entity_type TEXT NOT NULL CHECK (
    entity_type IN ('ANIMAL', 'GROUP', 'FARM', 'INVENTORY', 'TASK')
  ),
  entity_id TEXT NOT NULL,
  anchored_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE (farm_id, anchor_type, entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_notification_anchors_farm_type
  ON notification_trigger_anchors (farm_id, anchor_type);

CREATE TABLE IF NOT EXISTS farm_task_dedupe (
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  task_definition_id UUID NOT NULL REFERENCES notification_task_definitions (id) ON DELETE CASCADE,
  dedupe_key TEXT NOT NULL,
  farm_task_id UUID NOT NULL REFERENCES farm_tasks (id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (farm_id, task_definition_id, dedupe_key)
);

CREATE TABLE IF NOT EXISTS feed_inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity_kg NUMERIC(12, 3) NOT NULL DEFAULT 0,
  reorder_threshold_kg NUMERIC(12, 3) NOT NULL DEFAULT 0,
  unit TEXT NOT NULL DEFAULT 'kg',
  expiry_date DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feed_inventory_farm
  ON feed_inventory_items (farm_id)
  WHERE is_active;

CREATE TABLE IF NOT EXISTS notification_scheduler_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  tasks_created INT NOT NULL DEFAULT 0,
  events_processed INT NOT NULL DEFAULT 0,
  summary JSONB NOT NULL DEFAULT '{}'::jsonb
);
