import type { FeedEligibilityContext, HerdSpecies } from './feed-eligibility.js';
import {
  NutritionRequirementsCatalog,
  type NutritionRequirementProfile,
} from './nutrition-requirements-catalog.js';

export interface NutritionProfileContext extends FeedEligibilityContext {
  months_since_calving?: number;
  fattening?: boolean;
  sick?: boolean;
  weaning?: boolean;
  maintenance?: boolean;
  breeding?: boolean;
  feed_cycle_hint?: string;
}

export interface ResolvedNutritionProfile {
  profile: NutritionRequirementProfile;
  profile_code: string;
  match_reason: string;
}

export function resolveNutritionProfile(
  catalog: NutritionRequirementsCatalog,
  ctx: NutritionProfileContext,
): ResolvedNutritionProfile {
  const dedicated = tryDedicatedProfile(catalog, ctx);
  if (dedicated) return dedicated;

  if (ctx.species === 'GOAT' || ctx.species === 'SHEEP') {
    return resolveSmallRuminant(catalog, ctx);
  }
  if (ctx.production_focus === 'MILK' || ctx.production_focus === 'BOTH') {
    return resolveDairy(catalog, ctx);
  }
  return resolveBeef(catalog, ctx);
}

function tryDedicatedProfile(
  catalog: NutritionRequirementsCatalog,
  ctx: NutritionProfileContext,
): ResolvedNutritionProfile | null {
  const hint = ctx.feed_cycle_hint;

  if (ctx.sick || hint === 'SICK') {
    const code =
      ctx.species === 'CATTLE' ? 'CATTLE_SICK' : `${ctx.species}_SICK`;
    const profile = catalog.getByCode(code);
    if (profile) {
      return {
        profile,
        profile_code: profile.profile_code,
        match_reason: 'dedicated sick profile',
      };
    }
  }

  if (ctx.weaning || hint === 'WEANING') {
    const code =
      ctx.species === 'CATTLE'
        ? 'CATTLE_WEANING'
        : `${ctx.species}_SMALL_RUMINANT_WEANING`;
    const profile = catalog.getByCode(code);
    if (profile) {
      return {
        profile,
        profile_code: profile.profile_code,
        match_reason: 'dedicated weaning profile',
      };
    }
  }

  if (
    ctx.species === 'CATTLE' &&
    ctx.sex === 'MALE' &&
    ctx.age_months >= 24 &&
    (ctx.production_focus === 'MILK' || ctx.production_focus === 'BOTH') &&
    !ctx.lactating
  ) {
    const profile = catalog.getByCode('CATTLE_DAIRY_BREEDING_BULL');
    if (profile) {
      return {
        profile,
        profile_code: profile.profile_code,
        match_reason: 'dairy breeding bull',
      };
    }
  }

  if (
    (ctx.breeding || hint === 'BREEDING') &&
    (ctx.species === 'GOAT' || ctx.species === 'SHEEP')
  ) {
    const profile = catalog.getByCode(
      `${ctx.species}_SMALL_RUMINANT_BREEDING`,
    );
    if (profile) {
      return {
        profile,
        profile_code: profile.profile_code,
        match_reason: 'small ruminant breeding',
      };
    }
  }

  if (
    ctx.maintenance ||
    hint === 'MAINTENANCE' ||
    hint === 'BULL_MAINTENANCE'
  ) {
    const code = beefMaintenanceCode(ctx);
    if (code) {
      const profile = catalog.getByCode(code);
      if (profile) {
        return {
          profile,
          profile_code: profile.profile_code,
          match_reason: 'beef maintenance',
        };
      }
    }
  }

  return null;
}

function beefMaintenanceCode(ctx: NutritionProfileContext): string | null {
  if (ctx.species !== 'CATTLE') return null;
  if (ctx.lactating || ctx.pregnant || ctx.fattening) return null;
  if (ctx.production_focus === 'MILK' || ctx.production_focus === 'BOTH') {
    return null;
  }
  const animalClass = beefAnimalClass(ctx);
  switch (animalClass) {
    case 'First Calf Heifer':
      return 'CATTLE_BEEF_FIRST_CALF_HEIFER_MAINTENANCE';
    case 'Mature Bull Maintenance':
      return 'CATTLE_BEEF_MATURE_BULL_MAINTENANCE';
    case 'Mature Cow':
      return 'CATTLE_BEEF_MATURE_COW_MAINTENANCE';
    default:
      return null;
  }
}

const DAIRY_STAGE_CODE: Record<string, string> = {
  'Dry (Far off)': 'CATTLE_DAIRY_DRY_FAR_OFF',
  'Close (Close up)': 'CATTLE_DAIRY_CLOSE_CLOSE_UP',
  'Cow - Fresh': 'CATTLE_DAIRY_COW_FRESH',
  'Cow - Early': 'CATTLE_DAIRY_COW_EARLY',
  'Cow - Mid': 'CATTLE_DAIRY_COW_MID',
  'Cow - Late': 'CATTLE_DAIRY_COW_LATE',
  '6-mo Heifer': 'CATTLE_DAIRY_6_MO_HEIFER',
  '12-mo Heifer': 'CATTLE_DAIRY_12_MO_HEIFER',
  '18-mo Heifer': 'CATTLE_DAIRY_18_MO_HEIFER',
  '24-mo Heifer (Close up)': 'CATTLE_DAIRY_24_MO_HEIFER_CLOSE_UP',
};

function resolveDairy(
  catalog: NutritionRequirementsCatalog,
  ctx: NutritionProfileContext,
): ResolvedNutritionProfile {
  let stage: string;
  if (ctx.lactating) {
    const m = ctx.months_since_calving ?? 2;
    if (m <= 1) stage = 'Cow - Fresh';
    else if (m <= 3) stage = 'Cow - Early';
    else if (m <= 6) stage = 'Cow - Mid';
    else stage = 'Cow - Late';
  } else if (ctx.pregnant) {
    stage = 'Close (Close up)';
  } else if (ctx.age_months < 8) {
    stage = '6-mo Heifer';
  } else if (ctx.age_months < 14) {
    stage = '12-mo Heifer';
  } else if (ctx.age_months < 20) {
    stage = '18-mo Heifer';
  } else if (ctx.age_months < 26) {
    stage = '24-mo Heifer (Close up)';
  } else {
    stage = 'Dry (Far off)';
  }

  const code = DAIRY_STAGE_CODE[stage];
  const profile =
    (code ? catalog.getByCode(code) : null) ??
    catalog.listForSpecies('CATTLE').find((p) => p.life_stage === stage);
  if (!profile) {
    throw new Error(`No dairy nutrition profile for stage: ${stage}`);
  }
  return {
    profile,
    profile_code: profile.profile_code,
    match_reason: `dairy life stage: ${stage}`,
  };
}

function beefAnimalClass(ctx: NutritionProfileContext): string {
  if (ctx.sex === 'MALE') {
    if (ctx.age_months < 11) return 'Growing Bull Calves <11 months';
    if (ctx.age_months < 24) return 'Growing Bull Yearlings >12 months';
    return 'Mature Bull Maintenance';
  }
  if (ctx.age_months < 11) return 'Feeder Calves <11 months of age';
  if (ctx.age_months < 24) return 'Feeder Yearlings >11 months of age';
  if (ctx.age_months < 30) return 'First Calf Heifer';
  return 'Mature Cow';
}

function resolveBeef(
  catalog: NutritionRequirementsCatalog,
  ctx: NutritionProfileContext,
): ResolvedNutritionProfile {
  const animalClass = beefAnimalClass(ctx);
  const m = ctx.months_since_calving;

  if (ctx.age_months < 24 && !ctx.lactating && animalClass.includes('Calves')) {
    const growing = catalog.listBeefGrowing(animalClass);
    const profile = growing[0];
    if (profile) {
      return {
        profile,
        profile_code: profile.profile_code,
        match_reason: `beef growth ${animalClass}`,
      };
    }
  }

  let lifeStage: string;
  if (ctx.lactating) {
    lifeStage = m != null && m >= 4 ? 'Mid Lactation' : 'Early Lactation';
  } else if (ctx.pregnant) {
    lifeStage = m != null && m >= 8 ? 'Late Gestation' : 'Mid Gestation';
  } else if (ctx.age_months < 24) {
    lifeStage = 'Growing';
    const growing = catalog.listBeefGrowing(animalClass);
    if (growing[0]) {
      return {
        profile: growing[0],
        profile_code: growing[0].profile_code,
        match_reason: `beef ${animalClass} / Growing`,
      };
    }
  } else if (
    !ctx.lactating &&
    !ctx.pregnant &&
    ctx.production_focus === 'MEAT'
  ) {
    const code = beefMaintenanceCode(ctx);
    if (code) {
      const profile = catalog.getByCode(code);
      if (profile) {
        return {
          profile,
          profile_code: profile.profile_code,
          match_reason: `beef maintenance ${animalClass}`,
        };
      }
    }
    lifeStage = 'Mid Gestation';
  } else {
    lifeStage = 'Mid Gestation';
  }

  const ranked = catalog.listBeef(animalClass, lifeStage, m ?? undefined);
  if (ranked[0]) {
    const profile = ranked[0];
    return {
      profile,
      profile_code: profile.profile_code,
      match_reason: `beef ${animalClass} / ${lifeStage}${
        m != null ? ` month ${m}` : ''
      }`,
    };
  }

  const fallback = catalog
    .listForSpecies('CATTLE')
    .find(
      (p) =>
        p.production_system === 'BEEF' &&
        p.animal_class === animalClass &&
        p.life_stage === lifeStage,
    );
  if (!fallback) {
    throw new Error(
      `No beef nutrition profile for ${animalClass} / ${lifeStage}`,
    );
  }
  return {
    profile: fallback,
    profile_code: fallback.profile_code,
    match_reason: `beef ${animalClass} / ${lifeStage} (fallback)`,
  };
}

function resolveSmallRuminant(
  catalog: NutritionRequirementsCatalog,
  ctx: NutritionProfileContext,
): ResolvedNutritionProfile {
  const species = ctx.species as HerdSpecies;
  let suffix: string;
  if (ctx.fattening) {
    suffix = 'SMALL_RUMINANT_FATTENING';
  } else if (ctx.lactating) {
    suffix = 'SMALL_RUMINANT_LACTATING';
  } else if (ctx.pregnant) {
    suffix = 'SMALL_RUMINANT_PREGNANT';
  } else {
    suffix = 'SMALL_RUMINANT_MAINTENANCE';
  }
  let code = `${species}_${suffix}`;
  if (ctx.age_months < 12) {
    const youngCode = `${code}_YOUNG`;
    if (catalog.getByCode(youngCode)) code = youngCode;
  }
  const profile = catalog.getByCode(code);
  if (!profile) {
    throw new Error(`No small ruminant profile: ${code}`);
  }
  return {
    profile,
    profile_code: profile.profile_code,
    match_reason: `small ruminant: ${profile.life_stage}`,
  };
}

export function buildGroupRequirements(
  profile: NutritionRequirementProfile,
  headCount: number,
  options: { fattening?: boolean } = {},
) {
  const heads = Math.max(1, headCount);
  let dmi = profile.dmi_kg_day;
  if (options.fattening && profile.production_system === 'SMALL_RUMINANT') {
    dmi *= 1.18;
  }

  if (profile.production_system === 'DAIRY') {
    const cpPct = profile.cp_percent_dm ?? 0;
    const ndfPct = profile.ndf_percent_dm ?? 0;
    const adfPct = profile.adf_percent_dm ?? 0;
    const caPct = profile.ca_percent_dm ?? 0;
    const pPct = profile.p_percent_dm ?? 0;
    const nel = profile.nel_mcal_per_kg_dm ?? 0;
    return {
      species: profile.species,
      optimizer: 'cattle' as const,
      per_animal: {
        dry_matter_kg: dmi,
        crude_protein_kg: (dmi * cpPct) / 100,
        ndf_kg: (dmi * ndfPct) / 100,
        fibre_kg: (dmi * adfPct) / 100,
        calcium_kg: (dmi * caPct) / 100,
        phosphorus_kg: (dmi * pPct) / 100,
        nem_mcal: nel * dmi,
        neg_mcal: 0,
      },
      group: {
        dry_matter_kg: dmi * heads,
        crude_protein_kg: ((dmi * cpPct) / 100) * heads,
        ndf_kg: ((dmi * ndfPct) / 100) * heads,
        fibre_kg: ((dmi * adfPct) / 100) * heads,
        calcium_kg: ((dmi * caPct) / 100) * heads,
        phosphorus_kg: ((dmi * pPct) / 100) * heads,
        nem_mcal: nel * dmi * heads,
        neg_mcal: 0,
        no_of_animals: heads,
      },
    };
  }

  if (profile.production_system === 'BEEF') {
    const cp = profile.cp_kg_day ?? 0;
    const ca = profile.ca_kg_day ?? 0;
    const p = profile.p_kg_day ?? 0;
    const nem = profile.nem_mcal_day ?? 0;
    return {
      species: profile.species,
      optimizer: 'cattle' as const,
      per_animal: {
        dry_matter_kg: dmi,
        crude_protein_kg: cp,
        ndf_kg: 0,
        fibre_kg: 0,
        calcium_kg: ca,
        phosphorus_kg: p,
        nem_mcal: nem,
        neg_mcal: profile.neg_mcal_day ?? 0,
      },
      group: {
        dry_matter_kg: dmi * heads,
        crude_protein_kg: cp * heads,
        ndf_kg: 0,
        fibre_kg: 0,
        calcium_kg: ca * heads,
        phosphorus_kg: p * heads,
        nem_mcal: nem * heads,
        neg_mcal: (profile.neg_mcal_day ?? 0) * heads,
        no_of_animals: heads,
      },
    };
  }

  const cp = profile.cp_kg_day ?? (dmi * (profile.cp_percent_dm ?? 12)) / 100;
  const tdn = profile.tdn_kg_day ?? dmi * 0.6;
  const caG = (profile.ca_kg_day ?? 0) * 1000;
  const pG = (profile.p_kg_day ?? 0) * 1000;
  return {
    species: profile.species,
    optimizer: 'small_ruminant' as const,
    per_animal: {
      dry_matter_kg: dmi,
      protein_kg: cp,
      tdn_kg: tdn,
      calcium_g: caG,
      phosphorus_g: pG,
      fodder_percent: profile.fodder_percent ?? 50,
      concentrate_percent: profile.concentrate_percent ?? 40,
    },
    group: {
      dry_matter_kg: dmi * heads,
      protein_kg: cp * heads,
      tdn_kg: tdn * heads,
      calcium_g: caG * heads,
      phosphorus_g: pG * heads,
      fodder_percent: profile.fodder_percent ?? 50,
      concentrate_percent: profile.concentrate_percent ?? 40,
      no_of_animals: heads,
    },
  };
}
