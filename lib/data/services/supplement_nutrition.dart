/// Nutrient contribution from a one-off supplement feeding (kg as-fed).
class SupplementNutritionInput {
  const SupplementNutritionInput({
    required this.kgAsFed,
    this.dryMatterPercent = 88,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
  });

  final double kgAsFed;
  final double dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
}

class SupplementNutritionContribution {
  const SupplementNutritionContribution({
    required this.dryMatterKg,
    required this.energyMj,
    required this.proteinKg,
    required this.ndfKg,
  });

  final double dryMatterKg;
  final double energyMj;
  final double proteinKg;
  final double ndfKg;

  SupplementNutritionContribution operator -() => SupplementNutritionContribution(
        dryMatterKg: -dryMatterKg,
        energyMj: -energyMj,
        proteinKg: -proteinKg,
        ndfKg: -ndfKg,
      );
}

abstract final class SupplementNutrition {
  static const maxRecommendations = 5;

  static SupplementNutritionContribution contribution(
    SupplementNutritionInput input,
  ) {
    final dm = input.kgAsFed * input.dryMatterPercent / 100;
    return SupplementNutritionContribution(
      dryMatterKg: dm,
      energyMj: input.kgAsFed * (input.nemMcalPerKg ?? 1.5),
      proteinKg: input.kgAsFed * (input.crudeProteinPercent ?? 0) / 100,
      ndfKg: input.kgAsFed * (input.ndfPercent ?? 0) / 100,
    );
  }

  static void applyToPayload(
    Map<String, dynamic> payload,
    SupplementNutritionContribution delta, {
    bool subtract = false,
  }) {
    final sign = subtract ? -1.0 : 1.0;
    final current = Map<String, dynamic>.from(
      payload['current'] as Map? ?? {},
    );
    current['dry_matter_kg'] =
        _num(current['dry_matter_kg']) + sign * delta.dryMatterKg;
    current['energy_mj'] = _num(current['energy_mj']) + sign * delta.energyMj;
    current['protein_kg'] = _num(current['protein_kg']) + sign * delta.proteinKg;
    if (current.containsKey('ndf_kg') || delta.ndfKg != 0) {
      current['ndf_kg'] = _num(current['ndf_kg']) + sign * delta.ndfKg;
    }
    payload['current'] = current;
  }

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;
}
