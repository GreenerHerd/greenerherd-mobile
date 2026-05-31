import type pg from 'pg';
import type { HerdSpecies } from './feed-eligibility.js';

export type ProductionSystem = 'DAIRY' | 'BEEF' | 'SMALL_RUMINANT';

export interface NutritionRequirementProfile {
  id: string;
  profile_code: string;
  species: HerdSpecies;
  production_system: ProductionSystem;
  life_stage: string;
  animal_class: string | null;
  body_weight_kg: number | null;
  months_since_calving: number | null;
  dmi_kg_day: number;
  cp_percent_dm: number | null;
  nel_mcal_per_kg_dm: number | null;
  ndf_percent_dm: number | null;
  adf_percent_dm: number | null;
  ca_percent_dm: number | null;
  p_percent_dm: number | null;
  milk_kg_day: number | null;
  tdn_kg_day: number | null;
  nem_mcal_day: number | null;
  neg_mcal_day: number | null;
  cp_kg_day: number | null;
  ca_kg_day: number | null;
  p_kg_day: number | null;
  fodder_percent: number | null;
  concentrate_percent: number | null;
  source_sheet: string | null;
}

function num(v: string | number | null | undefined): number | null {
  if (v === null || v === undefined || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function mapRow(row: Record<string, unknown>): NutritionRequirementProfile {
  return {
    id: String(row.id),
    profile_code: String(row.profile_code),
    species: row.species as HerdSpecies,
    production_system: row.production_system as ProductionSystem,
    life_stage: String(row.life_stage),
    animal_class: row.animal_class == null ? null : String(row.animal_class),
    body_weight_kg: num(row.body_weight_kg as string | number | null),
    months_since_calving: num(row.months_since_calving as string | number | null) as
      | number
      | null,
    dmi_kg_day: Number(row.dmi_kg_day),
    cp_percent_dm: num(row.cp_percent_dm as string | number | null),
    nel_mcal_per_kg_dm: num(row.nel_mcal_per_kg_dm as string | number | null),
    ndf_percent_dm: num(row.ndf_percent_dm as string | number | null),
    adf_percent_dm: num(row.adf_percent_dm as string | number | null),
    ca_percent_dm: num(row.ca_percent_dm as string | number | null),
    p_percent_dm: num(row.p_percent_dm as string | number | null),
    milk_kg_day: num(row.milk_kg_day as string | number | null),
    tdn_kg_day: num(row.tdn_kg_day as string | number | null),
    nem_mcal_day: num(row.nem_mcal_day as string | number | null),
    neg_mcal_day: num(row.neg_mcal_day as string | number | null),
    cp_kg_day: num(row.cp_kg_day as string | number | null),
    ca_kg_day: num(row.ca_kg_day as string | number | null),
    p_kg_day: num(row.p_kg_day as string | number | null),
    fodder_percent: num(row.fodder_percent as string | number | null),
    concentrate_percent: num(row.concentrate_percent as string | number | null),
    source_sheet: row.source_sheet == null ? null : String(row.source_sheet),
  };
}

export class NutritionRequirementsCatalog {
  private readonly all: NutritionRequirementProfile[];
  private readonly byCode = new Map<string, NutritionRequirementProfile>();

  private constructor(rows: NutritionRequirementProfile[]) {
    this.all = rows;
    for (const row of rows) {
      this.byCode.set(row.profile_code, row);
    }
  }

  static fromRecords(rows: NutritionRequirementProfile[]): NutritionRequirementsCatalog {
    if (rows.length === 0) {
      throw new Error('NutritionRequirementsCatalog requires at least one profile');
    }
    return new NutritionRequirementsCatalog(rows);
  }

  static async load(pool: pg.Pool): Promise<NutritionRequirementsCatalog> {
    const { rows } = await pool.query(
      `SELECT id, profile_code, species, production_system, life_stage, animal_class,
              body_weight_kg, months_since_calving, dmi_kg_day,
              cp_percent_dm, nel_mcal_per_kg_dm, ndf_percent_dm, adf_percent_dm,
              ca_percent_dm, p_percent_dm, milk_kg_day,
              tdn_kg_day, nem_mcal_day, neg_mcal_day, cp_kg_day, ca_kg_day, p_kg_day,
              fodder_percent, concentrate_percent, source_sheet
       FROM nutrition_requirement_profiles
       WHERE is_active = TRUE
       ORDER BY profile_code`,
    );
    if (rows.length === 0) {
      throw new Error(
        'No nutrition profiles in database. Run: cd services/db && npm run db:extract-requirements && npm run db:seed',
      );
    }
    return new NutritionRequirementsCatalog(
      rows.map((r) => mapRow(r as unknown as Record<string, unknown>)),
    );
  }

  get size(): number {
    return this.all.length;
  }

  list(): NutritionRequirementProfile[] {
    return [...this.all];
  }

  getByCode(code: string): NutritionRequirementProfile | null {
    return this.byCode.get(code) ?? null;
  }

  listForSpecies(species: HerdSpecies): NutritionRequirementProfile[] {
    return this.all.filter((p) => p.species === species);
  }

  listBeef(
    animalClass: string,
    lifeStage: string,
    monthsSinceCalving?: number,
  ): NutritionRequirementProfile[] {
    const matches = this.all.filter(
      (p) =>
        p.production_system === 'BEEF' &&
        p.animal_class === animalClass &&
        p.life_stage === lifeStage,
    );
    if (!matches.length) return [];
    if (monthsSinceCalving == null) return matches;
    return matches
      .filter((p) => p.months_since_calving != null)
      .sort(
        (a, b) =>
          Math.abs((a.months_since_calving ?? 0) - monthsSinceCalving) -
          Math.abs((b.months_since_calving ?? 0) - monthsSinceCalving),
      );
  }

  /** Closest growth-row profile for calves/yearlings (weight range in profile_code). */
  listBeefGrowing(
    animalClass: string,
    weightKg?: number,
  ): NutritionRequirementProfile[] {
    const matches = this.all.filter(
      (p) =>
        p.production_system === 'BEEF' &&
        p.animal_class === animalClass &&
        p.life_stage === 'Growing',
    );
    if (!matches.length) return [];
    if (weightKg == null) return matches;
    return [...matches].sort((a, b) => {
      const wa = a.body_weight_kg ?? 0;
      const wb = b.body_weight_kg ?? 0;
      return Math.abs(wa - weightKg) - Math.abs(wb - weightKg);
    });
  }
}
