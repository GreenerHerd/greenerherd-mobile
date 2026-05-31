import type { FeedProductRecord, FeedType } from './feed-catalog.js';
import {
  findMatchingEligibilityRule,
  type FeedEligibilityContext,
} from './feed-eligibility.js';
import type { FeedPricingCatalog } from './feed-pricing-catalog.js';

export interface OptimizerFeedInput {
  name: string;
  type: FeedType;
  costPerKg: number;
  costCurrency: string;
  dmPercent: number;
  cpPercent: number;
  fibrePercent?: number;
  ndfPercent?: number;
  calciumPercent?: number;
  phosphorusPercent?: number;
  nemMcalPerKg?: number;
  negMcalPerKg?: number;
  tdnPercent?: number;
  maxIntakePercentOfDM?: number;
  maxIntakeWeightInKgPerAnimal?: number;
  minIntakePercentOfDM?: number;
  minIntakeWeightInKgPerAnimal?: number;
  compositionBasis: 'dm';
}

const DEFAULT_DM = 90;
const DEFAULT_CP = 8;
const DEFAULT_TDN = 55;
const DEFAULT_MINERAL = 0.1;
const DEFAULT_COST_USD = 0.35;

export function productToOptimizerFeed(
  product: FeedProductRecord,
  pricing: FeedPricingCatalog | undefined,
  countryCode?: string,
  eligibilityContext?: FeedEligibilityContext,
): OptimizerFeedInput | null {
  const dm = product.dm_percent ?? DEFAULT_DM;
  if (dm <= 0) return null;

  const price = pricing?.resolveForProduct(
    product.name_en,
    product.feed_type,
    countryCode,
  );
  const costPerKg =
    price?.local_price_per_kg ??
    (price?.usd_per_kg != null ? price.usd_per_kg : null) ??
    DEFAULT_COST_USD;
  const costCurrency = price?.currency ?? (countryCode ? 'USD' : 'USD');

  const rule =
    eligibilityContext != null
      ? findMatchingEligibilityRule(product, eligibilityContext)
      : product.eligibility_rules[0] ?? null;
  const maxDmPct =
    rule?.max_perc_feed ?? rule?.max_perc_conc ?? rule?.max_perc_weight;

  const includedProductNumbers = (eligibilityContext as unknown as {
    included_product_numbers?: number[];
  } | null)?.included_product_numbers;
  const isIncluded = includedProductNumbers?.some(
    (n) => n === product.product_number,
  );

  // Bound used by optimizers to ensure "accepted" products have some
  // minimum presence in the optimized mix.
  const minIntakePercentOfDM = isIncluded ? 0.1 : undefined; // 0.1% of DM

  // The optimizer treats `cost` as the objective. To make sure the accepted
  // product shows up (since the LP solver doesn't reliably honor variable
  // `min` bounds), we bias the effective cost for accepted products.
  let adjustedCostPerKg = costPerKg;
  if (includedProductNumbers != null && includedProductNumbers.length > 0) {
    adjustedCostPerKg = costPerKg * (isIncluded ? 0.01 : 1.0);
  }

  return {
    name: product.name_en,
    type: product.feed_type,
    costPerKg: adjustedCostPerKg,
    costCurrency,
    dmPercent: dm,
    cpPercent: product.cp_percent ?? DEFAULT_CP,
    fibrePercent: product.adf_percent ?? product.fiber_percent ?? undefined,
    ndfPercent: product.ndf_percent ?? undefined,
    calciumPercent: product.calcium_percent ?? DEFAULT_MINERAL,
    phosphorusPercent: product.phosphorus_percent ?? DEFAULT_MINERAL,
    nemMcalPerKg: product.nem_mcal_kg ?? product.me_mcal_kg ?? undefined,
    negMcalPerKg: product.neg_mcal_kg ?? undefined,
    tdnPercent:
      product.tdn_percent ??
      (product.me_mcal_kg != null ? product.me_mcal_kg * 20 : DEFAULT_TDN),
    maxIntakePercentOfDM: maxDmPct ?? undefined,
    maxIntakeWeightInKgPerAnimal: rule?.max_feed_weight_kg ?? undefined,
    minIntakePercentOfDM,
    compositionBasis: 'dm',
  };
}

export function buildCattleOptimizerRequirements(group: {
  dry_matter_kg: number;
  crude_protein_kg: number;
  ndf_kg: number;
  fibre_kg: number;
  calcium_kg: number;
  phosphorus_kg: number;
  nem_mcal: number;
  neg_mcal: number;
  no_of_animals: number;
}) {
  return {
    dryMatterKg: group.dry_matter_kg,
    crudeProteinKg: group.crude_protein_kg,
    ndfKg: group.ndf_kg,
    fibreKg: group.fibre_kg,
    calciumKg: group.calcium_kg,
    phosphorusKg: group.phosphorus_kg,
    nemMcal: group.nem_mcal,
    negMcal: group.neg_mcal,
    noOfAnimals: group.no_of_animals,
  };
}

export function buildSmallRuminantOptimizerRequirements(group: {
  dry_matter_kg: number;
  protein_kg: number;
  tdn_kg: number;
  calcium_g: number;
  phosphorus_g: number;
  fodder_percent: number;
  concentrate_percent: number;
  no_of_animals: number;
}) {
  return {
    dryMatterKg: group.dry_matter_kg,
    proteinKg: group.protein_kg,
    tdnKg: group.tdn_kg,
    calciumG: group.calcium_g,
    phosphorusG: group.phosphorus_g,
    fodderPercent: group.fodder_percent,
    concentratePercent: group.concentrate_percent,
    noOfAnimals: group.no_of_animals,
  };
}
