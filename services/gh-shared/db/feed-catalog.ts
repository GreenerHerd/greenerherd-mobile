import type pg from 'pg';
import {
  mergeTransRows,
  namesFromLegacyRow,
  publicNames,
  resolveCatalogName,
  type CatalogLocale,
  type CatalogNames,
} from './catalog-i18n.js';
import type { FeedEligibilityRule } from './feed-eligibility-rule.js';
import { matchesSpeciesScope } from './feed-species-scope.js';

export type { FeedSpeciesScope } from './feed-species-scope.js';

export type FeedType = 'FODDER' | 'CONCENTRATE' | 'ADDITIVE';

export type ProductionFocus = 'DAIRY' | 'MEAT';

export type { FeedEligibilityRule } from './feed-eligibility-rule.js';

export interface FeedProductRecord {
  id: string;
  product_number: number;
  name_en: string;
  names: CatalogNames;
  name_ar: string | null;
  feed_type: FeedType;
  eligibility_rules: FeedEligibilityRule[];
  dm_percent: number | null;
  nem_mcal_kg: number | null;
  neg_mcal_kg: number | null;
  cp_percent: number | null;
  crude_fat_percent: number | null;
  ndf_percent: number | null;
  adf_percent: number | null;
  tdn_percent: number | null;
  de_mcal_kg: number | null;
  me_mcal_kg: number | null;
  me_mj_kg_dm: number | null;
  fiber_percent: number | null;
  moisture_percent: number | null;
  calcium_percent: number | null;
  phosphorus_percent: number | null;
  potassium_percent: number | null;
  magnesium_percent: number | null;
  sodium_percent: number | null;
  zinc_mg_kg: number | null;
  copper_mg_kg: number | null;
  manganese_mg_kg: number | null;
  iron_mg_kg: number | null;
  selenium_mg_kg: number | null;
  biotin: string | null;
  vitamin_a_iu_kg: number | null;
  vitamin_b1_iu_kg: number | null;
  vitamin_b2_iu_kg: number | null;
  vitamin_b6_iu_kg: number | null;
  vitamin_b12_iu_kg: number | null;
  vitamin_d3_iu_kg: number | null;
  vitamin_e_mg_kg: number | null;
}

interface FeedRow extends FeedProductRecord {
  source?: string | null;
}

function num(v: string | number | null | undefined): number | null {
  if (v === null || v === undefined || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function int(v: string | number | null | undefined): number | null {
  const n = num(v);
  return n === null ? null : Math.trunc(n);
}

function mapRuleRow(row: Record<string, unknown>): FeedEligibilityRule {
  return {
    id: String(row.id),
    rule_number: Number(row.rule_number),
    product_id: String(row.product_id),
    species_scope: row.species_scope as FeedSpeciesScope,
    max_perc_feed: num(row.max_perc_feed as string | number | null),
    max_perc_conc: num(row.max_perc_conc as string | number | null),
    max_perc_weight: num(row.max_perc_weight as string | number | null),
    max_feed_weight_kg: num(row.max_feed_weight_kg as string | number | null),
    production_focus: (row.production_focus as ProductionFocus | null) ?? null,
    sex_restriction: (row.sex_restriction as 'MALE' | 'FEMALE' | null) ?? null,
    min_age_months: int(row.min_age_months as string | number | null),
    max_age_months: int(row.max_age_months as string | number | null),
    breeding_cycle: row.breeding_cycle == null ? null : String(row.breeding_cycle),
    lactation_exclusion:
      row.lactation_exclusion == null ? null : String(row.lactation_exclusion),
    lactation_inclusion:
      row.lactation_inclusion == null ? null : String(row.lactation_inclusion),
    dietary_needs: row.dietary_needs == null ? null : String(row.dietary_needs),
  };
}

function mapProductRow(row: Record<string, unknown>): FeedProductRecord {
  const name_en = String(row.name_en);
  const name_ar = row.name_ar == null ? null : String(row.name_ar);
  const embedded = row.eligibility_rules;
  return {
    id: String(row.id),
    product_number: Number(row.product_number),
    name_en,
    names: namesFromLegacyRow({ name_en, name_ar }),
    name_ar,
    feed_type: row.feed_type as FeedType,
    eligibility_rules: Array.isArray(embedded)
      ? embedded.map((r) => mapRuleRow(r as Record<string, unknown>))
      : [],
    dm_percent: num(row.dm_percent as string | number | null),
    nem_mcal_kg: num(row.nem_mcal_kg as string | number | null),
    neg_mcal_kg: num(row.neg_mcal_kg as string | number | null),
    cp_percent: num(row.cp_percent as string | number | null),
    crude_fat_percent: num(row.crude_fat_percent as string | number | null),
    ndf_percent: num(row.ndf_percent as string | number | null),
    adf_percent: num(row.adf_percent as string | number | null),
    tdn_percent: num(row.tdn_percent as string | number | null),
    de_mcal_kg: num(row.de_mcal_kg as string | number | null),
    me_mcal_kg: num(row.me_mcal_kg as string | number | null),
    me_mj_kg_dm: num(row.me_mj_kg_dm as string | number | null),
    fiber_percent: num(row.fiber_percent as string | number | null),
    moisture_percent: num(row.moisture_percent as string | number | null),
    calcium_percent: num(row.calcium_percent as string | number | null),
    phosphorus_percent: num(row.phosphorus_percent as string | number | null),
    potassium_percent: num(row.potassium_percent as string | number | null),
    magnesium_percent: num(row.magnesium_percent as string | number | null),
    sodium_percent: num(row.sodium_percent as string | number | null),
    zinc_mg_kg: num(row.zinc_mg_kg as string | number | null),
    copper_mg_kg: num(row.copper_mg_kg as string | number | null),
    manganese_mg_kg: num(row.manganese_mg_kg as string | number | null),
    iron_mg_kg: num(row.iron_mg_kg as string | number | null),
    selenium_mg_kg: num(row.selenium_mg_kg as string | number | null),
    biotin: row.biotin == null ? null : String(row.biotin),
    vitamin_a_iu_kg: num(row.vitamin_a_iu_kg as string | number | null),
    vitamin_b1_iu_kg: num(row.vitamin_b1_iu_kg as string | number | null),
    vitamin_b2_iu_kg: num(row.vitamin_b2_iu_kg as string | number | null),
    vitamin_b6_iu_kg: num(row.vitamin_b6_iu_kg as string | number | null),
    vitamin_b12_iu_kg: num(row.vitamin_b12_iu_kg as string | number | null),
    vitamin_d3_iu_kg: num(row.vitamin_d3_iu_kg as string | number | null),
    vitamin_e_mg_kg: num(row.vitamin_e_mg_kg as string | number | null),
  };
}

export class FeedCatalog {
  private readonly all: FeedProductRecord[];
  private readonly byNumber = new Map<number, FeedProductRecord>();
  private readonly byId = new Map<string, FeedProductRecord>();

  private constructor(rows: FeedProductRecord[]) {
    this.all = rows;
    for (const row of rows) {
      this.byNumber.set(row.product_number, row);
      this.byId.set(row.id, row);
    }
  }

  static fromRecords(rows: FeedProductRecord[]): FeedCatalog {
    if (rows.length === 0) {
      throw new Error('FeedCatalog.fromRecords requires at least one product');
    }
    return new FeedCatalog(rows);
  }

  static async load(pool: pg.Pool): Promise<FeedCatalog> {
    const { rows: productRows } = await pool.query<FeedRow>(
      `SELECT
        id, product_number, name_en, name_ar, feed_type,
        dm_percent, nem_mcal_kg, neg_mcal_kg, cp_percent, crude_fat_percent,
        ndf_percent, adf_percent, tdn_percent, de_mcal_kg, me_mcal_kg, me_mj_kg_dm,
        fiber_percent, moisture_percent, calcium_percent, phosphorus_percent,
        potassium_percent, magnesium_percent, sodium_percent,
        zinc_mg_kg, copper_mg_kg, manganese_mg_kg, iron_mg_kg, selenium_mg_kg,
        biotin, vitamin_a_iu_kg, vitamin_b1_iu_kg, vitamin_b2_iu_kg,
        vitamin_b6_iu_kg, vitamin_b12_iu_kg, vitamin_d3_iu_kg, vitamin_e_mg_kg
       FROM feed_products
       WHERE is_active = TRUE
       ORDER BY product_number`,
    );
    if (productRows.length === 0) {
      throw new Error(
        'No feed products in database. Run: cd services/db && npm run db:extract-feeds && npm run db:seed',
      );
    }

    const { rows: ruleRows } = await pool.query(
      `SELECT
        id, rule_number, product_id, species_scope,
        max_perc_feed, max_perc_conc, max_perc_weight, max_feed_weight_kg,
        production_focus, sex_restriction, min_age_months, max_age_months,
        breeding_cycle, lactation_exclusion, lactation_inclusion, dietary_needs
       FROM feed_product_eligibility_rules
       WHERE is_active = TRUE
       ORDER BY rule_number`,
    );

    const rulesByProduct = new Map<string, FeedEligibilityRule[]>();
    for (const row of ruleRows) {
      const rule = mapRuleRow(row as unknown as Record<string, unknown>);
      const list = rulesByProduct.get(rule.product_id) ?? [];
      list.push(rule);
      rulesByProduct.set(rule.product_id, list);
    }

    const catalog = new FeedCatalog(
      productRows.map((r) => {
        const product = mapProductRow(r as unknown as Record<string, unknown>);
        product.eligibility_rules = rulesByProduct.get(product.id) ?? [];
        return product;
      }),
    );
    await catalog.attachTranslations(pool);
    return catalog;
  }

  private async attachTranslations(pool: pg.Pool): Promise<void> {
    const { rows } = await pool.query<{
      product_id: string;
      locale: string;
      name: string;
    }>(`SELECT product_id, locale, name FROM feed_product_trans`);
    const byProduct = new Map<string, Array<{ locale: string; name: string }>>();
    for (const row of rows) {
      const list = byProduct.get(row.product_id) ?? [];
      list.push(row);
      byProduct.set(row.product_id, list);
    }
    for (const record of this.all) {
      const merged = mergeTransRows(record.names, byProduct.get(record.id) ?? []);
      Object.assign(record.names, merged);
      record.name_ar = record.names.ar ?? record.name_ar;
    }
  }

  localizedName(record: FeedProductRecord, locale: CatalogLocale): string {
    return resolveCatalogName(record.names, locale, record.name_en);
  }

  list(filter?: {
    species?: 'CATTLE' | 'GOAT' | 'SHEEP';
    feed_type?: FeedType;
  }): FeedProductRecord[] {
    let list = [...this.all];
    if (filter?.feed_type) {
      list = list.filter((p) => p.feed_type === filter.feed_type);
    }
    if (filter?.species) {
      list = list.filter((p) =>
        p.eligibility_rules.some((r) => matchesSpeciesScope(r.species_scope, filter.species!)),
      );
    }
    return list;
  }

  getRulesForProduct(productId: string): FeedEligibilityRule[] {
    const product = this.byId.get(productId);
    return product?.eligibility_rules ?? [];
  }

  getByProductNumber(productNumber: number): FeedProductRecord | null {
    return this.byNumber.get(productNumber) ?? null;
  }

  getById(id: string): FeedProductRecord | null {
    return this.byId.get(id) ?? null;
  }

  get size(): number {
    return this.all.length;
  }

  countsByType(): Record<FeedType, number> {
    return {
      FODDER: this.all.filter((p) => p.feed_type === 'FODDER').length,
      CONCENTRATE: this.all.filter((p) => p.feed_type === 'CONCENTRATE').length,
      ADDITIVE: this.all.filter((p) => p.feed_type === 'ADDITIVE').length,
    };
  }
}

export { matchesSpeciesScope } from './feed-species-scope.js';

export function toPublicFeedProduct(p: FeedProductRecord, locale?: CatalogLocale) {
  const loc = locale ?? 'en';
  return {
    id: p.id,
    product_number: p.product_number,
    name_en: p.name_en,
    name: resolveCatalogName(p.names, loc, p.name_en),
    names: publicNames(p.names),
    name_ar: p.name_ar,
    feed_type: p.feed_type,
    species_scopes: [...new Set(p.eligibility_rules.map((r) => r.species_scope))],
    eligibility_rules: p.eligibility_rules.map((r) => ({
      rule_number: r.rule_number,
      species_scope: r.species_scope,
      max_perc_feed: r.max_perc_feed,
      max_perc_conc: r.max_perc_conc,
      production_focus: r.production_focus,
      min_age_months: r.min_age_months,
      max_age_months: r.max_age_months,
      lactation_inclusion: r.lactation_inclusion,
    })),
    dm_percent: p.dm_percent,
    cp_percent: p.cp_percent,
    nem_mcal_kg: p.nem_mcal_kg,
    neg_mcal_kg: p.neg_mcal_kg,
    tdn_percent: p.tdn_percent,
    calcium_percent: p.calcium_percent,
    phosphorus_percent: p.phosphorus_percent,
  };
}
