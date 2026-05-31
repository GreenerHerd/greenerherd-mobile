import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import { InventoryService } from './services/inventory-service.js';
import { inventoryRoutes } from './routes/inventory.js';
import { mealRoutes } from './routes/meals.js';
import { referenceRoutes } from './routes/reference.js';
import {
  bootstrapInventoryData,
  type InventoryBootstrapOverrides,
} from './db/bootstrap.js';

export interface AppOptions extends InventoryBootstrapOverrides {
  jwtSecret?: string;
  seedDemo?: boolean;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const { store, feedCatalog, pool } = await bootstrapInventoryData({
    store: options.store,
    feedCatalog: options.feedCatalog,
  });
  const inventoryService = new InventoryService(store, pool);

  const app = Fastify({ logger: createFastifyLogger('gh-api-inventory') });
  await app.register(cors, { origin: true });

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send(errorBody(error.code, error.message));
    }
    return reply.status(500).send(errorBody('INTERNAL_ERROR', error.message));
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'gh-api-inventory',
    storage: pool ? 'postgres' : 'memory',
    feed_items: store.listFeed('farm-1').length,
    catalogue_feeds: feedCatalog?.size ?? 0,
  }));

  if (feedCatalog) {
    await referenceRoutes(app, feedCatalog);
  }

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await inventoryRoutes(scoped, inventoryService);
    await mealRoutes(scoped, inventoryService);
  });

  return { app, inventoryService, store, secret, pool, feedCatalog };
}
