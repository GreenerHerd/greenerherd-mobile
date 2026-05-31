import '../models/inventory_models.dart';

/// Combined meal nutrients normalised to 1 kg of mix (as-fed).
class MealMixNutritionPerKg {
  const MealMixNutritionPerKg({
    required this.totalMixKg,
    required this.dryMatterPercent,
    required this.crudeProteinPercent,
    required this.nemMcalPerKg,
    required this.ndfPercent,
    this.calciumPercent,
    this.phosphorusPercent,
    this.costPerKg,
    this.hasNutritionData = false,
  });

  final double totalMixKg;
  final double dryMatterPercent;
  final double crudeProteinPercent;
  final double nemMcalPerKg;
  final double ndfPercent;
  final double? calciumPercent;
  final double? phosphorusPercent;
  final double? costPerKg;
  final bool hasNutritionData;
}

abstract final class MealMixNutritionCalculator {
  MealMixNutritionCalculator._();

  static MealMixNutritionPerKg? calculate({
    required Iterable<({String? feedId, double kg})> ingredients,
    required List<FeedInventoryItem> feedItems,
  }) {
    var totalKg = 0.0;
    var totalDm = 0.0;
    var totalCp = 0.0;
    var totalEnergy = 0.0;
    var totalNdf = 0.0;
    var totalCa = 0.0;
    var totalP = 0.0;
    var totalCost = 0.0;
    var hasNutrition = false;
    var hasCa = false;
    var hasP = false;

    for (final ing in ingredients) {
      if (ing.feedId == null || ing.kg <= 0) continue;
      final feed = _feedById(feedItems, ing.feedId!);
      if (feed == null) continue;

      totalKg += ing.kg;
      if (feed.unitCost != null && feed.unitCost! > 0) {
        totalCost += ing.kg * feed.unitCost!;
      }

      final n = feed.customNutrition;
      if (n.isEmpty) continue;
      hasNutrition = true;

      final dm = (n['dry_matter_percent'] as num?)?.toDouble() ?? 0;
      final cp = (n['crude_protein_percent'] as num?)?.toDouble() ?? 0;
      final ne = (n['nem_mcal_per_kg'] as num?)?.toDouble() ?? 0;
      final ndf = (n['ndf_percent'] as num?)?.toDouble() ?? 0;
      final ca = (n['calcium_percent'] as num?)?.toDouble();
      final p = (n['phosphorus_percent'] as num?)?.toDouble();

      totalDm += ing.kg * dm / 100;
      totalCp += ing.kg * cp / 100;
      totalEnergy += ing.kg * ne;
      totalNdf += ing.kg * ndf / 100;
      if (ca != null) {
        hasCa = true;
        totalCa += ing.kg * ca / 100;
      }
      if (p != null) {
        hasP = true;
        totalP += ing.kg * p / 100;
      }
    }

    if (totalKg <= 0) return null;

    return MealMixNutritionPerKg(
      totalMixKg: totalKg,
      dryMatterPercent: totalDm / totalKg * 100,
      crudeProteinPercent: totalCp / totalKg * 100,
      nemMcalPerKg: totalEnergy / totalKg,
      ndfPercent: totalNdf / totalKg * 100,
      calciumPercent: hasCa ? totalCa / totalKg * 100 : null,
      phosphorusPercent: hasP ? totalP / totalKg * 100 : null,
      costPerKg: totalCost > 0 ? totalCost / totalKg : null,
      hasNutritionData: hasNutrition,
    );
  }

  static FeedInventoryItem? _feedById(List<FeedInventoryItem> feeds, String id) {
    for (final feed in feeds) {
      if (feed.id == id) return feed;
    }
    return null;
  }
}
