import '../models/enums.dart';
import '../models/models.dart';

/// When pregnancy / lactation status tags may be applied (group wizard, profiles).
abstract final class ReproductionStatusRules {
  ReproductionStatusRules._();

  /// Minimum age (months) before a female may be marked pregnant or lactating.
  static int minReproductionAgeMonths(Species species) => switch (species) {
        Species.cattle => 15,
        Species.goat => 7,
        Species.sheep => 7,
      };

  static bool isFemaleSex(String sex) {
    final s = sex.trim().toUpperCase();
    return s == 'F' || s == 'FEMALE';
  }

  static int? ageMonthsFromAnimal(Animal animal) {
    if (animal.dob != null) return ageMonthsFromDob(animal.dob);
    final label = animal.ageLabel.trim();
    final m = RegExp(r'^(\d+)m$').firstMatch(label);
    if (m != null) return int.tryParse(m.group(1)!);
    final y = RegExp(r'^(\d+)y$').firstMatch(label);
    if (y != null) return (int.tryParse(y.group(1)!) ?? 0) * 12;
    return null;
  }

  static int? ageMonthsFromDob(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  static bool canBePregnant({
    required Species species,
    required String sex,
    int? ageMonths,
  }) {
    if (!isFemaleSex(sex)) return false;
    if (ageMonths == null) return false;
    return ageMonths >= minReproductionAgeMonths(species);
  }

  static bool canLactate({
    required Species species,
    required String sex,
    int? ageMonths,
  }) {
    if (!isFemaleSex(sex)) return false;
    if (ageMonths == null) return false;
    return ageMonths >= minReproductionAgeMonths(species);
  }

  static bool canMarkReadyToBreed({
    required Species species,
    required String sex,
    int? ageMonths,
  }) {
    if (ageMonths == null) return false;
    if (ageMonths < minReproductionAgeMonths(species)) return false;
    if (isFemaleSex(sex)) return true;
    return species == Species.sheep || species == Species.goat;
  }

  static bool canMarkReadyToBreedForAnimal(Animal animal) =>
      canMarkReadyToBreed(
        species: animal.species,
        sex: animal.sex,
        ageMonths: ageMonthsFromAnimal(animal),
      );

  /// Breeding tab shows status controls for females and breeding males (rams/bucks).
  static bool showsBreedingStatusTab(Animal animal) =>
      isFemaleSex(animal.sex) || canMarkReadyToBreedForAnimal(animal);

  /// Heifer applies to female cattle that have not yet calved.
  static bool canMarkHeifer({
    required Species species,
    required String sex,
  }) =>
      species == Species.cattle && isFemaleSex(sex);

  static String disabledPregnancyTooltip({
    required Species species,
    required String sex,
    int? ageMonths,
  }) {
    if (!isFemaleSex(sex)) return 'Pregnancy applies to females only';
    if (ageMonths == null) return 'Enter age before marking pregnant';
    final min = minReproductionAgeMonths(species);
    if (ageMonths < min) {
      return 'Minimum $min months for pregnancy (${_speciesLabel(species)})';
    }
    return 'Pregnancy';
  }

  static String disabledLactatingTooltip({
    required Species species,
    required String sex,
    int? ageMonths,
  }) {
    if (!isFemaleSex(sex)) return 'Lactation applies to females only';
    if (ageMonths == null) return 'Enter age before marking lactating';
    final min = minReproductionAgeMonths(species);
    if (ageMonths < min) {
      return 'Minimum $min months for lactation (${_speciesLabel(species)})';
    }
    return 'Lactating';
  }

  static String _speciesLabel(Species species) => switch (species) {
        Species.cattle => 'cattle',
        Species.goat => 'goats',
        Species.sheep => 'sheep',
      };

  /// Minimum months after calving before the next breeding cycle (voluntary waiting period).
  static int minMonthsSinceCalvingForRebreeding(Species species) =>
      switch (species) {
        Species.cattle => 2,
        Species.goat => 2,
        Species.sheep => 2,
      };

  /// Months since last calving for nutrition / breeding KPI (null if never calved).
  static int? effectiveMonthsSinceCalving(Animal animal) {
    if (animal.monthsSinceCalving != null) return animal.monthsSinceCalving;
    if (animal.tags.contains(AnimalTagType.lactating)) return 2;
    return null;
  }

  /// Females post-calving (or currently lactating) show the breeding-cycle KPI.
  static bool showsBreedingCycleKpi(Animal animal) {
    if (!isFemaleSex(animal.sex)) return false;
    if (animal.isHeifer == true && animal.monthsSinceCalving == null) {
      return false;
    }
    return animal.monthsSinceCalving != null ||
        animal.tags.contains(AnimalTagType.lactating) ||
        animal.isHeifer == false;
  }

  static bool isEligibleForNextBreeding(Animal animal) {
    if (!isFemaleSex(animal.sex)) return false;
    if (animal.tags.contains(AnimalTagType.pregnant)) return false;
    if (animal.tags.contains(AnimalTagType.readyToBreed)) return true;
    final months = effectiveMonthsSinceCalving(animal);
    if (months == null) return false;
    return months >= minMonthsSinceCalvingForRebreeding(animal.species);
  }

  /// Past voluntary waiting period since calving but not yet tagged ready to breed.
  static bool needsReadyToBreedTag(Animal animal) {
    if (!isFemaleSex(animal.sex)) return false;
    if (animal.tags.contains(AnimalTagType.pregnant)) return false;
    if (animal.tags.contains(AnimalTagType.readyToBreed)) return false;
    final months = effectiveMonthsSinceCalving(animal);
    if (months == null) return false;
    return months >= minMonthsSinceCalvingForRebreeding(animal.species);
  }

  /// Lactation phase label key suffix for [AppLocalizations] (fresh/peak/mid/late/dry).
  static String lactationStageKey(int monthsSinceCalving) {
    if (monthsSinceCalving <= 1) return 'fresh';
    if (monthsSinceCalving <= 3) return 'peak';
    if (monthsSinceCalving <= 6) return 'mid';
    return 'late';
  }
}

/// Group breeding tab / nutrition context summary from herd members.
class GroupBreedingCycleSummary {
  const GroupBreedingCycleSummary({
    required this.lactatingCount,
    required this.medianMonthsSinceCalving,
    required this.readyForRebreedingCount,
    required this.waitingCount,
    required this.lactationStageCounts,
  });

  final int lactatingCount;
  final int? medianMonthsSinceCalving;
  final int readyForRebreedingCount;
  final int waitingCount;
  final Map<String, int> lactationStageCounts;

  static bool showsBreedingCycleKpi(List<Animal> members) {
    return members.any(showsBreedingCycleKpiForAnimal);
  }

  static bool showsBreedingCycleKpiForAnimal(Animal animal) =>
      ReproductionStatusRules.showsBreedingCycleKpi(animal);

  static GroupBreedingCycleSummary? fromMembers(List<Animal> members) {
    final lactating = members
        .where(
          (a) =>
              ReproductionStatusRules.isFemaleSex(a.sex) &&
              ReproductionStatusRules.showsBreedingCycleKpi(a),
        )
        .toList();
    if (lactating.isEmpty) return null;

    final monthsValues = lactating
        .map(ReproductionStatusRules.effectiveMonthsSinceCalving)
        .whereType<int>()
        .toList()
      ..sort();

    final stageCounts = <String, int>{
      'fresh': 0,
      'peak': 0,
      'mid': 0,
      'late': 0,
    };
    var ready = 0;
    var waiting = 0;
    for (final animal in lactating) {
      final months = ReproductionStatusRules.effectiveMonthsSinceCalving(animal);
      if (months != null) {
        final stage = ReproductionStatusRules.lactationStageKey(months);
        stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;
      }
      if (ReproductionStatusRules.isEligibleForNextBreeding(animal)) {
        ready++;
      } else if (!animal.tags.contains(AnimalTagType.pregnant)) {
        waiting++;
      }
    }

    return GroupBreedingCycleSummary(
      lactatingCount: lactating.length,
      medianMonthsSinceCalving: monthsValues.isEmpty
          ? null
          : monthsValues[monthsValues.length ~/ 2],
      readyForRebreedingCount: ready,
      waitingCount: waiting,
      lactationStageCounts: stageCounts,
    );
  }
}
