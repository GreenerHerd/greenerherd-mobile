import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';
import type { FeedPricingCatalog } from '@greenerherd/shared-db/feed-pricing-catalog';
import type { NutritionService } from '../../src/services/nutrition-service.js';

export class ApiWorld extends World {
  app!: FastifyInstance;
  nutritionService!: NutritionService;
  feedCatalog?: FeedCatalog;
  pricingCatalog?: FeedPricingCatalog;
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string> = {};
  /** Set by nutrition matrix step for threshold validation */
  matrixScenarioId?: string;
}

setWorldConstructor(ApiWorld);
