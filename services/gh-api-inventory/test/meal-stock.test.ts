import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { analyzeMealIngredientStock } from '../src/domain/meal-stock.js';
import {
  clampFeedQuantityKg,
  InMemoryInventoryStore,
} from '../src/repositories/inventory-store.js';

describe('meal-stock', () => {
  it('clamps negative feed quantity to zero', () => {
    assert.equal(clampFeedQuantityKg(-50), 0);
    assert.equal(clampFeedQuantityKg(12.5), 12.5);
  });

  it('flags low stock and insufficient batch on meal ingredients', () => {
    const store = new InMemoryInventoryStore();
    store.seedDemoFeed('farm-1');
    const feeds = store.listFeed('farm-1');
    const alfalfa = feeds.find((f) => f.name.includes('Alfalfa'))!;
    const warnings = analyzeMealIngredientStock(feeds, [
      { feed_inventory_item_id: alfalfa.id, amount_kg: 500 },
    ]);
    assert.ok(warnings.length > 0);
    assert.ok(warnings.some((w) => w.low_stock));
    assert.ok(warnings.some((w) => w.insufficient_for_batch));
  });

  it('stores negative add as zero when bypassing API validation', () => {
    const store = new InMemoryInventoryStore();
    const item = store.createFeedItem('farm-1', {
      name: 'Zeroed',
      source_type: 'CUSTOM',
      quantity_kg: -10,
      custom_nutrition: { feed_type: 'FODDER', dry_matter_percent: 90 },
      supplier_name: 'Test',
    });
    assert.equal(item.quantity_kg, 0);
  });
});
