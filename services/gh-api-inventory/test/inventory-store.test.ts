import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  computeWeeksOfSupply,
  InMemoryInventoryStore,
  isLowStock,
  rollingWeeklyUsageKg,
} from '../src/repositories/inventory-store.js';

describe('inventory-store helpers', () => {
  it('flags low stock when quantity is at or below one week threshold', () => {
    assert.equal(isLowStock(100, 200), true);
    assert.equal(isLowStock(201, 200), false);
  });

  it('computes weeks of supply from weekly usage', () => {
    assert.equal(computeWeeksOfSupply(140, 70), 2);
    assert.equal(computeWeeksOfSupply(50, 0), null);
  });

  it('deducts stock and updates weekly usage on feeding', () => {
    const store = new InMemoryInventoryStore();
    store.seedDemoFeed('farm-1');
    const feeds = store.listFeed('farm-1');
    const meal = store.createMeal('farm-1', { name: 'Test meal' });
    store.addMealIngredient(meal.id, feeds[0]!.id, 40);
    store.addMealIngredient(meal.id, feeds[1]!.id, 10);
    const before = store.getFeed(feeds[0]!.id)!.quantity_kg;
    store.recordGroupFeeding({
      farm_id: 'farm-1',
      group_id: 'g1',
      meal_type_id: meal.id,
      total_weight_kg: 50,
    });
    const after = store.getFeed(feeds[0]!.id)!.quantity_kg;
    assert.ok(after < before);
    const weekly = rollingWeeklyUsageKg(store.usageLogs, feeds[0]!.id);
    assert.ok(weekly > 0);
  });
});
