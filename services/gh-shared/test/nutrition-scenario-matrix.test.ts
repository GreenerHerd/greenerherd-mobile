import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { loadBddFeedCatalog } from '../test-fixtures/bdd-feed-catalog.js';
import { loadBddFeedPricingCatalog } from '../test-fixtures/bdd-feed-pricing-catalog.js';
import { loadBddNutritionRequirementsCatalog } from '../test-fixtures/bdd-nutrition-requirements-catalog.js';
import { recommendFeedPlan } from '../db/feed-recommendation.js';
import { resolveNutritionProfile } from '../db/nutrition-profile-resolver.js';
import { validateRecommendation } from '../db/feed-recommendation-validation.js';
import { NUTRITION_BDD_SCENARIOS } from '../db/nutrition-bdd-scenarios.js';

describe('nutrition BDD scenario matrix', () => {
  const feedCatalog = loadBddFeedCatalog();
  const pricingCatalog = loadBddFeedPricingCatalog();
  const requirementsCatalog = loadBddNutritionRequirementsCatalog();

  for (const scenario of NUTRITION_BDD_SCENARIOS) {
    it(`${scenario.id}: ${scenario.name}`, () => {
      const resolved = resolveNutritionProfile(
        requirementsCatalog,
        scenario.request,
      );
      assert.equal(
        resolved.profile_code,
        scenario.expected_profile_code,
        `profile mismatch for ${scenario.id}`,
      );

      if (!scenario.expect_success) {
        assert.throws(
          () =>
            recommendFeedPlan(
              feedCatalog,
              requirementsCatalog,
              pricingCatalog,
              scenario.request,
            ),
          (err: Error) =>
            err.message.includes('No feasible') ||
            err.message.includes('Infeasible'),
        );
        return;
      }

      const result = recommendFeedPlan(
        feedCatalog,
        requirementsCatalog,
        pricingCatalog,
        scenario.request,
      );
      assert.ok(
        result.optimizer_pass === 'complete' ||
          result.optimizer_pass === 'partial',
        `unexpected optimizer_pass for ${scenario.id}`,
      );
      assert.ok(
        Array.isArray(result.nutrient_gaps),
        'expected nutrient_gaps on recommendation',
      );
      if (result.catalog_achievement.needs_market_supplement) {
        assert.ok(
          result.nutrient_gaps.length > 0,
          `${scenario.id}: gaps should be listed when supplements needed`,
        );
      }
      const isSpecial =
        result.profile_code.includes('FATTENING') ||
        result.profile_code.includes('GROWING');
      const maxOverage =
        scenario.request.overage_percent ??
        (result.requirements.optimizer === 'small_ruminant'
          ? 0.12
          : isSpecial
            ? 0.15
            : 0.05);
      const validation = validateRecommendation(result, feedCatalog, {
        max_overage_percent: maxOverage,
        enforce_feed_type_split: true,
      });
      assert.ok(
        validation.valid,
        `${scenario.id} validation failed: ${validation.errors.join('; ')}`,
      );
    });
  }
});
