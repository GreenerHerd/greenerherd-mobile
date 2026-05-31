import '../models/enums.dart';
import '../models/models.dart';
import 'nutrition_feed_cycle.dart';
import 'nutrition_profile_resolver.dart';
import 'reproduction_status_rules.dart';

/// Builds [NutritionProfileContext] from groups / animals for requirement lookup.
abstract final class NutritionContextBuilder {
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
    final lactating = animal.tags.contains(AnimalTagType.lactating);
    final pregnant = animal.tags.contains(AnimalTagType.pregnant);
    final fattening = animal.tags.contains(AnimalTagType.fattening);
    final weaning = animal.tags.contains(AnimalTagType.weaning);
    final sick = animal.tags.contains(AnimalTagType.sick);
    final breeding = animal.tags.contains(AnimalTagType.readyToBreed);

    return NutritionProfileContext(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
      productionFocus: production,
      lactating: lactating && !weaning,
      pregnant: pregnant,
      fattening: fattening,
      sick: sick,
      weaning: weaning,
      breeding: breeding,
      monthsSinceCalving: _monthsSinceCalvingFromAnimal(animal),
      headCount: 1,
      feedCycleHint: _feedCycleHint(
        species: species,
        purpose: null,
        production: production,
        lactating: lactating,
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
    var breeding = base.breeding;
    var maintenance = false;

    if (!hasIndividualState) {
      switch (group.purpose) {
        case GroupPurpose.fattening:
          fattening = true;
        case GroupPurpose.maintenance:
          maintenance = true;
        case GroupPurpose.breeding:
          breeding = true;
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
      headCount: 1,
      feedCycleHint: _feedCycleHint(
        species: base.species,
        purpose: group.purpose,
        production: base.productionFocus,
        lactating: lactating,
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
    final breeding = group.purpose == GroupPurpose.breeding ||
        herd.any((a) => a.tags.contains(AnimalTagType.readyToBreed));
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
    if (lactating) {
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

  static int? _monthsSinceCalvingFromAnimal(Animal animal) {
    if (animal.gestMonths != null &&
        animal.tags.contains(AnimalTagType.pregnant)) {
      return null;
    }
    if (animal.tags.contains(AnimalTagType.lactating)) {
      return animal.monthsSinceCalving ?? 2;
    }
    return animal.monthsSinceCalving;
  }
}
