import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/todays_feed_nutrition.dart';

void main() {
  const baseGap = NutritionGap(
    groupId: 'g1',
    dryMatterActualKg: 100,
    dryMatterTargetKg: 200,
    energyActualMj: 500,
    energyTargetMj: 1000,
    proteinActualKg: 20,
    proteinTargetKg: 40,
    ndfActualKg: 30,
    ndfTargetKg: 60,
    calciumActualKg: 4,
    calciumTargetKg: 8,
    phosphorusActualKg: 2,
    phosphorusTargetKg: 4,
  );

  const meal = MealPlan(
    id: 'meal-morning',
    name: 'Morning mix',
    totalKgPerBatch: 100,
    ingredients: [
      MealIngredientLine(
        feedInventoryItemId: 'feed-alfalfa',
        amountKg: 70,
        feedItemName: 'Alfalfa',
      ),
      MealIngredientLine(
        feedInventoryItemId: 'feed-barley',
        amountKg: 30,
        feedItemName: 'Barley',
      ),
    ],
  );

  const feeds = [
    FeedInventoryItem(
      id: 'feed-alfalfa',
      name: 'Alfalfa',
      sourceType: InventorySourceType.standard,
      quantityKg: 100,
      unit: 'kg',
      customNutrition: {
        'dry_matter_percent': 90.0,
        'crude_protein_percent': 18.0,
        'nem_mcal_per_kg': 1.2,
        'ndf_percent': 40.0,
      },
    ),
    FeedInventoryItem(
      id: 'feed-barley',
      name: 'Barley',
      sourceType: InventorySourceType.standard,
      quantityKg: 100,
      unit: 'kg',
      customNutrition: {
        'dry_matter_percent': 88.0,
        'crude_protein_percent': 12.0,
        'nem_mcal_per_kg': 2.0,
        'ndf_percent': 20.0,
      },
    ),
  ];

  group('TodaysFeedNutritionCalculator', () {
    test('scales nutrients when feed weight changes', () {
      final light = TodaysFeedNutritionCalculator.applyToGap(
        base: baseGap,
        entries: [
          TodaysFeedEntry(
            id: '1',
            groupId: 'g1',
            recordedAt: _now,
            title: 'Morning mix',
            subtitle: '50 kg',
            costSar: 0,
            weightKg: 50,
            mealTypeId: 'meal-morning',
          ),
        ],
        meals: [meal],
        feedItems: feeds,
      );
      final heavy = TodaysFeedNutritionCalculator.applyToGap(
        base: baseGap,
        entries: [
          TodaysFeedEntry(
            id: '1',
            groupId: 'g1',
            recordedAt: _now,
            title: 'Morning mix',
            subtitle: '100 kg',
            costSar: 0,
            weightKg: 100,
            mealTypeId: 'meal-morning',
          ),
        ],
        meals: [meal],
        feedItems: feeds,
      );

      expect(heavy.dryMatterActualKg, greaterThan(light.dryMatterActualKg));
      expect(
        heavy.dryMatterActualKg / light.dryMatterActualKg,
        closeTo(2, 0.01),
      );
      expect(
        heavy.calciumActualKg! / light.calciumActualKg!,
        closeTo(2, 0.01),
      );
    });

    test('returns zero actuals when no feed logged', () {
      final gap = TodaysFeedNutritionCalculator.applyToGap(
        base: baseGap,
        entries: const [],
        meals: [meal],
        feedItems: feeds,
      );
      expect(gap.dryMatterActualKg, 0);
      expect(gap.energyActualMj, 0);
      expect(gap.calciumActualKg, 0);
    });
  });
}

final _now = DateTime(2026, 5, 29);
