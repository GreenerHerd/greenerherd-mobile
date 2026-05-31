import 'nutrition_feed_cycle.dart';
import 'nutrition_requirements_catalog.dart';

/// Feed-plan / recommendation request context (mirrors gh-shared resolver input).
class NutritionProfileContext {
  const NutritionProfileContext({
    required this.species,
    this.sex,
    required this.ageMonths,
    required this.productionFocus,
    required this.lactating,
    this.pregnant = false,
    this.fattening = false,
    this.sick = false,
    this.weaning = false,
    this.maintenance = false,
    this.breeding = false,
    this.monthsSinceCalving,
    this.headCount = 1,
    this.countryCode = 'SA',
    this.feedCycleHint,
  });

  factory NutritionProfileContext.fromRequest(Map<String, dynamic> request) {
    return NutritionProfileContext(
      species: request['species'] as String? ?? 'CATTLE',
      sex: request['sex'] as String?,
      ageMonths: (request['age_months'] as num?)?.toInt() ?? 24,
      productionFocus: request['production_focus'] as String? ?? 'MEAT',
      lactating: request['lactating'] as bool? ?? false,
      pregnant: request['pregnant'] as bool? ?? false,
      fattening: request['fattening'] as bool? ?? false,
      sick: request['sick'] as bool? ?? false,
      weaning: request['weaning'] as bool? ?? false,
      maintenance: request['maintenance'] as bool? ?? false,
      breeding: request['breeding'] as bool? ?? false,
      monthsSinceCalving: (request['months_since_calving'] as num?)?.toInt(),
      headCount: (request['head_count'] as num?)?.toInt() ?? 1,
      countryCode: request['country_code'] as String? ?? 'SA',
      feedCycleHint: request['feed_cycle_hint'] as String?,
    );
  }

  final String species;
  final String? sex;
  final int ageMonths;
  final String productionFocus;
  final bool lactating;
  final bool pregnant;
  final bool fattening;
  final bool sick;
  final bool weaning;
  final bool maintenance;
  final bool breeding;
  final int? monthsSinceCalving;
  final int headCount;
  final String countryCode;
  /// Expected feed cycle from app purpose/tags (for coverage checks).
  final String? feedCycleHint;
}

class ResolvedNutritionProfile {
  const ResolvedNutritionProfile({
    required this.profile,
    required this.profileCode,
    required this.matchReason,
  });

  final NutritionRequirementProfile profile;
  final String profileCode;
  final String matchReason;
}

/// Maps herd context → masterfile profile (aligned with nutrition-profile-resolver.ts).
abstract final class NutritionProfileResolver {
  static const _dairyStageCode = <String, String>{
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

  static ResolvedNutritionProfile resolve(
    NutritionRequirementsCatalog catalog,
    NutritionProfileContext ctx,
  ) {
    final dedicated = _tryDedicatedProfile(catalog, ctx);
    if (dedicated != null) return dedicated;

    if (ctx.species == 'GOAT' || ctx.species == 'SHEEP') {
      return _resolveSmallRuminant(catalog, ctx);
    }
    if (ctx.productionFocus == 'MILK' || ctx.productionFocus == 'BOTH') {
      return _resolveDairy(catalog, ctx);
    }
    return _resolveBeef(catalog, ctx);
  }

  static ResolvedNutritionProfile? _tryDedicatedProfile(
    NutritionRequirementsCatalog catalog,
    NutritionProfileContext ctx,
  ) {
    final hint = ctx.feedCycleHint;

    if (ctx.sick || hint == NutritionFeedCycle.sick) {
      final code = ctx.species == 'CATTLE'
          ? 'CATTLE_SICK'
          : '${ctx.species}_SICK';
      final profile = catalog.getByCode(code);
      if (profile != null) {
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'dedicated sick profile',
        );
      }
    }

    if (ctx.weaning || hint == NutritionFeedCycle.weaning) {
      final code = ctx.species == 'CATTLE'
          ? 'CATTLE_WEANING'
          : '${ctx.species}_SMALL_RUMINANT_WEANING';
      final profile = catalog.getByCode(code);
      if (profile != null) {
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'dedicated weaning profile',
        );
      }
    }

    if (ctx.species == 'CATTLE' &&
        ctx.sex == 'MALE' &&
        ctx.ageMonths >= 24 &&
        (ctx.productionFocus == 'MILK' || ctx.productionFocus == 'BOTH') &&
        !ctx.lactating) {
      final profile = catalog.getByCode('CATTLE_DAIRY_BREEDING_BULL');
      if (profile != null) {
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'dairy breeding bull',
        );
      }
    }

    if ((ctx.breeding || hint == NutritionFeedCycle.breeding) &&
        (ctx.species == 'GOAT' || ctx.species == 'SHEEP')) {
      final profile =
          catalog.getByCode('${ctx.species}_SMALL_RUMINANT_BREEDING');
      if (profile != null) {
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'small ruminant breeding',
        );
      }
    }

    if (ctx.maintenance ||
        hint == NutritionFeedCycle.maintenance ||
        hint == NutritionFeedCycle.bullMaintenance) {
      final code = _beefMaintenanceCode(ctx);
      if (code != null) {
        final profile = catalog.getByCode(code);
        if (profile != null) {
          return ResolvedNutritionProfile(
            profile: profile,
            profileCode: profile.profileCode,
            matchReason: 'beef maintenance',
          );
        }
      }
    }

    return null;
  }

  static String? _beefMaintenanceCode(NutritionProfileContext ctx) {
    if (ctx.species != 'CATTLE') return null;
    if (ctx.lactating || ctx.pregnant || ctx.fattening) return null;
    if (ctx.productionFocus == 'MILK' || ctx.productionFocus == 'BOTH') {
      return null;
    }
    final animalClass = _beefAnimalClass(ctx);
    return switch (animalClass) {
      'First Calf Heifer' => 'CATTLE_BEEF_FIRST_CALF_HEIFER_MAINTENANCE',
      'Mature Bull Maintenance' => 'CATTLE_BEEF_MATURE_BULL_MAINTENANCE',
      'Mature Cow' => 'CATTLE_BEEF_MATURE_COW_MAINTENANCE',
      _ => null,
    };
  }

  static ResolvedNutritionProfile _resolveDairy(
    NutritionRequirementsCatalog catalog,
    NutritionProfileContext ctx,
  ) {
    late final String stage;
    if (ctx.lactating) {
      final m = ctx.monthsSinceCalving ?? 2;
      if (m <= 1) {
        stage = 'Cow - Fresh';
      } else if (m <= 3) {
        stage = 'Cow - Early';
      } else if (m <= 6) {
        stage = 'Cow - Mid';
      } else {
        stage = 'Cow - Late';
      }
    } else if (ctx.pregnant) {
      stage = 'Close (Close up)';
    } else if (ctx.ageMonths < 8) {
      stage = '6-mo Heifer';
    } else if (ctx.ageMonths < 14) {
      stage = '12-mo Heifer';
    } else if (ctx.ageMonths < 20) {
      stage = '18-mo Heifer';
    } else if (ctx.ageMonths < 26) {
      stage = '24-mo Heifer (Close up)';
    } else {
      stage = 'Dry (Far off)';
    }

    final code = _dairyStageCode[stage];
    final profile = (code != null ? catalog.getByCode(code) : null) ??
        catalog
            .listForSpecies('CATTLE')
            .where((p) => p.lifeStage == stage)
            .firstOrNull;
    if (profile == null) {
      throw StateError('No dairy nutrition profile for stage: $stage');
    }
    return ResolvedNutritionProfile(
      profile: profile,
      profileCode: profile.profileCode,
      matchReason: 'dairy life stage: $stage',
    );
  }

  static String _beefAnimalClass(NutritionProfileContext ctx) {
    if (ctx.sex == 'MALE') {
      if (ctx.ageMonths < 11) return 'Growing Bull Calves <11 months';
      if (ctx.ageMonths < 24) return 'Growing Bull Yearlings >12 months';
      return 'Mature Bull Maintenance';
    }
    if (ctx.ageMonths < 11) return 'Feeder Calves <11 months of age';
    if (ctx.ageMonths < 24) return 'Feeder Yearlings >11 months of age';
    if (ctx.ageMonths < 30) return 'First Calf Heifer';
    return 'Mature Cow';
  }

  static ResolvedNutritionProfile _resolveBeef(
    NutritionRequirementsCatalog catalog,
    NutritionProfileContext ctx,
  ) {
    final animalClass = _beefAnimalClass(ctx);
    final m = ctx.monthsSinceCalving;

    if (ctx.ageMonths < 24 &&
        !ctx.lactating &&
        animalClass.contains('Calves')) {
      final growing = catalog.listBeefGrowing(animalClass);
      if (growing.isNotEmpty) {
        final profile = growing.first;
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'beef growth $animalClass',
        );
      }
    }

    late final String lifeStage;
    if (ctx.lactating) {
      lifeStage = m != null && m >= 4 ? 'Mid Lactation' : 'Early Lactation';
    } else if (ctx.pregnant) {
      lifeStage = m != null && m >= 8 ? 'Late Gestation' : 'Mid Gestation';
    } else if (ctx.ageMonths < 24) {
      lifeStage = 'Growing';
      final growing = catalog.listBeefGrowing(animalClass);
      if (growing.isNotEmpty) {
        final profile = growing.first;
        return ResolvedNutritionProfile(
          profile: profile,
          profileCode: profile.profileCode,
          matchReason: 'beef $animalClass / Growing',
        );
      }
    } else if (!ctx.lactating &&
        !ctx.pregnant &&
        ctx.productionFocus == 'MEAT') {
      final code = _beefMaintenanceCode(ctx);
      if (code != null) {
        final profile = catalog.getByCode(code);
        if (profile != null) {
          return ResolvedNutritionProfile(
            profile: profile,
            profileCode: profile.profileCode,
            matchReason: 'beef maintenance $animalClass',
          );
        }
      }
      lifeStage = 'Mid Gestation';
    } else {
      lifeStage = 'Mid Gestation';
    }

    final ranked = catalog.listBeef(
      animalClass,
      lifeStage,
      monthsSinceCalving: m,
    );
    if (ranked.isNotEmpty) {
      final profile = ranked.first;
      return ResolvedNutritionProfile(
        profile: profile,
        profileCode: profile.profileCode,
        matchReason:
            'beef $animalClass / $lifeStage${m != null ? ' month $m' : ''}',
      );
    }

    final fallback = catalog.listForSpecies('CATTLE').where(
          (p) =>
              p.productionSystem == 'BEEF' &&
              p.animalClass == animalClass &&
              p.lifeStage == lifeStage,
        );
    if (fallback.isEmpty) {
      throw StateError(
        'No beef nutrition profile for $animalClass / $lifeStage',
      );
    }
    final profile = fallback.first;
    return ResolvedNutritionProfile(
      profile: profile,
      profileCode: profile.profileCode,
      matchReason: 'beef $animalClass / $lifeStage (fallback)',
    );
  }

  static ResolvedNutritionProfile _resolveSmallRuminant(
    NutritionRequirementsCatalog catalog,
    NutritionProfileContext ctx,
  ) {
    late final String suffix;
    if (ctx.fattening) {
      suffix = 'SMALL_RUMINANT_FATTENING';
    } else if (ctx.lactating) {
      suffix = 'SMALL_RUMINANT_LACTATING';
    } else if (ctx.pregnant) {
      suffix = 'SMALL_RUMINANT_PREGNANT';
    } else {
      suffix = 'SMALL_RUMINANT_MAINTENANCE';
    }
    var code = '${ctx.species}_$suffix';
    if (ctx.ageMonths < 12) {
      final youngCode = '${code}_YOUNG';
      if (catalog.getByCode(youngCode) != null) {
        code = youngCode;
      }
    }
    final profile = catalog.getByCode(code);
    if (profile == null) {
      throw StateError('No small ruminant profile: $code');
    }
    return ResolvedNutritionProfile(
      profile: profile,
      profileCode: profile.profileCode,
      matchReason: 'small ruminant: ${profile.lifeStage}'
          '${ctx.ageMonths < 12 ? ' (young)' : ''}',
    );
  }

  /// Per-animal and group nutrient targets from a resolved profile.
  static Map<String, dynamic> buildGroupRequirements(
    NutritionRequirementProfile profile,
    int headCount, {
    bool fattening = false,
  }) {
    final heads = headCount < 1 ? 1 : headCount;
    var dmi = profile.dmiKgDay;
    if (fattening && profile.productionSystem == 'SMALL_RUMINANT') {
      dmi *= 1.18;
    }

    if (profile.productionSystem == 'DAIRY') {
      final cpPct = profile.cpPercentDm ?? 0;
      final ndfPct = profile.ndfPercentDm ?? 0;
      final adfPct = profile.adfPercentDm ?? 0;
      final caPct = profile.caPercentDm ?? 0;
      final pPct = profile.pPercentDm ?? 0;
      final nel = profile.nelMcalPerKgDm ?? 0;
      final perAnimal = {
        'dry_matter_kg': dmi,
        'crude_protein_kg': dmi * cpPct / 100,
        'ndf_kg': dmi * ndfPct / 100,
        'fibre_kg': dmi * adfPct / 100,
        'calcium_kg': dmi * caPct / 100,
        'phosphorus_kg': dmi * pPct / 100,
        'nem_mcal': nel * dmi,
        'neg_mcal': 0.0,
      };
      return {
        'species': profile.species,
        'optimizer': 'cattle',
        'per_animal': perAnimal,
        'group': {
          for (final e in perAnimal.entries) e.key: e.value * heads,
          'no_of_animals': heads,
        },
      };
    }

    if (profile.productionSystem == 'BEEF') {
      final cp = profile.cpKgDay ?? 0;
      final ca = profile.caKgDay ?? 0;
      final p = profile.pKgDay ?? 0;
      final nem = profile.nemMcalDay ?? 0;
      final neg = profile.negMcalDay ?? 0;
      final perAnimal = {
        'dry_matter_kg': dmi,
        'crude_protein_kg': cp,
        'ndf_kg': 0.0,
        'fibre_kg': 0.0,
        'calcium_kg': ca,
        'phosphorus_kg': p,
        'nem_mcal': nem,
        'neg_mcal': neg,
      };
      return {
        'species': profile.species,
        'optimizer': 'cattle',
        'per_animal': perAnimal,
        'group': {
          for (final e in perAnimal.entries) e.key: e.value * heads,
          'no_of_animals': heads,
        },
      };
    }

    final cp = profile.cpKgDay ?? (dmi * (profile.cpPercentDm ?? 12)) / 100;
    final tdn = profile.tdnKgDay ?? dmi * 0.6;
    final caG = (profile.caKgDay ?? 0) * 1000;
    final pG = (profile.pKgDay ?? 0) * 1000;
    final perAnimal = {
      'dry_matter_kg': dmi,
      'protein_kg': cp,
      'tdn_kg': tdn,
      'calcium_g': caG,
      'phosphorus_g': pG,
      'fodder_percent': profile.fodderPercent ?? 50,
      'concentrate_percent': profile.concentratePercent ?? 40,
    };
    return {
      'species': profile.species,
      'optimizer': 'small_ruminant',
      'per_animal': perAnimal,
      'group': {
        'dry_matter_kg': dmi * heads,
        'protein_kg': cp * heads,
        'tdn_kg': tdn * heads,
        'calcium_g': caG * heads,
        'phosphorus_g': pG * heads,
        'fodder_percent': profile.fodderPercent ?? 50,
        'concentrate_percent': profile.concentratePercent ?? 40,
        'no_of_animals': heads,
      },
    };
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
