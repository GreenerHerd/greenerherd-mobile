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
}
