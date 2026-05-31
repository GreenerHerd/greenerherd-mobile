/**
 * Feed Eligibility Service
 * Determines which feed products are suitable for specific animal groups based on:
 * - Animal species (cattle, sheep, goats, etc.)
 * - Animal sex (male, female)
 * - Product focus (dairy, meat)
 * - Age constraints (minimum/maximum age)
 * - Lactation period (dry, lactating)
 * - Pregnancy states (pregnant, ready to breed)
 */

function validateAnimalGroup(animalGroup) {
  const required = ['species', 'sex', 'age', 'lactationStatus', 'pregnancyStatus'];
  
  for (const field of required) {
    if (animalGroup[field] === undefined || animalGroup[field] === null) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  // Validate species
  const validSpecies = ['cattle', 'sheep', 'goats', 'pigs', 'poultry'];
  if (!validSpecies.includes(animalGroup.species)) {
    throw new Error(`Invalid species: ${animalGroup.species}. Must be one of: ${validSpecies.join(', ')}`);
  }
  
  // Validate sex
  const validSex = ['male', 'female'];
  if (!validSex.includes(animalGroup.sex)) {
    throw new Error(`Invalid sex: ${animalGroup.sex}. Must be one of: ${validSex.join(', ')}`);
  }
  
  // Validate age
  if (typeof animalGroup.age !== 'number' || animalGroup.age < 0) {
    throw new Error(`Invalid age: ${animalGroup.age}. Must be a non-negative number`);
  }
  
  // Validate lactation status
  const validLactationStatus = ['dry', 'lactating', 'not_applicable'];
  if (!validLactationStatus.includes(animalGroup.lactationStatus)) {
    throw new Error(`Invalid lactation status: ${animalGroup.lactationStatus}. Must be one of: ${validLactationStatus.join(', ')}`);
  }
  
  // Validate pregnancy status
  const validPregnancyStatus = ['pregnant', 'ready_to_breed', 'not_applicable'];
  if (!validPregnancyStatus.includes(animalGroup.pregnancyStatus)) {
    throw new Error(`Invalid pregnancy status: ${animalGroup.pregnancyStatus}. Must be one of: ${validPregnancyStatus.join(', ')}`);
  }
}

function validateFeed(feed) {
  const required = ['name', 'type', 'speciesEligibility'];
  
  for (const field of required) {
    if (feed[field] === undefined || feed[field] === null) {
      throw new Error(`Feed ${feed.name || 'unknown'} missing required field: ${field}`);
    }
  }
  
  // Validate species eligibility
  if (!Array.isArray(feed.speciesEligibility)) {
    throw new Error(`Feed ${feed.name} speciesEligibility must be an array`);
  }
  
  // Validate age constraints if present
  if (feed.minAge !== undefined && feed.minAge !== null) {
    if (typeof feed.minAge !== 'number' || feed.minAge < 0) {
      throw new Error(`Feed ${feed.name} minAge must be a non-negative number`);
    }
  }
  
  if (feed.maxAge !== undefined && feed.maxAge !== null) {
    if (typeof feed.maxAge !== 'number' || feed.maxAge < 0) {
      throw new Error(`Feed ${feed.name} maxAge must be a non-negative number`);
    }
  }
  
  // Validate sex restrictions if present
  if (feed.sexRestrictions && !Array.isArray(feed.sexRestrictions)) {
    throw new Error(`Feed ${feed.name} sexRestrictions must be an array`);
  }
  
  // Validate lactation restrictions if present
  if (feed.lactationRestrictions && !Array.isArray(feed.lactationRestrictions)) {
    throw new Error(`Feed ${feed.name} lactationRestrictions must be an array`);
  }
  
  // Validate pregnancy restrictions if present
  if (feed.pregnancyRestrictions && !Array.isArray(feed.pregnancyRestrictions)) {
    throw new Error(`Feed ${feed.name} pregnancyRestrictions must be an array`);
  }
}

function isFeedEligibleForAnimalGroup(feed, animalGroup) {
  // Check species eligibility
  if (!feed.speciesEligibility.includes(animalGroup.species)) {
    return { eligible: false, reason: `Not suitable for ${animalGroup.species}` };
  }
  
  // Check age constraints
  if (feed.minAge !== undefined && feed.minAge !== null) {
    if (animalGroup.age < feed.minAge) {
      return { eligible: false, reason: `Animal age ${animalGroup.age} months is below minimum ${feed.minAge} months` };
    }
  }
  
  if (feed.maxAge !== undefined && feed.maxAge !== null) {
    if (animalGroup.age > feed.maxAge) {
      return { eligible: false, reason: `Animal age ${animalGroup.age} months exceeds maximum ${feed.maxAge} months` };
    }
  }
  
  // Check sex restrictions
  if (feed.sexRestrictions && feed.sexRestrictions.length > 0) {
    if (feed.sexRestrictions.includes(animalGroup.sex)) {
      return { eligible: false, reason: `Not suitable for ${animalGroup.sex} animals` };
    }
  }
  
  // Check lactation restrictions
  if (feed.lactationRestrictions && feed.lactationRestrictions.length > 0) {
    if (feed.lactationRestrictions.includes(animalGroup.lactationStatus)) {
      return { eligible: false, reason: `Not suitable for ${animalGroup.lactationStatus} animals` };
    }
  }
  
  // Check pregnancy restrictions
  if (feed.pregnancyRestrictions && feed.pregnancyRestrictions.length > 0) {
    if (feed.pregnancyRestrictions.includes(animalGroup.pregnancyStatus)) {
      return { eligible: false, reason: `Not suitable for ${animalGroup.pregnancyStatus} animals` };
    }
  }
  
  return { eligible: true, reason: 'Suitable for this animal group' };
}

function getEligibleFeeds(animalGroup, feeds, options = {}) {
  const { includeReasons = false, strictMode = true } = options;
  
  // Validate inputs
  validateAnimalGroup(animalGroup);
  
  if (!Array.isArray(feeds) || feeds.length === 0) {
    throw new Error('Feeds array is required and must not be empty');
  }
  
  // Validate all feeds
  if (strictMode) {
    feeds.forEach(validateFeed);
  }
  
  const eligibleFeeds = [];
  const ineligibleFeeds = [];
  
  for (const feed of feeds) {
    try {
      const eligibility = isFeedEligibleForAnimalGroup(feed, animalGroup);
      
      if (eligibility.eligible) {
        eligibleFeeds.push({
          ...feed,
          eligibilityReason: includeReasons ? eligibility.reason : undefined
        });
      } else {
        ineligibleFeeds.push({
          name: feed.name,
          type: feed.type,
          reason: eligibility.reason
        });
      }
    } catch (error) {
      if (strictMode) {
        throw error;
      } else {
        ineligibleFeeds.push({
          name: feed.name,
          type: feed.type,
          reason: `Validation error: ${error.message}`
        });
      }
    }
  }
  
  return {
    animalGroup,
    eligibleFeeds,
    ineligibleFeeds,
    summary: {
      totalFeeds: feeds.length,
      eligibleCount: eligibleFeeds.length,
      ineligibleCount: ineligibleFeeds.length,
      eligibilityRate: (eligibleFeeds.length / feeds.length) * 100
    }
  };
}

function getEligibleFeedsForMultipleGroups(animalGroups, feeds, options = {}) {
  if (!Array.isArray(animalGroups) || animalGroups.length === 0) {
    throw new Error('Animal groups array is required and must not be empty');
  }
  
  const results = animalGroups.map(animalGroup => 
    getEligibleFeeds(animalGroup, feeds, options)
  );
  
  // Find feeds that are eligible for ALL groups (common feeds)
  const allEligibleFeeds = results.reduce((common, result) => {
    if (common.length === 0) {
      return result.eligibleFeeds.map(f => f.name);
    }
    return common.filter(feedName => 
      result.eligibleFeeds.some(f => f.name === feedName)
    );
  }, []);
  
  return {
    results,
    commonEligibleFeeds: allEligibleFeeds,
    summary: {
      totalGroups: animalGroups.length,
      totalFeeds: feeds.length,
      averageEligibilityRate: results.reduce((sum, r) => sum + r.summary.eligibilityRate, 0) / results.length
    }
  };
}

module.exports = {
  getEligibleFeeds,
  getEligibleFeedsForMultipleGroups,
  isFeedEligibleForAnimalGroup,
  validateAnimalGroup,
  validateFeed
};










