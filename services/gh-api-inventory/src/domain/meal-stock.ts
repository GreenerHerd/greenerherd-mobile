import type { FeedInventoryItem } from './types.js';
import {
  clampFeedQuantityKg,
  isLowStock,
} from '../repositories/inventory-store.js';

export interface MealStockWarning {
  feed_inventory_item_id: string;
  feed_item_name: string;
  available_kg: number;
  requested_kg: number;
  low_stock: boolean;
  insufficient_for_batch: boolean;
}

export function analyzeMealIngredientStock(
  feeds: FeedInventoryItem[],
  ingredients: Array<{ feed_inventory_item_id: string; amount_kg: number }>,
): MealStockWarning[] {
  const warnings: MealStockWarning[] = [];
  for (const ing of ingredients) {
    const feed = feeds.find((f) => f.id === ing.feed_inventory_item_id);
    if (!feed) continue;
    const available = clampFeedQuantityKg(feed.quantity_kg);
    const requested = ing.amount_kg;
    const low = isLowStock(available, feed.reorder_threshold_kg);
    const insufficient = requested > available;
    if (low || insufficient) {
      warnings.push({
        feed_inventory_item_id: feed.id,
        feed_item_name: feed.name,
        available_kg: available,
        requested_kg: requested,
        low_stock: low,
        insufficient_for_batch: insufficient,
      });
    }
  }
  return warnings;
}
