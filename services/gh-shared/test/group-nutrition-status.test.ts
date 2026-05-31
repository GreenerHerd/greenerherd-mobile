import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { loadBddFeedCatalog } from '../test-fixtures/bdd-feed-catalog.js';
import { loadBddFeedPricingCatalog } from '../test-fixtures/bdd-feed-pricing-catalog.js';
import { loadBddNutritionRequirementsCatalog } from '../test-fixtures/bdd-nutrition-requirements-catalog.js';
import {
  buildGroupNutritionStatus,
  getGroupNutrition,
  solutionToFeedPlanLines,
} from '../db/group-nutrition-status.js';
import { recommendFeedPlan } from '../db/feed-recommendation.js';

describe('group nutrition status', () => {
  it('builds required and plan totals from recommendation', () => {
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
    const status = buildGroupNutritionStatus('g1', result, {
      current_intake_ratio: 0.76,
    });
    assert.equal(status.group_id, 'g1');
    assert.ok(status.required.dry_matter_kg > 0);
    assert.ok(status.plan.dry_matter_kg > 0);
    assert.ok(status.current);
    assert.ok(status.current!.dry_matter_kg < status.required.dry_matter_kg);
    assert.equal(status.optimizer_pass, result.optimizer_pass);
  });

  it('returns feed plan lines from solution', () => {
    const catalog = loadBddFeedCatalog();
    const result = recommendFeedPlan(
      catalog,
      loadBddNutritionRequirementsCatalog(),
      loadBddFeedPricingCatalog(),
      {
        species: 'GOAT',
        age_months: 24,
        production_focus: 'MILK',
        lactating: true,
        head_count: 5,
        country_code: 'SA',
      },
    );
    const lines = solutionToFeedPlanLines(catalog, result.recommendation);
    assert.ok(lines.length > 0);
    assert.ok(lines.every((l) => l.kg_per_day > 0));
  });

  it('getGroupNutrition wraps recommend + status', () => {
    const status = getGroupNutrition(
      loadBddFeedCatalog(),
      loadBddNutritionRequirementsCatalog(),
      loadBddFeedPricingCatalog(),
      'herd-1',
      {
        species: 'CATTLE',
        age_months: 48,
        production_focus: 'MILK',
        lactating: true,
        months_since_calving: 2,
        head_count: 10,
      },
    );
    assert.equal(status.group_id, 'herd-1');
    assert.ok(status.recommendation.solution);
  });
});
