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

  // Optional MinIntake constraints (used to "prefer"/ensure user-accepted feeds)
  const minIntakePercentOfDM = toNumber(feed.minIntakePercentOfDM, 'minIntakePercentOfDM', true);
  const minIntakeWeightInKgPerAnimal = toNumber(feed.minIntakeWeightInKgPerAnimal, 'minIntakeWeightInKgPerAnimal', true);
  
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
    minIntakePercentOfDM,
    minIntakeWeightInKgPerAnimal,
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

function getFeedType(feedOrName) {
  const feed = typeof feedOrName === 'object' && feedOrName ? feedOrName : null;
  if (feed?.type) {
    const t = String(feed.type).toUpperCase();
    if (t === 'FODDER') return 'Fodder';
    if (t === 'CONCENTRATE') return 'Concentrate';
    if (t === 'ADDITIVE') return 'Additive';
    return feed.type;
  }
  const feedName = feed ? feed.name : feedOrName;
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

function buildConstraints(requirements, overagePercent, normalizedFeeds, options = {}) {
  const req = normalizeRequirements(requirements);
  const lpConstraints = {};
  const humanReadable = {};
  const nutrientFloor =
    options.nutrientFloorRatio != null ? Number(options.nutrientFloorRatio) : 0.8;

  const addConstraint = (key, label, reqValue) => {
    if (reqValue === undefined || reqValue === null) return;
    const v = Number(reqValue);
    if (!Number.isFinite(v) || v <= 0) return; // skip non-positive
    const max = v * (1 + overagePercent);
    const min = v * nutrientFloor;
    lpConstraints[key] = { min, max };
    humanReadable[label] = { min, max };
  };

  addConstraint('DM', 'dryMatterKg', req.dryMatterKg);
  addConstraint('CP', 'proteinKg', req.proteinKg);
  addConstraint('TDN', 'tdnKg', req.tdnKg);
  addConstraint('CA', 'calciumG', req.calciumG / 1000); // Convert grams to kg
  addConstraint('P', 'phosphorusG', req.phosphorusG / 1000); // Convert grams to kg

  const dmTotal = req.dryMatterKg;
  const fodderPct = req.fodderPercent ?? 50;
  const concentratePct = req.concentratePercent ?? 40;
  const additiveMaxPct = 5;

  if (dmTotal > 0) {
    // 55% of profile fodder guideline — leaves room for concentrate while staying near harness
    const minFodderRatio = (fodderPct / 100) * 0.55;
    const maxConcentrateRatio = (concentratePct / 100) * (1 + overagePercent);
    const maxAdditiveRatio = (additiveMaxPct / 100) * (1 + overagePercent);
    lpConstraints._minFodderRatio = minFodderRatio;
    lpConstraints._maxConcentrateRatio = maxConcentrateRatio;
    lpConstraints._maxAdditiveRatio = maxAdditiveRatio;
    humanReadable.fodderDmMinRatio = minFodderRatio;
    humanReadable.concentrateDmMaxRatio = maxConcentrateRatio;
    humanReadable.additiveDmMaxRatio = maxAdditiveRatio;
  }

  if (Object.keys(lpConstraints).length === 0) {
    throw new Error('No positive requirements provided to constrain the model');
  }

  return { lpConstraints, humanReadable };
}

const DEFAULT_NUTRIENT_FLOOR_LADDER = [0.95, 0.9, 0.85, 0.8, 0.75, 0.65];

function applyDmTypeRatioConstraints(lpConstraints) {
  const minFodderR = lpConstraints._minFodderRatio;
  const maxConcR = lpConstraints._maxConcentrateRatio;
  const maxAddR = lpConstraints._maxAdditiveRatio;
  delete lpConstraints._minFodderRatio;
  delete lpConstraints._maxConcentrateRatio;
  delete lpConstraints._maxAdditiveRatio;
  if (minFodderR != null) {
    lpConstraints.FODDER_RATIO = { min: 0 };
  }
  if (maxConcR != null) {
    lpConstraints.CONC_RATIO = { max: 0 };
  }
  if (maxAddR != null) {
    lpConstraints.ADD_RATIO = { max: 0 };
  }
  return { minFodderR, maxConcR, maxAddR };
}

function buildVariableCoeffs(feed, ratioMeta, requirements, constraints) {
  const v = {};
  const feedType = getFeedType(feed);
  let costMultiplier = 1.0;
  if (feedType === 'Fodder') {
    costMultiplier = 0.1;
  } else if (feedType === 'Concentrate') {
    costMultiplier = 0.5;
  }

  v.cost = feed.costPerKg * costMultiplier;
  v.realCost = feed.costPerKg;
  v.matchScore =
    feed.cpKgPerKg * 100 + feed.tdnKgPerKg * 50 + feed.dmKgPerKg * 10;

  v.DM = feed.dmKgPerKg;
  if (feed.cpKgPerKg > 0) v.CP = feed.cpKgPerKg;
  if (feed.tdnKgPerKg > 0) v.TDN = feed.tdnKgPerKg;
  if (feed.calciumKgPerKg > 0) v.CA = feed.calciumKgPerKg;
  if (feed.phosphorusKgPerKg > 0) v.P = feed.phosphorusKgPerKg;

  const dm = feed.dmKgPerKg;
  const { minFodderR, maxConcR, maxAddR } = ratioMeta;
  if (minFodderR != null) {
    v.FODDER_RATIO =
      feedType === 'Fodder' ? (1 - minFodderR) * dm : -minFodderR * dm;
  }
  if (maxConcR != null) {
    v.CONC_RATIO =
      feedType === 'Concentrate' ? (1 - maxConcR) * dm : -maxConcR * dm;
  }
  if (maxAddR != null) {
    v.ADD_RATIO =
      feedType === 'Additive' ? (1 - maxAddR) * dm : -maxAddR * dm;
  }

  if (
    (feed.maxIntakePercentOfDM && feed.maxIntakePercentOfDM > 0) ||
    (feed.maxIntakeWeightInKgPerAnimal && feed.maxIntakeWeightInKgPerAnimal > 0) ||
    (feed.minIntakePercentOfDM && feed.minIntakePercentOfDM > 0) ||
    (feed.minIntakeWeightInKgPerAnimal && feed.minIntakeWeightInKgPerAnimal > 0)
  ) {
    let maxIntakeKg = Infinity;
    let minIntakeKg = 0;
    let constraintReason = '';
    let minConstraintReason = '';
    const numAnimals = requirements.noOfAnimals || 1;

    if (feed.maxIntakePercentOfDM > 0 && requirements.dryMatterKg > 0) {
      const maxFromPercentDM =
        (feed.maxIntakePercentOfDM / 100) *
        (requirements.dryMatterKg / feed.dmKgPerKg);
      if (maxFromPercentDM < maxIntakeKg) {
        maxIntakeKg = maxFromPercentDM;
        constraintReason = `${feed.maxIntakePercentOfDM}% of DM`;
      }
    }

    if (feed.maxIntakeWeightInKgPerAnimal > 0) {
      const maxFromWeightPerAnimal =
        feed.maxIntakeWeightInKgPerAnimal * numAnimals;
      if (maxFromWeightPerAnimal < maxIntakeKg) {
        maxIntakeKg = maxFromWeightPerAnimal;
        constraintReason = `${feed.maxIntakeWeightInKgPerAnimal}kg per animal × ${numAnimals} animals`;
      }
    }

    // MinIntake (prefer/ensure accepted feeds)
    if (feed.minIntakePercentOfDM > 0 && requirements.dryMatterKg > 0) {
      const minFromPercentDM =
        (feed.minIntakePercentOfDM / 100) *
        (requirements.dryMatterKg / feed.dmKgPerKg);
      if (minFromPercentDM > minIntakeKg) {
        minIntakeKg = minFromPercentDM;
        minConstraintReason = `${feed.minIntakePercentOfDM}% of DM`;
      }
    }

    if (feed.minIntakeWeightInKgPerAnimal > 0) {
      const minFromWeightPerAnimal =
        feed.minIntakeWeightInKgPerAnimal * numAnimals;
      if (minFromWeightPerAnimal > minIntakeKg) {
        minIntakeKg = minFromWeightPerAnimal;
        minConstraintReason = `${feed.minIntakeWeightInKgPerAnimal}kg per animal × ${numAnimals} animals`;
      }
    }

    if (
      maxIntakeKg < Infinity &&
      maxIntakeKg < requirements.dryMatterKg * 0.05
    ) {
      maxIntakeKg *= 1.2;
      constraintReason += ' (relaxed)';
    }

    if (maxIntakeKg < Infinity) v.max = maxIntakeKg;
    if (minIntakeKg > 0) {
      v.min = maxIntakeKg < Infinity ? Math.min(minIntakeKg, maxIntakeKg) : minIntakeKg;
      constraints.humanReadable[`${feed.name} (MinIntake)`] = {
        min: v.min,
        reason: minConstraintReason,
      };
    } else {
      v.min = 0;
    }

    if (maxIntakeKg < Infinity) {
      constraints.humanReadable[`${feed.name} (MaxIntake)`] = {
        max: maxIntakeKg,
        reason: constraintReason,
      };
    }
  }

  return v;
}

function buildLpModel(
  requirements,
  normalizedFeeds,
  lpConstraints,
  ratioMeta,
  optimizeKey,
  opType,
  humanReadable,
) {
  const model = {
    name: 'small-ruminant-feed-mix',
    optimize: optimizeKey,
    opType,
    constraints: lpConstraints,
    variables: {},
  };

  const constraintBag = { humanReadable };
  for (const feed of normalizedFeeds) {
    model.variables[feed.varName] = buildVariableCoeffs(
      feed,
      ratioMeta,
      requirements,
      constraintBag,
    );
  }

  return model;
}

function extractSolution(results, normalizedFeeds) {
  const solution = {};

  for (const feed of normalizedFeeds) {
    const qty =
      typeof results[feed.varName] === 'number' ? results[feed.varName] : 0;
    const roundedQty = roundTo(qty > 0 ? qty : 0, 6);
    if (roundedQty > 0) {
      solution[feed.name] = roundedQty;
    }
  }

  return solution;
}

function computeTotalsAndCost(solution, normalizedFeeds) {
  const totals = {
    dryMatterKg: 0,
    proteinKg: 0,
    tdnKg: 0,
    calciumG: 0,
    phosphorusG: 0,
  };

  let totalCost = 0;
  for (const feed of normalizedFeeds) {
    const qty = solution[feed.name] || 0;
    totals.dryMatterKg += qty * feed.dmKgPerKg;
    totals.proteinKg += qty * feed.cpKgPerKg;
    totals.tdnKg += qty * feed.tdnKgPerKg;
    totals.calciumG += qty * feed.calciumKgPerKg * 1000;
    totals.phosphorusG += qty * feed.phosphorusKgPerKg * 1000;
    totalCost += qty * feed.costPerKg;
  }

  return { totals, totalCost };
}

function nutrientMatchScore(totals, requirements) {
  const req = normalizeRequirements(requirements);
  const dmR =
    req.dryMatterKg > 0 ? totals.dryMatterKg / req.dryMatterKg : 1;
  const cpR = req.proteinKg > 0 ? totals.proteinKg / req.proteinKg : 1;
  const tdnR = req.tdnKg > 0 ? totals.tdnKg / req.tdnKg : 1;
  return Math.min(dmR, cpR, tdnR);
}

function solveOnce(
  requirements,
  normalizedFeeds,
  overagePercent,
  nutrientFloorRatio,
) {
  const constraints = buildConstraints(
    requirements,
    overagePercent,
    normalizedFeeds,
    { nutrientFloorRatio },
  );
  const lpConstraints = { ...constraints.lpConstraints };
  const ratioMeta = {
    minFodderR: lpConstraints._minFodderRatio,
    maxConcR: lpConstraints._maxConcentrateRatio,
    maxAddR: lpConstraints._maxAdditiveRatio,
  };
  applyDmTypeRatioConstraints(lpConstraints);

  const costModel = buildLpModel(
    requirements,
    normalizedFeeds,
    lpConstraints,
    ratioMeta,
    'cost',
    'min',
    constraints,
  );
  const costResults = solver.Solve(costModel);
  if (!costResults.feasible) {
    throw new Error(
      `No feasible solution found: ${costResults.result || 'Infeasible model'}`,
    );
  }

  let solution = extractSolution(costResults, normalizedFeeds);
  let { totals, totalCost } = computeTotalsAndCost(solution, normalizedFeeds);

  const refineModel = buildLpModel(
    requirements,
    normalizedFeeds,
    lpConstraints,
    ratioMeta,
    'matchScore',
    'max',
    constraints,
  );
  refineModel.constraints.REAL_COST = {
    max: totalCost * 1.08,
  };
  const refineResults = solver.Solve(refineModel);
  if (refineResults.feasible) {
    const refined = extractSolution(refineResults, normalizedFeeds);
    const refinedBundle = computeTotalsAndCost(refined, normalizedFeeds);
    if (
      nutrientMatchScore(refinedBundle.totals, requirements) >=
      nutrientMatchScore(totals, requirements) - 0.001
    ) {
      solution = refined;
      totals = refinedBundle.totals;
      totalCost = refinedBundle.totalCost;
    }
  }

  return {
    solution,
    totals,
    totalCost,
    constraints: constraints.humanReadable,
    nutrientFloorRatio,
  };
}

function optimizeSmallRuminantFeedMix(requirements, feeds, options = {}) {
  const overagePercent = options.overagePercent || 0.1;

  if (!Array.isArray(feeds) || feeds.length === 0) {
    throw new Error('Feeds array is required and must not be empty');
  }

  const normalizedFeeds = feeds.map(normalizeFeed);
  const ladder =
    options.nutrientFloorLadder ||
    (options.nutrientFloorRatio != null
      ? [options.nutrientFloorRatio]
      : DEFAULT_NUTRIENT_FLOOR_LADDER);

  let best = null;
  let lastError = null;

  for (const floor of ladder) {
    try {
      const candidate = solveOnce(
        requirements,
        normalizedFeeds,
        overagePercent,
        floor,
      );
      if (
        !best ||
        nutrientMatchScore(candidate.totals, requirements) >
          nutrientMatchScore(best.totals, requirements)
      ) {
        best = candidate;
      }
      break;
    } catch (err) {
      lastError = err;
    }
  }

  if (!best) {
    throw (
      lastError ||
      new Error('No feasible solution found: Infeasible model')
    );
  }

  const currency =
    normalizedFeeds.length > 0 ? normalizedFeeds[0].costCurrency : 'SAR';

  return {
    solution: best.solution,
    totals: best.totals,
    costPerDay: roundTo(best.totalCost, 2),
    costCurrency: currency,
    constraints: {
      ...best.constraints,
      nutrientFloorUsed: best.nutrientFloorRatio,
    },
  };
}

module.exports = {
  optimizeSmallRuminantFeedMix,
  normalizeFeed,
  normalizeRequirements,
  getFeedType
};
