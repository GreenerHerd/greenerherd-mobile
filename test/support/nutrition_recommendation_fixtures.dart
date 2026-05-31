import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/feed_catalog_loader.dart';
import 'package:greenerherd_mobile/data/services/feed_eligibility_service.dart';
import 'package:greenerherd_mobile/data/services/todays_feed_nutrition.dart';
import 'package:greenerherd_mobile/features/nutrition/gap_supplement_recommendations.dart';

import 'feed_eligibility_fixtures.dart';

/// Nutrition gap scenarios paired with livestock groups from [EligibilityLivestockPool].
abstract final class NutritionGapPool {
  static NutritionGap energyShortfall({
    required String groupId,
    double energyTargetMj = 100,
    double energyActualMj = 25,
    double dmTargetKg = 40,
    double dmActualKg = 12,
  }) {
    return NutritionGap(
      groupId: groupId,
      dryMatterTargetKg: dmTargetKg,
      dryMatterActualKg: dmActualKg,
      energyTargetMj: energyTargetMj,
      energyActualMj: energyActualMj,
    );
  }

  static NutritionGap energyAndProteinShortfall({
    required String groupId,
    double energyTargetMj = 100,
    double energyActualMj = 30,
    double proteinTargetKg = 4,
    double proteinActualKg = 1,
  }) {
    return NutritionGap(
      groupId: groupId,
      dryMatterTargetKg: 45,
      dryMatterActualKg: 15,
      energyTargetMj: energyTargetMj,
      energyActualMj: energyActualMj,
      proteinTargetKg: proteinTargetKg,
      proteinActualKg: proteinActualKg,
    );
  }

  static NutritionGap proteinOnlyShortfall({
    required String groupId,
    double proteinTargetKg = 5,
    double proteinActualKg = 1.5,
  }) {
    return NutritionGap(
      groupId: groupId,
      dryMatterTargetKg: 40,
      dryMatterActualKg: 20,
      energyTargetMj: 80,
      energyActualMj: 80,
      proteinTargetKg: proteinTargetKg,
      proteinActualKg: proteinActualKg,
    );
  }

  /// Herd requirement gap before today's feed is applied in the UI.
  static NutritionGap lactatingHerdPlan({required String groupId}) =>
      energyAndProteinShortfall(
        groupId: groupId,
        energyTargetMj: 120,
        energyActualMj: 0,
        proteinTargetKg: 5,
        proteinActualKg: 0,
      );

  static NutritionGap dryHerdPlan({required String groupId}) => energyShortfall(
        groupId: groupId,
        energyTargetMj: 90,
        energyActualMj: 0,
      );
}

/// Sample meals and inventory for gap-after-meal tests.
abstract final class NutritionMealPool {
  static const barleyFeedId = 'feed-barley-inv';
  static const hayFeedId = 'feed-hay-inv';
  static const morningMealId = 'meal-morning-barley';
  static const lightMealId = 'meal-light-hay';

  static FeedInventoryItem barleyInventory({double quantityKg = 500}) {
    return FeedInventoryItem(
      id: barleyFeedId,
      name: 'Barley',
      sourceType: InventorySourceType.standard,
      quantityKg: quantityKg,
      unit: 'kg',
      feedProductNumber: 1001,
      feedType: InventoryFeedType.fodder,
      unitCost: 1.2,
      customNutrition: const {
        'dry_matter_percent': 88,
        'crude_protein_percent': 12.3,
        'nem_mcal_per_kg': 2.0,
        'ndf_percent': 45,
      },
    );
  }

  static FeedInventoryItem lowEnergyHay({double quantityKg = 300}) {
    return FeedInventoryItem(
      id: hayFeedId,
      name: 'Low energy hay',
      sourceType: InventorySourceType.custom,
      quantityKg: quantityKg,
      unit: 'kg',
      feedType: InventoryFeedType.fodder,
      unitCost: 0.8,
      customNutrition: const {
        'dry_matter_percent': 90,
        'crude_protein_percent': 6,
        'nem_mcal_per_kg': 0.9,
        'ndf_percent': 62,
      },
    );
  }

  static MealPlan morningBarleyMeal() {
    return MealPlan(
      id: morningMealId,
      name: 'Morning barley mix',
      totalKgPerBatch: 10,
      ingredients: const [
        MealIngredientLine(
          feedInventoryItemId: barleyFeedId,
          feedItemName: 'Barley',
          amountKg: 10,
        ),
      ],
    );
  }

  static MealPlan lightHayMeal() {
    return MealPlan(
      id: lightMealId,
      name: 'Light hay ration',
      totalKgPerBatch: 8,
      ingredients: const [
        MealIngredientLine(
          feedInventoryItemId: hayFeedId,
          feedItemName: 'Low energy hay',
          amountKg: 8,
        ),
      ],
    );
  }

  static TodaysFeedEntry loggedMeal({
    required String groupId,
    required String mealId,
    required double weightKg,
  }) {
    return TodaysFeedEntry(
      id: 'feed-log-$mealId',
      groupId: groupId,
      recordedAt: DateTime(2026, 5, 29, 7, 30),
      title: 'Morning feed',
      subtitle: '${weightKg.toInt()} kg · group ration',
      costSar: weightKg * 1.5,
      weightKg: weightKg,
      mealTypeId: mealId,
      headCount: 1,
    );
  }

  static NutritionGap gapAfterLoggedMeal({
    required NutritionGap baseGap,
    required MealPlan meal,
    required List<FeedInventoryItem> feedItems,
    required TodaysFeedEntry entry,
  }) {
    return TodaysFeedNutritionCalculator.applyToGap(
      base: baseGap,
      entries: [entry],
      meals: [meal],
      feedItems: feedItems,
    );
  }
}

/// Inventory items for recommendation ranking tests (standard + marketplace).
abstract final class NutritionInventoryPool {
  static FeedInventoryItem barleyStandard({double qty = 400}) =>
      NutritionMealPool.barleyInventory(quantityKg: qty);

  static FeedInventoryItem steamedCornLactation({double qty = 100}) {
    return FeedInventoryItem(
      id: 'inv-steamed-corn',
      name: 'Steamed Corn Flake',
      sourceType: InventorySourceType.standard,
      quantityKg: qty,
      unit: 'kg',
      feedProductNumber: 1014,
      feedType: InventoryFeedType.concentrate,
      unitCost: 2.4,
    );
  }

  static FeedInventoryItem customHighEnergy({double qty = 80}) {
    return FeedInventoryItem(
      id: 'inv-high-energy',
      name: 'Farm high-energy mix',
      sourceType: InventorySourceType.custom,
      quantityKg: qty,
      unit: 'kg',
      feedType: InventoryFeedType.concentrate,
      unitCost: 2.1,
      customNutrition: const {
        'dry_matter_percent': 88,
        'crude_protein_percent': 14,
        'nem_mcal_per_kg': 2.5,
        'ndf_percent': 28,
      },
    );
  }

  static FeedInventoryItem customProteinBoost({double qty = 60}) {
    return FeedInventoryItem(
      id: 'inv-protein-boost',
      name: 'Protein booster',
      sourceType: InventorySourceType.custom,
      quantityKg: qty,
      unit: 'kg',
      feedType: InventoryFeedType.concentrate,
      unitCost: 3.0,
      customNutrition: const {
        'dry_matter_percent': 90,
        'crude_protein_percent': 46,
        'nem_mcal_per_kg': 1.4,
        'ndf_percent': 18,
      },
    );
  }

  static Future<FeedInventoryItem> marketplaceBarleyListing() async {
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    MarketplaceFeedProduct? listing;
    for (final p in marketplace) {
      if (p.nameEn == 'Barley') {
        listing = p;
        break;
      }
    }
    assert(listing != null, 'Barley marketplace listing required');
    return FeedInventoryItem(
      id: 'inv-mp-barley',
      name: listing!.nameEn,
      sourceType: InventorySourceType.marketplace,
      quantityKg: 200,
      unit: 'kg',
      marketplaceProductId: listing.id,
      feedType: InventoryFeedType.fodder,
      unitCost: listing.pricePerKg,
    );
  }

  static Future<FeedInventoryItem> marketplaceSteamedCornListing() async {
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    MarketplaceFeedProduct? listing;
    for (final p in marketplace) {
      if (p.nameEn == 'Steamed Corn Flake') {
        listing = p;
        break;
      }
    }
    assert(listing != null, 'Steamed Corn Flake marketplace listing required');
    return FeedInventoryItem(
      id: 'inv-mp-steamed-corn',
      name: listing!.nameEn,
      sourceType: InventorySourceType.marketplace,
      quantityKg: 50,
      unit: 'kg',
      marketplaceProductId: listing.id,
      feedType: InventoryFeedType.concentrate,
      unitCost: listing.pricePerKg,
    );
  }
}

/// Scenario definition linking group, gap, and optional meal context.
class NutritionRecommendationScenario {
  const NutritionRecommendationScenario({
    required this.key,
    required this.groupKey,
    required this.gap,
    this.description = '',
  });

  final String key;
  final String groupKey;
  final NutritionGap gap;
  final String description;

  List<Animal> get members => EligibilityLivestockPool.membersOf(groupKey);
}

abstract final class NutritionRecommendationScenarios {
  static final standardCatalog = [
    NutritionRecommendationScenario(
      key: 'lactating_energy_gap',
      groupKey: 'lactating_dairy',
      gap: NutritionGapPool.energyShortfall(groupId: 'g-lactating'),
      description: 'Lactating dairy cows with large energy shortfall',
    ),
    NutritionRecommendationScenario(
      key: 'dry_dairy_energy_gap',
      groupKey: 'dry_dairy_cows',
      gap: NutritionGapPool.energyShortfall(groupId: 'g-dry-dairy'),
      description: 'Dry dairy cows — lactation-only products excluded',
    ),
    NutritionRecommendationScenario(
      key: 'meat_cattle_energy_gap',
      groupKey: 'meat_cattle',
      gap: NutritionGapPool.energyShortfall(groupId: 'g-meat-cattle'),
      description: 'Meat bulls/steers — dairy lactation feeds excluded',
    ),
    NutritionRecommendationScenario(
      key: 'small_ruminant_energy_gap',
      groupKey: 'small_ruminants',
      gap: NutritionGapPool.energyShortfall(groupId: 'g-sr'),
      description: 'Sheep and goats — cattle-only products excluded',
    ),
    NutritionRecommendationScenario(
      key: 'mixed_lactation_energy_protein',
      groupKey: 'mixed_lactation',
      gap: NutritionGapPool.energyAndProteinShortfall(groupId: 'g-mixed'),
      description: 'Mixed dry + lactating — lactation feeds allowed via lac cows',
    ),
  ];
}

/// Test helpers mirroring [GapSupplementRecommendations] ranking and eligibility.
abstract final class NutritionRecommendationAsserts {
  static double gapScore(
    NutritionGap gap, {
    required double? nemMcalPerKg,
    double? crudeProteinPercent,
  }) {
    final nem = nemMcalPerKg ?? 0;
    final cp = crudeProteinPercent ?? 0;
    final energyShort =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    final proteinShort = gap.proteinTargetKg != null && gap.proteinActualKg != null
        ? (gap.proteinTargetKg! - gap.proteinActualKg!)
            .clamp(0, double.infinity)
        : 0.0;
    final cpContributionPerKg = cp / 100;
    return energyShort * nem + proteinShort * cpContributionPerKg;
  }

  static double? _defaultCpForFeedType(String feedType) {
    return switch (feedType.toUpperCase()) {
      'CONCENTRATE' => 14.0,
      'FODDER' => 9.0,
      'ADDITIVE' => 5.0,
      _ => null,
    };
  }

  static Future<FeedCatalogProduct?> bestEligibleCatalogProduct(
    NutritionGap gap,
    List<Animal> members,
  ) async {
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final eligible =
        FeedEligibilityService.filterProductsForAnimals(catalog, members);
    FeedCatalogProduct? best;
    var bestScore = -1.0;
    for (final product in eligible) {
      final score = gapScore(
        gap,
        nemMcalPerKg: product.nemMcalPerKg,
        crudeProteinPercent:
            product.crudeProteinPercent ?? _defaultCpForFeedType(product.feedType),
      );
      if (score > bestScore) {
        bestScore = score;
        best = product;
      }
    }
    return best;
  }

  static Future<MarketplaceFeedProduct?> bestEligibleMarketplaceProduct(
    NutritionGap gap,
    List<Animal> members,
  ) async {
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final eligible =
        FeedEligibilityService.filterMarketplaceProductsForAnimals(
      marketplace,
      members,
    );
    MarketplaceFeedProduct? best;
    var bestScore = -1.0;
    for (final product in eligible) {
      final score = gapScore(
        gap,
        nemMcalPerKg: product.nemMcalPerKg,
        crudeProteinPercent:
            product.crudeProteinPercent ?? _defaultCpForFeedType(product.feedType),
      );
      if (score > bestScore) {
        bestScore = score;
        best = product;
      }
    }
    return best;
  }

  static Future<void> assertAllStandardOptionsEligible(
    List<GapSupplementOption> options,
    List<Animal> members,
  ) async {
    if (members.isEmpty) return;
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final active = members.where((a) => a.status == AnimalStatus.active);
    for (final option in options) {
      if (option.catalogProductNumber == null) continue;
      FeedCatalogProduct? product;
      for (final p in catalog) {
        if (p.productNumber == option.catalogProductNumber) {
          product = p;
          break;
        }
      }
      expect(product, isNotNull, reason: 'Unknown catalog product ${option.name}');
      final anyEligible = active.any(
        (animal) =>
            FeedEligibilityService.isProductEligibleForAnimal(product!, animal),
      );
      expect(
        anyEligible,
        isTrue,
        reason: '${option.name} must be eligible for at least one group member',
      );
    }
  }

  static Future<void> assertAllMarketplaceOptionsEligible(
    List<GapSupplementOption> options,
    List<Animal> members,
  ) async {
    if (members.isEmpty) return;
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final active = members.where((a) => a.status == AnimalStatus.active);
    for (final option in options) {
      if (option.marketplaceProductId == null) continue;
      final product = FeedEligibilityService.marketplaceProductById(
        marketplace,
        option.marketplaceProductId!,
      );
      expect(product, isNotNull, reason: 'Unknown marketplace ${option.name}');
      final anyEligible = active.any(
        (animal) =>
            FeedEligibilityService.isMarketplaceProductEligibleForAnimal(
          product!,
          animal,
        ),
      );
      expect(
        anyEligible,
        isTrue,
        reason: '${option.name} must be eligible for at least one group member',
      );
    }
  }

  static Future<void> assertAllInventoryOptionsEligible(
    List<GapSupplementOption> options,
    List<FeedInventoryItem> inventory,
    List<Animal> members,
  ) async {
    if (members.isEmpty) return;
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final eligibleNumbers = FeedEligibilityService.filterProductsForAnimals(
      catalog,
      members,
    ).map((p) => p.productNumber).toSet();
    final eligibleMpIds = FeedEligibilityService.filterMarketplaceProductsForAnimals(
      marketplace,
      members,
    ).map((p) => p.id).toSet();

    for (final option in options) {
      if (option.inventoryItemId == null) continue;
      FeedInventoryItem? item;
      for (final inv in inventory) {
        if (inv.id == option.inventoryItemId) {
          item = inv;
          break;
        }
      }
      expect(item, isNotNull);
      if (item!.feedProductNumber != null) {
        expect(
          eligibleNumbers.contains(item.feedProductNumber),
          isTrue,
          reason: '${item.name} must be eligible for group',
        );
      }
      if (item.marketplaceProductId != null) {
        expect(
          eligibleMpIds.contains(item.marketplaceProductId),
          isTrue,
          reason: '${item.name} marketplace listing must be eligible',
        );
      }
    }
  }

  static void assertRankedByGapScore(
    List<GapSupplementOption> options,
    NutritionGap gap,
  ) {
    expect(options, isNotEmpty);
    expect(options.first.isTopPick, isTrue);
    for (var i = 0; i < options.length - 1; i++) {
      final a = options[i];
      final b = options[i + 1];
      final scoreA = gapScore(
        gap,
        nemMcalPerKg: a.nemMcalPerKg,
        crudeProteinPercent: a.crudeProteinPercent,
      );
      final scoreB = gapScore(
        gap,
        nemMcalPerKg: b.nemMcalPerKg,
        crudeProteinPercent: b.crudeProteinPercent,
      );
      expect(
        scoreA >= scoreB,
        isTrue,
        reason: '${a.name} (${scoreA}) should rank above ${b.name} (${scoreB})',
      );
    }
  }

  static void assertExcludesProduct(
    List<GapSupplementOption> options,
    String productName,
  ) {
    expect(
      options.any((o) => o.name == productName),
      isFalse,
      reason: '$productName should not be recommended',
    );
  }

  static Future<List<GapSupplementOption>> loadStandard({
    required NutritionGap gap,
    required List<Animal> members,
    Locale locale = const Locale('en'),
  }) {
    return GapSupplementRecommendations.load(
      source: GapSupplementSource.standard,
      gap: gap,
      locale: locale,
      inventory: const [],
      groupMembers: members,
    );
  }

  static Future<List<GapSupplementOption>> loadMarketplace({
    required NutritionGap gap,
    required List<Animal> members,
    Locale locale = const Locale('en'),
  }) {
    return GapSupplementRecommendations.load(
      source: GapSupplementSource.marketplace,
      gap: gap,
      locale: locale,
      inventory: const [],
      groupMembers: members,
    );
  }

  static Future<List<GapSupplementOption>> loadInventory({
    required NutritionGap gap,
    required List<Animal> members,
    required List<FeedInventoryItem> inventory,
    Locale locale = const Locale('en'),
  }) {
    return GapSupplementRecommendations.load(
      source: GapSupplementSource.inventory,
      gap: gap,
      locale: locale,
      inventory: inventory,
      groupMembers: members,
    );
  }
}
