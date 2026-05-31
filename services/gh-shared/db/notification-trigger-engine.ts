import type { NotificationTaskDefinition } from './notification-task-catalog.js';
import { isDefinitionEnabledForUser } from './notification-preferences.js';
import type { UserNotificationPreferenceRecord } from './notification-preferences.js';
import { computeDueDate, formatDueDateIso } from './notification-due-date.js';
import {
  resolveTriggerKey,
  triggerKeysForDomainEvent,
  type DomainEventType,
  type TriggerKey,
} from './notification-trigger-registry.js';

export type FarmTaskType =
  | 'MANUAL'
  | 'AUTO'
  | 'AUTO_BREEDING'
  | 'AUTO_VACCINATION'
  | 'AUTO_HEALTH'
  | 'AUTO_NUTRITION'
  | 'AUTO_WEATHER';

export interface FarmTaskDraft {
  farm_id: string;
  task_definition_id: string;
  title: string;
  description: string | null;
  task_type: FarmTaskType;
  group_id: string | null;
  animal_id: string | null;
  assigned_to: string | null;
  due_date: string;
  priority: 'HIGH' | 'MEDIUM' | 'LOW' | null;
  metadata: Record<string, unknown>;
  dedupe_key: string;
  notify_user_ids: string[];
}

export interface DomainEvent {
  type: DomainEventType;
  farm_id: string;
  occurred_at: string;
  group_id?: string;
  animal_id?: string;
  payload?: Record<string, unknown>;
}

export interface AnimalSnapshot {
  id: string;
  group_id: string | null;
  species: 'CATTLE' | 'GOAT' | 'SHEEP';
  sex: 'MALE' | 'FEMALE';
  tags: string[];
  status: string;
  age_months?: number;
  estimated_due_date?: string;
}

export interface GroupSnapshot {
  id: string;
  name: string;
  species: 'CATTLE' | 'GOAT' | 'SHEEP';
  head_count: number;
}

export interface InventorySnapshot {
  id: string;
  name: string;
  quantity_kg: number;
  reorder_threshold_kg: number;
  is_feed: boolean;
}

export interface TriggerAnchor {
  anchor_type: string;
  entity_type: 'ANIMAL' | 'GROUP' | 'FARM' | 'INVENTORY';
  entity_id: string;
  anchored_at: string;
}

export interface WeatherAlert {
  kind: TriggerKey;
  message: string;
}

export interface FarmSchedulerContext {
  farm_id: string;
  country_code?: string;
  as_of: string;
  animals: AnimalSnapshot[];
  groups: GroupSnapshot[];
  inventory: InventorySnapshot[];
  anchors: TriggerAnchor[];
  weather_alerts?: WeatherAlert[];
  farm_user_ids: string[];
  preferences_by_user: Map<string, UserNotificationPreferenceRecord[]>;
}

export interface SchedulerResult {
  created: FarmTaskDraft[];
  skipped_dedupe: number;
  skipped_preferences: number;
  skipped_no_match: number;
}

function taskTypeForCategory(category: string): FarmTaskType {
  const c = category.toLowerCase();
  if (c.includes('breed')) return 'AUTO_BREEDING';
  if (c.includes('vaccin') || c.includes('health')) return 'AUTO_HEALTH';
  if (c.includes('nutrition') || c.includes('feed')) return 'AUTO_NUTRITION';
  if (c.includes('weather')) return 'AUTO_WEATHER';
  return 'AUTO';
}

function speciesMatches(
  def: NotificationTaskDefinition,
  species: 'CATTLE' | 'GOAT' | 'SHEEP' | null,
): boolean {
  if (!def.species || def.species === 'ALL') return true;
  if (!species) return true;
  if (def.species === 'SMALL_RUMINANT') {
    return species === 'GOAT' || species === 'SHEEP';
  }
  return def.species === species;
}

function interpolate(
  template: string,
  vars: Record<string, string>,
): string {
  let out = template;
  for (const [key, value] of Object.entries(vars)) {
    out = out.replaceAll(`{${key}}`, value);
    out = out.replaceAll(`{${key.replace(/\s+/g, ' ')}}`, value);
  }
  return out
    .replaceAll('{Group Name}', vars.group_name ?? 'group')
    .replaceAll('{Tag Number}', vars.tag_number ?? 'animal')
    .replaceAll('{Product Name}', vars.product_name ?? 'product')
    .replaceAll('{Recommended Product}', vars.product_name ?? 'product')
    .replaceAll('{Recommmended Product}', vars.product_name ?? 'product');
}

function usersToNotify(
  def: NotificationTaskDefinition,
  ctx: FarmSchedulerContext,
): string[] {
  const ids: string[] = [];
  for (const userId of ctx.farm_user_ids) {
    const prefs = ctx.preferences_by_user.get(userId) ?? [];
    const stored = prefs.find((p) => p.task_definition_id === def.id);
    if (isDefinitionEnabledForUser(def, stored)) ids.push(userId);
  }
  return ids;
}

function buildDraft(
  def: NotificationTaskDefinition,
  ctx: FarmSchedulerContext,
  options: {
    group?: GroupSnapshot;
    animal?: AnimalSnapshot;
    dueDate: Date;
    extraMeta?: Record<string, unknown>;
    dedupeSuffix: string;
  },
): FarmTaskDraft | null {
  const notify = usersToNotify(def, ctx);
  if (notify.length === 0) return null;

  const groupName = options.group?.name ?? 'group';
  const tag = options.animal?.id ?? '';
  const productName =
    (options.extraMeta?.product_name as string | undefined) ?? 'product';

  const title = interpolate(def.task_name, {
    group_name: groupName,
    tag_number: tag,
    product_name: productName,
  });
  const description =
    def.expanded_detail != null
      ? interpolate(def.expanded_detail, {
          group_name: groupName,
          tag_number: tag,
          product_name: productName,
        })
      : def.notification_text != null
        ? interpolate(def.notification_text, {
            group_name: groupName,
            tag_number: tag,
            product_name: productName,
          })
        : null;

  const due = formatDueDateIso(options.dueDate);
  const entityId =
    options.animal?.id ?? options.group?.id ?? ctx.farm_id;
  const dedupe_key = `${def.id}:${entityId}:${due}:${options.dedupeSuffix}`;

  return {
    farm_id: ctx.farm_id,
    task_definition_id: def.id,
    title,
    description,
    task_type: taskTypeForCategory(def.category),
    group_id: options.group?.id ?? options.animal?.group_id ?? null,
    animal_id: options.animal?.id ?? null,
    assigned_to: def.action_by === 'SYSTEM' ? null : notify[0] ?? null,
    due_date: due,
    priority: def.priority,
    metadata: {
      trigger_key: resolveTriggerKey(def.trigger_event),
      trigger_event: def.trigger_event,
      task_id: def.task_id,
      category: def.category,
      channels: def.channels,
      notify_user_ids: notify,
      ...options.extraMeta,
    },
    dedupe_key,
    notify_user_ids: notify,
  };
}

function definitionsForKeys(
  definitions: NotificationTaskDefinition[],
  keys: TriggerKey[],
): NotificationTaskDefinition[] {
  return definitions.filter((d) => {
    if (!d.go_live || !d.is_active) return false;
    const key = resolveTriggerKey(d.trigger_event);
    return keys.includes(key);
  });
}

export class NotificationTriggerEngine {
  constructor(private readonly definitions: NotificationTaskDefinition[]) {}

  processDomainEvent(
    event: DomainEvent,
    ctx: FarmSchedulerContext,
    existingDedupeKeys: Set<string>,
  ): SchedulerResult {
    const keys = triggerKeysForDomainEvent(event.type);
    const matched = definitionsForKeys(this.definitions, keys);
    const asOf = new Date(event.occurred_at);
    const created: FarmTaskDraft[] = [];
    let skipped_dedupe = 0;
    let skipped_preferences = 0;
    let skipped_no_match = 0;

    const group = event.group_id
      ? ctx.groups.find((g) => g.id === event.group_id)
      : undefined;
    const animal = event.animal_id
      ? ctx.animals.find((a) => a.id === event.animal_id)
      : undefined;

    for (const def of matched) {
      if (!speciesMatches(def, animal?.species ?? group?.species ?? null)) {
        skipped_no_match += 1;
        continue;
      }

      const dueDate = computeDueDate(def.due_date_rule, asOf);
      const draft = buildDraft(def, ctx, {
        group,
        animal,
        dueDate,
        dedupeSuffix: event.type,
        extraMeta: {
          domain_event: event.type,
          ...event.payload,
        },
      });
      if (!draft) {
        skipped_preferences += 1;
        continue;
      }
      if (existingDedupeKeys.has(draft.dedupe_key)) {
        skipped_dedupe += 1;
        continue;
      }
      created.push(draft);
      existingDedupeKeys.add(draft.dedupe_key);
    }

    return { created, skipped_dedupe, skipped_preferences, skipped_no_match };
  }

  runScheduledSweep(
    ctx: FarmSchedulerContext,
    existingDedupeKeys: Set<string>,
  ): SchedulerResult {
    const asOf = new Date(ctx.as_of);
    const month = asOf.getMonth() + 1;
    const created: FarmTaskDraft[] = [];
    let skipped_dedupe = 0;
    let skipped_preferences = 0;
    let skipped_no_match = 0;

    const lowInventoryDefs = definitionsForKeys(this.definitions, ['LOW_INVENTORY']);
    for (const item of ctx.inventory) {
      if (!item.is_feed) continue;
      if (item.quantity_kg > item.reorder_threshold_kg) continue;
      for (const def of lowInventoryDefs) {
        const dueDate = computeDueDate(def.due_date_rule, asOf);
        const draft = buildDraft(def, ctx, {
          dueDate,
          dedupeSuffix: `inv:${item.id}`,
          extraMeta: { product_name: item.name, inventory_id: item.id },
        });
        if (!draft) {
          skipped_preferences += 1;
          continue;
        }
        if (existingDedupeKeys.has(draft.dedupe_key)) {
          skipped_dedupe += 1;
          continue;
        }
        created.push(draft);
        existingDedupeKeys.add(draft.dedupe_key);
      }
    }

    const campaignDefs = definitionsForKeys(this.definitions, ['SCHEDULED_CAMPAIGN']);
    for (const def of campaignDefs) {
      const text = (def.trigger_event ?? '').toLowerCase();
      const months = parseCampaignMonths(text);
      if (months.length > 0 && !months.includes(month)) {
        skipped_no_match += 1;
        continue;
      }
      const dueDate = computeDueDate(def.due_date_rule, asOf);
      const draft = buildDraft(def, ctx, {
        dueDate,
        dedupeSuffix: `campaign:${month}`,
        extraMeta: { campaign_month: month },
      });
      if (!draft) {
        skipped_preferences += 1;
        continue;
      }
      if (existingDedupeKeys.has(draft.dedupe_key)) {
        skipped_dedupe += 1;
        continue;
      }
      created.push(draft);
      existingDedupeKeys.add(draft.dedupe_key);
    }

    for (const alert of ctx.weather_alerts ?? []) {
      const defs = definitionsForKeys(this.definitions, [alert.kind]);
      for (const def of defs) {
        const dueDate = computeDueDate(def.due_date_rule, asOf);
        const draft = buildDraft(def, ctx, {
          dueDate,
          dedupeSuffix: `wx:${alert.kind}`,
          extraMeta: { weather_message: alert.message },
        });
        if (!draft) {
          skipped_preferences += 1;
          continue;
        }
        if (existingDedupeKeys.has(draft.dedupe_key)) {
          skipped_dedupe += 1;
          continue;
        }
        created.push(draft);
        existingDedupeKeys.add(draft.dedupe_key);
      }
    }

    const illDefs = definitionsForKeys(this.definitions, ['ANIMAL_MARKED_ILL']);
    for (const animal of ctx.animals) {
      if (!animal.tags.map((t) => t.toUpperCase()).includes('SICK')) continue;
      for (const def of illDefs) {
        if (!speciesMatches(def, animal.species)) continue;
        const group = ctx.groups.find((g) => g.id === animal.group_id);
        const dueDate = computeDueDate(def.due_date_rule, asOf);
        const draft = buildDraft(def, ctx, {
          group,
          animal,
          dueDate,
          dedupeSuffix: 'sick',
        });
        if (!draft) {
          skipped_preferences += 1;
          continue;
        }
        if (existingDedupeKeys.has(draft.dedupe_key)) {
          skipped_dedupe += 1;
          continue;
        }
        created.push(draft);
        existingDedupeKeys.add(draft.dedupe_key);
      }
    }

    return {
      created,
      skipped_dedupe,
      skipped_preferences,
      skipped_no_match,
    };
  }

  runAll(
    ctx: FarmSchedulerContext,
    events: DomainEvent[],
    existingDedupeKeys: Set<string>,
  ): SchedulerResult {
    const merged: SchedulerResult = {
      created: [],
      skipped_dedupe: 0,
      skipped_preferences: 0,
      skipped_no_match: 0,
    };
    const keys = new Set(existingDedupeKeys);

    for (const event of events) {
      const r = this.processDomainEvent(event, ctx, keys);
      merged.created.push(...r.created);
      merged.skipped_dedupe += r.skipped_dedupe;
      merged.skipped_preferences += r.skipped_preferences;
      merged.skipped_no_match += r.skipped_no_match;
    }

    const sweep = this.runScheduledSweep(ctx, keys);
    merged.created.push(...sweep.created);
    merged.skipped_dedupe += sweep.skipped_dedupe;
    merged.skipped_preferences += sweep.skipped_preferences;
    merged.skipped_no_match += sweep.skipped_no_match;

    return merged;
  }
}

const MONTH_NAMES: Record<string, number> = {
  jan: 1,
  january: 1,
  feb: 2,
  february: 2,
  mar: 3,
  march: 3,
  apr: 4,
  april: 4,
  may: 5,
  jun: 6,
  june: 6,
  jul: 7,
  july: 7,
  aug: 8,
  august: 8,
  sep: 9,
  sept: 9,
  september: 9,
  oct: 10,
  october: 10,
  nov: 11,
  november: 11,
  dec: 12,
  december: 12,
};

function parseCampaignMonths(text: string): number[] {
  const found = new Set<number>();
  const tokens = text.replace(/[&/]/g, ',').split(/[,\s]+/);
  for (const token of tokens) {
    const key = token.toLowerCase().replace(/[^a-z]/g, '');
    if (key && MONTH_NAMES[key]) found.add(MONTH_NAMES[key]!);
  }
  return [...found];
}
