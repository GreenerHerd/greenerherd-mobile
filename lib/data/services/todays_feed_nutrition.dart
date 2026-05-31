import '../models/inventory_models.dart';
import '../models/models.dart';

/// Nutrient totals derived from today's logged feed (as-fed kg).
class TodaysFeedNutritionTotals {
  const TodaysFeedNutritionTotals({
    this.dryMatterKg = 0,
    this.proteinKg = 0,
    this.energyMj = 0,
    this.ndfKg = 0,
    this.calciumKg,
    this.phosphorusKg,
    this.totalWeightKg = 0,
  });

  final double dryMatterKg;
  final double proteinKg;
  final double energyMj;
  final double ndfKg;
  final double? calciumKg;
  final double? phosphorusKg;
  final double totalWeightKg;

  bool get hasData => totalWeightKg > 0;
}

/// Sums nutrition from meal plans and feed inventory for today's feed rows.
abstract final class TodaysFeedNutritionCalculator {
  TodaysFeedNutritionCalculator._();

  static NutritionGap applyToGap({
    required NutritionGap base,
    required List<TodaysFeedEntry> entries,
    required List<MealPlan> meals,
    required List<FeedInventoryItem> feedItems,
  }) {
    if (entries.isEmpty) return base.withNoLoggedFeedToday();

    final totals = sumEntries(
      entries: entries,
      meals: meals,
      feedItems: feedItems,
    );
    if (!totals.hasData) return base.withNoLoggedFeedToday();

    final calcium = totals.calciumKg ??
        _scaleMineral(
          base.calciumActualKg,
          base.dryMatterActualKg,
          totals.dryMatterKg,
        );
    final phosphorus = totals.phosphorusKg ??
        _scaleMineral(
          base.phosphorusActualKg,
          base.dryMatterActualKg,
          totals.dryMatterKg,
        );

    return NutritionGap(
      groupId: base.groupId,
      dryMatterActualKg: totals.dryMatterKg,
      dryMatterTargetKg: base.dryMatterTargetKg,
      energyActualMj: totals.energyMj,
      energyTargetMj: base.energyTargetMj,
      proteinActualKg: base.proteinActualKg != null ? totals.proteinKg : null,
      proteinTargetKg: base.proteinTargetKg,
      ndfActualKg: base.ndfActualKg != null ? totals.ndfKg : null,
      ndfTargetKg: base.ndfTargetKg,
      calciumActualKg: base.calciumTargetKg != null ? calcium : null,
      calciumTargetKg: base.calciumTargetKg,
      phosphorusActualKg: base.phosphorusTargetKg != null ? phosphorus : null,
      phosphorusTargetKg: base.phosphorusTargetKg,
      fixGapMessage: base.fixGapMessage,
      dailyCostPerHeadSar: base.dailyCostPerHeadSar,
      dailyCostChangePct: base.dailyCostChangePct,
      optimizerPass: base.optimizerPass,
      profileCode: base.profileCode,
      planDryMatterKg: base.planDryMatterKg,
      needsMarketSupplement: base.needsMarketSupplement,
    );
  }

  static TodaysFeedNutritionTotals sumEntries({
    required List<TodaysFeedEntry> entries,
    required List<MealPlan> meals,
    required List<FeedInventoryItem> feedItems,
  }) {
    var dryMatterKg = 0.0;
    var proteinKg = 0.0;
    var energyMj = 0.0;
    var ndfKg = 0.0;
    var calciumKg = 0.0;
    var phosphorusKg = 0.0;
    var hasCalcium = false;
    var hasPhosphorus = false;
    var totalWeightKg = 0.0;

    for (final entry in entries) {
      final kg = entry.effectiveWeightKg;
      if (kg <= 0) continue;
      totalWeightKg += kg;

      if (entry.mealTypeId != null) {
        final meal = _mealById(meals, entry.mealTypeId!);
        if (entry.fedIngredients.isNotEmpty) {
          for (final ing in entry.fedIngredients) {
            final feed = _feedById(feedItems, ing.feedInventoryItemId);
            if (feed == null) continue;
            final part = _nutrientsForFeedKg(feed, ing.amountKg);
            dryMatterKg += part.dryMatterKg;
            proteinKg += part.proteinKg;
            energyMj += part.energyMj;
            ndfKg += part.ndfKg;
            if (part.calciumKg != null) {
              hasCalcium = true;
              calciumKg += part.calciumKg!;
            }
            if (part.phosphorusKg != null) {
              hasPhosphorus = true;
              phosphorusKg += part.phosphorusKg!;
            }
          }
          continue;
        }
        if (meal != null && meal.totalKgPerBatch > 0) {
          final scale = kg / meal.totalKgPerBatch;
          for (final ing in meal.ingredients) {
            final ingKg = ing.amountKg * scale;
            final feed = _feedById(feedItems, ing.feedInventoryItemId);
            if (feed == null) continue;
            final part = _nutrientsForFeedKg(feed, ingKg);
            dryMatterKg += part.dryMatterKg;
            proteinKg += part.proteinKg;
            energyMj += part.energyMj;
            ndfKg += part.ndfKg;
            if (part.calciumKg != null) {
              hasCalcium = true;
              calciumKg += part.calciumKg!;
            }
            if (part.phosphorusKg != null) {
              hasPhosphorus = true;
              phosphorusKg += part.phosphorusKg!;
            }
          }
          continue;
        }
      }

      final fallback = _fallbackFeed(feedItems);
      if (fallback != null) {
        final part = _nutrientsForFeedKg(fallback, kg);
        dryMatterKg += part.dryMatterKg;
        proteinKg += part.proteinKg;
        energyMj += part.energyMj;
        ndfKg += part.ndfKg;
        if (part.calciumKg != null) {
          hasCalcium = true;
          calciumKg += part.calciumKg!;
        }
        if (part.phosphorusKg != null) {
          hasPhosphorus = true;
          phosphorusKg += part.phosphorusKg!;
        }
      }
    }

    return TodaysFeedNutritionTotals(
      dryMatterKg: dryMatterKg,
      proteinKg: proteinKg,
      energyMj: energyMj,
      ndfKg: ndfKg,
      calciumKg: hasCalcium ? calciumKg : null,
      phosphorusKg: hasPhosphorus ? phosphorusKg : null,
      totalWeightKg: totalWeightKg,
    );
  }

  static MealPlan? _mealById(List<MealPlan> meals, String id) {
    for (final meal in meals) {
      if (meal.id == id) return meal;
    }
    return null;
  }

  static FeedInventoryItem? _feedById(List<FeedInventoryItem> feeds, String id) {
    for (final feed in feeds) {
      if (feed.id == id) return feed;
    }
    return null;
  }

  static FeedInventoryItem? _fallbackFeed(List<FeedInventoryItem> feeds) {
    if (feeds.isEmpty) return null;
    return feeds.first;
  }

  static _FeedNutrientPart _nutrientsForFeedKg(
    FeedInventoryItem feed,
    double kg,
  ) {
    final n = feed.customNutrition;
    if (n.isEmpty) {
      return const _FeedNutrientPart();
    }
    final dmPct = (n['dry_matter_percent'] as num?)?.toDouble() ?? 0;
    final cpPct = (n['crude_protein_percent'] as num?)?.toDouble() ?? 0;
    final nem = (n['nem_mcal_per_kg'] as num?)?.toDouble() ?? 0;
    final ndfPct = (n['ndf_percent'] as num?)?.toDouble() ?? 0;
    final caPct = (n['calcium_percent'] as num?)?.toDouble();
    final pPct = (n['phosphorus_percent'] as num?)?.toDouble();

    return _FeedNutrientPart(
      dryMatterKg: kg * dmPct / 100,
      proteinKg: kg * cpPct / 100,
      energyMj: kg * nem,
      ndfKg: kg * ndfPct / 100,
      calciumKg: caPct != null ? kg * caPct / 100 : null,
      phosphorusKg: pPct != null ? kg * pPct / 100 : null,
    );
  }

  static double? _scaleMineral(
    double? baselineActual,
    double baselineDm,
    double computedDm,
  ) {
    if (baselineActual == null || baselineDm <= 0 || computedDm <= 0) {
      return null;
    }
    return baselineActual * computedDm / baselineDm;
  }
}

class _FeedNutrientPart {
  const _FeedNutrientPart({
    this.dryMatterKg = 0,
    this.proteinKg = 0,
    this.energyMj = 0,
    this.ndfKg = 0,
    this.calciumKg,
    this.phosphorusKg,
  });

  final double dryMatterKg;
  final double proteinKg;
  final double energyMj;
  final double ndfKg;
  final double? calciumKg;
  final double? phosphorusKg;
}
