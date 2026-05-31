import type { Pool } from 'pg';
import type {
  AnimalSnapshot,
  FarmSchedulerContext,
  GroupSnapshot,
  InventorySnapshot,
  TriggerAnchor,
} from '@greenerherd/shared-db/notification-trigger-engine';
import type { UserNotificationPreferenceRecord } from '@greenerherd/shared-db/notification-preferences';

/** Demo context when running without Postgres (matches Flutter mock seed). */
export function demoSchedulerContext(farmId: string): FarmSchedulerContext {
  return {
    farm_id: farmId,
    country_code: 'SA',
    as_of: new Date().toISOString(),
    groups: [
      { id: 'g1', name: 'Milking A', species: 'CATTLE', head_count: 22 },
      { id: 'g5', name: 'Maintenance B', species: 'GOAT', head_count: 48 },
    ],
    animals: [
      {
        id: 'a1',
        group_id: 'g3',
        species: 'CATTLE',
        sex: 'FEMALE',
        tags: ['PREGNANT', 'LACTATING'],
        status: 'ACTIVE',
        age_months: 50,
      },
      {
        id: 'c1',
        group_id: 'g9',
        species: 'SHEEP',
        sex: 'FEMALE',
        tags: ['SICK'],
        status: 'ACTIVE',
        age_months: 38,
      },
    ],
    inventory: [
      {
        id: 'i1',
        name: 'Alfalfa hay (mid-bloom)',
        quantity_kg: 120,
        reorder_threshold_kg: 200,
        is_feed: true,
      },
      {
        id: 'i2',
        name: 'Barley concentrate',
        quantity_kg: 80,
        reorder_threshold_kg: 110,
        is_feed: true,
      },
    ],
    anchors: [],
    farm_user_ids: ['u1', 'u2', 'u3'],
    preferences_by_user: new Map([
      ['u1', []],
      ['u2', []],
      ['u3', []],
    ]),
  };
}

function ageMonthsFromDob(dob: Date | null, asOf: Date): number | undefined {
  if (!dob) return undefined;
  const months =
    (asOf.getFullYear() - dob.getFullYear()) * 12 +
    (asOf.getMonth() - dob.getMonth());
  return Math.max(0, months);
}

export async function loadFarmSchedulerContext(
  pool: Pool,
  farmId: string,
  asOf: Date = new Date(),
): Promise<FarmSchedulerContext> {
  const [farmRes, groupsRes, animalsRes, inventoryRes, anchorsRes, usersRes, prefsRes] =
    await Promise.all([
      pool.query(`SELECT country FROM farms WHERE id = $1`, [farmId]),
      pool.query(
        `SELECT id, name, species,
          (SELECT COUNT(*)::int FROM animals a WHERE a.group_id = g.id AND a.status = 'ACTIVE') AS head_count
         FROM animal_groups g WHERE farm_id = $1`,
        [farmId],
      ),
      pool.query(
        `SELECT id, group_id, species, sex, status, tags, dob FROM animals WHERE farm_id = $1 AND status = 'ACTIVE'`,
        [farmId],
      ),
      pool.query(
        `SELECT id, name, quantity_kg,
          GREATEST(
            COALESCE(reorder_threshold_kg, 0),
            COALESCE(weekly_usage_kg, 0)
          ) AS reorder_threshold_kg
         FROM feed_inventory_items WHERE farm_id = $1 AND is_active`,
        [farmId],
      ),
      pool.query(
        `SELECT anchor_type, entity_type, entity_id, anchored_at FROM notification_trigger_anchors WHERE farm_id = $1`,
        [farmId],
      ),
      pool.query(
        `SELECT user_id FROM farm_users WHERE farm_id = $1 AND is_active`,
        [farmId],
      ),
      pool.query(
        `SELECT user_id, task_definition_id, enabled, push_enabled, in_app_enabled
         FROM user_notification_preferences WHERE farm_id = $1`,
        [farmId],
      ),
    ]);

  const groups: GroupSnapshot[] = groupsRes.rows.map((r) => ({
    id: String(r.id),
    name: String(r.name),
    species: r.species as GroupSnapshot['species'],
    head_count: Number(r.head_count ?? 0),
  }));

  const animals: AnimalSnapshot[] = animalsRes.rows.map((r) => {
    const tagsRaw = r.tags;
    const tags = Array.isArray(tagsRaw)
      ? tagsRaw.map((t) => String(t).toUpperCase())
      : [];
    const dob = r.dob ? new Date(String(r.dob)) : null;
    return {
      id: String(r.id),
      group_id: r.group_id == null ? null : String(r.group_id),
      species: r.species as AnimalSnapshot['species'],
      sex: r.sex as AnimalSnapshot['sex'],
      tags,
      status: String(r.status),
      age_months: ageMonthsFromDob(dob, asOf),
    };
  });

  const inventory: InventorySnapshot[] = inventoryRes.rows.map((r) => ({
    id: String(r.id),
    name: String(r.name),
    quantity_kg: Number(r.quantity_kg),
    reorder_threshold_kg: Number(r.reorder_threshold_kg),
    is_feed: true,
  }));

  const anchors: TriggerAnchor[] = anchorsRes.rows.map((r) => ({
    anchor_type: String(r.anchor_type),
    entity_type: r.entity_type as TriggerAnchor['entity_type'],
    entity_id: String(r.entity_id),
    anchored_at: String(r.anchored_at),
  }));

  const farm_user_ids = usersRes.rows.map((r) => String(r.user_id));
  const preferences_by_user = new Map<string, UserNotificationPreferenceRecord[]>();
  for (const row of prefsRes.rows) {
    const userId = String(row.user_id);
    const list = preferences_by_user.get(userId) ?? [];
    list.push({
      task_definition_id: String(row.task_definition_id),
      enabled: Boolean(row.enabled),
      push_enabled: Boolean(row.push_enabled),
      in_app_enabled: Boolean(row.in_app_enabled),
    });
    preferences_by_user.set(userId, list);
  }
  for (const userId of farm_user_ids) {
    if (!preferences_by_user.has(userId)) preferences_by_user.set(userId, []);
  }

  return {
    farm_id: farmId,
    country_code: farmRes.rows[0]?.country
      ? String(farmRes.rows[0].country)
      : undefined,
    as_of: asOf.toISOString(),
    groups,
    animals,
    inventory,
    anchors,
    farm_user_ids,
    preferences_by_user,
  };
}
