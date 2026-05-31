import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/repositories/local_inventory_repository.dart';
import 'package:greenerherd_mobile/features/inventory/meal_plans_screen.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Meal plans from inventory', () {
    late BddHarness harness;
    late LocalInventoryRepository inventory;

    setUp(() {
      harness = BddHarness();
      inventory = LocalInventoryRepository();
    });

    List<Override> inventoryOverrides() => [
          inventoryRepositoryProvider.overrideWithValue(inventory),
        ];

    Future<void> openMealPlansScreen(WidgetTester tester) async {
      await harness.pumpScreen(
        tester,
        const MealPlansScreen(),
        overrides: inventoryOverrides(),
      );
    }

    bddAsyncDomainScenario(
      'Seeded morning mix lists ingredients and batch weight',
      tags: ['positive'],
      body: () async {
        final meals = await inventory.listMeals();
        final morning = meals.firstWhere((m) => m.name == 'Morning mix');
        expect(morning.totalKgPerBatch, 85);
        expect(
          morning.ingredients.any(
            (i) => i.feedItemName == 'Alfalfa hay (mid-bloom)',
          ),
          isTrue,
        );
      },
    );

    bddAsyncDomainScenario(
      'New meal can be created with ingredients',
      tags: ['positive'],
      body: () async {
        final meal = await inventory.createMeal('Test ration');
        final result = await inventory.setMealIngredients(meal.id, [
          const MealIngredientInput(
            feedInventoryItemId: 'feed-alfalfa',
            amountKg: 40,
          ),
          const MealIngredientInput(
            feedInventoryItemId: 'feed-barley',
            amountKg: 15,
          ),
        ]);
        expect(result.meal.totalKgPerBatch, 55);
      },
    );

    bddAsyncDomainScenario(
      'Saving meal ingredients warns when stock is low',
      tags: ['positive'],
      body: () async {
        final meals = await inventory.listMeals();
        final morning = meals.firstWhere((m) => m.name == 'Morning mix');
        final result = await inventory.setMealIngredients(morning.id, [
          const MealIngredientInput(
            feedInventoryItemId: 'feed-alfalfa',
            amountKg: 200,
          ),
        ]);
        expect(result.stockWarnings, isNotEmpty);
        expect(
          result.stockWarnings.any((w) => w.lowStock && w.feedItemName.contains('Alfalfa')),
          isTrue,
        );
      },
    );

    bddAsyncDomainScenario(
      'Negative feed quantity is stored as zero',
      tags: ['negative'],
      body: () async {
        await inventory.addFeed(
          const CreateFeedInventoryInput(
            name: 'Empty bag',
            sourceType: InventorySourceType.custom,
            quantityKg: -40,
            purchasedVolumeKg: 0,
            supplierName: 'Local mill',
            customNutrition: CustomNutritionInput(
              feedType: InventoryFeedType.fodder,
              dryMatterPercent: 90,
            ),
          ),
        );
        final item = (await inventory.listFeed())
            .firstWhere((f) => f.name == 'Empty bag');
        expect(item.quantityKg, 0);
      },
    );

    bddAsyncDomainScenario(
      'Feeding beyond on-hand stock clamps to zero',
      tags: ['negative'],
      body: () async {
        final meals = await inventory.listMeals();
        final morning = meals.firstWhere((m) => m.name == 'Morning mix');
        await inventory.recordFeeding(
          groupId: 'g1',
          mealTypeId: morning.id,
          totalWeightKg: 500,
        );
        final alfalfa = (await inventory.listFeed())
            .firstWhere((f) => f.name == 'Alfalfa hay (mid-bloom)');
        expect(alfalfa.quantityKg, 0);
      },
    );

    bddScenario(
      'Meal plans screen lists seeded meal',
      tags: ['positive'],
      body: (tester) async {
        await openMealPlansScreen(tester);
        expect(find.text('Morning mix'), findsOneWidget);
        expect(find.textContaining('2 ingredients'), findsOneWidget);
      },
    );
  });
}
