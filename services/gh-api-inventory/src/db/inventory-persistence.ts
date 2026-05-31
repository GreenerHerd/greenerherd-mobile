import type pg from 'pg';
import type {
  FeedInventoryItem,
  FeedType,
  InventorySourceType,
  MealType,
} from '../domain/types.js';
import { InMemoryInventoryStore } from '../repositories/inventory-store.js';

function rowToFeed(row: Record<string, unknown>): FeedInventoryItem {
  return {
    id: String(row.id),
    farm_id: String(row.farm_id),
    name: String(row.name),
    source_type: String(row.source_type) as InventorySourceType,
    feed_product_number:
      row.feed_product_number == null ? null : Number(row.feed_product_number),
    marketplace_product_id:
      row.marketplace_product_id == null
        ? null
        : String(row.marketplace_product_id),
    feed_type: row.feed_type == null ? null : (String(row.feed_type) as FeedType),
    quantity_kg: Number(row.quantity_kg),
    purchased_volume_kg:
      row.purchased_volume_kg == null ? null : Number(row.purchased_volume_kg),
    unit_cost: row.unit_cost == null ? null : Number(row.unit_cost),
    currency: String(row.currency ?? 'SAR'),
    supplier_name: row.supplier_name == null ? null : String(row.supplier_name),
    supplier_phone: row.supplier_phone == null ? null : String(row.supplier_phone),
    supplier_notes: row.supplier_notes == null ? null : String(row.supplier_notes),
    custom_nutrition:
      row.custom_nutrition && typeof row.custom_nutrition === 'object'
        ? (row.custom_nutrition as FeedInventoryItem['custom_nutrition'])
        : {},
    weekly_usage_kg: Number(row.weekly_usage_kg ?? 0),
    reorder_threshold_kg: Number(
      row.reorder_threshold_kg ?? row.weekly_usage_kg ?? 0,
    ),
    unit: String(row.unit ?? 'kg'),
    expiry_date: row.expiry_date == null ? null : String(row.expiry_date),
    notes: row.notes == null ? null : String(row.notes),
    is_active: Boolean(row.is_active ?? true),
    updated_at: new Date(String(row.updated_at)).toISOString(),
  };
}

/** Load all active inventory for a farm into an in-memory store (used with DATABASE_URL). */
export async function hydrateInventoryStore(
  pool: pg.Pool,
  store: InMemoryInventoryStore,
): Promise<void> {
  const { rows: feeds } = await pool.query(
    `SELECT * FROM feed_inventory_items WHERE is_active = TRUE`,
  );
  for (const row of feeds) {
    const item = rowToFeed(row);
    store.feedItems.set(item.id, item);
  }

  const { rows: meals } = await pool.query(
    `SELECT * FROM meal_types WHERE is_active = TRUE`,
  );
  for (const row of meals) {
    const meal: MealType = {
      id: String(row.id),
      farm_id: String(row.farm_id),
      name: String(row.name),
      description: row.description == null ? null : String(row.description),
      is_active: true,
      ingredients: [],
      total_kg_per_batch: 0,
      created_at: new Date(String(row.created_at)).toISOString(),
      updated_at: new Date(String(row.updated_at)).toISOString(),
    };
    store.meals.set(meal.id, meal);
  }

  const { rows: ings } = await pool.query(
    `SELECT mi.*, fi.name AS feed_item_name
     FROM meal_ingredients mi
     JOIN feed_inventory_items fi ON fi.id = mi.feed_inventory_item_id`,
  );
  for (const row of ings) {
    store.addMealIngredient(
      String(row.meal_type_id),
      String(row.feed_inventory_item_id),
      Number(row.amount_kg),
    );
  }
}

/** Upsert a single feed row after in-memory mutation. */
export async function upsertFeedItem(
  pool: pg.Pool,
  item: FeedInventoryItem,
): Promise<void> {
  await pool.query(
    `INSERT INTO feed_inventory_items (
      id, farm_id, name, source_type, feed_product_number, marketplace_product_id,
      feed_type, quantity_kg, purchased_volume_kg, unit_cost, currency,
      supplier_name, supplier_phone, supplier_notes, custom_nutrition,
      weekly_usage_kg, reorder_threshold_kg, unit, expiry_date, notes, is_active, updated_at
    ) VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15::jsonb,$16,$17,$18,$19,$20,$21,NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      source_type = EXCLUDED.source_type,
      feed_product_number = EXCLUDED.feed_product_number,
      marketplace_product_id = EXCLUDED.marketplace_product_id,
      feed_type = EXCLUDED.feed_type,
      quantity_kg = EXCLUDED.quantity_kg,
      purchased_volume_kg = EXCLUDED.purchased_volume_kg,
      unit_cost = EXCLUDED.unit_cost,
      currency = EXCLUDED.currency,
      supplier_name = EXCLUDED.supplier_name,
      supplier_phone = EXCLUDED.supplier_phone,
      supplier_notes = EXCLUDED.supplier_notes,
      custom_nutrition = EXCLUDED.custom_nutrition,
      weekly_usage_kg = EXCLUDED.weekly_usage_kg,
      reorder_threshold_kg = EXCLUDED.reorder_threshold_kg,
      unit = EXCLUDED.unit,
      expiry_date = EXCLUDED.expiry_date,
      notes = EXCLUDED.notes,
      is_active = EXCLUDED.is_active,
      updated_at = NOW()`,
    [
      item.id,
      item.farm_id,
      item.name,
      item.source_type,
      item.feed_product_number,
      item.marketplace_product_id,
      item.feed_type,
      item.quantity_kg,
      item.purchased_volume_kg,
      item.unit_cost,
      item.currency,
      item.supplier_name,
      item.supplier_phone,
      item.supplier_notes,
      JSON.stringify(item.custom_nutrition ?? {}),
      item.weekly_usage_kg,
      item.reorder_threshold_kg,
      item.unit,
      item.expiry_date,
      item.notes,
      item.is_active,
    ],
  );
}

export async function replaceMealIngredients(
  pool: pg.Pool,
  mealId: string,
  ingredients: Array<{ feed_inventory_item_id: string; amount_kg: number }>,
): Promise<void> {
  await pool.query(`DELETE FROM meal_ingredients WHERE meal_type_id = $1`, [
    mealId,
  ]);
  let sort = 0;
  for (const ing of ingredients) {
    await pool.query(
      `INSERT INTO meal_ingredients (id, meal_type_id, feed_inventory_item_id, amount_kg, sort_order)
       VALUES (gen_random_uuid(), $1, $2, $3, $4)`,
      [mealId, ing.feed_inventory_item_id, ing.amount_kg, sort++],
    );
  }
}
