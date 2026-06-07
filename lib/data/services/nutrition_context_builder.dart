import '../models/animal_lactation_cycle.dart';
import '../models/enums.dart';
import '../models/models.dart';
import 'lactation_cycle_service.dart';
import 'nutrition_feed_cycle.dart';
import 'nutrition_profile_resolver.dart';
import 'reproduction_status_rules.dart';

/// Builds [NutritionProfileContext] from groups / animals for requirement lookup.
abstract final class NutritionContextBuilder {
  static const _lactationCycleService = LactationCycleService();
  /// Tags that define an individual nutritional state and override group purpose.
  static const _individualStateTags = {
    AnimalTagType.lactating,
    AnimalTagType.pregnant,
    AnimalTagType.sick,
    AnimalTagType.weaning,
    AnimalTagType.fattening,
    AnimalTagType.readyToBreed,
  };

  static NutritionProfileContext fromAnimal(Animal animal) {
    final species = switch (animal.species) {
      Species.cattle => 'CATTLE',
      Species.goat => 'GOAT',
      Species.sheep => 'SHEEP',
    };
    final production = switch (animal.productionPurpose) {
      SpeciesPurpose.milk => 'MILK',
      SpeciesPurpose.meat => 'MEAT',
      SpeciesPurpose.both => 'BOTH',
    };
    final sex = ReproductionStatusRules.isFemaleSex(animal.sex)
        ? 'FEMALE'
        : 'MALE';
    final ageMonths =
        ReproductionStatusRules.ageMonthsFromAnimal(animal) ?? 24;
    final cycle = _lactationCycleService.effectiveCycle(animal);
    final lactating = cycle != null
        ? LactationCycleCatalog.isLactating(cycle)
        : animal.tags.contains(AnimalTagType.lactating);
    final lactatingTwin =
        cycle != null && LactationCycleCatalog.isTwinLactation(cycle);
    final pregnant = animal.tags.contains(AnimalTagType.pregnant);
    final fattening = animal.tags.contains(AnimalTagType.fattening);
    final weaning = animal.tags.contains(AnimalTagType.weaning);
    final sick = animal.tags.contains(AnimalTagType.sick);
    final breeding = ReproductionStatusRules.breedingForNutrition(animal);

    return NutritionProfileContext(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
      productionFocus: production,
      lactating: lactating && !weaning,
      lactatingTwin: lactatingTwin,
      pregnant: pregnant,
      fattening: fattening,
      sick: sick,
      weaning: weaning,
      breeding: breeding,
      monthsSinceCalving: _monthsSinceCalvingFromAnimal(animal, cycle: cycle),
      headCount: 1,
      feedCycleHint: _feedCycleHint(
        species: species,
        purpose: null,
        production: production,
        lactating: lactating,
        lactatingTwin: lactatingTwin,
        lactationCycle: cycle,
        pregnant: pregnant,
        fattening: fattening,
        weaning: weaning,
        sick: sick,
        breeding: breeding,
        maintenance: false,
        ageMonths: ageMonths,
        sex: sex,
      ),
    );
  }

  /// Per-member context: individual tags win; group purpose applies only for
  /// breeding, maintenance, and fattening on untagged animals.
  static NutritionProfileContext fromMemberInGroup(
    Animal animal,
    AnimalGroup group,
  ) {
    final base = fromAnimal(animal);
    final hasIndividualState = _hasIndividualNutritionState(animal);

    var lactating = base.lactating;
    var pregnant = base.pregnant;
    var sick = base.sick;
    var weaning = base.weaning;
    var fattening = base.fattening;
    var breeding = ReproductionStatusRules.breedingForNutrition(animal, group: group);
    var maintenance = false;

    if (!hasIndividualState) {
      switch (group.purpose) {
        case GroupPurpose.fattening:
          fattening = true;
        case GroupPurpose.maintenance:
          maintenance = true;
        case GroupPurpose.breeding:
          breeding = ReproductionStatusRules.breedingForNutrition(
            animal,
            group: group,
          );
        default:
          break;
      }
    }

    return NutritionProfileContext(
      species: base.species,
      sex: base.sex,
      ageMonths: base.ageMonths,
      productionFocus: base.productionFocus,
      lactating: lactating,
      pregnant: pregnant,
      fattening: fattening,
      sick: sick,
      weaning: weaning,
      maintenance: maintenance,
      breeding: breeding,
      monthsSinceCalving: base.monthsSinceCalving,
      lactatingTwin: base.lactatingTwin,
      headCount: 1,
      feedCycleHint: _feedCycleHint(
        species: base.species,
        purpose: group.purpose,
        production: base.productionFocus,
        lactating: lactating,
        lactatingTwin: base.lactatingTwin,
        lactationCycle: animal.lactationCycle ??
            _lactationCycleService.effectiveCycle(animal),
        pregnant: pregnant,
        fattening: fattening,
        weaning: weaning,
        sick: sick,
        breeding: breeding,
        maintenance: maintenance,
        ageMonths: base.ageMonths,
        sex: base.sex,
      ),
    );
  }

  static NutritionProfileContext fromGroup(
    AnimalGroup group, {
    List<Animal>? members,
  }) {
    final species = switch (group.species) {
      Species.cattle => 'CATTLE',
      Species.goat => 'GOAT',
      Species.sheep => 'SHEEP',
    };

    final herd = members?.where((a) => a.groupId == group.id).toList() ??
        <Animal>[];
    final ageMonths = _medianAgeMonths(herd) ?? 24;
    final sex = _predominantSex(herd);
    final production = _predominantProduction(herd, group);

    final lactating =
        herd.any((a) => a.tags.contains(AnimalTagType.lactating));
    final pregnant = herd.any((a) => a.tags.contains(AnimalTagType.pregnant));
    final fattening = group.purpose == GroupPurpose.fattening ||
        herd.any((a) => a.tags.contains(AnimalTagType.fattening));
    final weaning = herd.any((a) => a.tags.contains(AnimalTagType.weaning));
    final sick = herd.any((a) => a.tags.contains(AnimalTagType.sick));
    final breeding = herd.any(
          (a) => ReproductionStatusRules.breedingForNutrition(a, group: group),
        ) ||
        (herd.isEmpty && group.purpose == GroupPurpose.breeding);
    final maintenance = group.purpose == GroupPurpose.maintenance &&
        herd.every((a) => !_hasIndividualNutritionState(a));

    return NutritionProfileContext(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
      productionFocus: production,
      lactating: lactating,
      pregnant: pregnant,
      fattening: fattening,
      sick: sick,
      weaning: weaning,
      maintenance: maintenance,
      breeding: breeding,
      monthsSinceCalving: _medianMonthsSinceCalving(herd),
      headCount: group.headCount,
      feedCycleHint: _feedCycleHint(
        species: species,
        purpose: group.purpose,
        production: production,
        lactating: lactating,
        pregnant: pregnant,
        fattening: fattening,
        weaning: weaning,
        sick: sick,
        breeding: breeding,
        maintenance: maintenance,
        ageMonths: ageMonths,
        sex: sex,
      ),
    );
  }

  static bool _hasIndividualNutritionState(Animal animal) {
    return animal.tags.any(_individualStateTags.contains);
  }

  static String? _feedCycleHint({
    required String species,
    required GroupPurpose? purpose,
    required String production,
    required bool lactating,
    bool lactatingTwin = false,
    AnimalLactationCycle? lactationCycle,
    required bool pregnant,
    required bool fattening,
    required bool weaning,
    required bool sick,
    required bool breeding,
    required bool maintenance,
    required int ageMonths,
    required String? sex,
  }) {
    if (sick) return NutritionFeedCycle.sick;
    if (weaning) return NutritionFeedCycle.weaning;
    if (fattening) return NutritionFeedCycle.fattening;
    if (lactationCycle == AnimalLactationCycle.cattlePreCalvingCloseToDryOff) {
      return NutritionFeedCycle.closeUp;
    }
    if (lactationCycle == AnimalLactationCycle.cattleDry) {
      return NutritionFeedCycle.dryFarOff;
    }
    if (lactationCycle == AnimalLactationCycle.nonLactating &&
        (species == 'GOAT' || species == 'SHEEP')) {
      return NutritionFeedCycle.maintenance;
    }
    if (lactating) {
      if (lactationCycle != null) {
        return switch (lactationCycle) {
          AnimalLactationCycle.cattleEarly => NutritionFeedCycle.fresh,
          AnimalLactationCycle.cattleMid => NutritionFeedCycle.midLactation,
          AnimalLactationCycle.cattleLate => NutritionFeedCycle.lateLactation,
          AnimalLactationCycle.cattleClose => NutritionFeedCycle.lateLactation,
          AnimalLactationCycle.cattlePreCalvingCloseToDryOff =>
            NutritionFeedCycle.closeUp,
          AnimalLactationCycle.lactatingSingle ||
          AnimalLactationCycle.lactatingTwin =>
            NutritionFeedCycle.lactating,
          _ => NutritionFeedCycle.earlyLactation,
        };
      }
      return NutritionFeedCycle.earlyLactation;
    }
    if (pregnant) {
      return species == 'CATTLE' && production != 'MEAT'
          ? NutritionFeedCycle.closeUp
          : NutritionFeedCycle.pregnant;
    }
    if (breeding) return NutritionFeedCycle.breeding;
    if (maintenance) {
      return NutritionFeedCycle.maintenance;
    }
    if (species == 'CATTLE' && sex == 'MALE' && production == 'MEAT') {
      return NutritionFeedCycle.bullMaintenance;
    }
    if (ageMonths < 11 && species == 'CATTLE' && production == 'MEAT') {
      return NutritionFeedCycle.growing;
    }
    return null;
  }

  static String _predominantProduction(
    List<Animal> herd,
    AnimalGroup group,
  ) {
    if (herd.isEmpty) {
      return switch (group.purpose) {
        GroupPurpose.breeding => 'BOTH',
        GroupPurpose.fattening => 'MEAT',
        _ => 'MEAT',
      };
    }
    var milk = 0;
    var meat = 0;
    for (final a in herd) {
      switch (a.productionPurpose) {
        case SpeciesPurpose.milk:
          milk++;
        case SpeciesPurpose.meat:
          meat++;
        case SpeciesPurpose.both:
          milk++;
          meat++;
      }
    }
    if (milk > meat) return 'MILK';
    if (meat > milk) return 'MEAT';
    return 'BOTH';
  }

  static String? _predominantSex(List<Animal> herd) {
    if (herd.isEmpty) return 'FEMALE';
    var males = 0;
    var females = 0;
    for (final a in herd) {
      if (ReproductionStatusRules.isFemaleSex(a.sex)) {
        females++;
      } else {
        males++;
      }
    }
    if (males > females) return 'MALE';
    if (females > males) return 'FEMALE';
    return 'FEMALE';
  }

  static int? _medianAgeMonths(List<Animal> herd) {
    final ages = herd
        .map(ReproductionStatusRules.ageMonthsFromAnimal)
        .whereType<int>()
        .toList();
    if (ages.isEmpty) return null;
    ages.sort();
    return ages[ages.length ~/ 2];
  }

  static int? _medianMonthsSinceCalving(List<Animal> herd) {
    final values = herd
        .map(_monthsSinceCalvingFromAnimal)
        .whereType<int>()
        .toList();
    if (values.isEmpty) return null;
    values.sort();
    return values[values.length ~/ 2];
  }

  static int? _monthsSinceCalvingFromAnimal(
    Animal animal, {
    AnimalLactationCycle? cycle,
  }) {
    if (animal.gestMonths != null &&
        animal.tags.contains(AnimalTagType.pregnant)) {
      return null;
    }
    final resolved = cycle ?? _lactationCycleService.effectiveCycle(animal);
    if (resolved != null) {
      return LactationCycleCatalog.monthsSinceCalvingFor(resolved) ??
          animal.monthsSinceCalving;
    }
    if (animal.tags.contains(AnimalTagType.lactating)) {
      return animal.monthsSinceCalving ?? 2;
    }
    return animal.monthsSinceCalving;
  }
}
