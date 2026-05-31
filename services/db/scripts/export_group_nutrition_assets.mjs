#!/usr/bin/env node
/**
 * Generates assets/data/group_nutrition/{groupId}.json for Flutter offline engine.
 * Run: npm run db:export-group-nutrition  (from services/db)
 */
import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadBddFeedCatalog } from '../../gh-shared/test-fixtures/bdd-feed-catalog.ts';
import { loadBddFeedPricingCatalog } from '../../gh-shared/test-fixtures/bdd-feed-pricing-catalog.ts';
import { loadBddNutritionRequirementsCatalog } from '../../gh-shared/test-fixtures/bdd-nutrition-requirements-catalog.ts';
import {
  getGroupNutrition,
  solutionToFeedPlanLines,
} from '../../gh-shared/db/group-nutrition-status.ts';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '../../..');
const outDir = join(repoRoot, 'assets/data/group_nutrition');

const profiles = [
  {
    groupId: 'g1',
    current_intake_ratio: 0.76,
    request: {
      species: 'CATTLE',
      age_months: 48,
      production_focus: 'MILK',
      lactating: true,
      months_since_calving: 2,
      head_count: 22,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g2',
    current_intake_ratio: 0.95,
    request: {
      species: 'CATTLE',
      age_months: 37,
      production_focus: 'BOTH',
      lactating: false,
      pregnant: false,
      head_count: 8,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g3',
    current_intake_ratio: 0.92,
    request: {
      species: 'CATTLE',
      age_months: 54,
      production_focus: 'MILK',
      lactating: false,
      pregnant: true,
      head_count: 6,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g4',
    current_intake_ratio: 0.8,
    request: {
      species: 'CATTLE',
      age_months: 8,
      production_focus: 'MEAT',
      lactating: false,
      head_count: 6,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g5',
    current_intake_ratio: 0.88,
    request: {
      species: 'GOAT',
      age_months: 24,
      production_focus: 'MILK',
      lactating: false,
      head_count: 48,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g6',
    current_intake_ratio: 0.9,
    request: {
      species: 'GOAT',
      age_months: 24,
      production_focus: 'MILK',
      lactating: false,
      pregnant: true,
      head_count: 22,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g7',
    current_intake_ratio: 0.85,
    request: {
      species: 'GOAT',
      age_months: 12,
      production_focus: 'MEAT',
      lactating: false,
      fattening: true,
      head_count: 26,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g8',
    current_intake_ratio: 0.9,
    request: {
      species: 'SHEEP',
      age_months: 32,
      production_focus: 'MEAT',
      lactating: false,
      head_count: 32,
      country_code: 'SA',
    },
  },
  {
    groupId: 'g9',
    current_intake_ratio: 0.75,
    request: {
      species: 'SHEEP',
      age_months: 38,
      production_focus: 'MEAT',
      lactating: false,
      head_count: 14,
      country_code: 'SA',
    },
  },
];

const feedCatalog = loadBddFeedCatalog();
const pricingCatalog = loadBddFeedPricingCatalog();
const requirementsCatalog = loadBddNutritionRequirementsCatalog();

mkdirSync(outDir, { recursive: true });

for (const { groupId, request, current_intake_ratio } of profiles) {
  const status = getGroupNutrition(
    feedCatalog,
    requirementsCatalog,
    pricingCatalog,
    groupId,
    request,
    { current_intake_ratio },
  );
  const feed_lines = solutionToFeedPlanLines(feedCatalog, status.recommendation);
  const payload = { ...status, feed_lines };
  writeFileSync(
    join(outDir, `${groupId}.json`),
    `${JSON.stringify(payload, null, 2)}\n`,
  );
  console.log(`Wrote ${groupId}.json (${status.optimizer_pass})`);
}
