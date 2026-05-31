const solver = require('javascript-lp-solver');

/**
 * Build and solve a least-cost feed mix LP.
 * Decision variables are kg as-fed for each feed item.
 * Nutrient coefficients are converted to kg (or MCal) per kg as-fed.
 *
 * @param {object} requirements - Daily nutrient requirements. Supported keys:
 *   - dryMatterKg, crudeProteinKg, fibreKg, ndfKg, calciumKg,
 *     phosphorusKg | phosphorousKg, nemMcal, negMcal
 * @param {Array<object>} feeds - Feed items with properties (case-insensitive accepted):
 *   - name (string, required)
 *   - costPerKg (number, required)
 *   - dmPercent (number 0-100, required)
 *   - cpPercent (number 0-100)
 *   - fibrePercent (number 0-100)
 *   - ndfPercent (number 0-100)
 *   - calciumPercent (number 0-100)
 *   - phosphorusPercent | phosphorousPercent (number 0-100)
 *   - nemMcalPerKg (number)
 *   - negMcalPerKg (number)
 *   - compositionBasis: "dm" | "as-fed" (default: "dm")
 * @param {object} options
 *   - overagePercent (default 0.05)
 * @returns {{solution: object, totals: object, costPerDay: number, constraints: object, variables: object}}
 */
function optimizeFeedMix(requirements, feeds, options = {}) {
  const overagePercent = options.overagePercent ?? 0.05;

  if (!Array.isArray(feeds)) {
    throw new Error('feeds must be an array');
  }
  // Accept a nested array (e.g. file contains [ [ ... ] ]) by flattening one level
  if (feeds.length > 0 && Array.isArray(feeds[0])) {
    feeds = feeds.flat();
  }
  if (feeds.length === 0) {
    throw new Error('feeds must be a non-empty array');
  }
  
  // Normalize feeds and compute coefficients per kg as-fed
  const normalizedFeeds = feeds.map((feed, idx) => normalizeFeed(feed, idx));

  // Determine which constraints are active based on requirements present and > 0
  const constraints = buildConstraints(requirements, overagePercent, normalizedFeeds);

  const model = {
    name: 'closest-match-feed-mix',
    optimize: 'cost',
    opType: 'min',
    constraints: constraints.lpConstraints,
    variables: {},
  };

  for (const feed of normalizedFeeds) {
    const v = {};
    // Objective coefficient with extreme preference for Fodders to meet nutritional needs
    let costMultiplier = 1.0;
    const feedType = getFeedType(feed.name);
    
    if (feedType === 'Fodder') {
      costMultiplier = 0.1; // 90% cost advantage for fodders - prioritize nutrition
    } else if (feedType === 'Concentrate') {
      costMultiplier = 0.5; // 50% cost advantage for concentrates
    } else if (feedType === 'Additive') {
      costMultiplier = 1.0; // No advantage for additives
    }
    
    v.cost = feed.costPerKg * costMultiplier;
    
    // Nutrient coefficients per kg as-fed
    v.DM = feed.dmKgPerKg;
    if (feed.cpKgPerKg > 0) v.CP = feed.cpKgPerKg;
    if (feed.fibreKgPerKg > 0) v.FIBRE = feed.fibreKgPerKg;
    if (feed.ndfKgPerKg > 0) v.NDF = feed.ndfKgPerKg;
    if (feed.caKgPerKg > 0) v.CA = feed.caKgPerKg;
    if (feed.pKgPerKg > 0) v.P = feed.pKgPerKg;
    if (feed.nemMcalPerKg > 0) v.NEM = feed.nemMcalPerKg;
    if (feed.negMcalPerKg > 0) v.NEg = feed.negMcalPerKg; // keep case distinct from NEM

    // Add MaxIntake constraints as variable bounds
    if ((feed.maxIntakePercentOfDM && feed.maxIntakePercentOfDM > 0) || 
        (feed.maxIntakeWeightInKgPerAnimal && feed.maxIntakeWeightInKgPerAnimal > 0)) {
      // Calculate the safer (more restrictive) constraint
      let maxIntakeKg = Infinity;
      let constraintReason = '';
      const numAnimals = requirements.noOfAnimals || 1;

      // Check percentage of DM constraint
      if (feed.maxIntakePercentOfDM > 0 && requirements.dryMatterKg > 0) {
        const maxFromPercentDM = (feed.maxIntakePercentOfDM / 100) * requirements.dryMatterKg / feed.dmKgPerKg;
        if (maxFromPercentDM < maxIntakeKg) {
          maxIntakeKg = maxFromPercentDM;
          constraintReason = `${feed.maxIntakePercentOfDM}% of DM`;
        }
      }

      // Check weight per animal constraint (scaled by number of animals)
      if (feed.maxIntakeWeightInKgPerAnimal > 0) {
        const maxFromWeightPerAnimal = feed.maxIntakeWeightInKgPerAnimal * numAnimals;
        if (maxFromWeightPerAnimal < maxIntakeKg) {
          maxIntakeKg = maxFromWeightPerAnimal;
          constraintReason = `${feed.maxIntakeWeightInKgPerAnimal}kg per animal × ${numAnimals} animals`;
        }
      }
      
      // Allow minimal flexibility for very restrictive constraints only
      if (maxIntakeKg < Infinity && maxIntakeKg < requirements.dryMatterKg * 0.05) {
        maxIntakeKg = maxIntakeKg * 1.2; // Allow 20% more for very restrictive constraints
        constraintReason += ' (relaxed)';
      }

      // Add the constraint as a variable bound
      if (maxIntakeKg < Infinity) {
        v.max = maxIntakeKg;
        v.min = 0;
        constraints.humanReadable[`${feed.name} (MaxIntake)`] = { 
          max: maxIntakeKg, 
          reason: constraintReason 
        };
      }
    }

    model.variables[feed.varName] = v;
  }

  const results = solver.Solve(model);

  if (!results.feasible) {
    const reason = results.result || 'Infeasible model';
    throw new Error(`No feasible solution found: ${reason}`);
  }

  // Extract solution and enforce MaxIntake constraints
  const solution = {};
  const numAnimals = requirements.noOfAnimals || 1; // Default to 1 animal if not specified
  
  for (const feed of normalizedFeeds) {
    let qty = typeof results[feed.varName] === 'number' ? results[feed.varName] : 0;
    
    // Enforce MaxIntake constraints by capping the quantity
    if (feed.maxIntakePercentOfDM > 0 || feed.maxIntakeWeightInKgPerAnimal > 0) {
      let maxIntakeKg = Infinity;
      
      // Check percentage of DM constraint
      if (feed.maxIntakePercentOfDM > 0 && requirements.dryMatterKg > 0) {
        const maxFromPercentDM = (feed.maxIntakePercentOfDM / 100) * requirements.dryMatterKg / feed.dmKgPerKg;
        if (maxFromPercentDM < maxIntakeKg) {
          maxIntakeKg = maxFromPercentDM;
        }
      }
      
      // Check weight per animal constraint (scaled by number of animals)
      if (feed.maxIntakeWeightInKgPerAnimal > 0) {
        const maxFromWeightPerAnimal = feed.maxIntakeWeightInKgPerAnimal * numAnimals;
        if (maxFromWeightPerAnimal < maxIntakeKg) {
          maxIntakeKg = maxFromWeightPerAnimal;
        }
      }
      
      // Cap the quantity to the MaxIntake constraint
      if (maxIntakeKg < Infinity) {
        qty = Math.min(qty, maxIntakeKg);
      }
    }
    
    // Guard against tiny negative zero or floating noise
    const roundedQty = roundTo(qty > 0 ? qty : 0, 6);
    if (roundedQty > 0) {
      solution[feed.name] = roundedQty;
    }
  }

  const totals = computeTotals(solution, normalizedFeeds);
  const costPerDay = Object.entries(solution).reduce((sum, [name, kg]) => {
    const feed = normalizedFeeds.find(f => f.name === name);
    return sum + kg * (feed ? feed.costPerKg : 0);
  }, 0);

  // Get currency from feeds (assume all feeds have same currency)
  const currency = normalizedFeeds.length > 0 ? normalizedFeeds[0].costCurrency : 'SAR';

  return {
    solution,
    totals,
    costPerDay: roundTo(costPerDay, 4),
    costCurrency: currency,
    constraints: constraints.humanReadable,
    variables: normalizedFeeds.map(f => ({ name: f.name, var: f.varName })),
  };
}

function roundTo(x, n) {
  const p = 10 ** n;
  return Math.round((x + Number.EPSILON) * p) / p;
}

function normalizeFeed(feed, index) {
  if (!feed) throw new Error('Invalid feed');
  const name = String(feed.name ?? `feed_${index + 1}`).trim();
  const varName = sanitizeVarName(name, index);
  const basis = (feed.compositionBasis || feed.basis || 'dm').toLowerCase();
  const context = ` in feed '${name}' (index ${index + 1})`;

   const costPerKg = toNumber(feed.costPerKg, 'costPerKg', false, context);
  const costCurrency = feed.costCurrency || 'SAR';
  const dmPercent = toNumber(feed.dmPercent ?? feed.DM_percent ?? feed.dryMatterPercent, 'dmPercent');

  const dmFractionAsFed = clamp01(dmPercent / 100);

  // Helper to compute kg per kg as-fed from percentage value
  const percentToKgPerKg = (percent) => {
    const frac = clamp01((percent ?? 0) / 100);
    if (basis === 'dm') {
      return frac * dmFractionAsFed; // (% of DM) * (kg DM / kg as-fed)
    }
    return frac; // (% of as-fed)
  };

  const cpKgPerKg = percentToKgPerKg(feed.cpPercent ?? feed.CP_percent ?? feed.crudeProteinPercent);
  const fibreKgPerKg = percentToKgPerKg(feed.fibrePercent ?? feed.FIBRE_percent ?? feed.fiberPercent);
  const ndfKgPerKg = percentToKgPerKg(feed.ndfPercent ?? feed.NDF_percent);
  const caKgPerKg = percentToKgPerKg(feed.calciumPercent ?? feed.CA_percent);
  const pKgPerKg = percentToKgPerKg(feed.phosphorusPercent ?? feed.phosphorousPercent ?? feed.P_percent);

  // Energy values may be reported per kg DM. Convert to per kg as-fed if so.
  const nemInput = toNumber(feed.nemMcalPerKg ?? feed.NEM_MCal_per_kg, 'nemMcalPerKg', true);
  const negInput = toNumber(feed.negMcalPerKg ?? feed.NEg_MCal_per_kg, 'negMcalPerKg', true);
  const nemMcalPerKg = basis === 'dm' ? nemInput * dmFractionAsFed : nemInput;
  const negMcalPerKg = basis === 'dm' ? negInput * dmFractionAsFed : negInput;

  // Extract MaxIntake constraints
  const maxIntakePercentOfDM = toNumber(feed.maxIntakePercentOfDM, 'maxIntakePercentOfDM', true);
  const maxIntakeWeightInKgPerAnimal = toNumber(feed.maxIntakeWeightInKgPerAnimal, 'maxIntakeWeightInKgPerAnimal', true);

  return {
    name,
    varName,
    costPerKg,
    costCurrency,
    dmKgPerKg: dmFractionAsFed,
    cpKgPerKg,
    fibreKgPerKg,
    ndfKgPerKg,
    caKgPerKg,
    pKgPerKg,
    nemMcalPerKg,
    negMcalPerKg,
    maxIntakePercentOfDM,
    maxIntakeWeightInKgPerAnimal,
  };
}

function sanitizeVarName(name, index) {
  const base = name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const suffix = String(index + 1).padStart(2, '0');
  const varName = `${base || 'feed'}_${suffix}`;
  return varName;
}

function toNumber(value, label, allowUndefined = false) {
  if (value === undefined || value === null || value === '') {
    if (allowUndefined) return 0;
    throw new Error(`Missing numeric value for ${label}`);
  }
  const n = Number(value);
  if (!Number.isFinite(n)) {
    throw new Error(`Invalid number for ${label}: ${value}`);
  }
  return n;
}

function clamp01(x) {
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(1, x));
}

function getFeedType(feedName) {
  // Map feed names to their types based on the feeds.json data
  const feedTypeMap = {
    'Alfalfa hay (mid-bloom)': 'Fodder',
    'Wheat Straw': 'Fodder',
    'Triticale Silage': 'Fodder',
    'Oat Hay': 'Fodder',
    'Barley': 'Fodder',
    'Corn': 'Fodder',
    'Soybean': 'Fodder',
    'Wheat': 'Fodder',
    'Cotton Seed': 'Fodder',
    'Beet Pulp': 'Fodder',
    'Wheat Bran': 'Fodder',
    'White Hay': 'Fodder',
    'Red Hay': 'Fodder',
    'Alfalfa': 'Fodder',
    'Fermented Corn': 'Fodder',
    'Soybean Hulls': 'Fodder',
    'Alfalfa Hay': 'Fodder',
    'Corn Silage': 'Fodder',
    'Sesame seed husk': 'Fodder',
    'Maize grain': 'Fodder',
    'Barley - raw': 'Concentrate',
    'Barley - Flakes': 'Concentrate',
    'Soya Bean Meal': 'Concentrate',
    'Steamed Corn Flake': 'Concentrate',
    'Steamed Barley Flakes': 'Concentrate',
    'Barley grain': 'Concentrate',
    'Soybean husk': 'Concentrate',
    'Wheat grain': 'Concentrate',
    'Cotton meal': 'Concentrate',
    'Beetroot pellets': 'Concentrate',
    'Corn Gluten Meal': 'Concentrate',
    'Molasses': 'Additive',
    'Limestone': 'Additive',
    'Salt': 'Additive',
    'Urea': 'Additive'
  };
  
  return feedTypeMap[feedName] || 'Unknown';
}

function buildConstraints(requirements, overagePercent, normalizedFeeds) {
  const req = normalizeRequirements(requirements);
  const lpConstraints = {};
  const humanReadable = {};

  const addConstraint = (key, label, reqValue) => {
    if (reqValue === undefined || reqValue === null) return;
    const v = Number(reqValue);
    if (!Number.isFinite(v) || v <= 0) return; // skip non-positive
    const max = v * (1 + overagePercent);
    // Set minimum to 80% of requirement to ensure better nutritional fulfillment
    const min = v * 0.8;
    lpConstraints[key] = { min, max };
    humanReadable[label] = { min, max };
  };

  addConstraint('DM', 'dryMatterKg', req.dryMatterKg);
  addConstraint('CP', 'crudeProteinKg', req.crudeProteinKg);
  addConstraint('FIBRE', 'fibreKg', req.fibreKg);
  addConstraint('NDF', 'ndfKg', req.ndfKg);
  addConstraint('CA', 'calciumKg', req.calciumKg);
  addConstraint('P', 'phosphorusKg', req.phosphorusKg);
  addConstraint('NEM', 'nemMcal', req.nemMcal);
  addConstraint('NEg', 'negMcal', req.negMcal);

  if (Object.keys(lpConstraints).length === 0) {
    throw new Error('No positive requirements provided to constrain the model');
  }

  return { lpConstraints, humanReadable };
}

function normalizeRequirements(r) {
  const req = { ...r };
  if (req.phosphorusKg === undefined && req.phosphorousKg !== undefined) {
    req.phosphorusKg = req.phosphorousKg;
  }
  // Prefer lower-case names if alternates are present
  return req;
}

function computeTotals(solution, normalizedFeeds) {
  const totals = {
    kgAsFed: 0,
    cost: 0,
    dryMatterKg: 0,
    crudeProteinKg: 0,
    fibreKg: 0,
    ndfKg: 0,
    calciumKg: 0,
    phosphorusKg: 0,
    nemMcal: 0,
    negMcal: 0,
  };
  for (const feed of normalizedFeeds) {
    const kg = solution[feed.name] || 0;
    totals.kgAsFed += kg;
    totals.cost += kg * feed.costPerKg;
    totals.dryMatterKg += kg * feed.dmKgPerKg;
    totals.crudeProteinKg += kg * feed.cpKgPerKg;
    totals.fibreKg += kg * feed.fibreKgPerKg;
    totals.ndfKg += kg * feed.ndfKgPerKg;
    totals.calciumKg += kg * feed.caKgPerKg;
    totals.phosphorusKg += kg * feed.pKgPerKg;
    totals.nemMcal += kg * feed.nemMcalPerKg;
    totals.negMcal += kg * feed.negMcalPerKg;
  }
  // Round reasonable decimals for reporting
  const rounded = {};
  for (const [k, v] of Object.entries(totals)) {
    rounded[k] = roundTo(v, 6);
  }
  return rounded;
}

module.exports = {
  optimizeFeedMix,
};
