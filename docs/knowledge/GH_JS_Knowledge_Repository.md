# Greener Herd — JavaScript Knowledge Repository

> **Purpose:** Authoritative reference for all business logic, rules, data, and infrastructure encoded in the Greener Herd JavaScript codebase. Structured so agents, skills, and developers can quickly understand what each module does, what it expects, and how to call it. Three categories of content are distinguished throughout:
>
> - 🔵 **RULES** — Business logic/constraints baked into code. Do not change without a product decision.
> - 🟢 **DATABASE** — Seed data that lives in code but can grow (new rows can be added).
> - 🟡 **APP LOGIC** — Algorithms and services that power mobile-app features.

---

## Table of Contents

1. [Feed Database (`feeds.json`)](#1-feed-database)
2. [Feed Eligibility Rules (`feed-eligibility-service.js`)](#2-feed-eligibility-rules)
3. [Cattle Feed Optimiser (`optimizer.js`)](#3-cattle-feed-optimiser)
4. [Small Ruminant Optimiser (`small-ruminant-optimizer.js`)](#4-small-ruminant-optimiser)
5. [Cull Evaluation Service (`cull-evaluation-service.js`)](#5-cull-evaluation-service)
6. [Email Service (`mailgunEmailService.js`)](#6-email-service)
7. [Shared Constants & Mappings](#7-shared-constants--mappings)
8. [Data Contracts Summary](#8-data-contracts-summary)

---

## 1. Feed Database

> 🟢 **DATABASE** — `feeds.json`
>
> Seed catalogue of 35 feed ingredients. New feeds can be added by appending a row following the schema below. The optimiser and eligibility service consume this catalogue at runtime.

### Schema per Feed Item

| Field | Type | Required | Description |
|---|---|---|---|
| `productid` | string | ✅ | Unique identifier e.g. `"product001"` |
| `name` | string | ✅ | Display name — matches the key in `feedTypeMap` |
| `type` | string | ✅ | `"Fodder"` \| `"Concentrate"` \| `"Additive"` |
| `costPerKg` | number | ✅ | Cost in SAR per kg as-fed |
| `costCurrency` | string | ✅ | Default `"SAR"` |
| `dmPercent` | number | ✅ | Dry matter % (e.g. 88 = 88% DM) |
| `cpPercent` | number | ✅ | Crude protein % of DM |
| `ndfPercent` | number | ✅ | Neutral detergent fibre % of DM |
| `fibrePercent` | number | ✅ | Acid detergent fibre / crude fibre % of DM |
| `calciumPercent` | number | ✅ | Calcium % of DM |
| `phosphorusPercent` | number | ✅ | Phosphorus % of DM |
| `nemMcalPerKg` | number | ✅ | Net energy maintenance (Mcal/kg DM); 0 if not applicable |
| `negMcalPerKg` | number | ✅ | Net energy gain (Mcal/kg DM); 0 if not applicable |
| `maxIntakePercentOfDM` | number \| null | — | Hard cap: max % of total DM ration this ingredient can make up |
| `maxIntakeWeightInKgPerAnimal` | number \| null | — | Hard cap: max kg as-fed per individual animal per day |
| `compositionBasis` | string | ✅ | Always `"dm"` — all percentages are DM-basis |

### Feed Catalogue (All 35 Ingredients)

#### Fodders (16)

| ID | Name | Cost SAR/kg | DM% | CP% | NDF% | Fibre% | Ca% | P% | NEm | NEg | MaxIntake% DM | MaxIntake kg/animal |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| product001 | Alfalfa hay (mid-bloom) | 1.80 | 88 | 18.0 | 48 | 28.0 | 1.50 | 0.30 | 0 | 2.20 | — | — |
| product002 | Wheat Straw | 0.90 | 90 | 3.0 | 80 | 35.0 | 0.30 | 0.10 | 0 | 1.40 | — | — |
| product003 | Triticale Silage | 1.50 | 35 | 10.0 | 50 | 9.0 | 0.25 | 0.30 | 0 | 1.80 | — | — |
| product004 | Oat Hay | 1.50 | 90 | 10.0 | 60 | 32.0 | 0.40 | 0.20 | 0 | 2.10 | — | — |
| product005 | Barley | 1.60 | 88 | 12.3 | 20 | 0 | 0.08 | 0.38 | 2.00 | 1.45 | — | — |
| product006 | Corn | 1.80 | 87.6 | 8.8 | 9 | 3.15 | 0.03 | 0.29 | 2.20 | 1.55 | — | — |
| product007 | Soybean | 2.80 | 90 | 53.0 | 13.86 | 3.54 | 0.30 | 0.61 | 2.10 | 1.50 | — | — |
| product008 | Wheat | 1.70 | 88 | 16.6 | 10 | 3.03 | 0.10 | 0.41 | 2.00 | 1.50 | — | — |
| product009 | Cotton Seed | 2.10 | 93 | 41.0 | 45 | 3.13 | 0.15 | 1.10 | 1.93 | 1.40 | — | — |
| product010 | Beet Pulp | 1.90 | 88.9 | 8.6 | 41.8 | 3.85 | 0.80 | 0.50 | 1.80 | 1.30 | 25 | 2.5 |
| product011 | Wheat Bran | 1.30 | 87 | 16.3 | 40 | 4.35 | 0.15 | 1.20 | 1.75 | 1.20 | 20 | 2.0 |
| product012 | White Hay | 1.60 | 90 | 5.4 | 59.4 | 4.21 | 0.34 | 0.21 | 1.30 | 0.60 | — | — |
| product013 | Red Hay | 1.70 | 92.1 | 3.5 | 57.2 | 1.58 | 0.37 | 0.11 | 1.33 | 0.65 | — | — |
| product014 | Alfalfa | 2.00 | 90.4 | 20.0 | 44 | 4.49 | 4.37 | 0.41 | 1.45 | 0.75 | — | — |
| product015 | Fermented Corn | 2.00 | 35 | 9.0 | 46 | 2.12 | 0.23 | 0.21 | 1.52 | 0.90 | — | — |
| product016 | Soybean Hulls | 2.40 | 91 | 11.0 | 58 | 2.23 | 0.49 | 0.18 | 1.84 | 1.15 | — | — |
| product025 | Alfalfa Hay | 2.00 | 88 | 18.0 | 45 | 27.0 | 1.30 | 0.24 | 1.40 | 0.97 | — | — |

#### Concentrates (15)

| ID | Name | Cost SAR/kg | DM% | CP% | NDF% | Fibre% | Ca% | P% | NEm | NEg | MaxIntake% DM | MaxIntake kg/animal |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| product017 | Barley - raw | 2.50 | 87 | 9.0 | 13.2 | 6.0 | 0.40 | 0.22 | 1.95 | 1.35 | 50 | 5.0 |
| product018 | Barley - Flakes | 1.80 | 87 | 9.0 | 13.2 | 6.0 | 0.40 | 0.22 | 1.95 | 1.35 | 40 | 4.0 |
| product019 | Soya Bean Meal | 2.10 | 87.5 | 47.0 | 11 | 5.0 | 0.20 | 0.67 | 1.87 | 1.30 | 20 | 2.0 |
| product020 | Steamed Corn Flake | 2.10 | 88 | 8.0 | 4.4 | 2.0 | 0.02 | 0.28 | 2.01 | 1.39 | 50 | 5.0 |
| product021 | Steamed Barley Flakes | 2.00 | 87 | 9.0 | 9.9 | 4.5 | 0.06 | 0.33 | 1.87 | 1.30 | 40 | 4.0 |
| product022 | Barley grain | 1.60 | 88 | 12.0 | 20 | 5.0 | 0.05 | 0.35 | 0 | 3.10 | — | — |
| product023 | Soybean husk | 2.40 | 90 | 12.0 | 60 | 35.0 | 0.20 | 0.60 | 0 | 2.50 | — | — |
| product026 | Wheat grain | 1.50 | 88 | 14.0 | 14 | 3.0 | 0.06 | 0.40 | 0 | 3.20 | 0 | 0 |
| product027 | Cotton meal | 2.40 | 92 | 27.0 | 30 | 12.0 | 0.20 | 0.90 | 0 | 2.30 | 15 | 1.5 |
| product028 | Beetroot pellets | 2.10 | 90 | 10.0 | 45 | 15.0 | 0.30 | 0.20 | 0 | 2.90 | 25 | 2.5 |
| product030 | Maize grain | 1.80 | 86 | 9.0 | 12 | 2.0 | 0.02 | 0.30 | 0 | 3.40 | — | — |
| product031 | Corn Silage | 1.40 | 35 | 9.0 | 45 | 8.0 | 0.20 | 0.25 | 0 | 1.85 | — | — |
| product032 | Corn Gluten Meal | 3.70 | 90 | 60.0 | 20 | 2.0 | 0.05 | 0.60 | 0 | 3.20 | 15 | 1.5 |
| product033 | Sesame seed husk | 2.30 | 90 | 0 | 60 | 0 | 0 | 0 | 0 | 2.00 | — | — |

#### Additives (4) — Strict Upper Limits Apply

| ID | Name | Cost SAR/kg | DM% | CP% | Ca% | P% | MaxIntake% DM | MaxIntake kg/animal | Notes |
|---|---|---|---|---|---|---|---|---|---|
| product024 | Molasses | 1.10 | 75 | 3.0 | 0.90 | 0.10 | 10 | 2.0 | Energy/palatability |
| product029 | Limestone | 0.80 | 99 | 0 | 36.0 | 0.02 | 1.5 | 0.15 | Calcium supplement |
| product034 | Salt | 0.70 | 100 | 0 | 0 | 0 | 1 | 0.10 | Mineral balance |
| product035 | Urea | 2.40 | 100 | 281 | 0 | 0 | 1 | 0.10 | Also: max 3% of concentrate; NOT for goats |

---

## 2. Feed Eligibility Rules

> 🔵 **RULES** — `feed-eligibility-service.js`
>
> Determines which feeds from the catalogue are **permissible** for a given animal group before the optimiser runs. This is a filter layer — it does not calculate quantities.

### Animal Group Input Contract

```js
{
  species:          'cattle' | 'sheep' | 'goats' | 'pigs' | 'poultry',
  sex:              'male' | 'female',
  age:              number,        // months, non-negative
  lactationStatus:  'dry' | 'lactating' | 'not_applicable',
  pregnancyStatus:  'pregnant' | 'ready_to_breed' | 'not_applicable'
}
```

### Feed Eligibility Fields (on each feed object)

| Field | Type | Description |
|---|---|---|
| `speciesEligibility` | string[] | **Required.** List of species this feed is eligible for. |
| `minAge` | number \| null | Minimum animal age in months (inclusive). |
| `maxAge` | number \| null | Maximum animal age in months (inclusive). |
| `sexRestrictions` | string[] | If animal sex is in this list, feed is **excluded**. |
| `lactationRestrictions` | string[] | If lactation status is in this list, feed is **excluded**. |
| `pregnancyRestrictions` | string[] | If pregnancy status is in this list, feed is **excluded**. |

### Eligibility Check Logic (ordered)

1. **Species** — `feed.speciesEligibility.includes(animalGroup.species)` → if false, exclude.
2. **Min age** — if animal age < `feed.minAge`, exclude.
3. **Max age** — if animal age > `feed.maxAge`, exclude.
4. **Sex restriction** — if `feed.sexRestrictions` contains the animal's sex, exclude.
5. **Lactation restriction** — if `feed.lactationRestrictions` contains the animal's lactation status, exclude.
6. **Pregnancy restriction** — if `feed.pregnancyRestrictions` contains the animal's pregnancy status, exclude.
7. If all checks pass → eligible.

### Exported Functions

```js
// Returns { animalGroup, eligibleFeeds[], ineligibleFeeds[], summary{} }
getEligibleFeeds(animalGroup, feeds, { includeReasons, strictMode })

// Runs getEligibleFeeds for multiple groups; adds commonEligibleFeeds[]
getEligibleFeedsForMultipleGroups(animalGroups, feeds, options)

// Returns { eligible: bool, reason: string }
isFeedEligibleForAnimalGroup(feed, animalGroup)

// Throws on invalid input
validateAnimalGroup(animalGroup)
validateFeed(feed)
```

### Options

| Option | Default | Description |
|---|---|---|
| `includeReasons` | `false` | Attach eligibility reason string to each returned feed |
| `strictMode` | `true` | Throw on validation errors (vs. skip invalid feeds) |

---

## 3. Cattle Feed Optimiser

> 🔵 **RULES** / 🟡 **APP LOGIC** — `optimizer.js`
>
> Linear programming (LP) solver (`javascript-lp-solver`) that finds the **least-cost feed mix** meeting all daily nutritional requirements for cattle. All composition values are on a **Dry Matter (DM) basis**.

### Input: Requirements Object

```js
{
  dryMatterKg:     number,   // Total DM intake per day (whole group)
  crudeProteinKg:  number,   // Total CP required per day (kg)
  fibreKg:         number,   // Total crude fibre required (kg)
  ndfKg:           number,   // Total NDF required (kg)
  calciumKg:       number,   // Total calcium required (kg)
  phosphorusKg:    number,   // Total phosphorus required (kg)
  nemMcal:         number,   // Net energy for maintenance (Mcal/day)
  negMcal:         number,   // Net energy for gain (Mcal/day)
  noOfAnimals:     number    // Number of animals (scales MaxIntake per-animal caps)
}
```

> Note: `phosphorousKg` is also accepted as an alias for `phosphorusKg`.

### Input: Feed Array

Each feed object must include all standard catalogue fields plus optionally:
- `maxIntakePercentOfDM` — cap as % of total DM
- `maxIntakeWeightInKgPerAnimal` — per-animal daily cap (scaled by `noOfAnimals`)
- `compositionBasis` — `"dm"` (default) or `"as-fed"`

### Constraint Model

Each requirement generates a **band constraint** (not just a minimum):
- **min** = 80% of requirement
- **max** = requirement × (1 + `overagePercent`, default 5%)

This ensures the solution is nutritionally adequate but not excessively over-supplied.

### Cost Multipliers by Feed Type

The LP objective minimises cost, but feed types receive a **preferential bias** to prioritise rumen-healthy rations:

| Type | Cost Multiplier | Effect |
|---|---|---|
| Fodder | × 0.1 | 90% cost discount — strongly preferred |
| Concentrate | × 0.5 | 50% discount — moderately preferred |
| Additive | × 1.0 | No bias — used only as needed |

### Output Object

```js
{
  solution:     { [feedName]: kgAsFed },  // Only feeds with qty > 0
  totals: {
    kgAsFed, cost, dryMatterKg, crudeProteinKg, fibreKg,
    ndfKg, calciumKg, phosphorusKg, nemMcal, negMcal
  },
  costPerDay:   number,  // Total SAR/day
  costCurrency: string,  // e.g. "SAR"
  constraints:  { [label]: { min, max } },  // Human-readable constraint values
  variables:    [{ name, var }]              // LP variable name map
}
```

### Exported Function

```js
const { optimizeFeedMix } = require('./optimizer');
const result = optimizeFeedMix(requirements, feeds, { overagePercent: 0.05 });
```

### Error Conditions

- `feeds` must be a non-empty array.
- Each feed must have `name`, `costPerKg`, and `dmPercent`.
- At least one requirement must be positive (non-zero).
- If LP solver cannot find a feasible solution: throws `"No feasible solution found: ..."`.

---

## 4. Small Ruminant Optimiser

> 🔵 **RULES** / 🟡 **APP LOGIC** — `small-ruminant-optimizer.js`
>
> Sheep and goat specific LP optimiser. Uses **TDN (Total Digestible Nutrients)** instead of NEg/NEm. Includes fodder/concentrate ratio targets. Default overage is 10% (vs. 5% for cattle).

### Input: Requirements Object

```js
{
  dryMatterKg:        number,  // Total DM intake per day (whole group)
  proteinKg:          number,  // Total protein (CP) required per day (kg)
  tdnKg:              number,  // Total digestible nutrients per day (kg)
  calciumG:           number,  // Calcium required per day in GRAMS
  phosphorusG:        number,  // Phosphorus required per day in GRAMS
  fodderPercent:      number,  // Target % of ration that should be Fodder
  concentratePercent: number,  // Target % of ration that should be Concentrate
  noOfAnimals:        number   // Scales per-animal MaxIntake caps
}
```

> ⚠️ Calcium and phosphorus are in **grams** for small ruminants (not kg). The service converts internally: `calciumG / 1000` and `phosphorusG / 1000` before passing to the LP solver.

### Input: Feed Array

Same as the cattle optimiser catalogue, but must include `tdnPercent` (% of DM) for each feed. Feeds without `tdnPercent` will fail validation.

### Feed Fields Required for Small Ruminant Optimiser

```js
{
  name, costPerKg, costCurrency,
  dmPercent,          // Dry matter %
  cpPercent,          // Crude protein % of DM
  tdnPercent,         // Total digestible nutrients % of DM  ← unique to small ruminant
  calciumPercent,     // Calcium % of DM
  phosphorusPercent,  // Phosphorus % of DM
  maxIntakePercentOfDM,          // optional
  maxIntakeWeightInKgPerAnimal,  // optional
  type                           // 'Fodder' | 'Concentrate' | 'Additive'
}
```

### Cost Multipliers

| Type | Multiplier | Compared to cattle optimiser |
|---|---|---|
| Fodder | × 0.9 | Less aggressive than cattle (0.1) |
| Concentrate | × 0.95 | Less aggressive than cattle (0.5) |
| Additive | × 1.0 | Same |

### Output Object

```js
{
  solution:   { [feedName]: kgAsFed },
  totals: {
    dryMatterKg, proteinKg, tdnKg,
    calciumG,     // converted back to grams in output
    phosphorusG   // converted back to grams in output
  },
  costPerDay:   number,
  costCurrency: string,
  constraints:  { [label]: { min, max } },
  model:        { name, opType, constraints, variables: count }
}
```

### Exported Functions

```js
const { optimizeSmallRuminantFeedMix, normalizeFeed, normalizeRequirements, getFeedType } = require('./small-ruminant-optimizer');
const result = optimizeSmallRuminantFeedMix(requirements, feeds, { overagePercent: 0.10 });
```

---

## 5. Cull Evaluation Service

> 🟡 **APP LOGIC** — `cull-evaluation-service.js` (service inferred from `cull-evaluation-service_test.js`)
>
> Scores animals across multiple health, reproductive, productivity, and age dimensions to recommend cull priority. Operates on batches and returns results sorted highest-score first.

### Exported Functions

```js
const {
  evaluateCullCandidates,
  computeHerdMilkAverage,
  formatCullSummary,
  DEFAULT_THRESHOLDS,
  PRIORITY,
} = require('./cull-evaluation-service');
```

### `evaluateCullCandidates(animals, data, context, options?)`

#### `animals[]` — Required Fields Per Animal

```js
{
  id:           string,   // Unique animal identifier
  species:      'CATTLE' | 'GOAT' | 'SHEEP',
  sex:          'MALE' | 'FEMALE',
  breed:        string,
  dob:          ISO8601,  // Date of birth (used to calculate age)
  status:       'ACTIVE' | 'SOLD' | 'DEAD' | ...,
  cull_flagged: boolean,  // Admin has manually flagged for cull
  _groupPurpose:'MILK' | 'MEAT' | 'FATTENING' | 'MAINTENANCE' | 'BOTH'
}
```

> ⚠️ **Only ACTIVE animals are evaluated.** Non-ACTIVE animals are silently excluded from results.

#### `data{}` — Supporting Records (keyed by animal ID)

```js
{
  breedingEvents: {
    [animalId]: [
      { method: 'AI' | 'NATURAL', outcome: 'BORN' | 'FAILED' | 'CONFIRMED_PREGNANT' | 'PENDING', event_date: ISO8601 }
    ]
  },
  pregnancies: {
    [animalId]: [
      { outcome: 'MISCARRIAGE' | 'BORN' | ..., actual_birth_date: ISO8601 }
    ]
  },
  healthRecords: {
    [animalId]: [
      { date_applied: ISO8601, illness_description: string }
    ]
  },
  weightHistory: {
    [animalId]: [
      { recorded_at: ISO8601, weight_kg: number }
    ]
  },
  milkRecords: {
    [animalId]: [
      { animal_id: string, recorded_date: ISO8601, volume_litres: number, session: 'MORNING' | 'EVENING' }
    ]
  }
}
```

#### `context{}` — Farm-Level Settings

```js
{
  farmSpeciesPurpose: { CATTLE: 'MILK' | 'MEAT' | 'BOTH', SHEEP: ..., GOAT: ... },
  herdMilkAvgPerDay:  { CATTLE: number, SHEEP: number, GOAT: number },
  asOf:               Date  // Reference date for all age/recency calculations
}
```

#### `options{}` — Optional Overrides

```js
{
  thresholds: {
    reproductiveInactivityMonths: number,  // Default: 12
    // ... other threshold overrides
  }
}
```

### Scoring Dimensions

Each dimension returns `{ triggered: bool, score: number, detail: string }`.

| Dimension Key | Triggered When | Notes |
|---|---|---|
| `reproductiveInactivity` | Female has no pregnancy/birth in past N months (default 12) | Males exempt; animals under minimum breeding age exempt |
| `failedAi` | 3+ failed AI attempts in current cycle (resets after successful pregnancy) | |
| `frequentMiscarriage` | 2+ miscarriages in past 12 months | |
| `frequentIllness` | 3+ distinct illness episodes in past 12 months | Only events within 12-month window count |
| `chronicIllness` | Same illness recurring twice, OR mastitis/lameness keyword in records | |
| `poorWeightGain` | Actual daily gain < 60% of expected for species/purpose | Requires ≥ 2 weight records |
| `lowMilkVsHerd` | Animal producing < 70% of herd average daily milk | Only evaluated when farm purpose includes MILK |
| `decliningMilk` | Recent 30-day average has declined > 25% vs prior 60-day window | |
| `overPeakAge` | Animal exceeds species productive lifespan threshold | Cattle: 7 years; species-specific thresholds |
| `alreadyCullFlagged` | `cull_flagged === true` | Admin override — always adds to score |

### Expected Daily Weight Gain by Species & Purpose

| Species | Purpose | Expected kg/day |
|---|---|---|
| Cattle | MAINTENANCE / MILK | 0.80 |
| Cattle | FATTENING | 1.10 |
| Sheep | Any | (species-specific in service) |
| Goat | Any | (species-specific in service) |

### Priority Classification

| Priority | Trigger |
|---|---|
| `PRIORITY.NONE` | `totalScore === 0` |
| `PRIORITY.LOW` | Low positive score |
| `PRIORITY.MEDIUM` | Moderate score |
| `PRIORITY.HIGH` | High score |
| `PRIORITY.IMMEDIATE` | Highest score tier |

### Result Object Per Animal

```js
{
  animalId:       string,
  priority:       PRIORITY.NONE | LOW | MEDIUM | HIGH | IMMEDIATE,
  totalScore:     number,
  cullReasons:    string[],          // Human-readable reason strings
  dimensionScores: {
    reproductiveInactivity: { triggered, score, detail },
    failedAi:               { triggered, score, detail },
    frequentMiscarriage:    { triggered, score, detail },
    frequentIllness:        { triggered, score, detail },
    chronicIllness:         { triggered, score, detail },
    poorWeightGain:         { triggered, score, detail },
    lowMilkVsHerd:          { triggered, score, detail },
    decliningMilk:          { triggered, score, detail },
    overPeakAge:            { triggered, score, detail },
    alreadyCullFlagged:     { triggered, score, detail },
  }
}
```

Results are **sorted descending by `totalScore`** (highest cull priority first).

### Helper Functions

```js
// Computes average daily milk across the herd for a given window
computeHerdMilkAverage(milkRecords[], asOf, windowDays?)  // → number

// Produces a multi-line human-readable summary for UI display
formatCullSummary(cullResult)  // → string
// Output includes: Species, Breed, Priority, Score, Reasons list
```

### Minimum Breeding Age By Species (Grace Period for Reproductive Inactivity)

Animals below minimum breeding age are **not penalised** for reproductive inactivity:

| Species | Min Breeding Age |
|---|---|
| Cattle | ~12 months (inferred from tests: 36-month old = well past) |
| Goat | ~6 months (test: 5-month old goat is exempt) |
| Sheep | ~6 months (aligned with goat) |

---

## 6. Email Service

> 🟡 **APP LOGIC** (Infrastructure) — `mailgunEmailService.js`
>
> Wrapper around the Mailgun API for sending transactional emails. Used for notifications, reports, and alerts. Supports attachments, structured logging, and full observability context.

### Constructor Options

```js
const emailService = new MailgunEmailService({
  apiKey:    process.env.MAILGUN_API_KEY,    // Required
  domain:    process.env.MAILGUN_DOMAIN,     // Required (e.g. 'mg.greenerherd.com')
  baseUrl:   process.env.MAILGUN_API_BASE_URL || 'https://api.mailgun.net',
  fromEmail: process.env.MAILGUN_FROM_EMAIL, // Required (sender address)
  timeout:   10000,  // ms, default 10s
  logger:    customLogger,  // Optional — must have .info() and .error()
  httpClient: axiosInstance // Optional — for testing/mocking
});
```

### `sendEmail(params)` — Input

```js
await emailService.sendEmail({
  subject:               string,     // Required — non-empty
  body:                  string,     // Required — plain text body
  recipients:            string | string[],  // Required — email address(es)
  from:                  string,     // Optional — overrides default fromEmail
  attachment:            Buffer | string | object | null,  // Optional
  attachmentFilename:    string,     // Default: 'attachment.json'
  attachmentContentType: string,     // Optional MIME type
  context: {                         // Optional observability context
    traceId, trace_id,
    correlationId, correlation_id,
    userId, user_id,
    ip, spanId, span_id,
    metadata: {}
  }
});
```

### Attachment Formats Supported

| Format | How It's Handled |
|---|---|
| `Buffer` | Sent directly |
| `string` | Decoded from base64 |
| `{ content, filename, contentType, encoding }` | Object format; `content` can be Buffer or base64 string |
| Plain `object` (no `content` key) | Serialised as `JSON.stringify(..., null, 2)` |

### Return Value

```js
{
  success:  true,
  status:   number,   // HTTP status from Mailgun
  id:       string,   // Mailgun message ID
  message:  string    // Mailgun confirmation message
}
```

### Error Handling

- Throws `Error('Failed to send email: {message}')` on Mailgun API error.
- Error message is extracted from `response.data.message`, `response.data.error`, or the Axios error message.
- All send attempts (success and failure) are logged with full observability context.

### Logging Events

| Event Key | When |
|---|---|
| `mailgun_email_service.send_email.requested` | Before API call |
| `mailgun_email_service.send_email.success` | After 2xx response |
| `mailgun_email_service.send_email.failure` | After error or non-2xx |

---

## 7. Shared Constants & Mappings

### `feedTypeMap` — Canonical Feed-to-Type Lookup

This mapping is duplicated in both `optimizer.js` and `small-ruminant-optimizer.js`. The single source of truth should eventually be the `type` field in `feeds.json`.

```js
// Fodder
'Alfalfa hay (mid-bloom)', 'Wheat Straw', 'Triticale Silage', 'Oat Hay',
'Barley', 'Corn', 'Soybean', 'Wheat', 'Cotton Seed', 'Beet Pulp',
'Wheat Bran', 'White Hay', 'Red Hay', 'Alfalfa', 'Fermented Corn',
'Soybean Hulls', 'Alfalfa Hay', 'Corn Silage', 'Sesame seed husk', 'Maize grain'

// Concentrate
'Barley - raw', 'Barley - Flakes', 'Soya Bean Meal', 'Steamed Corn Flake',
'Steamed Barley Flakes', 'Barley grain', 'Soybean husk', 'Wheat grain',
'Cotton meal', 'Beetroot pellets', 'Corn Gluten Meal'

// Additive
'Molasses', 'Limestone', 'Salt', 'Urea'
```

### Valid Enum Values (from `feed-eligibility-service.js`)

```
Species:          cattle | sheep | goats | pigs | poultry
Sex:              male | female
LactationStatus:  dry | lactating | not_applicable
PregnancyStatus:  pregnant | ready_to_breed | not_applicable
```

### Valid Enum Values (from `cull-evaluation-service.js`)

```
Species:       CATTLE | SHEEP | GOAT  (uppercase)
Sex:           MALE | FEMALE
Status:        ACTIVE | SOLD | DEAD
GroupPurpose:  MILK | MEAT | FATTENING | MAINTENANCE | BOTH
AI Outcome:    BORN | FAILED | CONFIRMED_PREGNANT | PENDING
Pregnancy outcome: MISCARRIAGE | BORN
Milk session:  MORNING | EVENING
```

> ⚠️ **Case sensitivity:** Feed eligibility service uses **lowercase** species (`cattle`). Cull service uses **UPPERCASE** (`CATTLE`). Always check which layer you are calling.

---

## 8. Data Contracts Summary

Quick-reference for agents building features that call these services.

### Flow: Feed Plan Generation

```
1. animalGroup (species, sex, age, lactationStatus, pregnancyStatus)
        ↓
2. feed-eligibility-service.getEligibleFeeds(animalGroup, allFeeds)
        ↓  returns eligibleFeeds[]
3. CATTLE?  → optimizer.optimizeFeedMix(requirements, eligibleFeeds)
   SHEEP/GOAT? → small-ruminant-optimizer.optimizeSmallRuminantFeedMix(requirements, eligibleFeeds)
        ↓  returns { solution, totals, costPerDay }
4. Display in mobile app / save as FeedPlan record
```

### Flow: Cull Evaluation

```
1. Load all ACTIVE animals for farm + supporting records
        ↓
2. computeHerdMilkAverage(allMilkRecords, asOf)  → herdAvg per species
        ↓
3. evaluateCullCandidates(animals, data, context, options)
        ↓  returns sorted results[]
4. Display priority list / trigger notification
```

### Flow: Notification Email

```
1. Trigger condition detected (e.g. cull IMMEDIATE, low feed stock)
        ↓
2. Build email body from notification template
        ↓
3. MailgunEmailService.sendEmail({ subject, body, recipients, context })
        ↓
4. Log success/failure with trace context
```

---

*Last updated from project artefacts: May 2026. Add new feeds to Section 1 table and `feedTypeMap` in both optimiser files when expanding the catalogue.*
