import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/services/feed_catalog_loader.dart';
import 'package:greenerherd_mobile/data/services/feed_eligibility_service.dart';
import 'package:greenerherd_mobile/data/services/supplement_nutrition.dart';
import 'package:greenerherd_mobile/features/nutrition/gap_supplement_recommendations.dart';

import 'support/feed_eligibility_fixtures.dart';
import 'support/nutrition_recommendation_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrition recommendation pools', () {
    test('meal pool produces partial gap after barley ration logged', () {
      final base = NutritionGapPool.lactatingHerdPlan(groupId: 'g-lactating');
      final feedItems = [NutritionMealPool.barleyInventory()];
      final meal = NutritionMealPool.morningBarleyMeal();
      final entry = NutritionMealPool.loggedMeal(
        groupId: 'g-lactating',
        mealId: meal.id,
        weightKg: 10,
      );
      final displayGap = NutritionMealPool.gapAfterLoggedMeal(
        baseGap: base,
        meal: meal,
        feedItems: feedItems,
        entry: entry,
      );
      expect(displayGap.energyActualMj, closeTo(20, 0.01));
      expect(displayGap.proteinActualKg, closeTo(1.23, 0.01));
      expect(
        displayGap.energyTargetMj - displayGap.energyActualMj,
        closeTo(100, 0.01),
      );
    });

    test('light hay meal leaves larger energy gap than barley meal', () {
      final base = NutritionGapPool.lactatingHerdPlan(groupId: 'g-lactating');
      final feedItems = [
        NutritionMealPool.barleyInventory(),
        NutritionMealPool.lowEnergyHay(),
      ];
      final barleyGap = NutritionMealPool.gapAfterLoggedMeal(
        baseGap: base,
        meal: NutritionMealPool.morningBarleyMeal(),
        feedItems: feedItems,
        entry: NutritionMealPool.loggedMeal(
          groupId: 'g-lactating',
          mealId: NutritionMealPool.morningMealId,
          weightKg: 10,
        ),
      );
      final hayGap = NutritionMealPool.gapAfterLoggedMeal(
        baseGap: base,
        meal: NutritionMealPool.lightHayMeal(),
        feedItems: feedItems,
        entry: NutritionMealPool.loggedMeal(
          groupId: 'g-lactating',
          mealId: NutritionMealPool.lightMealId,
          weightKg: 8,
        ),
      );
      final barleyShortfall =
          barleyGap.energyTargetMj - barleyGap.energyActualMj;
      final hayShortfall = hayGap.energyTargetMj - hayGap.energyActualMj;
      expect(barleyShortfall, lessThan(hayShortfall));
    });
  });

  group('Standard catalogue recommendations', () {
    for (final scenario in NutritionRecommendationScenarios.standardCatalog) {
      test('${scenario.key}: all options eligible for ${scenario.groupKey}', () async {
        final options = await NutritionRecommendationAsserts.loadStandard(
          gap: scenario.gap,
          members: scenario.members,
        );
        expect(options, isNotEmpty);
        await NutritionRecommendationAsserts.assertAllStandardOptionsEligible(
          options,
          scenario.members,
        );
      });

      test('${scenario.key}: top pick is best eligible product for gap', () async {
        final options = await NutritionRecommendationAsserts.loadStandard(
          gap: scenario.gap,
          members: scenario.members,
        );
        final expectedBest =
            await NutritionRecommendationAsserts.bestEligibleCatalogProduct(
          scenario.gap,
          scenario.members,
        );
        expect(expectedBest, isNotNull);
        expect(options.first.name, expectedBest!.nameEn);
        expect(options.first.isTopPick, isTrue);
        NutritionRecommendationAsserts.assertRankedByGapScore(options, scenario.gap);
      });

      test('${scenario.key}: returns at most ${SupplementNutrition.maxRecommendations} options',
          () async {
        final options = await NutritionRecommendationAsserts.loadStandard(
          gap: scenario.gap,
          members: scenario.members,
        );
        expect(options.length, lessThanOrEqualTo(SupplementNutrition.maxRecommendations));
      });
    }

    test('dry dairy group excludes Steamed Corn Flake', () async {
      final scenario = NutritionRecommendationScenarios.standardCatalog
          .firstWhere((s) => s.key == 'dry_dairy_energy_gap');
      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: scenario.gap,
        members: scenario.members,
      );
      NutritionRecommendationAsserts.assertExcludesProduct(
        options,
        'Steamed Corn Flake',
      );
    });

    test('lactating group includes Steamed Corn Flake and ranks by energy score',
        () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-lactating');
      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: gap,
        members: members,
      );
      expect(options.any((o) => o.name == 'Steamed Corn Flake'), isTrue);
      final expectedBest =
          await NutritionRecommendationAsserts.bestEligibleCatalogProduct(
        gap,
        members,
      );
      expect(options.first.name, expectedBest!.nameEn);
    });

    test('meat cattle group excludes dairy lactation concentrate', () async {
      final members = EligibilityLivestockPool.membersOf('meat_cattle');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-meat-cattle');
      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: gap,
        members: members,
      );
      NutritionRecommendationAsserts.assertExcludesProduct(
        options,
        'Steamed Corn Flake',
      );
    });
  });

  group('Marketplace recommendations', () {
    for (final scenario in NutritionRecommendationScenarios.standardCatalog) {
      test('${scenario.key}: marketplace options eligible for ${scenario.groupKey}',
          () async {
        final options = await NutritionRecommendationAsserts.loadMarketplace(
          gap: scenario.gap,
          members: scenario.members,
        );
        expect(options, isNotEmpty);
        await NutritionRecommendationAsserts.assertAllMarketplaceOptionsEligible(
          options,
          scenario.members,
        );
      });

      test('${scenario.key}: marketplace top pick matches best eligible listing',
          () async {
        final options = await NutritionRecommendationAsserts.loadMarketplace(
          gap: scenario.gap,
          members: scenario.members,
        );
        final expectedBest =
            await NutritionRecommendationAsserts.bestEligibleMarketplaceProduct(
          scenario.gap,
          scenario.members,
        );
        expect(expectedBest, isNotNull);
        expect(
          NutritionRecommendationAsserts.gapScore(
            scenario.gap,
            nemMcalPerKg: options.first.nemMcalPerKg,
          ),
          NutritionRecommendationAsserts.gapScore(
            scenario.gap,
            nemMcalPerKg: expectedBest!.nemMcalPerKg,
          ),
        );
        if (options.first.marketplaceProductId != null) {
          final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
          final topListing = FeedEligibilityService.marketplaceProductById(
            marketplace,
            options.first.marketplaceProductId!,
          );
          expect(topListing?.standardProductNumber, expectedBest.standardProductNumber);
        }
        NutritionRecommendationAsserts.assertRankedByGapScore(options, scenario.gap);
      });
    }

    test('dry dairy marketplace excludes Steamed Corn Flake listing', () async {
      final members = EligibilityLivestockPool.membersOf('dry_dairy_cows');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-dry-dairy');
      final options = await NutritionRecommendationAsserts.loadMarketplace(
        gap: gap,
        members: members,
      );
      NutritionRecommendationAsserts.assertExcludesProduct(
        options,
        'Steamed Corn Flake',
      );
    });
  });

  group('Inventory recommendations', () {
    test('lactating group ranks custom high-energy mix above barley', () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-lactating');
      final inventory = [
        NutritionInventoryPool.barleyStandard(),
        NutritionInventoryPool.customHighEnergy(),
      ];
      final options = await NutritionRecommendationAsserts.loadInventory(
        gap: gap,
        members: members,
        inventory: inventory,
      );
      await NutritionRecommendationAsserts.assertAllInventoryOptionsEligible(
        options,
        inventory,
        members,
      );
      expect(options.first.name, 'Farm high-energy mix');
      expect(options.first.nemMcalPerKg, closeTo(2.5, 0.01));
      NutritionRecommendationAsserts.assertRankedByGapScore(options, gap);
    });

    test('dry dairy inventory excludes ineligible steamed corn standard item',
        () async {
      final members = EligibilityLivestockPool.membersOf('dry_dairy_cows');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-dry-dairy');
      final inventory = [
        NutritionInventoryPool.barleyStandard(),
        NutritionInventoryPool.steamedCornLactation(),
      ];
      final options = await NutritionRecommendationAsserts.loadInventory(
        gap: gap,
        members: members,
        inventory: inventory,
      );
      NutritionRecommendationAsserts.assertExcludesProduct(
        options,
        'Steamed Corn Flake',
      );
      expect(options.any((o) => o.name == 'Barley'), isTrue);
    });

    test('dry dairy inventory excludes ineligible marketplace steamed corn',
        () async {
      final members = EligibilityLivestockPool.membersOf('dry_dairy_cows');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-dry-dairy');
      final mpSteamed =
          await NutritionInventoryPool.marketplaceSteamedCornListing();
      final inventory = [
        NutritionInventoryPool.barleyStandard(),
        mpSteamed,
      ];
      final options = await NutritionRecommendationAsserts.loadInventory(
        gap: gap,
        members: members,
        inventory: inventory,
      );
      NutritionRecommendationAsserts.assertExcludesProduct(
        options,
        'Steamed Corn Flake',
      );
      await NutritionRecommendationAsserts.assertAllInventoryOptionsEligible(
        options,
        inventory,
        members,
      );
    });

    test('small ruminant group inventory only shows eligible species items',
        () async {
      final members = EligibilityLivestockPool.membersOf('small_ruminants');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-sr');
      final inventory = [
        NutritionInventoryPool.barleyStandard(),
        NutritionInventoryPool.customHighEnergy(),
        await NutritionInventoryPool.marketplaceBarleyListing(),
      ];
      final options = await NutritionRecommendationAsserts.loadInventory(
        gap: gap,
        members: members,
        inventory: inventory,
      );
      await NutritionRecommendationAsserts.assertAllInventoryOptionsEligible(
        options,
        inventory,
        members,
      );
      expect(options, isNotEmpty);
      for (final option in options) {
        if (option.catalogProductNumber != null) {
          final product = EligibilityProductPool.catalog.values.firstWhere(
            (p) => p.productNumber == option.catalogProductNumber,
            orElse: () => throw StateError('catalog ${option.name}'),
          );
          expect(
            members.any(
              (a) => FeedEligibilityService.isProductEligibleForAnimal(
                product,
                a,
              ),
            ),
            isTrue,
          );
        }
      }
    });
  });

  group('Gap-after-meal recommendations', () {
    test('lactating herd after barley meal recommends best eligible supplement',
        () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final base = NutritionGapPool.lactatingHerdPlan(groupId: 'g-lactating');
      final feedItems = [NutritionMealPool.barleyInventory()];
      final meal = NutritionMealPool.morningBarleyMeal();
      final displayGap = NutritionMealPool.gapAfterLoggedMeal(
        baseGap: base,
        meal: meal,
        feedItems: feedItems,
        entry: NutritionMealPool.loggedMeal(
          groupId: 'g-lactating',
          mealId: meal.id,
          weightKg: 10,
        ),
      );
      expect(displayGap.energyActualMj, greaterThan(0));

      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: displayGap,
        members: members,
      );
      final expectedBest =
          await NutritionRecommendationAsserts.bestEligibleCatalogProduct(
        displayGap,
        members,
      );
      expect(options.first.name, expectedBest!.nameEn);
      await NutritionRecommendationAsserts.assertAllStandardOptionsEligible(
        options,
        members,
      );
    });

    test('inventory recommendations use meal-adjusted gap for suggested kg',
        () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final largeShortfall = NutritionGapPool.energyShortfall(
        groupId: 'g-lactating',
        energyTargetMj: 120,
        energyActualMj: 20,
      );
      final smallShortfall = NutritionGapPool.energyShortfall(
        groupId: 'g-lactating',
        energyTargetMj: 120,
        energyActualMj: 90,
      );
      final inventory = [NutritionInventoryPool.customHighEnergy()];
      final largeGapOptions = await NutritionRecommendationAsserts.loadInventory(
        gap: largeShortfall,
        members: members,
        inventory: inventory,
      );
      final smallGapOptions = await NutritionRecommendationAsserts.loadInventory(
        gap: smallShortfall,
        members: members,
        inventory: inventory,
      );
      expect(
        largeGapOptions.first.suggestedKgPerDay,
        greaterThan(smallGapOptions.first.suggestedKgPerDay),
      );
    });
  });

  group('Combined energy and protein gap ranking', () {
    test('top pick still follows energy-weighted score for mixed gap', () async {
      final members = EligibilityLivestockPool.membersOf('mixed_lactation');
      final gap = NutritionGapPool.energyAndProteinShortfall(groupId: 'g-mixed');
      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: gap,
        members: members,
      );
      final expectedBest =
          await NutritionRecommendationAsserts.bestEligibleCatalogProduct(
        gap,
        members,
      );
      expect(options.first.name, expectedBest!.nameEn);
      NutritionRecommendationAsserts.assertRankedByGapScore(options, gap);
    });

    test('top pick energy impact is highest among returned options', () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-lactating');
      final options = await NutritionRecommendationAsserts.loadStandard(
        gap: gap,
        members: members,
      );
      final topImpact = options.first.energyImpact;
      for (final option in options.skip(1)) {
        if (option.energyImpact == '—') continue;
        final topPct = int.parse(topImpact.replaceAll(RegExp(r'[^\d]'), ''));
        final optPct = int.parse(option.energyImpact.replaceAll(RegExp(r'[^\d]'), ''));
        expect(topPct, greaterThanOrEqualTo(optPct));
      }
    });
  });

  group('Cross-source eligibility consistency', () {
    test('same group gap yields eligible standard and marketplace top picks',
        () async {
      final members = EligibilityLivestockPool.membersOf('lactating_dairy');
      final gap = NutritionGapPool.energyShortfall(groupId: 'g-lactating');
      final standard = await NutritionRecommendationAsserts.loadStandard(
        gap: gap,
        members: members,
      );
      final marketplace = await NutritionRecommendationAsserts.loadMarketplace(
        gap: gap,
        members: members,
      );
      await NutritionRecommendationAsserts.assertAllStandardOptionsEligible(
        standard,
        members,
      );
      await NutritionRecommendationAsserts.assertAllMarketplaceOptionsEligible(
        marketplace,
        members,
      );
      expect(standard.first.isTopPick, isTrue);
      expect(marketplace.first.isTopPick, isTrue);
    });
  });
}
