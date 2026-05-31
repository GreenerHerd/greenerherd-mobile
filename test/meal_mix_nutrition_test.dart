import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/services/meal_mix_nutrition.dart';

void main() {
  group('MealMixNutritionCalculator', () {
    const alfalfa = FeedInventoryItem(
      id: 'feed-alfalfa',
      name: 'Alfalfa',
      sourceType: InventorySourceType.standard,
      quantityKg: 100,
      unit: 'kg',
      unitCost: 2,
      customNutrition: {
        'dry_matter_percent': 90.0,
        'crude_protein_percent': 18.0,
        'nem_mcal_per_kg': 1.2,
        'ndf_percent': 40.0,
        'calcium_percent': 1.2,
        'phosphorus_percent': 0.25,
      },
    );

    const barley = FeedInventoryItem(
      id: 'feed-barley',
      name: 'Barley',
      sourceType: InventorySourceType.standard,
      quantityKg: 100,
      unit: 'kg',
      unitCost: 1,
      customNutrition: {
        'dry_matter_percent': 88.0,
        'crude_protein_percent': 12.0,
        'nem_mcal_per_kg': 2.0,
        'ndf_percent': 20.0,
      },
    );

    test('returns per-kg nutrients for a mix', () {
      final mix = MealMixNutritionCalculator.calculate(
        ingredients: [
          (feedId: 'feed-alfalfa', kg: 60.0),
          (feedId: 'feed-barley', kg: 40.0),
        ],
        feedItems: const [alfalfa, barley],
      );

      expect(mix, isNotNull);
      expect(mix!.totalMixKg, 100);
      expect(mix.dryMatterPercent, closeTo(89.2, 0.1));
      expect(mix.crudeProteinPercent, closeTo(15.6, 0.1));
      expect(mix.nemMcalPerKg, closeTo(1.52, 0.01));
      expect(mix.ndfPercent, closeTo(32.0, 0.1));
      expect(mix.calciumPercent, closeTo(0.72, 0.01));
      expect(mix.phosphorusPercent, closeTo(0.15, 0.01));
      expect(mix.costPerKg, closeTo(1.6, 0.01));
    });
  });
}
