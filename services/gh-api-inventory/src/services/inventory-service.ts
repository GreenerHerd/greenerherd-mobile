import { AppError } from '../lib/errors.js';
import type { CustomNutrition, FeedItemPublic } from '../domain/types.js';
import type pg from 'pg';
import {
  emitInventoryBelowThreshold,
} from '@greenerherd/shared-db/domain-event-client';
import { analyzeMealIngredientStock } from '../domain/meal-stock.js';
import {
  replaceMealIngredients,
  upsertFeedItem,
} from '../db/inventory-persistence.js';
import {
  clampFeedQuantityKg,
  computeWeeksOfSupply,
  InMemoryInventoryStore,
  isLowStock,
} from '../repositories/inventory-store.js';

function toPublicFeed(item: ReturnType<InMemoryInventoryStore['getFeed']> & object): FeedItemPublic {
  const f = item as NonNullable<ReturnType<InMemoryInventoryStore['getFeed']>>;
  return {
    ...f,
    low_stock: isLowStock(f.quantity_kg, f.reorder_threshold_kg),
    weeks_of_supply: computeWeeksOfSupply(f.quantity_kg, f.weekly_usage_kg),
  };
}

function validateCustomNutrition(
  sourceType: string,
  nutrition?: CustomNutrition,
): void {
  if (sourceType !== 'CUSTOM') return;
  if (!nutrition?.feed_type) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Custom feed products require feed_type in custom_nutrition',
      400,
    );
  }
  const hasMacro =
    nutrition.dry_matter_percent != null ||
    nutrition.crude_protein_percent != null ||
    nutrition.nem_mcal_per_kg != null;
  if (!hasMacro) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Custom feed products require at least one nutritional value (DM%, CP%, or NEm)',
      400,
    );
  }
}

function validateSupplier(
  sourceType: string,
  supplierName?: string | null,
): void {
  if (sourceType === 'MARKETPLACE') return;
  if (!supplierName?.trim()) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Supplier name is required for standard and custom inventory items',
      400,
    );
  }
}

export class InventoryService {
  constructor(
    private readonly store: InMemoryInventoryStore,
    private readonly pool?: pg.Pool,
  ) {}

  listFeed(farmId: string): FeedItemPublic[] {
    return this.store.listFeed(farmId).map((f) => toPublicFeed(f));
  }

  listMedical(farmId: string) {
    return this.store.listMedical(farmId).map((m) => ({
      ...m,
      low_stock: m.reorder_threshold > 0 && m.quantity <= m.reorder_threshold,
    }));
  }

  getFeed(farmId: string, id: string): FeedItemPublic {
    const item = this.store.getFeed(id);
    if (!item || item.farm_id !== farmId) {
      throw new AppError('NOT_FOUND', 'Feed inventory item not found', 404);
    }
    return toPublicFeed(item);
  }

  async createFeed(
    farmId: string,
    body: {
      name: string;
      source_type: 'STANDARD' | 'MARKETPLACE' | 'CUSTOM';
      feed_product_number?: number | null;
      marketplace_product_id?: string | null;
      feed_type?: string | null;
      quantity_kg: number;
      purchased_volume_kg?: number | null;
      unit_cost?: number | null;
      currency?: string;
      supplier_name?: string | null;
      supplier_phone?: string | null;
      supplier_notes?: string | null;
      custom_nutrition?: CustomNutrition;
      estimated_daily_usage_kg?: number;
      reorder_threshold_kg?: number;
      expiry_date?: string | null;
      notes?: string | null;
    },
  ): Promise<FeedItemPublic> {
    validateCustomNutrition(body.source_type, body.custom_nutrition);
    validateSupplier(body.source_type, body.supplier_name);
    if (body.source_type === 'STANDARD' && body.feed_product_number == null) {
      throw new AppError(
        'VALIDATION_ERROR',
        'feed_product_number required for STANDARD source',
        400,
      );
    }
    if (body.source_type === 'MARKETPLACE' && !body.marketplace_product_id) {
      throw new AppError(
        'VALIDATION_ERROR',
        'marketplace_product_id required for MARKETPLACE source',
        400,
      );
    }
    const created = this.store.createFeedItem(farmId, {
      ...body,
      feed_type: body.feed_type as FeedItemPublic['feed_type'],
    });
    if (this.pool) {
      await upsertFeedItem(this.pool, created);
    }
    return toPublicFeed(created);
  }

  createMedical(
    farmId: string,
    body: {
      name: string;
      medicine_type: string;
      purpose?: string | null;
      quantity: number;
      unit: 'kg' | 'litre' | 'unit' | 'dose';
      unit_cost?: number | null;
      currency?: string;
      purchased_volume?: number | null;
      batch_number?: string | null;
      expiry_date?: string | null;
      supplier_name?: string | null;
      supplier_phone?: string | null;
      supplier_notes?: string | null;
      source_type?: 'STANDARD' | 'MARKETPLACE' | 'CUSTOM';
      estimated_weekly_usage?: number;
      notes?: string | null;
    },
  ) {
    validateSupplier(body.source_type ?? 'CUSTOM', body.supplier_name);
    return this.store.createMedicalItem(farmId, {
      name: body.name,
      medicine_type: body.medicine_type,
      purpose: body.purpose,
      quantity: body.quantity,
      unit: body.unit,
      unit_cost: body.unit_cost,
      currency: body.currency,
      purchased_volume: body.purchased_volume,
      batch_number: body.batch_number,
      expiry_date: body.expiry_date,
      supplier_name: body.supplier_name,
      supplier_phone: body.supplier_phone,
      supplier_notes: body.supplier_notes,
      source_type: body.source_type,
      weekly_usage: body.estimated_weekly_usage,
      reorder_threshold: body.estimated_weekly_usage,
      notes: body.notes,
    });
  }

  listMeals(farmId: string) {
    return this.store.listMeals(farmId);
  }

  createMeal(farmId: string, body: { name: string; description?: string | null }) {
    return this.store.createMeal(farmId, body);
  }

  async setMealIngredients(
    farmId: string,
    mealId: string,
    ingredients: Array<{ feed_inventory_item_id: string; amount_kg: number }>,
  ) {
    const meal = this.store.getMeal(mealId);
    if (!meal || meal.farm_id !== farmId) {
      throw new AppError('NOT_FOUND', 'Meal not found', 404);
    }
    for (const ing of [...this.store.mealIngredients.values()].filter(
      (i) => i.meal_type_id === mealId,
    )) {
      this.store.mealIngredients.delete(ing.id);
    }
    for (const row of ingredients) {
      const added = this.store.addMealIngredient(
        mealId,
        row.feed_inventory_item_id,
        row.amount_kg,
      );
      if (!added) {
        throw new AppError(
          'VALIDATION_ERROR',
          `Invalid feed item ${row.feed_inventory_item_id} for this meal`,
          400,
        );
      }
    }
    const updated = this.store.getMeal(mealId)!;
    const stock_warnings = analyzeMealIngredientStock(
      this.store.listFeed(farmId),
      ingredients,
    );
    if (this.pool) {
      await replaceMealIngredients(this.pool, mealId, ingredients);
    }
    return { ...updated, stock_warnings };
  }

  async recordFeeding(
    farmId: string,
    body: {
      group_id: string;
      meal_type_id?: string | null;
      total_weight_kg: number;
      head_count?: number | null;
      notes?: string | null;
      recorded_by?: string | null;
    },
  ) {
    try {
      const result = this.store.recordGroupFeeding({
        farm_id: farmId,
        group_id: body.group_id,
        meal_type_id: body.meal_type_id ?? null,
        total_weight_kg: body.total_weight_kg,
        head_count: body.head_count,
        notes: body.notes,
        recorded_by: body.recorded_by,
      });
      if (this.pool) {
        for (const item of result.low_stock) {
          await upsertFeedItem(this.pool, item);
        }
        const touchedIds = new Set(
          this.store.usageLogs
            .filter((l) => l.feeding_record_id === result.record.id)
            .map((l) => l.feed_inventory_item_id),
        );
        for (const id of touchedIds) {
          const feed = this.store.getFeed(id);
          if (feed) await upsertFeedItem(this.pool, feed);
        }
      }
      void emitInventoryBelowThreshold(
        farmId,
        result.low_stock.map((f) => ({
          id: f.id,
          name: f.name,
          quantity_kg: f.quantity_kg,
        })),
      );
      return {
        feeding: result.record,
        low_stock_items: result.low_stock.map((f) => toPublicFeed(f)),
      };
    } catch (e) {
      if (e instanceof Error && e.message === 'MEAL_NOT_FOUND') {
        throw new AppError('NOT_FOUND', 'Meal not found', 404);
      }
      throw e;
    }
  }

  lowStockSummary(farmId: string) {
    const feed = this.store.lowStockFeed(farmId);
    return {
      feed_items: feed.map((f) => toPublicFeed(f)),
      count: feed.length,
    };
  }

  usageSummary(farmId: string, feedItemId: string) {
    const item = this.store.getFeed(feedItemId);
    if (!item || item.farm_id !== farmId) {
      throw new AppError('NOT_FOUND', 'Feed inventory item not found', 404);
    }
    const logs = this.store.usageLogs
      .filter((l) => l.feed_inventory_item_id === feedItemId)
      .slice(-50)
      .reverse();
    return {
      item: toPublicFeed(item),
      logs,
    };
  }
}
