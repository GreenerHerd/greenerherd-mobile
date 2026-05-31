import {
  FeedCatalog,
  type FeedProductRecord,
  type FeedType,
  matchesSpeciesScope,
  toPublicFeedProduct,
} from './feed-catalog.js';
import {
  ruleEligibilityFields,
  type FeedEligibilityRule,
} from './feed-eligibility-rule.js';

export type HerdSpecies = 'CATTLE' | 'GOAT' | 'SHEEP';
export type HerdSex = 'MALE' | 'FEMALE';
/** Farm species purpose / output type from onboarding */
export type HerdProductionFocus = 'MILK' | 'MEAT' | 'BOTH';

export interface FeedEligibilityContext {
  species: HerdSpecies;
  sex?: HerdSex;
  age_months: number;
  production_focus: HerdProductionFocus;
  lactating: boolean;
  pregnant?: boolean;
  feed_types?: FeedType[];
}

export interface EligibilityResult {
  eligible: boolean;
  reason: string;
  matched_rule_number?: number;
}

export interface EligibleFeedsResponse {
  context: FeedEligibilityContext;
  eligible_products: Array<
    ReturnType<typeof toPublicFeedProduct> & { eligibility_reason?: string }
  >;
  ineligible_products: Array<{
    product_number: number;
    name_en: string;
    feed_type: FeedType;
    reason: string;
  }>;
  summary: {
    total_products: number;
    eligible_count: number;
    ineligible_count: number;
    eligibility_rate: number;
  };
  optimizer_pass: 'pending';
}

export function validateEligibilityContext(ctx: FeedEligibilityContext): void {
  if (!['CATTLE', 'GOAT', 'SHEEP'].includes(ctx.species)) {
    throw new Error(`Invalid species: ${ctx.species}`);
  }
  if (typeof ctx.age_months !== 'number' || ctx.age_months < 0) {
    throw new Error('age_months must be a non-negative number');
  }
  if (!['MILK', 'MEAT', 'BOTH'].includes(ctx.production_focus)) {
    throw new Error(`Invalid production_focus: ${ctx.production_focus}`);
  }
  if (ctx.sex && !['MALE', 'FEMALE'].includes(ctx.sex)) {
    throw new Error(`Invalid sex: ${ctx.sex}`);
  }
}

export function isRuleEligible(
  rule: FeedEligibilityRule,
  product: Pick<FeedProductRecord, 'feed_type'>,
  ctx: FeedEligibilityContext,
): EligibilityResult {
  if (!matchesSpeciesScope(rule.species_scope, ctx.species)) {
    return {
      eligible: false,
      reason: `Rule scope ${rule.species_scope} does not include ${ctx.species}`,
    };
  }

  if (ctx.feed_types?.length && !ctx.feed_types.includes(product.feed_type)) {
    return {
      eligible: false,
      reason: `Feed type ${product.feed_type} not requested`,
    };
  }

  if (rule.production_focus === 'DAIRY') {
    if (ctx.production_focus !== 'MILK' && ctx.production_focus !== 'BOTH') {
      return {
        eligible: false,
        reason: 'Rule is for dairy production only',
      };
    }
  }
  if (rule.production_focus === 'MEAT') {
    if (ctx.production_focus !== 'MEAT' && ctx.production_focus !== 'BOTH') {
      return {
        eligible: false,
        reason: 'Rule is for meat production only',
      };
    }
  }

  if (rule.sex_restriction && ctx.sex && rule.sex_restriction !== ctx.sex) {
    return {
      eligible: false,
      reason: `Rule restricted to ${rule.sex_restriction} animals`,
    };
  }

  if (rule.min_age_months != null && ctx.age_months < rule.min_age_months) {
    return {
      eligible: false,
      reason: `Minimum age is ${rule.min_age_months} months`,
    };
  }
  if (rule.max_age_months != null && ctx.age_months > rule.max_age_months) {
    return {
      eligible: false,
      reason: `Maximum age is ${rule.max_age_months} months`,
    };
  }

  if (rule.lactation_inclusion) {
    const needsLactation = /lactat/i.test(rule.lactation_inclusion);
    if (needsLactation && !ctx.lactating) {
      return {
        eligible: false,
        reason: 'Rule requires lactating animals',
      };
    }
  }

  if (rule.lactation_exclusion && ctx.lactating) {
    return {
      eligible: false,
      reason: `Excluded during: ${rule.lactation_exclusion}`,
    };
  }

  return {
    eligible: true,
    reason: 'Eligible for this herd context',
    matched_rule_number: rule.rule_number,
  };
}

/** First rule that passes all constraints for this context, if any. */
export function findMatchingEligibilityRule(
  product: FeedProductRecord,
  ctx: FeedEligibilityContext,
): FeedEligibilityRule | null {
  for (const rule of product.eligibility_rules) {
    if (isRuleEligible(rule, product, ctx).eligible) return rule;
  }
  return null;
}

export function isProductEligible(
  product: FeedProductRecord,
  ctx: FeedEligibilityContext,
): EligibilityResult {
  if (product.eligibility_rules.length === 0) {
    return { eligible: true, reason: 'No eligibility restrictions' };
  }

  let lastFailure: EligibilityResult | null = null;
  for (const rule of product.eligibility_rules) {
    const result = isRuleEligible(rule, product, ctx);
    if (result.eligible) return result;
    lastFailure = result;
  }

  return (
    lastFailure ?? {
      eligible: false,
      reason: 'No matching eligibility rule for this herd context',
    }
  );
}

export function findEligibleFeeds(
  catalog: FeedCatalog,
  ctx: FeedEligibilityContext,
  options: { include_reasons?: boolean } = {},
): EligibleFeedsResponse {
  validateEligibilityContext(ctx);

  const candidates = catalog.list({ species: ctx.species });
  const eligible_products: EligibleFeedsResponse['eligible_products'] = [];
  const ineligible_products: EligibleFeedsResponse['ineligible_products'] = [];

  for (const product of candidates) {
    const result = isProductEligible(product, ctx);
    if (result.eligible) {
      eligible_products.push({
        ...toPublicFeedProduct(product),
        ...(options.include_reasons ? { eligibility_reason: result.reason } : {}),
      });
    } else {
      ineligible_products.push({
        product_number: product.product_number,
        name_en: product.name_en,
        feed_type: product.feed_type,
        reason: result.reason,
      });
    }
  }

  eligible_products.sort((a, b) => a.product_number - b.product_number);

  const total = candidates.length;
  return {
    context: ctx,
    eligible_products,
    ineligible_products,
    summary: {
      total_products: total,
      eligible_count: eligible_products.length,
      ineligible_count: ineligible_products.length,
      eligibility_rate: total === 0 ? 0 : (eligible_products.length / total) * 100,
    },
    optimizer_pass: 'pending',
  };
}

/** Map group purpose to production focus when farm species purpose is unavailable */
export function productionFocusFromGroupPurpose(
  purpose: string | undefined,
  fallback: HerdProductionFocus = 'BOTH',
): HerdProductionFocus {
  switch (purpose) {
    case 'MILK':
    case 'PREGNANT':
      return 'MILK';
    case 'FATTENING':
      return 'MEAT';
    default:
      return fallback;
  }
}

/** Approximate age in months from API age_range enum */
export function ageMonthsFromRange(ageRange: string | null | undefined): number {
  const map: Record<string, number> = {
    '0_3M': 2,
    '3_6M': 5,
    '6_12M': 9,
    '1_2Y': 18,
    '2_3Y': 30,
    '3_5Y': 48,
    '5PLUS_Y': 72,
  };
  if (!ageRange) return 24;
  return map[ageRange] ?? 24;
}

export { ruleEligibilityFields };
