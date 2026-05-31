import { randomUUID } from 'node:crypto';
import type {
  CustomNutrition,
  FeedInventoryItem,
  FeedType,
  GroupFeedingRecord,
  InventorySourceType,
  InventoryUsageLog,
  MealIngredient,
  MealType,
  MedicalInventoryItem,
  UsageReason,
} from '../domain/types.js';

const MS_PER_DAY = 86_400_000;

export function computeWeeksOfSupply(
  quantityKg: number,
  weeklyUsageKg: number,
): number | null {
  if (weeklyUsageKg <= 0) return null;
  return Math.round((quantityKg / weeklyUsageKg) * 10) / 10;
}

export function isLowStock(quantityKg: number, reorderThresholdKg: number): boolean {
  if (reorderThresholdKg <= 0) return false;
  return quantityKg <= reorderThresholdKg;
}

export function clampFeedQuantityKg(quantityKg: number): number {
  if (!Number.isFinite(quantityKg)) return 0;
  return Math.max(0, quantityKg);
}

export function rollingWeeklyUsageKg(
  logs: InventoryUsageLog[],
  feedItemId: string,
  asOf = new Date(),
): number {
  const since = new Date(asOf.getTime() - 7 * MS_PER_DAY);
  return logs
    .filter(
      (l) =>
        l.feed_inventory_item_id === feedItemId &&
        new Date(l.created_at) >= since &&
        l.delta_kg < 0,
    )
    .reduce((sum, l) => sum + Math.abs(l.delta_kg), 0);
}

export class InMemoryInventoryStore {
  readonly feedItems = new Map<string, FeedInventoryItem>();
  readonly medicalItems = new Map<string, MedicalInventoryItem>();
  readonly meals = new Map<string, MealType>();
  readonly mealIngredients = new Map<string, MealIngredient>();
  readonly feedingRecords = new Map<string, GroupFeedingRecord>();
  readonly usageLogs: InventoryUsageLog[] = [];

  seedDemoFeed(farmId: string): void {
    this.createFeedItem(farmId, {
      name: 'Alfalfa hay (mid-bloom)',
      source_type: 'STANDARD',
      feed_product_number: 1001,
      feed_type: 'FODDER',
      quantity_kg: 120,
      purchased_volume_kg: 500,
      unit_cost: 1.8,
      currency: 'SAR',
      supplier_name: 'Local Fodder Co.',
      supplier_phone: '+966500000001',
      weekly_usage_kg: 200,
      reorder_threshold_kg: 200,
    });
    this.createFeedItem(farmId, {
      name: 'Barley concentrate',
      source_type: 'MARKETPLACE',
      marketplace_product_id: 'mp-barley-01',
      feed_type: 'CONCENTRATE',
      quantity_kg: 80,
      purchased_volume_kg: 200,
      unit_cost: 2.1,
      currency: 'SAR',
      weekly_usage_kg: 110,
      reorder_threshold_kg: 110,
    });
  }

  seedDemoMedical(farmId: string): void {
    this.createMedicalItem(farmId, {
      name: 'Penicillin',
      medicine_type: 'ANTIBIOTIC',
      purpose: 'Mastitis treatment',
      quantity: 12,
      unit: 'dose',
      unit_cost: 45,
      currency: 'SAR',
      purchased_volume: 24,
      supplier_name: 'Vet Supplies KSA',
      reorder_threshold: 6,
      weekly_usage: 4,
    });
  }

  createFeedItem(
    farmId: string,
    input: {
      name: string;
      source_type: InventorySourceType;
      feed_product_number?: number | null;
      marketplace_product_id?: string | null;
      feed_type?: FeedType | null;
      quantity_kg: number;
      purchased_volume_kg?: number | null;
      unit_cost?: number | null;
      currency?: string;
      supplier_name?: string | null;
      supplier_phone?: string | null;
      supplier_notes?: string | null;
      custom_nutrition?: CustomNutrition;
      weekly_usage_kg?: number;
      reorder_threshold_kg?: number;
      estimated_daily_usage_kg?: number;
      expiry_date?: string | null;
      notes?: string | null;
    },
  ): FeedInventoryItem {
    const weekly =
      input.weekly_usage_kg ??
      (input.estimated_daily_usage_kg != null
        ? input.estimated_daily_usage_kg * 7
        : 0);
    const reorder =
      input.reorder_threshold_kg ?? (weekly > 0 ? weekly : 0);
    const record: FeedInventoryItem = {
      id: randomUUID(),
      farm_id: farmId,
      name: input.name,
      source_type: input.source_type,
      feed_product_number: input.feed_product_number ?? null,
      marketplace_product_id: input.marketplace_product_id ?? null,
      feed_type: input.feed_type ?? null,
      quantity_kg: clampFeedQuantityKg(input.quantity_kg),
      purchased_volume_kg: input.purchased_volume_kg ?? input.quantity_kg,
      unit_cost: input.unit_cost ?? null,
      currency: input.currency ?? 'SAR',
      supplier_name: input.supplier_name ?? null,
      supplier_phone: input.supplier_phone ?? null,
      supplier_notes: input.supplier_notes ?? null,
      custom_nutrition: input.custom_nutrition ?? {},
      weekly_usage_kg: weekly,
      reorder_threshold_kg: reorder,
      unit: 'kg',
      expiry_date: input.expiry_date ?? null,
      notes: input.notes ?? null,
      is_active: true,
      updated_at: new Date().toISOString(),
    };
    this.feedItems.set(record.id, record);
    // quantity_kg already reflects on-hand stock; do not add purchased_volume again.
    return record;
  }

  createMedicalItem(
    farmId: string,
    input: Partial<MedicalInventoryItem> & {
      name: string;
      medicine_type: string;
      quantity: number;
      unit: MedicalInventoryItem['unit'];
    },
  ): MedicalInventoryItem {
    const weekly = input.weekly_usage ?? 0;
    const record: MedicalInventoryItem = {
      id: randomUUID(),
      farm_id: farmId,
      name: input.name,
      medicine_type: input.medicine_type,
      purpose: input.purpose ?? null,
      quantity: input.quantity,
      unit: input.unit,
      unit_cost: input.unit_cost ?? null,
      currency: input.currency ?? 'SAR',
      purchased_volume: input.purchased_volume ?? input.quantity,
      batch_number: input.batch_number ?? null,
      expiry_date: input.expiry_date ?? null,
      reorder_threshold: input.reorder_threshold ?? weekly,
      weekly_usage: weekly,
      supplier_name: input.supplier_name ?? null,
      supplier_phone: input.supplier_phone ?? null,
      supplier_notes: input.supplier_notes ?? null,
      source_type: input.source_type ?? 'CUSTOM',
      notes: input.notes ?? null,
      is_active: true,
      updated_at: new Date().toISOString(),
    };
    this.medicalItems.set(record.id, record);
    return record;
  }

  listFeed(farmId: string): FeedInventoryItem[] {
    return [...this.feedItems.values()]
      .filter((f) => f.farm_id === farmId && f.is_active)
      .sort((a, b) => a.name.localeCompare(b.name));
  }

  listMedical(farmId: string): MedicalInventoryItem[] {
    return [...this.medicalItems.values()]
      .filter((m) => m.farm_id === farmId && m.is_active)
      .sort((a, b) => a.name.localeCompare(b.name));
  }

  getFeed(id: string): FeedInventoryItem | undefined {
    return this.feedItems.get(id);
  }

  updateFeed(id: string, patch: Partial<FeedInventoryItem>): FeedInventoryItem | undefined {
    const existing = this.feedItems.get(id);
    if (!existing) return undefined;
    const updated = {
      ...existing,
      ...patch,
      id: existing.id,
      farm_id: existing.farm_id,
      updated_at: new Date().toISOString(),
    };
    this.feedItems.set(id, updated);
    return updated;
  }

  logUsage(input: {
    farm_id: string;
    feed_inventory_item_id: string;
    delta_kg: number;
    reason: UsageReason;
    group_id?: string | null;
    meal_type_id?: string | null;
    feeding_record_id?: string | null;
    notes?: string | null;
  }): InventoryUsageLog {
    const log: InventoryUsageLog = {
      id: randomUUID(),
      farm_id: input.farm_id,
      feed_inventory_item_id: input.feed_inventory_item_id,
      delta_kg: input.delta_kg,
      reason: input.reason,
      group_id: input.group_id ?? null,
      meal_type_id: input.meal_type_id ?? null,
      feeding_record_id: input.feeding_record_id ?? null,
      notes: input.notes ?? null,
      created_at: new Date().toISOString(),
    };
    this.usageLogs.push(log);
    const item = this.feedItems.get(input.feed_inventory_item_id);
    if (item) {
      item.quantity_kg = Math.max(0, item.quantity_kg + input.delta_kg);
      item.weekly_usage_kg = rollingWeeklyUsageKg(
        this.usageLogs,
        item.id,
      );
      if (item.weekly_usage_kg > 0) {
        item.reorder_threshold_kg = item.weekly_usage_kg;
      }
      item.updated_at = new Date().toISOString();
    }
    return log;
  }

  refreshWeeklyThresholds(farmId: string): void {
    for (const item of this.listFeed(farmId)) {
      item.weekly_usage_kg = rollingWeeklyUsageKg(this.usageLogs, item.id);
      if (item.weekly_usage_kg > 0) {
        item.reorder_threshold_kg = item.weekly_usage_kg;
      }
    }
  }

  lowStockFeed(farmId: string): FeedInventoryItem[] {
    return this.listFeed(farmId).filter((f) =>
      isLowStock(f.quantity_kg, f.reorder_threshold_kg),
    );
  }

  createMeal(
    farmId: string,
    input: { name: string; description?: string | null },
  ): MealType {
    const meal: MealType = {
      id: randomUUID(),
      farm_id: farmId,
      name: input.name,
      description: input.description ?? null,
      is_active: true,
      ingredients: [],
      total_kg_per_batch: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    this.meals.set(meal.id, meal);
    return meal;
  }

  addMealIngredient(
    mealId: string,
    feedItemId: string,
    amountKg: number,
  ): MealIngredient | undefined {
    const meal = this.meals.get(mealId);
    const feed = this.feedItems.get(feedItemId);
    if (!meal || !feed || feed.farm_id !== meal.farm_id) return undefined;
    const existing = [...this.mealIngredients.values()].find(
      (i) => i.meal_type_id === mealId && i.feed_inventory_item_id === feedItemId,
    );
    if (existing) {
      existing.amount_kg = amountKg;
      this.syncMealTotals(mealId);
      return existing;
    }
    const ing: MealIngredient = {
      id: randomUUID(),
      meal_type_id: mealId,
      feed_inventory_item_id: feedItemId,
      amount_kg: amountKg,
      sort_order: meal.ingredients.length,
      feed_item_name: feed.name,
    };
    this.mealIngredients.set(ing.id, ing);
    this.syncMealTotals(mealId);
    return ing;
  }

  syncMealTotals(mealId: string): void {
    const meal = this.meals.get(mealId);
    if (!meal) return;
    const ings = [...this.mealIngredients.values()].filter(
      (i) => i.meal_type_id === mealId,
    );
    meal.ingredients = ings.map((i) => ({
      ...i,
      feed_item_name:
        this.feedItems.get(i.feed_inventory_item_id)?.name ?? i.feed_item_name,
    }));
    meal.total_kg_per_batch = ings.reduce((s, i) => s + i.amount_kg, 0);
    meal.updated_at = new Date().toISOString();
  }

  listMeals(farmId: string): MealType[] {
    return [...this.meals.values()]
      .filter((m) => m.farm_id === farmId && m.is_active)
      .map((m) => {
        this.syncMealTotals(m.id);
        return this.meals.get(m.id)!;
      });
  }

  getMeal(id: string): MealType | undefined {
    const meal = this.meals.get(id);
    if (meal) this.syncMealTotals(id);
    return meal;
  }

  recordGroupFeeding(input: {
    farm_id: string;
    group_id: string;
    meal_type_id: string | null;
    total_weight_kg: number;
    head_count?: number | null;
    notes?: string | null;
    recorded_by?: string | null;
  }): { record: GroupFeedingRecord; low_stock: FeedInventoryItem[] } {
    const meal = input.meal_type_id
      ? this.getMeal(input.meal_type_id)
      : undefined;
    if (input.meal_type_id && !meal) {
      throw new Error('MEAL_NOT_FOUND');
    }

    const perHead =
      input.head_count && input.head_count > 0
        ? input.total_weight_kg / input.head_count
        : null;

    const record: GroupFeedingRecord = {
      id: randomUUID(),
      farm_id: input.farm_id,
      group_id: input.group_id,
      meal_type_id: input.meal_type_id,
      recorded_date: new Date().toISOString().slice(0, 10),
      total_weight_kg: input.total_weight_kg,
      per_head_kg: perHead,
      head_count: input.head_count ?? null,
      notes: input.notes ?? null,
      recorded_by: input.recorded_by ?? null,
      created_at: new Date().toISOString(),
    };
    this.feedingRecords.set(record.id, record);

    if (meal && meal.total_kg_per_batch > 0) {
      const scale = input.total_weight_kg / meal.total_kg_per_batch;
      for (const ing of meal.ingredients) {
        const deduct = ing.amount_kg * scale;
        this.logUsage({
          farm_id: input.farm_id,
          feed_inventory_item_id: ing.feed_inventory_item_id,
          delta_kg: -deduct,
          reason: 'FEEDING',
          group_id: input.group_id,
          meal_type_id: meal.id,
          feeding_record_id: record.id,
          notes: `Fed ${meal.name}`,
        });
      }
    }

    return {
      record,
      low_stock: this.lowStockFeed(input.farm_id),
    };
  }
}
