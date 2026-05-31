import type { FeedCatalog } from './feed-catalog.js';
import { findEligibleFeeds, type FeedEligibilityContext } from './feed-eligibility.js';
import type { FeedPricingCatalog } from './feed-pricing-catalog.js';
import {
  buildCattleOptimizerRequirements,
  buildSmallRuminantOptimizerRequirements,
  productToOptimizerFeed,
} from './feed-optimizer-bridge.js';
import {
  buildGroupRequirements,
  resolveNutritionProfile,
  type NutritionProfileContext,
} from './nutrition-profile-resolver.js';
import type { NutritionRequirementsCatalog } from './nutrition-requirements-catalog.js';
import {
  optimizeCattleFeedMix,
  optimizeSmallRuminantFeedMix,
} from '../optimizers/index.js';
import {
  computeNutrientGaps,
  summarizeCatalogAchievement,
  type CatalogAchievement,
  type NutrientGap,
} from './feed-recommendation-gaps.js';

export interface FeedRecommendationRequest extends NutritionProfileContext {
  head_count?: number;
  country_code?: string;
  overage_percent?: number;
  /**
   * Optional user selection: when provided and non-empty, the optimizer will
   * only consider eligible feeds whose `product_number` is in this list.
   *
   * This enables "product-suggestions agent" style flows where users can
   * accept/deselect recommended feeds and the optimizer updates accordingly.
   */
  included_product_numbers?: number[];
}

export interface FeedRecommendationResult {
  context: FeedEligibilityContext;
  head_count: number;
  profile_code: string;
  match_reason: string;
  requirements: ReturnType<typeof buildGroupRequirements>;
  eligible_count: number;
  recommendation: {
    solution: Record<string, number>;
    totals: Record<string, number>;
    cost_per_day: number;
    cost_currency: string;
    constraints?: Record<string, unknown>;
  };
  optimizer_pass: 'complete' | 'partial';
  nutrient_gaps: NutrientGap[];
  catalog_achievement: CatalogAchievement;
}

export function recommendFeedPlan(
  feedCatalog: FeedCatalog,
  requirementsCatalog: NutritionRequirementsCatalog,
  pricingCatalog: FeedPricingCatalog | undefined,
  request: FeedRecommendationRequest,
): FeedRecommendationResult {
  const headCount = Math.max(1, request.head_count ?? 1);
  const eligibility = findEligibleFeeds(feedCatalog, request, {
    include_reasons: false,
  });

  const resolved = resolveNutritionProfile(requirementsCatalog, request);
  const requirements = buildGroupRequirements(resolved.profile, headCount, {
    fattening: request.fattening,
  });

  // NOTE: `included_product_numbers` is treated as a "preference" that the
  // optimizer should satisfy (via min intake constraints), but we do not
  // hard-filter eligible feeds. This avoids infeasible LPs when the accepted
  // selection is small or conflicts with nutrient constraints.
  const feeds = eligibility.eligible_products
    .map((p) => {
      const full = feedCatalog.getByProductNumber(p.product_number);
      if (!full) return null;
      return productToOptimizerFeed(
        full,
        pricingCatalog,
        request.country_code,
        request,
      );
    })
    .filter((f): f is NonNullable<typeof f> => f !== null);

  if (feeds.length === 0) {
    throw new Error('No eligible feeds with sufficient nutrition data for optimizer');
  }

  const isGrowingBeef =
    requirements.optimizer === 'cattle' &&
    resolved.profile.life_stage === 'Growing';
  const overage =
    request.overage_percent ??
    (requirements.optimizer === 'small_ruminant'
      ? 0.12
      : isGrowingBeef
        ? 0.15
        : 0.05);

  let raw: Record<string, unknown>;
  if (requirements.optimizer === 'cattle') {
    raw = optimizeCattleFeedMix(
      buildCattleOptimizerRequirements(requirements.group),
      feeds,
      { overagePercent: overage },
    ) as Record<string, unknown>;
  } else {
    raw = optimizeSmallRuminantFeedMix(
      buildSmallRuminantOptimizerRequirements(requirements.group),
      feeds,
      { overagePercent: overage },
    ) as Record<string, unknown>;
  }

  const nutrientFloorUsed =
    typeof (raw.constraints as Record<string, unknown>)?.nutrientFloorUsed ===
    'number'
      ? Number((raw.constraints as Record<string, unknown>).nutrientFloorUsed)
      : undefined;

  const draft: FeedRecommendationResult = {
    context: request,
    head_count: headCount,
    profile_code: resolved.profile_code,
    match_reason: resolved.match_reason,
    requirements,
    eligible_count: feeds.length,
    recommendation: {
      solution: (raw.solution as Record<string, number>) ?? {},
      totals: (raw.totals as Record<string, number>) ?? {},
      cost_per_day: Number(raw.costPerDay ?? 0),
      cost_currency: String(raw.costCurrency ?? 'USD'),
      constraints: raw.constraints as Record<string, unknown> | undefined,
    },
    optimizer_pass: 'complete',
    nutrient_gaps: [],
    catalog_achievement: {
      primary_min_ratio: 1,
      needs_market_supplement: false,
    },
  };

  draft.nutrient_gaps = computeNutrientGaps(draft);
  draft.catalog_achievement = summarizeCatalogAchievement(
    draft,
    draft.nutrient_gaps,
    { nutrient_floor_used: nutrientFloorUsed },
  );
  draft.optimizer_pass =
    draft.catalog_achievement.primary_min_ratio >= 0.8 - 0.002
      ? 'complete'
      : 'partial';

  return draft;
}
