import type pg from 'pg';
import {
  mergeTransRows,
  namesFromLegacyRow,
  publicNames,
  resolveCatalogName,
  type CatalogLocale,
  type CatalogNames,
} from './catalog-i18n.js';

export type BreedSpecies = 'CATTLE' | 'GOAT' | 'SHEEP';

export interface BreedWeightPoint {
  sex: 'MALE' | 'FEMALE';
  age_months: number;
  weight_kg: number;
}

export interface BreedRecord {
  id: string;
  species: BreedSpecies;
  code: string;
  name_en: string;
  /** Locale → display name (from breed_trans). */
  names: CatalogNames;
  name_ar: string | null;
  name_ur: string | null;
  name_fr: string | null;
  origin: string | null;
  primary_purpose: string | null;
  color: string | null;
  milk_production_kg_year: string | null;
  heat_tolerance: string | null;
  disease_resistance: string | null;
  birth_ease: string | null;
  feed_efficiency: string | null;
  temperament: string | null;
  adult_male_weight_kg: string | null;
  adult_female_weight_kg: string | null;
  adaptability: string | null;
  longevity_years: string | null;
  height_male_cm: string | null;
  height_female_cm: string | null;
  known_for: string | null;
}

interface BreedRow {
  id: string;
  species: BreedSpecies;
  code: string;
  name_en: string;
  name_ar: string | null;
  name_ur: string | null;
  name_fr: string | null;
  origin: string | null;
  primary_purpose: string | null;
  color: string | null;
  milk_production_kg_year: string | null;
  heat_tolerance: string | null;
  disease_resistance: string | null;
  birth_ease: string | null;
  feed_efficiency: string | null;
  temperament: string | null;
  adult_male_weight_kg: string | null;
  adult_female_weight_kg: string | null;
  adaptability: string | null;
  longevity_years: string | null;
  height_male_cm: string | null;
  height_female_cm: string | null;
  known_for: string | null;
}

export class BreedCatalog {
  private readonly all: BreedRecord[];
  private readonly bySpecies = new Map<BreedSpecies, BreedRecord[]>();
  private readonly lookup = new Map<string, BreedRecord>();
  private readonly byId = new Map<string, BreedRecord>();
  private readonly weightsByBreedId = new Map<string, BreedWeightPoint[]>();

  private constructor(rows: BreedRecord[]) {
    this.all = rows;
    for (const row of rows) {
      this.byId.set(row.id, row);
      const list = this.bySpecies.get(row.species) ?? [];
      list.push(row);
      this.bySpecies.set(row.species, list);
      this.indexKey(row.species, row.code, row);
      this.indexKey(row.species, row.name_en, row);
      if (row.name_ar) this.indexKey(row.species, row.name_ar, row);
      const names = row.names ?? namesFromLegacyRow(row);
      for (const name of Object.values(names)) {
        if (name) this.indexKey(row.species, name, row);
      }
      if (row.name_en.includes('/')) {
        for (const part of row.name_en.split('/')) {
          this.indexKey(row.species, part.trim(), row);
        }
      }
    }
  }

  private indexKey(species: BreedSpecies, raw: string, row: BreedRecord): void {
    const key = `${species}::${normalizeBreedKey(raw)}`;
    this.lookup.set(key, row);
  }

  static fromRecords(rows: BreedRecord[]): BreedCatalog {
    if (rows.length === 0) {
      throw new Error('BreedCatalog.fromRecords requires at least one breed');
    }
    return new BreedCatalog(rows);
  }

  setWeights(breedId: string, points: BreedWeightPoint[]): void {
    this.weightsByBreedId.set(breedId, points);
  }

  getWeights(breedId: string): BreedWeightPoint[] | null {
    return this.weightsByBreedId.get(breedId) ?? null;
  }

  static async load(pool: pg.Pool): Promise<BreedCatalog> {
    const { rows } = await pool.query<BreedRow>(
      `SELECT
        id, species, code, name_en, name_ar, name_ur, name_fr,
        origin, primary_purpose, color, milk_production_kg_year,
        heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
        temperament, adult_male_weight_kg, adult_female_weight_kg,
        adaptability, longevity_years, height_male_cm, height_female_cm, known_for
       FROM breeds
       WHERE is_active = TRUE
       ORDER BY species, name_en`,
    );
    if (rows.length === 0) {
      throw new Error(
        'No breeds in database. Run: cd services/db && npm run db:setup',
      );
    }
    const catalog = new BreedCatalog(
      rows.map((row) => ({
        ...row,
        names: namesFromLegacyRow(row),
      })),
    );
    await catalog.attachTranslations(pool);
    return catalog;
  }

  private async attachTranslations(pool: pg.Pool): Promise<void> {
    const { rows } = await pool.query<{ breed_id: string; locale: string; name: string }>(
      `SELECT breed_id, locale, name FROM breed_trans`,
    );
    const byBreed = new Map<string, Array<{ locale: string; name: string }>>();
    for (const row of rows) {
      const list = byBreed.get(row.breed_id) ?? [];
      list.push(row);
      byBreed.set(row.breed_id, list);
    }
    for (const record of this.all) {
      const merged = mergeTransRows(record.names, byBreed.get(record.id) ?? []);
      Object.assign(record.names, merged);
      record.name_ar = record.names.ar ?? record.name_ar;
      record.name_fr = record.names.fr ?? record.name_fr;
      record.name_ur = record.names.ur ?? record.name_ur;
    }
  }

  localizedName(record: BreedRecord, locale: CatalogLocale): string {
    return resolveCatalogName(record.names, locale, record.name_en);
  }

  static async loadWeights(
    pool: pg.Pool,
    breedId: string,
  ): Promise<BreedWeightPoint[]> {
    const { rows } = await pool.query<{
      sex: 'MALE' | 'FEMALE';
      age_months: number;
      weight_kg: string;
    }>(
      `SELECT sex, age_months, weight_kg
       FROM breed_weight_by_age
       WHERE breed_id = $1
       ORDER BY sex, age_months`,
      [breedId],
    );
    return rows.map((r) => ({
      sex: r.sex,
      age_months: r.age_months,
      weight_kg: Number(r.weight_kg),
    }));
  }

  list(species?: BreedSpecies): BreedRecord[] {
    if (!species) return [...this.all];
    return [...(this.bySpecies.get(species) ?? [])];
  }

  getById(id: string): BreedRecord | null {
    return this.byId.get(id) ?? null;
  }

  resolve(species: BreedSpecies, breed: string): BreedRecord | null {
    return this.lookup.get(`${species}::${normalizeBreedKey(breed)}`) ?? null;
  }

  require(species: BreedSpecies, breed: string): BreedRecord {
    const found = this.resolve(species, breed);
    if (!found) {
      throw new Error(`UNKNOWN_BREED:${species}:${breed}`);
    }
    return found;
  }

  get size(): number {
    return this.all.length;
  }

  countsBySpecies(): Record<BreedSpecies, number> {
    return {
      CATTLE: this.bySpecies.get('CATTLE')?.length ?? 0,
      GOAT: this.bySpecies.get('GOAT')?.length ?? 0,
      SHEEP: this.bySpecies.get('SHEEP')?.length ?? 0,
    };
  }
}

export function normalizeBreedKey(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[/\\]+/g, '_')
    .replace(/[^a-z0-9_]+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
}

export function toPublicBreed(b: BreedRecord, locale?: CatalogLocale) {
  const loc = locale ?? 'en';
  return {
    id: b.id,
    species: b.species,
    code: b.code,
    name_en: b.name_en,
    name: resolveCatalogName(b.names, loc, b.name_en),
    names: publicNames(b.names),
    name_ar: b.name_ar,
    name_ur: b.name_ur,
    name_fr: b.name_fr,
    origin: b.origin,
    primary_purpose: b.primary_purpose,
    color: b.color,
    milk_production_kg_year: b.milk_production_kg_year,
    heat_tolerance: b.heat_tolerance,
    disease_resistance: b.disease_resistance,
    birth_ease: b.birth_ease,
    feed_efficiency: b.feed_efficiency,
    temperament: b.temperament,
    adult_male_weight_kg: b.adult_male_weight_kg,
    adult_female_weight_kg: b.adult_female_weight_kg,
    adaptability: b.adaptability,
    longevity_years: b.longevity_years,
    height_male_cm: b.height_male_cm,
    height_female_cm: b.height_female_cm,
    known_for: b.known_for,
  };
}
