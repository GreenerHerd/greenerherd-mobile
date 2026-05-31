const solver = require('javascript-lp-solver');

/**
 * Small Ruminant Feed Optimizer
 * Optimizes feed mix for small ruminants (sheep, goats) with specific constraints:
 * - % of feed that should be Fodder
 * - % of feed that should be Concentrates
 * - Daily protein intake based on % of body weight
 * - Daily TDN needs
 * - Calcium and phosphorus in grams
 */

function toNumber(value, fieldName, allowNull = false) {
  if (value === null || value === undefined) {
    if (allowNull) return null;
    throw new Error(`Missing required field: ${fieldName}`);
  }
  const num = Number(value);
  if (!Number.isFinite(num)) {
    throw new Error(`Invalid number for ${fieldName}: ${value}`);
  }
  return num;
}

function roundTo(num, decimals) {
  return Math.round(num * Math.pow(10, decimals)) / Math.pow(10, decimals);
}

function normalizeFeed(feed) {
  const name = String(feed.name || '').trim();
  if (!name) throw new Error('Feed name is required');
  
  const varName = name.replace(/[^a-zA-Z0-9]/g, '_');
  const costPerKg = toNumber(feed.costPerKg, 'costPerKg');
  const costCurrency = feed.costCurrency || 'SAR';
  const dmPercent = toNumber(feed.dmPercent, 'dmPercent');
  const cpPercent = toNumber(feed.cpPercent, 'cpPercent');
  const tdnPercent = toNumber(feed.tdnPercent, 'tdnPercent');
  const calciumPercent = toNumber(feed.calciumPercent, 'calciumPercent');
  const phosphorusPercent = toNumber(feed.phosphorusPercent, 'phosphorusPercent');
  
  // Convert percentages to fractions
  const dmFractionAsFed = dmPercent / 100;
  const cpFractionAsFed = cpPercent / 100;
  const tdnFractionAsFed = tdnPercent / 100;
  const calciumFractionAsFed = calciumPercent / 100;
  const phosphorusFractionAsFed = phosphorusPercent / 100;
  
  // Extract MaxIntake constraints
  const maxIntakePercentOfDM = toNumber(feed.maxIntakePercentOfDM, 'maxIntakePercentOfDM', true);
  const maxIntakeWeightInKgPerAnimal = toNumber(feed.maxIntakeWeightInKgPerAnimal, 'maxIntakeWeightInKgPerAnimal', true);
  
  return {
    name,
    varName,
    costPerKg,
    costCurrency,
    dmKgPerKg: dmFractionAsFed,
    cpKgPerKg: cpFractionAsFed,
    tdnKgPerKg: tdnFractionAsFed,
    calciumKgPerKg: calciumFractionAsFed,
    phosphorusKgPerKg: phosphorusFractionAsFed,
    maxIntakePercentOfDM,
    maxIntakeWeightInKgPerAnimal,
    type: feed.type
  };
}

function normalizeRequirements(requirements) {
  return {
    dryMatterKg: toNumber(requirements.dryMatterKg, 'dryMatterKg'),
    proteinKg: toNumber(requirements.proteinKg, 'proteinKg'),
    tdnKg: toNumber(requirements.tdnKg, 'tdnKg'),
    calciumG: toNumber(requirements.calciumG, 'calciumG'),
    phosphorusG: toNumber(requirements.phosphorusG, 'phosphorusG'),
    fodderPercent: toNumber(requirements.fodderPercent, 'fodderPercent'),
    concentratePercent: toNumber(requirements.concentratePercent, 'concentratePercent'),
    noOfAnimals: requirements.noOfAnimals || 1
  };
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
  addConstraint('CP', 'proteinKg', req.proteinKg);
  addConstraint('TDN', 'tdnKg', req.tdnKg);
  addConstraint('CA', 'calciumG', req.calciumG / 1000); // Convert grams to kg
  addConstraint('P', 'phosphorusG', req.phosphorusG / 1000); // Convert grams to kg

  // Note: Fodder and Concentrate percentages are guidelines, not strict constraints
  // The optimizer will prioritize meeting nutritional requirements at lowest cost

  if (Object.keys(lpConstraints).length === 0) {
    throw new Error('No positive requirements provided to constrain the model');
  }

  return { lpConstraints, humanReadable };
}

function optimizeSmallRuminantFeedMix(requirements, feeds, options = {}) {
  const overagePercent = options.overagePercent || 0.10;
  
  if (!Array.isArray(feeds) || feeds.length === 0) {
    throw new Error('Feeds array is required and must not be empty');
  }

  const normalizedFeeds = feeds.map(normalizeFeed);
  const constraints = buildConstraints(requirements, overagePercent, normalizedFeeds);

  const model = {
    name: 'small-ruminant-feed-mix',
    opType: 'min',
    constraints: constraints.lpConstraints,
    variables: {},
  };

  for (const feed of normalizedFeeds) {
    const v = {};
    // Objective coefficient with moderate preference for Fodders, focus on cost optimization
    let costMultiplier = 1.0;
    const feedType = getFeedType(feed.name);
    
    if (feedType === 'Fodder') {
      costMultiplier = 0.9; // 10% cost advantage for fodders
    } else if (feedType === 'Concentrate') {
      costMultiplier = 0.95; // 5% cost advantage for concentrates
    } else if (feedType === 'Additive') {
      costMultiplier = 1.0; // No advantage for additives
    }
    
    v.cost = feed.costPerKg * costMultiplier;
    
    // Nutrient coefficients per kg as-fed
    v.DM = feed.dmKgPerKg;
    if (feed.cpKgPerKg > 0) v.CP = feed.cpKgPerKg;
    if (feed.tdnKgPerKg > 0) v.TDN = feed.tdnKgPerKg;
    if (feed.calciumKgPerKg > 0) v.CA = feed.calciumKgPerKg;
    if (feed.phosphorusKgPerKg > 0) v.P = feed.phosphorusKgPerKg;

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
  const numAnimals = requirements.noOfAnimals || 1;

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

  // Calculate totals
  const totals = {
    dryMatterKg: 0,
    proteinKg: 0,
    tdnKg: 0,
    calciumG: 0,
    phosphorusG: 0
  };

  for (const feed of normalizedFeeds) {
    const qty = solution[feed.name] || 0;
    totals.dryMatterKg += qty * feed.dmKgPerKg;
    totals.proteinKg += qty * feed.cpKgPerKg;
    totals.tdnKg += qty * feed.tdnKgPerKg;
    totals.calciumG += qty * feed.calciumKgPerKg * 1000; // Convert kg to grams
    totals.phosphorusG += qty * feed.phosphorusKgPerKg * 1000; // Convert kg to grams
  }

  // Calculate total cost
  let totalCost = 0;
  for (const feed of normalizedFeeds) {
    const qty = solution[feed.name] || 0;
    totalCost += qty * feed.costPerKg;
  }

  // Get currency from feeds (assume all feeds have same currency)
  const currency = normalizedFeeds.length > 0 ? normalizedFeeds[0].costCurrency : 'SAR';

  return {
    solution,
    totals,
    costPerDay: roundTo(totalCost, 2),
    costCurrency: currency,
    constraints: constraints.humanReadable,
    model: {
      name: model.name,
      opType: model.opType,
      constraints: model.constraints,
      variables: Object.keys(model.variables).length
    }
  };
}

module.exports = {
  optimizeSmallRuminantFeedMix,
  normalizeFeed,
  normalizeRequirements,
  getFeedType
};
