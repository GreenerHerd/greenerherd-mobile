import type { FeedRecommendationResult } from './feed-recommendation.js';

export interface NutrientGap {
  nutrient: string;
  target: number;
  actual: number;
  unit: string;
  percent_of_target: number;
  /** Positive when actual is below target */
  shortfall: number;
  bridge_note: string;
}

export interface CatalogAchievement {
  /** Minimum ratio across primary nutrients (DM, protein/CP, TDN/NEM) */
  primary_min_ratio: number;
  /** Highest nutrient-floor ratio used by the LP when provided */
  nutrient_floor_used?: number;
  /** True when any primary nutrient is more than 10% below requirement */
  needs_market_supplement: boolean;
}

const BRIDGE_NOTE =
  'Cover with market concentrates, mineral premixes, or local supplements as needed.';

function ratio(actual: number, target: number): number {
  if (target <= 0) return actual <= 0 ? 1 : Infinity;
  return actual / target;
}

export function computeNutrientGaps(
  result: FeedRecommendationResult,
): NutrientGap[] {
  const gaps: NutrientGap[] = [];
  const totals = result.recommendation.totals;
  const group = result.requirements.group;

  const addGap = (
    nutrient: string,
    target: number | undefined,
    actual: number | undefined,
    unit: string,
  ) => {
    if (target == null || target <= 0 || actual == null) return;
    const r = ratio(actual, target);
    const shortfall = Math.max(0, target - actual);
    if (shortfall <= target * 0.02) return;
    gaps.push({
      nutrient,
      target,
      actual,
      unit,
      percent_of_target: r,
      shortfall,
      bridge_note: BRIDGE_NOTE,
    });
  };

  if (result.requirements.optimizer === 'cattle') {
    const g = group as {
      dry_matter_kg: number;
      crude_protein_kg: number;
      calcium_kg: number;
      phosphorus_kg: number;
      nem_mcal?: number;
    };
    addGap(
      'dryMatter',
      g.dry_matter_kg,
      totals.dryMatterKg as number,
      'kg/day',
    );
    addGap(
      'crudeProtein',
      g.crude_protein_kg,
      totals.crudeProteinKg as number,
      'kg/day',
    );
    addGap('calcium', g.calcium_kg, totals.calciumKg as number, 'kg/day');
    addGap(
      'phosphorus',
      g.phosphorus_kg,
      totals.phosphorusKg as number,
      'kg/day',
    );
    if (g.nem_mcal != null && g.nem_mcal > 0) {
      addGap('nem', g.nem_mcal, totals.nemMcal as number, 'Mcal/day');
    }
  } else {
    const g = group as {
      dry_matter_kg: number;
      protein_kg: number;
      tdn_kg: number;
      calcium_g: number;
      phosphorus_g: number;
    };
    addGap(
      'dryMatter',
      g.dry_matter_kg,
      totals.dryMatterKg as number,
      'kg/day',
    );
    addGap('protein', g.protein_kg, totals.proteinKg as number, 'kg/day');
    addGap('tdn', g.tdn_kg, totals.tdnKg as number, 'kg/day');
    addGap(
      'calcium',
      g.calcium_g,
      (totals.calciumG as number) ?? (totals.calciumKg as number) * 1000,
      'g/day',
    );
    addGap(
      'phosphorus',
      g.phosphorus_g,
      (totals.phosphorusG as number) ?? (totals.phosphorusKg as number) * 1000,
      'g/day',
    );
  }

  return gaps.sort(
    (a, b) => a.percent_of_target - b.percent_of_target,
  );
}

function primaryNutrientRatios(result: FeedRecommendationResult): number[] {
  const totals = result.recommendation.totals;
  const group = result.requirements.group;
  const ratios: number[] = [];

  if (result.requirements.optimizer === 'cattle') {
    const g = group as {
      dry_matter_kg: number;
      crude_protein_kg: number;
      nem_mcal?: number;
    };
    ratios.push(ratio(totals.dryMatterKg as number, g.dry_matter_kg));
    ratios.push(ratio(totals.crudeProteinKg as number, g.crude_protein_kg));
    if (g.nem_mcal != null && g.nem_mcal > 0) {
      ratios.push(ratio(totals.nemMcal as number, g.nem_mcal));
    }
  } else {
    const g = group as {
      dry_matter_kg: number;
      protein_kg: number;
      tdn_kg: number;
    };
    ratios.push(ratio(totals.dryMatterKg as number, g.dry_matter_kg));
    ratios.push(ratio(totals.proteinKg as number, g.protein_kg));
    ratios.push(ratio(totals.tdnKg as number, g.tdn_kg));
  }

  return ratios.filter((r) => Number.isFinite(r));
}

export function summarizeCatalogAchievement(
  result: FeedRecommendationResult,
  gaps: NutrientGap[],
  options: { nutrient_floor_used?: number } = {},
): CatalogAchievement {
  const ratios = primaryNutrientRatios(result);
  const primary_min_ratio =
    ratios.length > 0 ? Math.min(...ratios) : 1;
  return {
    primary_min_ratio,
    nutrient_floor_used: options.nutrient_floor_used,
    needs_market_supplement:
      primary_min_ratio < 0.9 || gaps.some((g) => g.shortfall > 0),
  };
}
