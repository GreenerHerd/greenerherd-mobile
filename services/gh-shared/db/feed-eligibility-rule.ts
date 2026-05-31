import type { ProductionFocus } from './feed-catalog.js';
import type { FeedSpeciesScope } from './feed-species-scope.js';

export interface FeedEligibilityRule {
  id: string;
  rule_number: number;
  product_id: string;
  species_scope: FeedSpeciesScope;
  max_perc_feed: number | null;
  max_perc_conc: number | null;
  max_perc_weight: number | null;
  max_feed_weight_kg: number | null;
  production_focus: ProductionFocus | null;
  sex_restriction: 'MALE' | 'FEMALE' | null;
  min_age_months: number | null;
  max_age_months: number | null;
  breeding_cycle: string | null;
  lactation_exclusion: string | null;
  lactation_inclusion: string | null;
  dietary_needs: string | null;
}

export function ruleEligibilityFields(
  rule: FeedEligibilityRule,
): Omit<FeedEligibilityRule, 'id' | 'rule_number' | 'product_id'> {
  return {
    species_scope: rule.species_scope,
    max_perc_feed: rule.max_perc_feed,
    max_perc_conc: rule.max_perc_conc,
    max_perc_weight: rule.max_perc_weight,
    max_feed_weight_kg: rule.max_feed_weight_kg,
    production_focus: rule.production_focus,
    sex_restriction: rule.sex_restriction,
    min_age_months: rule.min_age_months,
    max_age_months: rule.max_age_months,
    breeding_cycle: rule.breeding_cycle,
    lactation_exclusion: rule.lactation_exclusion,
    lactation_inclusion: rule.lactation_inclusion,
    dietary_needs: rule.dietary_needs,
  };
}
