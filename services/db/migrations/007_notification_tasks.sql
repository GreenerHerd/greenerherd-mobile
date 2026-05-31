-- Notification / recommended-task catalogue (GreenerHerd amendable) + per-user preferences

CREATE TABLE IF NOT EXISTS notification_task_definitions (
  id UUID PRIMARY KEY,
  task_id INT NOT NULL UNIQUE,
  category TEXT,
  country_code CHAR(2),
  species TEXT CHECK (
    species IS NULL
    OR species IN ('ALL', 'CATTLE', 'GOAT', 'SHEEP', 'SMALL_RUMINANT')
  ),
  current_state TEXT,
  source TEXT,
  notification_text TEXT,
  task_name TEXT NOT NULL,
  notification_text_ar TEXT,
  task_name_ar TEXT,
  expanded_detail TEXT,
  expanded_detail_ar TEXT,
  level TEXT,
  trigger_event TEXT,
  trigger_criteria TEXT,
  due_date_rule TEXT,
  action_by TEXT CHECK (action_by IS NULL OR action_by IN ('USER', 'SYSTEM')),
  priority TEXT CHECK (
    priority IS NULL
    OR priority IN ('HIGH', 'MEDIUM', 'LOW')
  ),
  frequency TEXT,
  system_action TEXT,
  channels TEXT[] NOT NULL DEFAULT '{}',
  go_live BOOLEAN NOT NULL DEFAULT TRUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  default_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_task_defs_category
  ON notification_task_definitions (category)
  WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_notification_task_defs_go_live
  ON notification_task_definitions (go_live, is_active);

CREATE TABLE IF NOT EXISTS user_notification_preferences (
  id UUID PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  task_definition_id UUID NOT NULL REFERENCES notification_task_definitions (id) ON DELETE CASCADE,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, farm_id, task_definition_id)
);

CREATE INDEX IF NOT EXISTS idx_user_notification_prefs_user_farm
  ON user_notification_preferences (user_id, farm_id);

-- Generated farmer tasks / reminders (instances)
CREATE TABLE IF NOT EXISTS farm_tasks (
  id UUID PRIMARY KEY,
  farm_id UUID NOT NULL REFERENCES farms (id) ON DELETE CASCADE,
  task_definition_id UUID REFERENCES notification_task_definitions (id),
  title TEXT NOT NULL,
  description TEXT,
  task_type TEXT NOT NULL DEFAULT 'AUTO' CHECK (
    task_type IN ('MANUAL', 'AUTO', 'AUTO_BREEDING', 'AUTO_VACCINATION', 'AUTO_HEALTH', 'AUTO_NUTRITION', 'AUTO_WEATHER')
  ),
  group_id UUID REFERENCES animal_groups (id) ON DELETE SET NULL,
  animal_id UUID REFERENCES animals (id) ON DELETE SET NULL,
  assigned_to TEXT REFERENCES users (id),
  due_date DATE,
  status TEXT NOT NULL DEFAULT 'PENDING' CHECK (
    status IN ('PENDING', 'IN_PROGRESS', 'COMPLETE', 'OVERDUE', 'DISMISSED')
  ),
  priority TEXT CHECK (
    priority IS NULL
    OR priority IN ('HIGH', 'MEDIUM', 'LOW')
  ),
  created_by TEXT REFERENCES users (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_farm_tasks_farm_due
  ON farm_tasks (farm_id, due_date)
  WHERE status NOT IN ('COMPLETE', 'DISMISSED');

CREATE INDEX IF NOT EXISTS idx_farm_tasks_definition
  ON farm_tasks (task_definition_id)
  WHERE task_definition_id IS NOT NULL;
