import type pg from 'pg';
import { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';
import { InMemoryInventoryStore } from '../repositories/inventory-store.js';
import { hydrateInventoryStore } from './inventory-persistence.js';

export interface InventoryBootstrap {
  store: InMemoryInventoryStore;
  feedCatalog?: FeedCatalog;
  pool?: pg.Pool;
}

export interface InventoryBootstrapOverrides {
  store?: InMemoryInventoryStore;
  feedCatalog?: FeedCatalog;
}

export async function bootstrapInventoryData(
  overrides: InventoryBootstrapOverrides = {},
): Promise<InventoryBootstrap> {
  if (overrides.store) {
    return {
      store: overrides.store,
      feedCatalog: overrides.feedCatalog,
    };
  }

  const store = new InMemoryInventoryStore();

  if (!shouldUseDatabase()) {
    store.seedDemoFeed('farm-1');
    store.seedDemoMedical('farm-1');
    const morning = store.createMeal('farm-1', {
      name: 'Morning mix',
      description: 'Milking group ration',
    });
    const feeds = store.listFeed('farm-1');
    if (feeds.length >= 2) {
      store.addMealIngredient(morning.id, feeds[0]!.id, 60);
      store.addMealIngredient(morning.id, feeds[1]!.id, 25);
    }
    return { store };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  const feedCatalog = await FeedCatalog.load(pool);
  const feedCount = await pool.query(`SELECT COUNT(*)::int AS c FROM feed_inventory_items`);
  if (Number(feedCount.rows[0]?.c ?? 0) === 0) {
    store.seedDemoFeed('farm-1');
    store.seedDemoMedical('farm-1');
    const morning = store.createMeal('farm-1', {
      name: 'Morning mix',
      description: 'Milking group ration',
    });
    const feeds = store.listFeed('farm-1');
    if (feeds.length >= 2) {
      store.addMealIngredient(morning.id, feeds[0]!.id, 60);
      store.addMealIngredient(morning.id, feeds[1]!.id, 25);
    }
  } else {
    await hydrateInventoryStore(pool, store);
  }
  console.log(
    `[gh-api-inventory] Postgres mode: ${feedCatalog.size} catalogue feeds, ${store.feedItems.size} inventory rows`,
  );
  return { store, feedCatalog, pool };
}
