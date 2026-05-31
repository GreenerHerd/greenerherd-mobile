import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import type { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';
import type { FeedPricingCatalog } from '@greenerherd/shared-db/feed-pricing-catalog';
import { AppError, errorBody } from './lib/errors.js';
import {
  bootstrapNutritionData,
  type NutritionBootstrapOverrides,
} from './db/bootstrap.js';
import { NutritionService } from './services/nutrition-service.js';
import { feedRoutes } from './routes/feeds.js';
import { eligibilityRoutes } from './routes/eligibility.js';
import { groupNutritionRoutes } from './routes/group-nutrition.js';
import { pricingRoutes } from './routes/pricing.js';
import { InMemoryFeedPlanRepository } from './repositories/in-memory-feed-plan-repository.js';
import { PostgresFeedPlanRepository } from './repositories/postgres-feed-plan-repository.js';

export interface AppOptions extends NutritionBootstrapOverrides {}

export async function buildApp(options: AppOptions = {}) {
  const { feedCatalog, pricingCatalog, requirementsCatalog, pool } =
    await bootstrapNutritionData(options);
  if (!feedCatalog) {
    throw new Error('Feed catalog is required for gh-api-nutrition');
  }

  const nutritionService = new NutritionService(
    feedCatalog,
    pricingCatalog,
    requirementsCatalog,
  );
  const feedPlanRepo = pool
    ? new PostgresFeedPlanRepository(pool)
    : new InMemoryFeedPlanRepository();
  const app = Fastify({ logger: createFastifyLogger('gh-api-nutrition') });
  await app.register(cors, { origin: true });

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send(errorBody(error.code, error.message));
    }
    const statusCode =
      typeof error === 'object' &&
      error !== null &&
      'statusCode' in error &&
      typeof (error as { statusCode: number }).statusCode === 'number'
        ? (error as { statusCode: number }).statusCode
        : 500;
    if (statusCode === 400) {
      return reply
        .status(400)
        .send(errorBody('VALIDATION_ERROR', error.message ?? 'Bad request'));
    }
    return reply.status(500).send(errorBody('INTERNAL_ERROR', error.message));
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'gh-api-nutrition',
    storage: pool ? 'postgres' : 'memory+feeds',
    feeds_loaded: feedCatalog.size,
    feeds_by_type: feedCatalog.countsByType(),
    indicative_prices_loaded: pricingCatalog?.size ?? 0,
    optimizer: requirementsCatalog ? 'ready' : 'pending',
    requirement_profiles_loaded: requirementsCatalog?.size ?? 0,
  }));

  await pricingRoutes(app, nutritionService);
  await feedRoutes(app, nutritionService);
  await eligibilityRoutes(app, nutritionService);
  await groupNutritionRoutes(app, nutritionService, feedPlanRepo);

  return { app, nutritionService, feedCatalog, pricingCatalog, pool, feedPlanRepo };
}
