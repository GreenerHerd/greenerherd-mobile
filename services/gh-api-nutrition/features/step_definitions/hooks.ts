import { After, Before } from '@cucumber/cucumber';
import { loadBddFeedCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-feed-catalog';
import { loadBddFeedPricingCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-feed-pricing-catalog';
import { loadBddNutritionRequirementsCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-nutrition-requirements-catalog';
import { buildApp } from '../../src/app.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  const feedCatalog = loadBddFeedCatalog();
  const pricingCatalog = loadBddFeedPricingCatalog();
  const requirementsCatalog = loadBddNutritionRequirementsCatalog();
  const { app, nutritionService } = await buildApp({
    feedCatalog,
    pricingCatalog,
    requirementsCatalog,
  });
  this.app = app;
  this.nutritionService = nutritionService;
  this.feedCatalog = feedCatalog;
  this.pricingCatalog = pricingCatalog;
  this.lastResponse = undefined;
  this.saved = {};
});

After(async function (this: ApiWorld) {
  await this.app.close();
});
