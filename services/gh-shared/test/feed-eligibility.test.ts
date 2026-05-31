import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { FeedCatalog, type FeedProductRecord } from '../db/feed-catalog.js';
import type { FeedEligibilityRule } from '../db/feed-eligibility-rule.js';
import { findEligibleFeeds, isProductEligible } from '../db/feed-eligibility.js';

const steamedCornRule: FeedEligibilityRule = {
  id: 'rule-steamed-corn',
  rule_number: 5015,
  product_id: '1',
  species_scope: 'CATTLE',
  max_perc_feed: 50,
  max_perc_conc: null,
  max_perc_weight: null,
  max_feed_weight_kg: null,
  production_focus: 'DAIRY',
  sex_restriction: null,
  min_age_months: 12,
  max_age_months: null,
  breeding_cycle: null,
  lactation_exclusion: null,
  lactation_inclusion: 'Lactation Period',
  dietary_needs: null,
};

const steamedCorn: FeedProductRecord = {
  id: '1',
  product_number: 1015,
  name_en: 'Steamed Corn Flake',
  names: { en: 'Steamed Corn Flake' },
  name_ar: null,
  feed_type: 'CONCENTRATE',
  eligibility_rules: [steamedCornRule],
  dm_percent: 88,
  nem_mcal_kg: 2,
  neg_mcal_kg: 1.4,
  cp_percent: 9,
  crude_fat_percent: null,
  ndf_percent: null,
  adf_percent: null,
  tdn_percent: null,
  de_mcal_kg: null,
  me_mcal_kg: null,
  me_mj_kg_dm: null,
  fiber_percent: null,
  moisture_percent: null,
  calcium_percent: null,
  phosphorus_percent: null,
  potassium_percent: null,
  magnesium_percent: null,
  sodium_percent: null,
  zinc_mg_kg: null,
  copper_mg_kg: null,
  manganese_mg_kg: null,
  iron_mg_kg: null,
  selenium_mg_kg: null,
  biotin: null,
  vitamin_a_iu_kg: null,
  vitamin_b1_iu_kg: null,
  vitamin_b2_iu_kg: null,
  vitamin_b6_iu_kg: null,
  vitamin_b12_iu_kg: null,
  vitamin_d3_iu_kg: null,
  vitamin_e_mg_kg: null,
};

const barleyAll: FeedProductRecord = {
  ...steamedCorn,
  id: '2',
  product_number: 1001,
  name_en: 'Barley',
  names: { en: 'Barley' },
  eligibility_rules: [
    {
      ...steamedCornRule,
      id: 'rule-barley-all',
      rule_number: 5001,
      product_id: '2',
      species_scope: 'ALL',
      production_focus: null,
      min_age_months: null,
      lactation_inclusion: null,
    },
  ],
};

describe('feed eligibility', () => {
  const catalog = FeedCatalog.fromRecords([steamedCorn, barleyAll]);

  it('excludes dairy lactation feed for dry cows', () => {
    const result = isProductEligible(steamedCorn, {
      species: 'CATTLE',
      age_months: 36,
      production_focus: 'MILK',
      lactating: false,
    });
    assert.equal(result.eligible, false);
  });

  it('includes dairy lactation feed for lactating dairy cows', () => {
    const result = isProductEligible(steamedCorn, {
      species: 'CATTLE',
      age_months: 36,
      production_focus: 'MILK',
      lactating: true,
    });
    assert.equal(result.eligible, true);
  });

  it('excludes cattle-only feed for sheep', () => {
    const result = isProductEligible(steamedCorn, {
      species: 'SHEEP',
      age_months: 24,
      production_focus: 'BOTH',
      lactating: true,
    });
    assert.equal(result.eligible, false);
  });

  it('findEligibleFeeds returns summary and pending optimizer pass', () => {
    const out = findEligibleFeeds(catalog, {
      species: 'CATTLE',
      age_months: 36,
      production_focus: 'MILK',
      lactating: true,
    });
    assert.equal(out.optimizer_pass, 'pending');
    assert.ok(out.eligible_products.some((p) => p.name_en === 'Barley'));
    assert.ok(out.eligible_products.some((p) => p.name_en === 'Steamed Corn Flake'));
  });
});
