import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { namesFromLegacyRow } from '../db/catalog-i18n.js';
import {
  BreedCatalog,
  type BreedRecord,
  type BreedSpecies,
  type BreedWeightPoint,
} from '../db/breed-catalog.js';

const HOLSTEIN_ID = '55a6c8ea-1c5f-5475-8fb8-9fba6ca00e93';

const SAMPLE_WEIGHTS: BreedWeightPoint[] = [
  { sex: 'FEMALE', age_months: 6, weight_kg: 180 },
  { sex: 'FEMALE', age_months: 12, weight_kg: 340 },
  { sex: 'FEMALE', age_months: 24, weight_kg: 520 },
  { sex: 'MALE', age_months: 12, weight_kg: 380 },
  { sex: 'MALE', age_months: 24, weight_kg: 650 },
];

function breedsJsonPath(): string {
  return path.resolve(
    fileURLToPath(new URL('.', import.meta.url)),
    '../../../assets/data/breeds.json',
  );
}

function toRecord(raw: Record<string, unknown>): BreedRecord {
  const name_en = String(raw.name_en);
  const name_ar = (raw.name_ar as string | null | undefined) ?? null;
  const names =
    raw.names && typeof raw.names === 'object'
      ? (raw.names as Record<string, string>)
      : namesFromLegacyRow({ name_en, name_ar });
  return {
    id: String(raw.id),
    species: raw.species as BreedSpecies,
    code: String(raw.code),
    name_en,
    names,
    name_ar,
    name_ur: null,
    name_fr: null,
    origin: (raw.origin as string | null | undefined) ?? null,
    primary_purpose: (raw.primary_purpose as string | null | undefined) ?? null,
    color: (raw.color as string | null | undefined) ?? null,
    milk_production_kg_year:
      (raw.milk_production_kg_year as string | null | undefined) ?? null,
    heat_tolerance: (raw.heat_tolerance as string | null | undefined) ?? null,
    disease_resistance:
      (raw.disease_resistance as string | null | undefined) ?? null,
    birth_ease: (raw.birth_ease as string | null | undefined) ?? null,
    feed_efficiency: null,
    temperament: null,
    adult_male_weight_kg: null,
    adult_female_weight_kg: null,
    adaptability: null,
    longevity_years: null,
    height_male_cm: null,
    height_female_cm: null,
    known_for: (raw.known_for as string | null | undefined) ?? null,
  };
}

let cached: BreedCatalog | undefined;

/** Full breed catalog from mobile assets — used by BDD when Postgres is not available. */
export function loadBddBreedCatalog(): BreedCatalog {
  if (cached) return cached;

  const file = breedsJsonPath();
  const parsed = JSON.parse(readFileSync(file, 'utf8')) as {
    breeds: Record<string, unknown>[];
  };
  const catalog = BreedCatalog.fromRecords(parsed.breeds.map(toRecord));
  catalog.setWeights(HOLSTEIN_ID, SAMPLE_WEIGHTS);
  cached = catalog;
  return catalog;
}

export function holsteinBreedId(): string {
  return HOLSTEIN_ID;
}
