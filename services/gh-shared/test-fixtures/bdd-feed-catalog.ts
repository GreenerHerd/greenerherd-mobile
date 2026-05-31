import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { namesFromLegacyRow } from '../db/catalog-i18n.js';
import {
  FeedCatalog,
  type FeedProductRecord,
  type FeedType,
  type ProductionFocus,
} from '../db/feed-catalog.js';
import type { FeedEligibilityRule } from '../db/feed-eligibility-rule.js';
import type { FeedSpeciesScope } from '../db/feed-species-scope.js';

function feedJsonPath(): string {
  return path.resolve(
    fileURLToPath(new URL('.', import.meta.url)),
    '../../../assets/data/feed_products.json',
  );
}

function num(v: unknown) {
  return v === null || v === undefined ? null : Number(v);
}

function mapRule(raw: Record<string, unknown>, productId: string): FeedEligibilityRule {
  return {
    id: String(raw.id ?? `${productId}-rule-${raw.rule_number}`),
    rule_number: Number(raw.rule_number),
    product_id: productId,
    species_scope: raw.species_scope as FeedSpeciesScope,
    max_perc_feed: num(raw.max_perc_feed),
    max_perc_conc: num(raw.max_perc_conc),
    max_perc_weight: num(raw.max_perc_weight),
    max_feed_weight_kg: num(raw.max_feed_weight_kg),
    production_focus: (raw.production_focus as ProductionFocus | null) ?? null,
    sex_restriction: (raw.sex_restriction as 'MALE' | 'FEMALE' | null) ?? null,
    min_age_months: raw.min_age_months == null ? null : Number(raw.min_age_months),
    max_age_months: raw.max_age_months == null ? null : Number(raw.max_age_months),
    breeding_cycle: (raw.breeding_cycle as string | null) ?? null,
    lactation_exclusion: (raw.lactation_exclusion as string | null) ?? null,
    lactation_inclusion: (raw.lactation_inclusion as string | null) ?? null,
    dietary_needs: (raw.dietary_needs as string | null) ?? null,
  };
}

function toRecord(raw: Record<string, unknown>): FeedProductRecord {
  const name_en = String(raw.name_en);
  const name_ar = (raw.name_ar as string | null) ?? null;
  const names =
    raw.names && typeof raw.names === 'object'
      ? (raw.names as Record<string, string>)
      : namesFromLegacyRow({ name_en, name_ar });
  const productId = String(raw.id);
  const embedded = raw.eligibility_rules;
  const eligibility_rules: FeedEligibilityRule[] = Array.isArray(embedded)
    ? embedded.map((r) => mapRule(r as Record<string, unknown>, productId))
    : raw.species_scope != null
      ? [
          mapRule(
            {
              rule_number: raw.rule_number ?? raw.product_number,
              ...raw,
            },
            productId,
          ),
        ]
      : [];

  return {
    id: productId,
    product_number: Number(raw.product_number),
    name_en,
    names,
    name_ar,
    feed_type: raw.feed_type as FeedType,
    eligibility_rules,
    dm_percent: num(raw.dm_percent),
    nem_mcal_kg: num(raw.nem_mcal_kg),
    neg_mcal_kg: num(raw.neg_mcal_kg),
    cp_percent: num(raw.cp_percent),
    crude_fat_percent: num(raw.crude_fat_percent),
    ndf_percent: num(raw.ndf_percent),
    adf_percent: num(raw.adf_percent),
    tdn_percent: num(raw.tdn_percent),
    de_mcal_kg: num(raw.de_mcal_kg),
    me_mcal_kg: num(raw.me_mcal_kg),
    me_mj_kg_dm: num(raw.me_mj_kg_dm),
    fiber_percent: num(raw.fiber_percent),
    moisture_percent: num(raw.moisture_percent),
    calcium_percent: num(raw.calcium_percent),
    phosphorus_percent: num(raw.phosphorus_percent),
    potassium_percent: num(raw.potassium_percent),
    magnesium_percent: num(raw.magnesium_percent),
    sodium_percent: num(raw.sodium_percent),
    zinc_mg_kg: num(raw.zinc_mg_kg),
    copper_mg_kg: num(raw.copper_mg_kg),
    manganese_mg_kg: num(raw.manganese_mg_kg),
    iron_mg_kg: num(raw.iron_mg_kg),
    selenium_mg_kg: num(raw.selenium_mg_kg),
    biotin: (raw.biotin as string | null) ?? null,
    vitamin_a_iu_kg: num(raw.vitamin_a_iu_kg),
    vitamin_b1_iu_kg: num(raw.vitamin_b1_iu_kg),
    vitamin_b2_iu_kg: num(raw.vitamin_b2_iu_kg),
    vitamin_b6_iu_kg: num(raw.vitamin_b6_iu_kg),
    vitamin_b12_iu_kg: num(raw.vitamin_b12_iu_kg),
    vitamin_d3_iu_kg: num(raw.vitamin_d3_iu_kg),
    vitamin_e_mg_kg: num(raw.vitamin_e_mg_kg),
  };
}

let cached: FeedCatalog | undefined;

export function loadBddFeedCatalog(): FeedCatalog {
  if (cached) return cached;
  const parsed = JSON.parse(readFileSync(feedJsonPath(), 'utf8')) as {
    products: Record<string, unknown>[];
  };
  cached = FeedCatalog.fromRecords(parsed.products.map(toRecord));
  return cached;
}

export function steamedCornFlakeProductNumber(): number {
  const catalog = loadBddFeedCatalog();
  const match = catalog
    .list()
    .find(
      (p) =>
        p.name_en === 'Steamed Corn Flake' &&
        p.eligibility_rules.some(
          (r) => r.species_scope === 'CATTLE' && r.production_focus === 'DAIRY',
        ),
    );
  if (!match) throw new Error('Steamed Corn Flake (Cattle) not in fixture');
  return match.product_number;
}

export function ureaCattleProductNumber(): number {
  const catalog = loadBddFeedCatalog();
  const match = catalog
    .list()
    .find(
      (p) =>
        p.name_en === 'Urea' &&
        p.eligibility_rules.some((r) => r.species_scope === 'CATTLE'),
    );
  if (!match) throw new Error('Urea (Cattle) not in fixture');
  return match.product_number;
}
