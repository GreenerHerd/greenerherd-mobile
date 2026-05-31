#!/usr/bin/env node
/**
 * Export gh-shared NUTRITION_BDD_SCENARIOS → mobile assets/data/nutrition_bdd_scenarios.json
 * Run from repo root: node services/db/scripts/export_nutrition_bdd_scenarios.mjs
 */
import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { NUTRITION_BDD_SCENARIOS } from '../../gh-shared/db/nutrition-bdd-scenarios.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '../../..');
const out = join(root, 'assets/data/nutrition_bdd_scenarios.json');
writeFileSync(
  out,
  JSON.stringify(
    {
      version: 1,
      scenario_count: NUTRITION_BDD_SCENARIOS.length,
      scenarios: NUTRITION_BDD_SCENARIOS,
    },
    null,
    2,
  ) + '\n',
);
console.log(`Wrote ${NUTRITION_BDD_SCENARIOS.length} scenarios → ${out}`);
