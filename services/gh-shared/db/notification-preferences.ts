import type {
  NotificationChannel,
  NotificationTaskCatalog,
  NotificationTaskDefinition,
} from './notification-task-catalog.js';

export interface UserNotificationPreferenceRecord {
  task_definition_id: string;
  enabled: boolean;
  push_enabled: boolean;
  in_app_enabled: boolean;
}

export interface NotificationPreferenceItem {
  task_definition_id: string;
  task_id: number;
  category: string;
  task_name: string;
  expanded_detail: string | null;
  trigger_event: string | null;
  priority: string | null;
  action_by: string | null;
  channels: NotificationChannel[];
  enabled: boolean;
  push_enabled: boolean;
  in_app_enabled: boolean;
  default_enabled: boolean;
}

export interface NotificationPreferencesPayload {
  farm_id: string;
  user_id: string;
  items: NotificationPreferenceItem[];
  categories: Array<{
    category: string;
    enabled_count: number;
    total_count: number;
  }>;
}

export interface PreferenceUpdateInput {
  task_definition_id: string;
  enabled?: boolean;
  push_enabled?: boolean;
  in_app_enabled?: boolean;
}

function mergeItem(
  definition: NotificationTaskDefinition,
  stored?: UserNotificationPreferenceRecord,
): NotificationPreferenceItem {
  const enabled = stored?.enabled ?? definition.default_enabled;
  const pushDefault = definition.channels.includes('PUSH');
  const inAppDefault = definition.channels.includes('IN_APP');
  return {
    task_definition_id: definition.id,
    task_id: definition.task_id,
    category: definition.category,
    task_name: definition.task_name,
    expanded_detail: definition.expanded_detail,
    trigger_event: definition.trigger_event,
    priority: definition.priority,
    action_by: definition.action_by,
    channels: definition.channels,
    enabled,
    push_enabled: enabled && (stored?.push_enabled ?? pushDefault),
    in_app_enabled: enabled && (stored?.in_app_enabled ?? inAppDefault),
    default_enabled: definition.default_enabled,
  };
}

export function buildNotificationPreferences(
  catalog: NotificationTaskCatalog,
  farmId: string,
  userId: string,
  stored: UserNotificationPreferenceRecord[],
  options: { go_live_only?: boolean } = {},
): NotificationPreferencesPayload {
  const byDef = new Map(stored.map((s) => [s.task_definition_id, s]));
  const definitions = catalog.list({
    go_live_only: options.go_live_only ?? true,
    active_only: true,
  });

  const items = definitions.map((d) => mergeItem(d, byDef.get(d.id)));

  const categoryMap = new Map<string, { enabled: number; total: number }>();
  for (const item of items) {
    const bucket = categoryMap.get(item.category) ?? { enabled: 0, total: 0 };
    bucket.total += 1;
    if (item.enabled) bucket.enabled += 1;
    categoryMap.set(item.category, bucket);
  }

  const categories = [...categoryMap.entries()]
    .map(([category, counts]) => ({
      category,
      enabled_count: counts.enabled,
      total_count: counts.total,
    }))
    .sort((a, b) => a.category.localeCompare(b.category));

  return { farm_id: farmId, user_id: userId, items, categories };
}

export function applyPreferenceUpdates(
  current: NotificationPreferenceItem[],
  updates: PreferenceUpdateInput[],
): NotificationPreferenceItem[] {
  const byId = new Map(current.map((i) => [i.task_definition_id, { ...i }]));
  for (const u of updates) {
    const item = byId.get(u.task_definition_id);
    if (!item) continue;
    if (u.enabled !== undefined) {
      item.enabled = u.enabled;
      if (!u.enabled) {
        item.push_enabled = false;
        item.in_app_enabled = false;
      }
    }
    if (u.push_enabled !== undefined) item.push_enabled = u.push_enabled && item.enabled;
    if (u.in_app_enabled !== undefined) {
      item.in_app_enabled = u.in_app_enabled && item.enabled;
    }
  }
  return [...byId.values()].sort((a, b) => a.task_id - b.task_id);
}

export function isDefinitionEnabledForUser(
  definition: NotificationTaskDefinition,
  stored: UserNotificationPreferenceRecord | undefined,
): boolean {
  if (!definition.is_active) return false;
  return stored?.enabled ?? definition.default_enabled;
}
