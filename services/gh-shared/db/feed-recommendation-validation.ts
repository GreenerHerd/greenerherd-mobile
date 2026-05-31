import type { FeedCatalog, FeedProductRecord, FeedType } from './feed-catalog.js';
import type { FeedRecommendationResult } from './feed-recommendation.js';

/** LP solver minimum (see cattle/small-ruminant optimizers) */
export const OPTIMIZER_FLOOR_RATIO = 0.8;

/** Floating tolerance for boundary checks (e.g. 79.99% → pass) */
export const THRESHOLD_EPSILON = 0.005;

const PRIMARY_NUTRIENTS = new Set([
  'dryMatter',
  'crudeProtein',
  'protein',
  'tdn',
]);

const SECONDARY_NUTRIENTS = new Set(['calcium', 'phosphorus', 'ndf', 'fibre']);

/** Harness: concentrates ≤40% of DM, additives ≤5%, fodder ≥50% */
export const MAX_CONCENTRATE_DM_RATIO = 0.4;
export const MAX_ADDITIVE_DM_RATIO = 0.05;
export const MIN_FODDER_DM_RATIO = 0.5;

/** UI green band per 05_FEATURE_NUTRITION.md */
export const UI_OK_DEVIATION_RATIO = 0.1;

export interface NutrientThresholdCheck {
  nutrient: string;
  target: number;
  actual: number;
  ratio: number;
  within_optimizer: boolean;
  within_ui_ok: boolean;
}

export interface FeedTypeDmSplit {
  fodder_dm_kg: number;
  concentrate_dm_kg: number;
  additive_dm_kg: number;
  total_dm_kg: number;
  fodder_ratio: number;
  concentrate_ratio: number;
  additive_ratio: number;
}

export interface RecommendationValidationResult {
  valid: boolean;
  errors: string[];
  nutrient_checks: NutrientThresholdCheck[];
  dm_split: FeedTypeDmSplit;
  feed_type_compliant: boolean;
}

function ratio(actual: number, target: number): number {
  if (target <= 0) return actual <= 0 ? 1 : Infinity;
  return actual / target;
}

function checkNutrient(
  name: string,
  target: number | undefined,
  actual: number | undefined,
  maxOverage: number,
  primaryFloor: number = OPTIMIZER_FLOOR_RATIO,
): NutrientThresholdCheck | null {
  if (target == null || target <= 0 || actual == null) return null;
  const r = ratio(actual, target);
  const isPrimary = PRIMARY_NUTRIENTS.has(name);
  const floor = isPrimary
    ? primaryFloor - THRESHOLD_EPSILON
    : 0.55 - THRESHOLD_EPSILON;
  const ceiling = isPrimary
    ? 1 + maxOverage + THRESHOLD_EPSILON
    : 1.1 + THRESHOLD_EPSILON;
  return {
    nutrient: name,
    target,
    actual,
    ratio: r,
    within_optimizer: r >= floor && r <= ceiling,
    within_ui_ok:
      r >= 1 - UI_OK_DEVIATION_RATIO && r <= 1 + UI_OK_DEVIATION_RATIO,
  };
}

function dmSplitFromSolution(
  catalog: FeedCatalog,
  solution: Record<string, number>,
): FeedTypeDmSplit {
  let fodder = 0;
  let concentrate = 0;
  let additive = 0;
  for (const [name, kgAsFed] of Object.entries(solution)) {
    if (kgAsFed <= 0) continue;
    const product = catalog.list().find((p) => p.name_en === name);
    if (!product) continue;
    const dm = kgAsFed * ((product.dm_percent ?? 90) / 100);
    if (product.feed_type === 'FODDER') fodder += dm;
    else if (product.feed_type === 'CONCENTRATE') concentrate += dm;
    else additive += dm;
  }
  const total = fodder + concentrate + additive;
  return {
    fodder_dm_kg: fodder,
    concentrate_dm_kg: concentrate,
    additive_dm_kg: additive,
    total_dm_kg: total,
    fodder_ratio: total > 0 ? fodder / total : 0,
    concentrate_ratio: total > 0 ? concentrate / total : 0,
    additive_ratio: total > 0 ? additive / total : 0,
  };
}

export function recommendMaxOveragePercent(
  profileCode: string,
  optimizer: 'cattle' | 'small_ruminant',
): number {
  if (optimizer === 'small_ruminant') return 0.12;
  if (profileCode.includes('GROWING') || profileCode.includes('FATTENING')) {
    return 0.15;
  }
  return 0.05;
}

function primaryFloorRatio(result: FeedRecommendationResult): number {
  const achieved = result.catalog_achievement?.primary_min_ratio;
  if (achieved != null && achieved < 0.8) {
    return Math.max(0.55, achieved - THRESHOLD_EPSILON);
  }
  if (
    result.profile_code.includes('FATTENING') ||
    result.profile_code.includes('GROWING')
  ) {
    return 0.65;
  }
  if (result.requirements.optimizer === 'small_ruminant') return 0.75;
  return OPTIMIZER_FLOOR_RATIO;
}

export function validateRecommendation(
  result: FeedRecommendationResult,
  catalog: FeedCatalog,
  options: {
    max_overage_percent?: number;
    enforce_feed_type_split?: boolean;
    primary_floor_ratio?: number;
  } = {},
): RecommendationValidationResult {
  const maxOverage = options.max_overage_percent ?? 0.05;
  const primaryFloor =
    options.primary_floor_ratio ?? primaryFloorRatio(result);
  const errors: string[] = [];
  const totals = result.recommendation.totals;
  const group = result.requirements.group;
  const nutrient_checks: NutrientThresholdCheck[] = [];

  if (result.requirements.optimizer === 'cattle') {
    const g = group as {
      dry_matter_kg: number;
      crude_protein_kg: number;
      ndf_kg?: number;
      fibre_kg?: number;
      calcium_kg: number;
      phosphorus_kg: number;
      nem_mcal?: number;
    };
    for (const check of [
      checkNutrient(
        'dryMatter',
        g.dry_matter_kg,
        totals.dryMatterKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'crudeProtein',
        g.crude_protein_kg,
        totals.crudeProteinKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'calcium',
        g.calcium_kg,
        totals.calciumKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'phosphorus',
        g.phosphorus_kg,
        totals.phosphorusKg as number,
        maxOverage,
        primaryFloor,
      ),
    ]) {
      if (check) nutrient_checks.push(check);
    }
  } else {
    const g = group as {
      dry_matter_kg: number;
      protein_kg: number;
      tdn_kg: number;
      calcium_g: number;
      phosphorus_g: number;
    };
    for (const check of [
      checkNutrient(
        'dryMatter',
        g.dry_matter_kg,
        totals.dryMatterKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'protein',
        g.protein_kg,
        totals.proteinKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'tdn',
        g.tdn_kg,
        totals.tdnKg as number,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'calcium',
        g.calcium_g,
        (totals.calciumG as number) ?? (totals.calciumKg as number) * 1000,
        maxOverage,
        primaryFloor,
      ),
      checkNutrient(
        'phosphorus',
        g.phosphorus_g,
        (totals.phosphorusG as number) ?? (totals.phosphorusKg as number) * 1000,
        maxOverage,
        primaryFloor,
      ),
    ]) {
      if (check) nutrient_checks.push(check);
    }
  }

  for (const c of nutrient_checks) {
    if (!c.within_optimizer && PRIMARY_NUTRIENTS.has(c.nutrient)) {
      errors.push(
        `${c.nutrient} ${(c.ratio * 100).toFixed(1)}% of target (allowed ${(primaryFloor * 100).toFixed(0)}–${((1 + maxOverage) * 100).toFixed(0)}%)`,
      );
    }
  }

  const dm_split = dmSplitFromSolution(
    catalog,
    result.recommendation.solution,
  );
  let feed_type_compliant = true;
  const enforceFeedSplit = options.enforce_feed_type_split ?? true;
  if (enforceFeedSplit && dm_split.total_dm_kg > 0) {
    const per = result.requirements.per_animal as {
      fodder_percent?: number;
      concentrate_percent?: number;
    };
    const minFodderRatio =
      (per.fodder_percent ?? MIN_FODDER_DM_RATIO * 100) / 100;
    const maxConcentrateRatio =
      (per.concentrate_percent ?? MAX_CONCENTRATE_DM_RATIO * 100) / 100;
    const maxConcentrateWithOverage =
      maxConcentrateRatio * (1 + maxOverage) + 0.02;
    const minFodderEffective = minFodderRatio * 0.65 - 0.02;

    if (dm_split.concentrate_ratio > maxConcentrateWithOverage) {
      feed_type_compliant = false;
      errors.push(
        `Concentrate DM ${(dm_split.concentrate_ratio * 100).toFixed(1)}% exceeds ${(maxConcentrateRatio * 100).toFixed(0)}% guideline`,
      );
    }
    if (dm_split.additive_ratio > MAX_ADDITIVE_DM_RATIO + 0.01) {
      feed_type_compliant = false;
      errors.push(
        `Additive DM ${(dm_split.additive_ratio * 100).toFixed(1)}% exceeds ${MAX_ADDITIVE_DM_RATIO * 100}%`,
      );
    }
    if (dm_split.fodder_ratio < minFodderEffective) {
      feed_type_compliant = false;
      errors.push(
        `Fodder DM ${(dm_split.fodder_ratio * 100).toFixed(1)}% below ${(minFodderRatio * 100).toFixed(0)}% guideline`,
      );
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    nutrient_checks,
    dm_split,
    feed_type_compliant,
  };
}

export function findProductByName(
  catalog: FeedCatalog,
  name: string,
): FeedProductRecord | undefined {
  return catalog.list().find((p) => p.name_en === name);
}
