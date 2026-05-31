import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  NutritionRequirementsCatalog,
  type NutritionRequirementProfile,
} from '../db/nutrition-requirements-catalog.js';

function jsonPath(): string {
  return path.resolve(
    fileURLToPath(new URL('.', import.meta.url)),
    '../../../assets/data/nutrition_requirements.json',
  );
}

function toRecord(raw: Record<string, unknown>): NutritionRequirementProfile {
  const num = (v: unknown) =>
    v === null || v === undefined ? null : Number(v);
  return {
    id: String(raw.id),
    profile_code: String(raw.profile_code),
    species: raw.species as NutritionRequirementProfile['species'],
    production_system:
      raw.production_system as NutritionRequirementProfile['production_system'],
    life_stage: String(raw.life_stage),
    animal_class: (raw.animal_class as string | null) ?? null,
    body_weight_kg: num(raw.body_weight_kg),
    months_since_calving: num(raw.months_since_calving) as number | null,
    dmi_kg_day: Number(raw.dmi_kg_day),
    cp_percent_dm: num(raw.cp_percent_dm),
    nel_mcal_per_kg_dm: num(raw.nel_mcal_per_kg_dm),
    ndf_percent_dm: num(raw.ndf_percent_dm),
    adf_percent_dm: num(raw.adf_percent_dm),
    ca_percent_dm: num(raw.ca_percent_dm),
    p_percent_dm: num(raw.p_percent_dm),
    milk_kg_day: num(raw.milk_kg_day),
    tdn_kg_day: num(raw.tdn_kg_day),
    nem_mcal_day: num(raw.nem_mcal_day),
    neg_mcal_day: num(raw.neg_mcal_day),
    cp_kg_day: num(raw.cp_kg_day),
    ca_kg_day: num(raw.ca_kg_day),
    p_kg_day: num(raw.p_kg_day),
    fodder_percent: num(raw.fodder_percent),
    concentrate_percent: num(raw.concentrate_percent),
    source_sheet: (raw.source_sheet as string | null) ?? null,
  };
}

let cached: NutritionRequirementsCatalog | undefined;

export function loadBddNutritionRequirementsCatalog(): NutritionRequirementsCatalog {
  if (cached) return cached;
  const parsed = JSON.parse(readFileSync(jsonPath(), 'utf8')) as {
    profiles: Record<string, unknown>[];
  };
  cached = NutritionRequirementsCatalog.fromRecords(
    parsed.profiles.map(toRecord),
  );
  return cached;
}
