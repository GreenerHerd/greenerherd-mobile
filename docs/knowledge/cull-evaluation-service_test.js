/**
 * Greener Herd — Cull Evaluation Algorithm Tests
 * Run with:  node cull-evaluation-service.test.js
 * (No test framework dependency — pure Node assertions)
 */

'use strict';

const assert = require('assert');
const {
  evaluateCullCandidates,
  computeHerdMilkAverage,
  formatCullSummary,
  DEFAULT_THRESHOLDS,
  PRIORITY,
} = require('./cull-evaluation-service');

// ─── helpers ────────────────────────────────────────────────────────────────

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  ✓  ${name}`);
    passed++;
  } catch (err) {
    console.error(`  ✗  ${name}`);
    console.error(`     ${err.message}`);
    failed++;
  }
}

function daysAgo(n, from = new Date('2025-01-01')) {
  const d = new Date(from);
  d.setDate(d.getDate() - n);
  return d.toISOString();
}

function monthsAgo(n, from = new Date('2025-01-01')) {
  const d = new Date(from);
  d.setMonth(d.getMonth() - n);
  return d.toISOString();
}

const AS_OF = new Date('2025-01-01');

// ─── factory helpers ─────────────────────────────────────────────────────────

function makeAnimal(overrides = {}) {
  return {
    id: 'animal-1',
    species: 'CATTLE',
    sex: 'FEMALE',
    breed: 'Holstein',
    dob: monthsAgo(36, AS_OF),   // 3 years old — well past breeding age
    status: 'ACTIVE',
    cull_flagged: false,
    _groupPurpose: 'MILK',
    ...overrides,
  };
}

function makeWeightHistory(gains, daySpacing = 30, baseWeight = 400, startDaysAgo = 90) {
  // gains: array of daily gain rates (kg/day) for each interval
  const records = [];
  let currentWeight = baseWeight;
  let currentDay = startDaysAgo;
  records.push({ recorded_at: daysAgo(currentDay, AS_OF), weight_kg: currentWeight });
  for (const gain of gains) {
    currentDay -= daySpacing;
    currentWeight += gain * daySpacing;
    records.push({ recorded_at: daysAgo(currentDay, AS_OF), weight_kg: currentWeight });
  }
  return records;
}

function makeMilkRecords(animalId, dailyVolume, daysCount = 90, startDaysAgo = 90) {
  const records = [];
  for (let i = 0; i < daysCount; i++) {
    records.push({
      animal_id: animalId,
      recorded_date: daysAgo(startDaysAgo - i, AS_OF),
      volume_litres: dailyVolume,
      session: 'MORNING',
    });
  }
  return records;
}

// ─── TEST SUITES ─────────────────────────────────────────────────────────────

console.log('\n══════════════════════════════════════════════');
console.log(' Greener Herd — Cull Algorithm Test Suite');
console.log('══════════════════════════════════════════════\n');

// ── Suite 1: Input validation ────────────────────────────────────────────────
console.log('Suite 1: Input validation');

test('throws when animals is empty array', () => {
  assert.throws(
    () => evaluateCullCandidates([], {}, { farmSpeciesPurpose: {}, asOf: AS_OF }),
    /non-empty array/
  );
});

test('throws when animals is not an array', () => {
  assert.throws(
    () => evaluateCullCandidates(null, {}, {}),
    /non-empty array/
  );
});

test('excludes non-ACTIVE animals', () => {
  const sold = makeAnimal({ id: 'sold-1', status: 'SOLD' });
  const results = evaluateCullCandidates([sold], {}, { farmSpeciesPurpose: { CATTLE: 'MILK' }, asOf: AS_OF });
  assert.strictEqual(results.length, 0, 'SOLD animal should be excluded');
});

// ── Suite 2: Zero-score baseline ─────────────────────────────────────────────
console.log('\nSuite 2: Zero-score baseline (healthy animal)');

test('healthy young female scores zero', () => {
  const animal = makeAnimal({ id: 'healthy-1', dob: monthsAgo(30, AS_OF) });
  const data = {
    breedingEvents: { 'healthy-1': [{ method: 'NATURAL', outcome: 'BORN', event_date: monthsAgo(6, AS_OF) }] },
    pregnancies:    { 'healthy-1': [] },
    healthRecords:  { 'healthy-1': [] },
    weightHistory:  { 'healthy-1': makeWeightHistory([0.85, 0.80], 30, 450) },
    milkRecords:    { 'healthy-1': makeMilkRecords('healthy-1', 25) },
  };
  const context = {
    farmSpeciesPurpose: { CATTLE: 'MILK' },
    herdMilkAvgPerDay:  { CATTLE: 25 },
    asOf: AS_OF,
  };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.priority, PRIORITY.NONE, `Expected NONE, got ${result.priority} (score ${result.totalScore})`);
  assert.strictEqual(result.totalScore, 0);
});

// ── Suite 3: Reproductive inactivity ─────────────────────────────────────────
console.log('\nSuite 3: Reproductive inactivity');

test('female with no pregnancy in 12 months is flagged', () => {
  const animal = makeAnimal({ id: 'repro-1' });
  const data = {
    breedingEvents: { 'repro-1': [{ method: 'NATURAL', outcome: 'FAILED', event_date: monthsAgo(14, AS_OF) }] },
    pregnancies:    { 'repro-1': [] },
    healthRecords:  { 'repro-1': [] },
    weightHistory:  { 'repro-1': makeWeightHistory([0.85], 30, 450) },
    milkRecords:    { 'repro-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.reproductiveInactivity.triggered, 'reproductive inactivity should trigger');
  assert.ok(result.totalScore > 0);
});

test('female under minimum breeding age is NOT penalised for inactivity', () => {
  const youngGoat = makeAnimal({ id: 'young-1', species: 'GOAT', dob: monthsAgo(5, AS_OF) });
  const data = {
    breedingEvents: { 'young-1': [] },
    pregnancies: { 'young-1': [] },
    healthRecords: { 'young-1': [] },
    weightHistory: { 'young-1': [] },
    milkRecords: { 'young-1': [] },
  };
  const context = { farmSpeciesPurpose: { GOAT: 'MILK' }, herdMilkAvgPerDay: { GOAT: 2 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([youngGoat], data, context);
  assert.strictEqual(result.dimensionScores.reproductiveInactivity.triggered, false);
});

test('male animals are NOT penalised for reproductive inactivity', () => {
  const bull = makeAnimal({ id: 'bull-1', sex: 'MALE' });
  const data = {
    breedingEvents: { 'bull-1': [] },
    pregnancies: { 'bull-1': [] },
    healthRecords: { 'bull-1': [] },
    weightHistory: { 'bull-1': [] },
    milkRecords: { 'bull-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([bull], data, context);
  assert.strictEqual(result.dimensionScores.reproductiveInactivity.triggered, false);
});

test('recent pregnancy within 12 months clears reproductive flag', () => {
  const animal = makeAnimal({ id: 'recent-preg-1' });
  const data = {
    breedingEvents: { 'recent-preg-1': [{ method: 'NATURAL', outcome: 'CONFIRMED_PREGNANT', event_date: monthsAgo(3, AS_OF) }] },
    pregnancies:    { 'recent-preg-1': [] },
    healthRecords:  { 'recent-preg-1': [] },
    weightHistory:  { 'recent-preg-1': [] },
    milkRecords:    { 'recent-preg-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'BOTH' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.reproductiveInactivity.triggered, false);
});

// ── Suite 4: Failed AI ────────────────────────────────────────────────────────
console.log('\nSuite 4: Failed AI attempts');

test('3+ failed AI attempts in current cycle triggers flag', () => {
  const animal = makeAnimal({ id: 'ai-fail-1' });
  const data = {
    breedingEvents: {
      'ai-fail-1': [
        { method: 'AI', outcome: 'FAILED',  event_date: monthsAgo(5, AS_OF) },
        { method: 'AI', outcome: 'FAILED',  event_date: monthsAgo(4, AS_OF) },
        { method: 'AI', outcome: 'PENDING', event_date: monthsAgo(2, AS_OF) },
      ],
    },
    pregnancies:   { 'ai-fail-1': [] },
    healthRecords: { 'ai-fail-1': [] },
    weightHistory: { 'ai-fail-1': [] },
    milkRecords:   { 'ai-fail-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.failedAi.triggered, 'failedAi should trigger');
});

test('AI failures reset after a successful pregnancy', () => {
  const animal = makeAnimal({ id: 'ai-reset-1' });
  const data = {
    breedingEvents: {
      'ai-reset-1': [
        { method: 'AI', outcome: 'FAILED',             event_date: monthsAgo(18, AS_OF) },
        { method: 'AI', outcome: 'FAILED',             event_date: monthsAgo(17, AS_OF) },
        { method: 'AI', outcome: 'FAILED',             event_date: monthsAgo(16, AS_OF) },
        { method: 'AI', outcome: 'CONFIRMED_PREGNANT', event_date: monthsAgo(14, AS_OF) }, // success resets
        { method: 'AI', outcome: 'FAILED',             event_date: monthsAgo(3, AS_OF) },  // only 1 failure since reset
      ],
    },
    pregnancies:   { 'ai-reset-1': [] },
    healthRecords: { 'ai-reset-1': [] },
    weightHistory: { 'ai-reset-1': [] },
    milkRecords:   { 'ai-reset-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.failedAi.triggered, false, 'failedAi should NOT trigger after reset');
});

// ── Suite 5: Miscarriages ─────────────────────────────────────────────────────
console.log('\nSuite 5: Frequent miscarriages');

test('2 miscarriages in 12 months triggers flag', () => {
  const animal = makeAnimal({ id: 'misc-1' });
  const data = {
    breedingEvents: { 'misc-1': [] },
    pregnancies: {
      'misc-1': [
        { outcome: 'MISCARRIAGE', actual_birth_date: monthsAgo(3, AS_OF) },
        { outcome: 'MISCARRIAGE', actual_birth_date: monthsAgo(7, AS_OF) },
      ],
    },
    healthRecords: { 'misc-1': [] },
    weightHistory: { 'misc-1': [] },
    milkRecords:   { 'misc-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'BOTH' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.frequentMiscarriage.triggered);
  assert.ok(result.cullReasons.some(r => r.includes('miscarriage')));
});

test('1 miscarriage does NOT trigger flag', () => {
  const animal = makeAnimal({ id: 'misc-2' });
  const data = {
    breedingEvents: { 'misc-2': [] },
    pregnancies:    { 'misc-2': [{ outcome: 'MISCARRIAGE', actual_birth_date: monthsAgo(4, AS_OF) }] },
    healthRecords:  { 'misc-2': [] },
    weightHistory:  { 'misc-2': [] },
    milkRecords:    { 'misc-2': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'BOTH' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.frequentMiscarriage.triggered, false);
});

// ── Suite 6: Health ───────────────────────────────────────────────────────────
console.log('\nSuite 6: Health records');

test('3+ illness episodes in 12 months triggers frequentIllness', () => {
  const animal = makeAnimal({ id: 'sick-1', sex: 'MALE', _groupPurpose: 'MAINTENANCE' });
  const data = {
    breedingEvents: { 'sick-1': [] },
    pregnancies:    { 'sick-1': [] },
    healthRecords: {
      'sick-1': [
        { date_applied: monthsAgo(2, AS_OF),  illness_description: 'Respiratory infection' },
        { date_applied: monthsAgo(5, AS_OF),  illness_description: 'Fever' },
        { date_applied: monthsAgo(9, AS_OF),  illness_description: 'Diarrhoea' },
      ],
    },
    weightHistory: { 'sick-1': [] },
    milkRecords:   { 'sick-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.frequentIllness.triggered);
});

test('mastitis keyword triggers chronicIllness flag', () => {
  const animal = makeAnimal({ id: 'mastitis-1' });
  const data = {
    breedingEvents: { 'mastitis-1': [] },
    pregnancies:    { 'mastitis-1': [] },
    healthRecords: {
      'mastitis-1': [
        { date_applied: monthsAgo(3, AS_OF), illness_description: 'Subclinical mastitis' },
      ],
    },
    weightHistory: { 'mastitis-1': [] },
    milkRecords:   { 'mastitis-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.chronicIllness.triggered, 'chronicIllness should trigger for mastitis');
});

test('same illness recurring twice triggers chronicIllness', () => {
  const animal = makeAnimal({ id: 'recur-1', sex: 'MALE' });
  const data = {
    breedingEvents: { 'recur-1': [] },
    pregnancies:    { 'recur-1': [] },
    healthRecords: {
      'recur-1': [
        { date_applied: monthsAgo(2, AS_OF), illness_description: 'Foot rot' },
        { date_applied: monthsAgo(6, AS_OF), illness_description: 'Foot rot' },
      ],
    },
    weightHistory: { 'recur-1': [] },
    milkRecords:   { 'recur-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.chronicIllness.triggered, 'recurring foot rot should trigger chronicIllness');
});

test('health events older than 12 months do NOT count', () => {
  const animal = makeAnimal({ id: 'old-sick-1', sex: 'MALE' });
  const data = {
    breedingEvents: { 'old-sick-1': [] },
    pregnancies:    { 'old-sick-1': [] },
    healthRecords: {
      'old-sick-1': [
        { date_applied: monthsAgo(15, AS_OF), illness_description: 'Mastitis' },
        { date_applied: monthsAgo(18, AS_OF), illness_description: 'Mastitis' },
        { date_applied: monthsAgo(20, AS_OF), illness_description: 'Pneumonia' },
      ],
    },
    weightHistory: { 'old-sick-1': [] },
    milkRecords:   { 'old-sick-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.frequentIllness.triggered, false, 'old health records should not count');
  assert.strictEqual(result.dimensionScores.chronicIllness.triggered, false);
});

// ── Suite 7: Weight gain ──────────────────────────────────────────────────────
console.log('\nSuite 7: Weight gain');

test('cattle gaining <60% of expected daily gain is flagged', () => {
  // Expected cattle daily gain = 0.80 kg/day. 60% threshold = 0.48 kg/day.
  // We give 0.30 kg/day → below threshold.
  const animal = makeAnimal({ id: 'poor-gain-1', sex: 'MALE', _groupPurpose: 'MAINTENANCE' });
  const data = {
    breedingEvents: { 'poor-gain-1': [] },
    pregnancies:    { 'poor-gain-1': [] },
    healthRecords:  { 'poor-gain-1': [] },
    weightHistory: {
      'poor-gain-1': makeWeightHistory([0.30, 0.30], 30, 300, 90),
    },
    milkRecords: { 'poor-gain-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.poorWeightGain.triggered, 'poor weight gain should trigger');
  assert.ok(result.dimensionScores.poorWeightGain.detail.includes('kg/day'));
});

test('cattle losing weight scores higher than just poor gain', () => {
  const animalLoss = makeAnimal({ id: 'loss-1', sex: 'MALE' });
  const animalPoor = makeAnimal({ id: 'poor-1', sex: 'MALE' });

  const makeData = (id, gainPerDay) => ({
    breedingEvents: { [id]: [] },
    pregnancies:    { [id]: [] },
    healthRecords:  { [id]: [] },
    weightHistory:  { [id]: makeWeightHistory([gainPerDay, gainPerDay], 30, 400, 90) },
    milkRecords:    { [id]: [] },
  });

  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [lossResult] = evaluateCullCandidates([animalLoss], makeData('loss-1', -0.20), context);
  const [poorResult] = evaluateCullCandidates([animalPoor], makeData('poor-1', 0.30), context);

  assert.ok(lossResult.dimensionScores.poorWeightGain.score >= poorResult.dimensionScores.poorWeightGain.score,
    'weight loss should score >= poor gain');
});

test('only 1 weight record does NOT trigger flag', () => {
  const animal = makeAnimal({ id: 'single-weight-1', sex: 'MALE' });
  const data = {
    breedingEvents: { 'single-weight-1': [] },
    pregnancies:    { 'single-weight-1': [] },
    healthRecords:  { 'single-weight-1': [] },
    weightHistory:  { 'single-weight-1': [{ recorded_at: daysAgo(30, AS_OF), weight_kg: 350 }] },
    milkRecords:    { 'single-weight-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.poorWeightGain.triggered, false);
});

test('fattening group uses higher expected daily gain', () => {
  // Cattle fattening: 1.10 kg/day expected. 60% = 0.66 kg/day.
  // Actual = 0.80 kg/day → above threshold → should NOT trigger.
  const animal = makeAnimal({ id: 'fatten-1', sex: 'MALE', _groupPurpose: 'FATTENING' });
  const data = {
    breedingEvents: { 'fatten-1': [] },
    pregnancies:    { 'fatten-1': [] },
    healthRecords:  { 'fatten-1': [] },
    weightHistory:  { 'fatten-1': makeWeightHistory([0.80, 0.80], 30, 300, 90) },
    milkRecords:    { 'fatten-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  // 0.80 / 1.10 = 72.7% which is above 60% threshold → should NOT trigger
  assert.strictEqual(result.dimensionScores.poorWeightGain.triggered, false,
    'Fattening animal gaining 0.80 should pass against 1.10 expected');
});

// ── Suite 8: Milk production ──────────────────────────────────────────────────
console.log('\nSuite 8: Milk production');

test('cow producing <70% of herd average is flagged', () => {
  const animal = makeAnimal({ id: 'low-milk-1' });
  const milkRecords = makeMilkRecords('low-milk-1', 15, 90); // 15 L/day
  const data = {
    breedingEvents: { 'low-milk-1': [{ method: 'NATURAL', outcome: 'BORN', event_date: monthsAgo(6, AS_OF) }] },
    pregnancies:    { 'low-milk-1': [] },
    healthRecords:  { 'low-milk-1': [] },
    weightHistory:  { 'low-milk-1': [] },
    milkRecords:    { 'low-milk-1': milkRecords },
  };
  const context = {
    farmSpeciesPurpose:  { CATTLE: 'MILK' },
    herdMilkAvgPerDay:   { CATTLE: 25 },  // this animal = 15/25 = 60% → below 70% threshold
    asOf: AS_OF,
  };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.lowMilkVsHerd.triggered, 'low milk vs herd should trigger');
  assert.ok(result.dimensionScores.lowMilkVsHerd.detail.includes('60%'));
});

test('cow producing exactly herd average is NOT flagged', () => {
  const animal = makeAnimal({ id: 'avg-milk-1' });
  const data = {
    breedingEvents: { 'avg-milk-1': [] },
    pregnancies:    { 'avg-milk-1': [] },
    healthRecords:  { 'avg-milk-1': [] },
    weightHistory:  { 'avg-milk-1': [] },
    milkRecords:    { 'avg-milk-1': makeMilkRecords('avg-milk-1', 25, 90) },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.lowMilkVsHerd.triggered, false);
});

test('MEAT-only farm does NOT evaluate milk production', () => {
  const animal = makeAnimal({ id: 'meat-1' });
  const data = {
    breedingEvents: { 'meat-1': [] },
    pregnancies:    { 'meat-1': [] },
    healthRecords:  { 'meat-1': [] },
    weightHistory:  { 'meat-1': [] },
    milkRecords:    { 'meat-1': makeMilkRecords('meat-1', 5, 90) },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.lowMilkVsHerd.triggered, false, 'MEAT farm should not evaluate milk');
});

test('declining milk trend is flagged', () => {
  const animal = makeAnimal({ id: 'decline-1' });
  // Historical peak: 30 L/day (days 90–60 ago)
  // Recent 30 days: 18 L/day → 40% drop → above 25% threshold
  const historicRecords = makeMilkRecords('decline-1', 30, 60, 90);
  const recentRecords = makeMilkRecords('decline-1', 18, 30, 30);
  const allRecords = [...historicRecords, ...recentRecords];

  const data = {
    breedingEvents: { 'decline-1': [] },
    pregnancies:    { 'decline-1': [] },
    healthRecords:  { 'decline-1': [] },
    weightHistory:  { 'decline-1': [] },
    milkRecords:    { 'decline-1': allRecords },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 20 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.decliningMilk.triggered, 'declining milk should trigger');
  assert.ok(result.dimensionScores.decliningMilk.detail.includes('declined'));
});

// ── Suite 9: Age ──────────────────────────────────────────────────────────────
console.log('\nSuite 9: Age evaluation');

test('cattle over 7 years old gets age flag', () => {
  const animal = makeAnimal({ id: 'old-1', sex: 'MALE', dob: monthsAgo(96, AS_OF) }); // 8 years
  const data = {
    breedingEvents: { 'old-1': [] },
    pregnancies:    { 'old-1': [] },
    healthRecords:  { 'old-1': [] },
    weightHistory:  { 'old-1': [] },
    milkRecords:    { 'old-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.overPeakAge.triggered, 'old cattle should trigger age flag');
  assert.ok(result.dimensionScores.overPeakAge.detail.includes('past peak'));
});

test('young cattle below peak age does NOT get age flag', () => {
  const animal = makeAnimal({ id: 'young-cattle-1', dob: monthsAgo(48, AS_OF) }); // 4 years
  const data = {
    breedingEvents: { 'young-cattle-1': [{ method: 'NATURAL', outcome: 'BORN', event_date: monthsAgo(6, AS_OF) }] },
    pregnancies:    { 'young-cattle-1': [] },
    healthRecords:  { 'young-cattle-1': [] },
    weightHistory:  { 'young-cattle-1': [] },
    milkRecords:    { 'young-cattle-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.dimensionScores.overPeakAge.triggered, false);
});

// ── Suite 10: Cull flag ───────────────────────────────────────────────────────
console.log('\nSuite 10: Admin cull flag');

test('cull_flagged=true adds to score', () => {
  const animal = makeAnimal({ id: 'flagged-1', cull_flagged: true });
  const data = {
    breedingEvents: { 'flagged-1': [{ method: 'NATURAL', outcome: 'BORN', event_date: monthsAgo(3, AS_OF) }] },
    pregnancies:    { 'flagged-1': [] },
    healthRecords:  { 'flagged-1': [] },
    weightHistory:  { 'flagged-1': makeWeightHistory([0.85], 30, 450) },
    milkRecords:    { 'flagged-1': makeMilkRecords('flagged-1', 25, 90) },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.ok(result.dimensionScores.alreadyCullFlagged.triggered);
  assert.ok(result.totalScore > 0);
});

// ── Suite 11: Priority thresholds ────────────────────────────────────────────
console.log('\nSuite 11: Priority classification');

test('score=0 → NONE', () => {
  const { PRIORITY: P } = require('./cull-evaluation-service');
  // We need a genuinely clean animal — use a 2-year-old male with good gain, fresh breeding success
  const animal = makeAnimal({ id: 'prio-none', sex: 'MALE', _groupPurpose: 'MAINTENANCE' });
  const data = {
    breedingEvents: { 'prio-none': [] },
    pregnancies:    { 'prio-none': [] },
    healthRecords:  { 'prio-none': [] },
    weightHistory:  { 'prio-none': makeWeightHistory([0.90], 30, 400) },
    milkRecords:    { 'prio-none': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MEAT' }, herdMilkAvgPerDay: {}, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(result.priority, P.NONE);
});

// ── Suite 12: Ranking ─────────────────────────────────────────────────────────
console.log('\nSuite 12: Ranking and sorting');

test('results are sorted highest score first', () => {
  const goodAnimal = makeAnimal({ id: 'rank-good', cull_flagged: false });
  const badAnimal  = makeAnimal({
    id: 'rank-bad',
    cull_flagged: true,
    dob: monthsAgo(100, AS_OF), // very old
  });

  const makeDataFor = id => ({
    breedingEvents: { [id]: [] },
    pregnancies:    { [id]: [] },
    healthRecords: {
      [id]: id === 'rank-bad'
        ? [
            { date_applied: monthsAgo(2, AS_OF), illness_description: 'Mastitis' },
            { date_applied: monthsAgo(4, AS_OF), illness_description: 'Mastitis' },
            { date_applied: monthsAgo(6, AS_OF), illness_description: 'Lameness' },
          ]
        : [],
    },
    weightHistory: { [id]: [] },
    milkRecords:   { [id]: [] },
  });

  const animals = [goodAnimal, badAnimal];
  const data = {
    breedingEvents: { ...makeDataFor('rank-good').breedingEvents, ...makeDataFor('rank-bad').breedingEvents },
    pregnancies:    { ...makeDataFor('rank-good').pregnancies,    ...makeDataFor('rank-bad').pregnancies },
    healthRecords:  { ...makeDataFor('rank-good').healthRecords,  ...makeDataFor('rank-bad').healthRecords },
    weightHistory:  { ...makeDataFor('rank-good').weightHistory,  ...makeDataFor('rank-bad').weightHistory },
    milkRecords:    { ...makeDataFor('rank-good').milkRecords,    ...makeDataFor('rank-bad').milkRecords },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const results = evaluateCullCandidates(animals, data, context);

  assert.strictEqual(results[0].animalId, 'rank-bad', 'bad animal should be ranked first');
  assert.ok(results[0].totalScore >= results[1].totalScore, 'scores should be descending');
});

// ── Suite 13: computeHerdMilkAverage ─────────────────────────────────────────
console.log('\nSuite 13: computeHerdMilkAverage');

test('correctly averages daily milk across herd', () => {
  const records = [
    ...makeMilkRecords('a1', 20, 30),
    ...makeMilkRecords('a2', 30, 30),
  ];
  const avg = computeHerdMilkAverage(records, AS_OF, 90);
  // Each animal has 30 days × 1 record each = 30 records each, daily total = 20 or 30
  assert.ok(avg >= 20 && avg <= 30, `Expected avg between 20-30, got ${avg}`);
});

test('returns 0 when no records', () => {
  const avg = computeHerdMilkAverage([], AS_OF, 90);
  assert.strictEqual(avg, 0);
});

// ── Suite 14: formatCullSummary ───────────────────────────────────────────────
console.log('\nSuite 14: formatCullSummary');

test('produces readable multi-line output', () => {
  const animal = makeAnimal({ id: 'fmt-1', cull_flagged: true });
  const data = {
    breedingEvents: { 'fmt-1': [] },
    pregnancies:    { 'fmt-1': [] },
    healthRecords: {
      'fmt-1': [
        { date_applied: monthsAgo(2, AS_OF), illness_description: 'Mastitis' },
        { date_applied: monthsAgo(5, AS_OF), illness_description: 'Mastitis' },
        { date_applied: monthsAgo(8, AS_OF), illness_description: 'Lameness' },
      ],
    },
    weightHistory: { 'fmt-1': makeWeightHistory([-0.10, -0.10], 30, 400) },
    milkRecords:   { 'fmt-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: { CATTLE: 25 }, asOf: AS_OF };
  const [result] = evaluateCullCandidates([animal], data, context);
  const summary = formatCullSummary(result);

  assert.ok(summary.includes('Species: CATTLE'), 'summary should include species');
  assert.ok(summary.includes('Priority'), 'summary should include priority');
  assert.ok(summary.includes('Reasons:'), 'summary should have reasons section');
});

// ── Suite 15: Threshold overrides ────────────────────────────────────────────
console.log('\nSuite 15: Custom threshold overrides');

test('custom reproductiveInactivityMonths override works', () => {
  const animal = makeAnimal({ id: 'custom-thresh-1' });
  const data = {
    breedingEvents: {
      'custom-thresh-1': [{ method: 'NATURAL', outcome: 'BORN', event_date: monthsAgo(7, AS_OF) }]
    },
    pregnancies:   { 'custom-thresh-1': [] },
    healthRecords: { 'custom-thresh-1': [] },
    weightHistory: { 'custom-thresh-1': [] },
    milkRecords:   { 'custom-thresh-1': [] },
  };
  const context = { farmSpeciesPurpose: { CATTLE: 'MILK' }, herdMilkAvgPerDay: {}, asOf: AS_OF };

  // With default 12-month window → last birth at 7 months ago → NOT flagged
  const [defaultResult] = evaluateCullCandidates([animal], data, context);
  assert.strictEqual(defaultResult.dimensionScores.reproductiveInactivity.triggered, false);

  // Override to 6-month window → last birth at 7 months ago → NOW flagged
  const [strictResult] = evaluateCullCandidates([animal], data, context, {
    thresholds: { reproductiveInactivityMonths: 6 },
  });
  assert.ok(strictResult.dimensionScores.reproductiveInactivity.triggered, 'strict threshold should flag');
});

// ── RESULTS ───────────────────────────────────────────────────────────────────

console.log('\n══════════════════════════════════════════════');
console.log(` Results: ${passed} passed, ${failed} failed`);
console.log('══════════════════════════════════════════════\n');

if (failed > 0) {
  process.exit(1);
}
