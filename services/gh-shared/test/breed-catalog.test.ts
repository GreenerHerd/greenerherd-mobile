import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  BreedCatalog,
  normalizeBreedKey,
  type BreedRecord,
} from '../db/breed-catalog.js';

const sampleRows: BreedRecord[] = [
  {
    id: '55a6c8ea-1c5f-5475-8fb8-9fba6ca00e93',
    species: 'CATTLE',
    code: 'HOLSTEIN',
    name_en: 'Holstein',
    names: { en: 'Holstein' },
    name_ar: 'هولشتاين',
    name_ur: null,
    name_fr: null,
    origin: 'Netherlands',
    primary_purpose: 'Dairy',
    color: null,
    milk_production_kg_year: null,
    heat_tolerance: null,
    disease_resistance: null,
    birth_ease: null,
    feed_efficiency: null,
    temperament: null,
    adult_male_weight_kg: null,
    adult_female_weight_kg: null,
    adaptability: null,
    longevity_years: null,
    height_male_cm: null,
    height_female_cm: null,
    known_for: null,
  },
  {
    id: 'f6dbd7d3-cf1e-5a9d-b31d-6ba94d2668ca',
    species: 'GOAT',
    code: 'ARADI_AARDI',
    name_en: 'Aradi/Aardi',
    names: { en: 'Aradi/Aardi' },
    name_ar: null,
    name_ur: null,
    name_fr: null,
    origin: null,
    primary_purpose: null,
    color: null,
    milk_production_kg_year: null,
    heat_tolerance: null,
    disease_resistance: null,
    birth_ease: null,
    feed_efficiency: null,
    temperament: null,
    adult_male_weight_kg: null,
    adult_female_weight_kg: null,
    adaptability: null,
    longevity_years: null,
    height_male_cm: null,
    height_female_cm: null,
    known_for: null,
  },
];

describe('BreedCatalog', () => {
  it('resolves breeds by English name and slash alias', () => {
    const catalog = BreedCatalog.fromRecords(sampleRows);
    assert.equal(catalog.resolve('CATTLE', 'Holstein')?.code, 'HOLSTEIN');
    assert.equal(catalog.resolve('GOAT', 'Aardi')?.code, 'ARADI_AARDI');
  });

  it('stores and returns in-memory weight curves', () => {
    const catalog = BreedCatalog.fromRecords(sampleRows);
    catalog.setWeights(sampleRows[0].id, [
      { sex: 'FEMALE', age_months: 12, weight_kg: 340 },
    ]);
    assert.equal(catalog.getWeights(sampleRows[0].id)?.length, 1);
    assert.equal(catalog.getWeights(sampleRows[1].id), null);
  });

  it('normalizes breed lookup keys', () => {
    assert.equal(normalizeBreedKey('  Holstein '), 'holstein');
    assert.equal(normalizeBreedKey('Aradi/Aardi'), 'aradi_aardi');
  });
});
