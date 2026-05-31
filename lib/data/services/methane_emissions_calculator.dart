import 'dart:math' as math;

import '../models/enums.dart';
import '../models/models.dart';

/// Enteric methane estimates for Middle East (GCC) livestock systems.
///
/// Based on IPCC Tier 1-style scaling by metabolic weight, with regional
/// adjustment factors for heat-stressed arid-zone management (slightly
/// lower dry matter intake vs temperate dairy, similar per-unit emissions).
class MethaneEmissionEstimate {
  const MethaneEmissionEstimate({
    required this.animalId,
    required this.tag,
    required this.species,
    required this.weightKg,
    required this.ageMonths,
    required this.ch4KgPerDay,
    required this.co2eKgPerDay,
    required this.methodNote,
  });

  final String animalId;
  final String tag;
  final Species species;
  final double weightKg;
  final int ageMonths;
  /// Methane (CH₄) kg per day.
  final double ch4KgPerDay;
  /// CO₂ equivalent kg per day (CH₄ × 28 GWP).
  final double co2eKgPerDay;
  final String methodNote;

  double get ch4GPerDay => ch4KgPerDay * 1000;
}

abstract final class MethaneEmissionsCalculator {
  static const gwpCh4 = 28.0;
  /// Internal audit tag (UI uses localized [AppLocalizations.methaneRegionMiddleEast]).
  static const _regionNote = 'ME-GCC';

  /// Reference mature body weight (kg) per species for scaling.
  static const _refWeight = {
    Species.cattle: 450.0,
    Species.sheep: 55.0,
    Species.goat: 45.0,
  };

  /// Adult baseline CH₄ (kg/day) at reference weight in arid dairy/beef systems.
  static const _adultCh4Baseline = {
    Species.cattle: 0.368,
    Species.sheep: 0.021,
    Species.goat: 0.018,
  };

  static MethaneEmissionEstimate forAnimal(Animal animal) {
    final ageMonths = _ageMonths(animal);
    final lactating = animal.tags.contains(AnimalTagType.lactating);
    final pregnant = animal.tags.contains(AnimalTagType.pregnant);
    final ch4 = _dailyCh4Kg(
      species: animal.species,
      weightKg: animal.weightKg,
      ageMonths: ageMonths,
      lactating: lactating,
      pregnant: pregnant,
    );
    return MethaneEmissionEstimate(
      animalId: animal.id,
      tag: animal.tag,
      species: animal.species,
      weightKg: animal.weightKg,
      ageMonths: ageMonths,
      ch4KgPerDay: ch4,
      co2eKgPerDay: ch4 * gwpCh4,
      methodNote: '$_regionNote · metabolic weight scaling',
    );
  }

  static List<MethaneEmissionEstimate> forAnimals(List<Animal> animals) =>
      animals.map(forAnimal).toList();

  static MethaneEmissionEstimate groupTotal(List<Animal> animals) {
    if (animals.isEmpty) {
      return const MethaneEmissionEstimate(
        animalId: 'group',
        tag: '—',
        species: Species.cattle,
        weightKg: 0,
        ageMonths: 0,
        ch4KgPerDay: 0,
        co2eKgPerDay: 0,
        methodNote: _regionNote,
      );
    }
    final estimates = forAnimals(animals);
    final totalCh4 =
        estimates.map((e) => e.ch4KgPerDay).reduce((a, b) => a + b);
    final totalWeight =
        animals.map((a) => a.weightKg).reduce((a, b) => a + b);
    return MethaneEmissionEstimate(
      animalId: 'group-total',
      tag: 'Herd total',
      species: animals.first.species,
      weightKg: totalWeight,
      ageMonths: 0,
      ch4KgPerDay: totalCh4,
      co2eKgPerDay: totalCh4 * gwpCh4,
      methodNote: '$_regionNote · ${animals.length} head total',
    );
  }

  static MethaneEmissionEstimate groupAverage(List<Animal> animals) {
    if (animals.isEmpty) {
      return const MethaneEmissionEstimate(
        animalId: 'group',
        tag: '—',
        species: Species.cattle,
        weightKg: 0,
        ageMonths: 0,
        ch4KgPerDay: 0,
        co2eKgPerDay: 0,
        methodNote: _regionNote,
      );
    }
    final estimates = forAnimals(animals);
    final avgCh4 =
        estimates.map((e) => e.ch4KgPerDay).reduce((a, b) => a + b) /
            estimates.length;
    final avgWeight =
        animals.map((a) => a.weightKg).reduce((a, b) => a + b) / animals.length;
    return MethaneEmissionEstimate(
      animalId: 'group-avg',
      tag: 'Herd average',
      species: animals.first.species,
      weightKg: avgWeight,
      ageMonths: (estimates.map((e) => e.ageMonths).reduce((a, b) => a + b) /
              estimates.length)
          .round(),
      ch4KgPerDay: avgCh4,
      co2eKgPerDay: avgCh4 * gwpCh4,
      methodNote: '$_regionNote · ${animals.length} head average',
    );
  }

  static double _dailyCh4Kg({
    required Species species,
    required double weightKg,
    required int ageMonths,
    required bool lactating,
    required bool pregnant,
  }) {
    final refW = _refWeight[species] ?? 400.0;
    final baseline = _adultCh4Baseline[species] ?? 0.35;
    final safeWeight = weightKg.clamp(20.0, 900.0);
    final weightFactor = math.pow(safeWeight / refW, 0.75).toDouble();

    var ageFactor = 1.0;
    if (ageMonths < 8) {
      ageFactor = 0.35;
    } else if (ageMonths < 12) {
      ageFactor = 0.55;
    } else if (ageMonths < 24) {
      ageFactor = 0.78;
    } else if (ageMonths > 120) {
      ageFactor = 0.92;
    }

    var productionFactor = 1.0;
    if (species == Species.cattle) {
      if (lactating) productionFactor = 1.14;
      if (pregnant && !lactating) productionFactor = 1.06;
    }

    return (baseline * weightFactor * ageFactor * productionFactor)
        .clamp(0.005, 2.5);
  }

  static int _ageMonths(Animal animal) {
    if (animal.dob != null) {
      final now = DateTime.now();
      return ((now.difference(animal.dob!).inDays) / 30.44).round().clamp(1, 180);
    }
    final label = animal.ageLabel.toLowerCase();
    final yearMatch = RegExp(r'(\d+)\s*y').firstMatch(label);
    final monthMatch = RegExp(r'(\d+)\s*m').firstMatch(label);
    var months = 0;
    if (yearMatch != null) months += int.parse(yearMatch.group(1)!) * 12;
    if (monthMatch != null) months += int.parse(monthMatch.group(1)!);
    return months > 0 ? months : 36;
  }
}
