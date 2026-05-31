import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import type { InventoryWorld } from './world.js';

function parseBody(raw: string): unknown {
  return JSON.parse(raw.trim());
}

function parseResponseBody(raw: string): unknown {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function getAtPath(obj: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc && typeof acc === 'object' && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, obj);
}

Given('the inventory API is running', function (this: InventoryWorld) {
  assert.ok(this.app);
});

When(
  'I GET inventory {string}',
  async function (this: InventoryWorld, path: string) {
    const res = await this.app.inject({
      method: 'GET',
      url: path,
      headers: { authorization: `Bearer ${this.token}` },
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I POST inventory {string} with body:',
  async function (this: InventoryWorld, path: string, doc: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: path,
      headers: {
        authorization: `Bearer ${this.token}`,
        'content-type': 'application/json',
      },
      payload: parseBody(doc),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
    const data = getAtPath(this.lastResponse.body, 'data');
    if (data && typeof data === 'object' && 'id' in data) {
      const id = String((data as { id: string }).id);
      if (path.includes('/meals')) {
        this.saved.mealId = id;
      } else if (path.includes('/medical')) {
        this.saved.medicalId = id;
      } else {
        this.saved.feedItemId = id;
      }
    }
  },
);

When(
  'I PUT inventory meal ingredients for first meal from feed list',
  async function (this: InventoryWorld) {
    let mealId = this.saved.mealId;
    if (!mealId) {
      const mealsRes = await this.app.inject({
        method: 'GET',
        url: '/api/v1/farms/farm-1/meals',
        headers: { authorization: `Bearer ${this.token}` },
      });
      const mealsBody = parseResponseBody(mealsRes.body) as {
        data?: Array<{ id: string }>;
      };
      mealId = mealsBody.data?.[0]?.id;
    }
    assert.ok(mealId, 'expected a meal id');
    const feedRes = await this.app.inject({
      method: 'GET',
      url: '/api/v1/farms/farm-1/inventory/feed',
      headers: { authorization: `Bearer ${this.token}` },
    });
    const feedBody = parseResponseBody(feedRes.body) as {
      data?: Array<{ id: string }>;
    };
    const feeds = feedBody.data ?? [];
    assert.ok(feeds.length >= 2, 'need at least two feed items');
    const res = await this.app.inject({
      method: 'PUT',
      url: `/api/v1/farms/farm-1/meals/${mealId}/ingredients`,
      headers: {
        authorization: `Bearer ${this.token}`,
        'content-type': 'application/json',
      },
      payload: {
        ingredients: [
          { feed_inventory_item_id: feeds[0]!.id, amount_kg: 60 },
          { feed_inventory_item_id: feeds[1]!.id, amount_kg: 25 },
        ],
      },
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I POST inventory feeding with meal and weight {int}',
  async function (this: InventoryWorld, kg: number) {
    const mealsRes = await this.app.inject({
      method: 'GET',
      url: '/api/v1/farms/farm-1/meals',
      headers: { authorization: `Bearer ${this.token}` },
    });
    const mealsBody = parseResponseBody(mealsRes.body) as {
      data?: Array<{ id: string }>;
    };
    const mealId = mealsBody.data?.[0]?.id;
    assert.ok(mealId, 'expected seeded meal');
    const res = await this.app.inject({
      method: 'POST',
      url: '/api/v1/farms/farm-1/feeding-records',
      headers: {
        authorization: `Bearer ${this.token}`,
        'content-type': 'application/json',
      },
      payload: {
        group_id: 'g1',
        meal_type_id: mealId,
        total_weight_kg: kg,
        head_count: 22,
      },
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

Then(
  'inventory response status is {int}',
  function (this: InventoryWorld, status: number) {
    assert.equal(this.lastResponse?.statusCode, status);
  },
);

Then(
  'inventory response data path {string} is at least {int}',
  function (this: InventoryWorld, path: string, min: number) {
    const value = getAtPath(this.lastResponse?.body, path);
    assert.ok(typeof value === 'number' && value >= min);
  },
);

Then(
  'inventory response data path {string} equals {int}',
  function (this: InventoryWorld, path: string, expected: number) {
    const value = getAtPath(this.lastResponse?.body, `data.${path}`);
    const num =
      typeof value === 'number'
        ? value
        : typeof value === 'string'
          ? Number(value)
          : NaN;
    assert.equal(num, expected);
  },
);

Then(
  'inventory first meal has at least {int} ingredients',
  function (this: InventoryWorld, min: number) {
    const meals = getAtPath(this.lastResponse?.body, 'data') as
      | Array<{ ingredients?: unknown[] }>
      | undefined;
    assert.ok(Array.isArray(meals) && meals.length > 0);
    const count = meals[0]?.ingredients?.length ?? 0;
    assert.ok(count >= min, `expected >= ${min} ingredients, got ${count}`);
  },
);

When(
  'I PUT inventory meal ingredients exceeding stock for saved meal',
  async function (this: InventoryWorld) {
    const mealId = this.saved.mealId;
    assert.ok(mealId, 'meal id not saved from prior POST');
    const feedRes = await this.app.inject({
      method: 'GET',
      url: '/api/v1/farms/farm-1/inventory/feed',
      headers: { authorization: `Bearer ${this.token}` },
    });
    const feedBody = parseResponseBody(feedRes.body) as {
      data?: Array<{ id: string; name: string }>;
    };
    const alfalfa = feedBody.data?.find((f) =>
      f.name.includes('Alfalfa'),
    );
    assert.ok(alfalfa, 'expected alfalfa feed item');
    const res = await this.app.inject({
      method: 'PUT',
      url: `/api/v1/farms/farm-1/meals/${mealId}/ingredients`,
      headers: {
        authorization: `Bearer ${this.token}`,
        'content-type': 'application/json',
      },
      payload: {
        ingredients: [
          { feed_inventory_item_id: alfalfa.id, amount_kg: 9999 },
        ],
      },
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

Then(
  'inventory feed item {string} quantity kg is {int}',
  function (this: InventoryWorld, name: string, expected: number) {
    const items = getAtPath(this.lastResponse?.body, 'data') as
      | Array<{ name: string; quantity_kg: number }>
      | undefined;
    assert.ok(Array.isArray(items));
    const item = items.find((i) => i.name === name);
    assert.ok(item, `feed item not found: ${name}`);
    assert.equal(item.quantity_kg, expected);
  },
);

Then('inventory meal has low stock warning', function (this: InventoryWorld) {
  const warnings = getAtPath(this.lastResponse?.body, 'data.stock_warnings') as
    | Array<{ low_stock: boolean }>
    | undefined;
  assert.ok(Array.isArray(warnings) && warnings.length > 0);
  assert.ok(
    warnings.some((w) => w.low_stock),
    'expected at least one low_stock warning',
  );
});

Then(
  'inventory meal has insufficient stock warning',
  function (this: InventoryWorld) {
    const warnings = getAtPath(
      this.lastResponse?.body,
      'data.stock_warnings',
    ) as Array<{ insufficient_for_batch: boolean }> | undefined;
    assert.ok(Array.isArray(warnings) && warnings.length > 0);
    assert.ok(
      warnings.some((w) => w.insufficient_for_batch),
      'expected insufficient_for_batch warning',
    );
  },
);

Then(
  'inventory low stock feed count is at least {int}',
  function (this: InventoryWorld, min: number) {
    const items = getAtPath(this.lastResponse?.body, 'data.feed_items');
    const count =
      typeof getAtPath(this.lastResponse?.body, 'data.count') === 'number'
        ? (getAtPath(this.lastResponse?.body, 'data.count') as number)
        : Array.isArray(items)
          ? items.length
          : 0;
    assert.ok(count >= min, `expected low-stock count >= ${min}, got ${count}`);
  },
);
