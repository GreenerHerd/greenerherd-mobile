import type pg from 'pg';
import { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';
import { FeedPricingCatalog } from '@greenerherd/shared-db/feed-pricing-catalog';
import { NutritionRequirementsCatalog } from '@greenerherd/shared-db/nutrition-requirements-catalog';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';

export interface NutritionDataBootstrap {
  feedCatalog?: FeedCatalog;
  pricingCatalog?: FeedPricingCatalog;
  requirementsCatalog?: NutritionRequirementsCatalog;
  pool?: pg.Pool;
}

export interface NutritionBootstrapOverrides {
  feedCatalog?: FeedCatalog;
  pricingCatalog?: FeedPricingCatalog;
  requirementsCatalog?: NutritionRequirementsCatalog;
}

export async function bootstrapNutritionData(
  overrides: NutritionBootstrapOverrides = {},
): Promise<NutritionDataBootstrap> {
  if (overrides.feedCatalog) {
    return {
      feedCatalog: overrides.feedCatalog,
      pricingCatalog: overrides.pricingCatalog,
      requirementsCatalog: overrides.requirementsCatalog,
    };
  }

  if (!shouldUseDatabase()) {
    return { pricingCatalog: overrides.pricingCatalog };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  const feedCatalog = await FeedCatalog.load(pool);
  const pricingCatalog = await FeedPricingCatalog.load(pool);
  const requirementsCatalog = await NutritionRequirementsCatalog.load(pool);
  console.log(
    `[gh-api-nutrition] Loaded ${feedCatalog.size} feeds, ${pricingCatalog.size} prices, ${requirementsCatalog.size} requirement profiles`,
  );
  return { feedCatalog, pricingCatalog, requirementsCatalog, pool };
}
