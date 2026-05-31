import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { loadBddFeedCatalog } from '../test-fixtures/bdd-feed-catalog.js';
import { loadBddFeedPricingCatalog } from '../test-fixtures/bdd-feed-pricing-catalog.js';
import { loadBddNutritionRequirementsCatalog } from '../test-fixtures/bdd-nutrition-requirements-catalog.js';
import { recommendFeedPlan } from '../db/feed-recommendation.js';
import { resolveNutritionProfile } from '../db/nutrition-profile-resolver.js';

describe('nutrition profile resolver', () => {
  it('maps lactating dairy cattle to early lactation profile', () => {
    const catalog = loadBddNutritionRequirementsCatalog();
    const resolved = resolveNutritionProfile(catalog, {
      species: 'CATTLE',
      age_months: 48,
      production_focus: 'MILK',
      lactating: true,
      months_since_calving: 2,
    });
    assert.equal(resolved.profile_code, 'CATTLE_DAIRY_COW_EARLY');
  });
});

describe('feed recommendation', () => {
  it('returns a feasible cattle mix with cost', () => {
    const result = recommendFeedPlan(
      loadBddFeedCatalog(),
      loadBddNutritionRequirementsCatalog(),
      loadBddFeedPricingCatalog(),
      {
        species: 'CATTLE',
        age_months: 48,
        production_focus: 'MILK',
        lactating: true,
        months_since_calving: 2,
        head_count: 10,
        country_code: 'SA',
      },
    );
    assert.equal(result.optimizer_pass, 'complete');
    assert.ok(result.recommendation.cost_per_day > 0);
    assert.ok(Object.keys(result.recommendation.solution).length > 0);
  });
});
