import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/repositories/local_inventory_repository.dart';

void main() {
  group('Today\'s feed weight updates', () {
    late LocalInventoryRepository inventory;

    setUp(() => inventory = LocalInventoryRepository());

    test('updateTodaysFeedWeight recalculates subtitle and cost', () async {
      final entries = await inventory.listTodaysFeedForGroup('g1');
      expect(entries, isNotEmpty);

      final first = entries.first;
      final updated = await inventory.updateTodaysFeedWeight(
        entryId: first.id,
        weightKg: first.effectiveWeightKg + 10,
      );

      expect(updated.weightKg, first.effectiveWeightKg + 10);
      expect(updated.subtitle, contains('kg'));
      expect(updated.costSar, greaterThan(0));

      final again = await inventory.listTodaysFeedForGroup('g1');
      expect(
        again.firstWhere((e) => e.id == first.id).weightKg,
        first.effectiveWeightKg + 10,
      );
    });

    test('updateTodaysFeedWeight rejects non-positive weight', () async {
      final entries = await inventory.listTodaysFeedForGroup('g1');
      expect(
        () => inventory.updateTodaysFeedWeight(
          entryId: entries.first.id,
          weightKg: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Today\'s feed meal detail', () {
    late LocalInventoryRepository inventory;

    setUp(() => inventory = LocalInventoryRepository());

    test('updateTodaysFeedMeal stores ingredient breakdown', () async {
      final entries = await inventory.listTodaysFeedForGroup('g1');
      final morning = entries.firstWhere((e) => e.mealTypeId == 'meal-morning');

      final updated = await inventory.updateTodaysFeedMeal(
        entryId: morning.id,
        ingredients: const [
          MealIngredientInput(
            feedInventoryItemId: 'feed-alfalfa',
            amountKg: 100,
          ),
          MealIngredientInput(
            feedInventoryItemId: 'feed-barley',
            amountKg: 48,
          ),
        ],
        headCount: 22,
      );

      expect(updated.weightKg, 148);
      expect(updated.fedIngredients, hasLength(2));
      expect(updated.subtitle, contains('6.7 kg/head'));
    });
  });
}
