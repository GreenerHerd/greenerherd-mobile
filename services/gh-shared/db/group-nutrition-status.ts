import type { FeedCatalog } from './feed-catalog.js';
import type {
  FeedRecommendationRequest,
  FeedRecommendationResult,
} from './feed-recommendation.js';
import { recommendFeedPlan } from './feed-recommendation.js';
import type { FeedPricingCatalog } from './feed-pricing-catalog.js';
import type { NutritionRequirementsCatalog } from './nutrition-requirements-catalog.js';
import type { NutrientGap } from './feed-recommendation-gaps.js';

export interface NutrientAmounts {
  dry_matter_kg: number;
  energy_mj: number;
  protein_kg: number;
  ndf_kg?: number;
}

export interface GroupNutritionStatus {
  group_id: string;
  profile_code: string;
  match_reason: string;
  head_count: number;
  required: NutrientAmounts;
  /** Totals delivered by the optimized catalog plan */
  plan: NutrientAmounts;
  /** What the group is currently fed (optional until feeding records exist) */
  current?: NutrientAmounts;
  optimizer_pass: FeedRecommendationResult['optimizer_pass'];
  nutrient_gaps: NutrientGap[];
  catalog_achievement: FeedRecommendationResult['catalog_achievement'];
  recommendation: FeedRecommendationResult['recommendation'];
  eligible_count: number;
}

export interface GroupNutritionOptions {
  /** Scale plan totals to approximate current intake (0–1). Ignored if current_totals set. */
  current_intake_ratio?: number;
  current_totals?: Partial<NutrientAmounts>;
}

function cattleEnergyMj(group: Record<string, number>): number {
  const nem = group.nem_mcal ?? 0;
  return nem * 4.184;
}

function smallRuminantEnergyMj(group: Record<string, number>): number {
  const tdn = group.tdn_kg ?? 0;
  return tdn * 11.5;
}

export function nutrientAmountsFromRequirements(
  result: FeedRecommendationResult,
): NutrientAmounts {
  const group = result.requirements.group as Record<string, number>;
  if (result.requirements.optimizer === 'cattle') {
    return {
      dry_matter_kg: group.dry_matter_kg ?? 0,
      protein_kg: group.crude_protein_kg ?? 0,
      energy_mj: cattleEnergyMj(group),
      ndf_kg: group.ndf_kg,
    };
  }
  return {
    dry_matter_kg: group.dry_matter_kg ?? 0,
    protein_kg: group.protein_kg ?? 0,
    energy_mj: smallRuminantEnergyMj(group),
  };
}

export function nutrientAmountsFromTotals(
  result: FeedRecommendationResult,
): NutrientAmounts {
  const totals = result.recommendation.totals;
  if (result.requirements.optimizer === 'cattle') {
    const nem = Number(totals.nemMcal ?? totals.NEm ?? 0);
    return {
      dry_matter_kg: Number(totals.dryMatterKg ?? 0),
      protein_kg: Number(totals.crudeProteinKg ?? totals.CP ?? 0),
      energy_mj: nem * 4.184,
      ndf_kg: Number(totals.ndfKg ?? totals.NDF ?? 0) || undefined,
    };
  }
  const tdn = Number(totals.tdnKg ?? totals.TDN ?? 0);
  return {
    dry_matter_kg: Number(totals.dryMatterKg ?? 0),
    protein_kg: Number(totals.proteinKg ?? totals.protein ?? 0),
    energy_mj: tdn * 11.5,
  };
}

function scaleAmounts(
  base: NutrientAmounts,
  ratio: number,
): NutrientAmounts {
  const r = Math.max(0, Math.min(1, ratio));
  return {
    dry_matter_kg: base.dry_matter_kg * r,
    protein_kg: base.protein_kg * r,
    energy_mj: base.energy_mj * r,
    ndf_kg: base.ndf_kg != null ? base.ndf_kg * r : undefined,
  };
}

export function buildGroupNutritionStatus(
  groupId: string,
  result: FeedRecommendationResult,
  options: GroupNutritionOptions = {},
): GroupNutritionStatus {
  const required = nutrientAmountsFromRequirements(result);
  const plan = nutrientAmountsFromTotals(result);

  let current: NutrientAmounts | undefined;
  if (options.current_totals) {
    current = {
      dry_matter_kg:
        options.current_totals.dry_matter_kg ?? plan.dry_matter_kg * 0.85,
      protein_kg: options.current_totals.protein_kg ?? plan.protein_kg * 0.85,
      energy_mj: options.current_totals.energy_mj ?? plan.energy_mj * 0.85,
      ndf_kg: options.current_totals.ndf_kg,
    };
  } else if (options.current_intake_ratio != null) {
    current = scaleAmounts(required, options.current_intake_ratio);
  }

  return {
    group_id: groupId,
    profile_code: result.profile_code,
    match_reason: result.match_reason,
    head_count: result.head_count,
    required,
    plan,
    current,
    optimizer_pass: result.optimizer_pass,
    nutrient_gaps: result.nutrient_gaps,
    catalog_achievement: result.catalog_achievement,
    recommendation: result.recommendation,
    eligible_count: result.eligible_count,
  };
}

export function getGroupNutrition(
  feedCatalog: FeedCatalog,
  requirementsCatalog: NutritionRequirementsCatalog,
  pricingCatalog: FeedPricingCatalog | undefined,
  groupId: string,
  request: FeedRecommendationRequest,
  options: GroupNutritionOptions = {},
): GroupNutritionStatus {
  const result = recommendFeedPlan(
    feedCatalog,
    requirementsCatalog,
    pricingCatalog,
    request,
  );
  return buildGroupNutritionStatus(groupId, result, options);
}

export interface FeedPlanLine {
  product_number: number | null;
  name: string;
  kg_per_day: number;
  cost_per_day: number;
  feed_type: string | null;
}

export function solutionToFeedPlanLines(
  feedCatalog: FeedCatalog,
  recommendation: {
    solution: Record<string, number>;
    cost_per_day: number;
  },
): FeedPlanLine[] {
  const solution = recommendation.solution;
  const totalKg = Object.values(solution).reduce((a, b) => a + b, 0);
  const totalCost = recommendation.cost_per_day;
  const lines: FeedPlanLine[] = [];

  for (const [name, kg] of Object.entries(solution)) {
    if (kg <= 0) continue;
    const product = feedCatalog
      .list()
      .find((p) => p.name_en === name || p.name_en.toLowerCase() === name.toLowerCase());
    const share = totalKg > 0 ? kg / totalKg : 0;
    lines.push({
      product_number: product?.product_number ?? null,
      name,
      kg_per_day: kg,
      cost_per_day: totalCost * share,
      feed_type: product?.feed_type ?? null,
    });
  }

  lines.sort((a, b) => b.kg_per_day - a.kg_per_day);
  return lines;
}
