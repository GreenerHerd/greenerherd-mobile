import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_inventory_repository.dart';
import 'package:greenerherd_mobile/data/repositories/local_inventory_repository.dart';
import 'package:greenerherd_mobile/data/services/inventory_api_client.dart';

import 'helpers/dio_test_utils.dart';

const _feedWire = {
  'id': 'feed-api-1',
  'name': 'API Alfalfa',
  'source_type': 'STANDARD',
  'feed_product_number': 1001,
  'feed_type': 'FODDER',
  'quantity_kg': 50,
  'unit': 'kg',
};

const _medWire = {
  'id': 'med-api-1',
  'name': 'API Penicillin',
  'medicine_type': 'ANTIBIOTIC',
  'quantity': 10,
  'unit': 'dose',
};

const _mealWire = {
  'id': 'meal-api-1',
  'name': 'API Morning',
  'ingredients': [
    {
      'feed_inventory_item_id': 'feed-api-1',
      'amount_kg': 40,
      'feed_item_name': 'API Alfalfa',
    },
  ],
  'total_kg_per_batch': 40,
};

Dio inventorySuccessDio() => dioWithHandler((options) {
      final path = options.path;
      final method = options.method;

      if (path.contains('/inventory/feed') && method == 'GET') {
        return jsonResponse(options, body: {'data': [_feedWire]});
      }
      if (path.contains('/inventory/medical') && method == 'GET') {
        return jsonResponse(options, body: {'data': [_medWire]});
      }
      if (path.contains('/inventory/low-stock') && method == 'GET') {
        return jsonResponse(
          options,
          body: {'feed_items': [_feedWire]},
        );
      }
      if (path.contains('/inventory/feed') && method == 'POST') {
        return jsonResponse(
          options,
          body: {'data': _feedWire},
          statusCode: 201,
        );
      }
      if (path.contains('/inventory/medical') && method == 'POST') {
        return jsonResponse(
          options,
          body: {'data': _medWire},
          statusCode: 201,
        );
      }
      if (path.contains('/meals') && method == 'GET') {
        return jsonResponse(options, body: {'data': [_mealWire]});
      }
      if (path.contains('/meals') && method == 'POST') {
        return jsonResponse(
          options,
          body: {'data': _mealWire},
          statusCode: 201,
        );
      }
      if (path.contains('/ingredients') && method == 'PUT') {
        return jsonResponse(options, body: {'data': _mealWire});
      }
      if (path.contains('/feeding-records') && method == 'POST') {
        return jsonResponse(
          options,
          body: {
            'data': {
              'feeding': {'id': 'feed-rec-1'},
              'low_stock_items': [_feedWire],
            },
          },
          statusCode: 201,
        );
      }
      throw StateError('Unhandled inventory request: $method $path');
    });

Dio inventoryFailingDio() => dioWithHandler((options) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 503,
          data: {'error': {'message': 'Service unavailable'}},
        ),
      );
    });

InventoryApiClient successClient() => InventoryApiClient(
      baseUrl: 'http://test',
      bearerToken: 'token',
      dio: inventorySuccessDio(),
    );

void main() {
  group('InventoryApiClient', () {
    late InventoryApiClient client;

    setUp(() => client = successClient());

    test('lists feed, medical, low stock, meals', () async {
      final feed = await client.listFeed('farm-1');
      expect(feed.single.name, 'API Alfalfa');

      final med = await client.listMedical('farm-1');
      expect(med.single.name, 'API Penicillin');

      final low = await client.listLowStock('farm-1');
      expect(low, hasLength(1));

      final meals = await client.listMeals('farm-1');
      expect(meals.single.name, 'API Morning');
    });

    test('creates feed and medical inventory', () async {
      final feed = await client.createFeed(
        'farm-1',
        const CreateFeedInventoryInput(
          name: 'New feed',
          sourceType: InventorySourceType.standard,
          quantityKg: 10,
          purchasedVolumeKg: 10,
          feedProductNumber: 1001,
        ),
      );
      expect(feed.id, 'feed-api-1');

      final med = await client.createMedical('farm-1', {
        'name': 'Med',
        'medicine_type': 'ANTIBIOTIC',
        'quantity': 5,
        'unit': 'dose',
        'withdrawal_periods': [
          {'species': 'cattle', 'meat_days': 14, 'milk_days': 72},
        ],
      });
      expect(med.name, 'API Penicillin');
    });

    test('creates meal and sets ingredients', () async {
      final meal = await client.createMeal(
        'farm-1',
        name: 'Evening',
        description: 'Late ration',
      );
      expect(meal.id, 'meal-api-1');

      final result = await client.setMealIngredients(
        'farm-1',
        'meal-api-1',
        const [
          MealIngredientInput(
            feedInventoryItemId: 'feed-api-1',
            amountKg: 30,
          ),
        ],
      );
      expect(result.meal.totalKgPerBatch, 40);
    });

    test('records feeding with low-stock payload', () async {
      final result = await client.recordFeeding(
        'farm-1',
        groupId: 'g1',
        mealTypeId: 'meal-api-1',
        totalWeightKg: 80,
        headCount: 20,
      );
      expect(result.feedingId, 'feed-rec-1');
      expect(result.lowStockItems, hasLength(1));
    });

    test('throws InventoryApiException on network failure', () async {
      final failing = InventoryApiClient(
        baseUrl: 'http://test',
        bearerToken: 'token',
        dio: inventoryFailingDio(),
      );
      expect(
        () => failing.listFeed('farm-1'),
        throwsA(isA<InventoryApiException>()),
      );
    });

    test('throws on unexpected POST status', () async {
      final dio = dioWithHandler((options) {
        return jsonResponse(
          options,
          body: {'data': _feedWire},
          statusCode: 200,
        );
      });
      final api = InventoryApiClient(
        baseUrl: 'http://test',
        bearerToken: 'token',
        dio: dio,
      );
      expect(
        () => api.createFeed(
          'farm-1',
          const CreateFeedInventoryInput(
            name: 'X',
            sourceType: InventorySourceType.custom,
            quantityKg: 1,
            purchasedVolumeKg: 1,
          ),
        ),
        throwsA(isA<InventoryApiException>()),
      );
    });
  });

  group('HybridInventoryRepository', () {
    late LocalInventoryRepository offline;

    setUp(() => offline = LocalInventoryRepository());

    HybridInventoryRepository repo({required InventoryApiClient api}) =>
        HybridInventoryRepository(
          apiClient: api,
          offline: offline,
          farmId: 'farm-1',
        );

    test('uses API for list operations when reachable', () async {
      final hybrid = repo(api: successClient());
      final feed = await hybrid.listFeed();
      expect(feed.any((f) => f.name == 'API Alfalfa'), isTrue);

      final med = await hybrid.listMedical();
      expect(med.any((m) => m.name == 'API Penicillin'), isTrue);

      final low = await hybrid.listLowStock();
      expect(low, isNotEmpty);

      final meals = await hybrid.listMeals();
      expect(meals.any((m) => m.name == 'API Morning'), isTrue);
    });

    test('falls back to offline store after API failure', () async {
      final hybrid = repo(api: InventoryApiClient(
        baseUrl: 'http://test',
        bearerToken: 'token',
        dio: inventoryFailingDio(),
      ));
      final feed = await hybrid.listFeed();
      expect(feed.any((f) => f.id == 'feed-alfalfa'), isTrue);

      final meals = await hybrid.listMeals();
      expect(meals.any((m) => m.id == 'meal-morning'), isTrue);
    });

    test('getFeed and restockFeed always use offline delegate', () async {
      final hybrid = repo(api: successClient());
      final alfalfa = await hybrid.getFeed('feed-alfalfa');
      expect(alfalfa?.name, contains('Alfalfa'));

      final restocked = await hybrid.restockFeed(
        feedId: 'feed-alfalfa',
        purchasedVolumeKg: 25,
        unitCost: 2.2,
        supplierPhone: '+966500000000',
      );
      expect(restocked.quantityKg, greaterThan(120));
      expect(restocked.supplierPhone, '+966500000000');
    });

    test('addFeed and addMedical via API', () async {
      final hybrid = repo(api: successClient());
      final feed = await hybrid.addFeed(
        const CreateFeedInventoryInput(
          name: 'API feed',
          sourceType: InventorySourceType.standard,
          quantityKg: 10,
          purchasedVolumeKg: 10,
        ),
      );
      expect(feed.id, 'feed-api-1');

      final med = await hybrid.addMedical(
        name: 'New med',
        medicineType: 'ANTIBIOTIC',
        quantity: 5,
        unit: 'dose',
        withdrawalPeriods: const [
          WithdrawalPeriod(species: 'cattle', meatDays: 7, milkDays: 3),
        ],
      );
      expect(med.name, 'API Penicillin');
    });

    test('createMeal and setMealIngredients via API', () async {
      final hybrid = repo(api: successClient());
      final meal = await hybrid.createMeal('API mix', description: 'Test');
      expect(meal.id, 'meal-api-1');

      final result = await hybrid.setMealIngredients(
        'meal-api-1',
        const [
          MealIngredientInput(
            feedInventoryItemId: 'feed-alfalfa',
            amountKg: 20,
          ),
        ],
      );
      expect(result.meal.totalKgPerBatch, 40);
    });

    test('recordFeeding via API mirrors entry to offline todays feed', () async {
      final hybrid = repo(api: successClient());
      final before = await hybrid.listTodaysFeedForGroup('g1');
      final result = await hybrid.recordFeeding(
        groupId: 'g1',
        mealTypeId: 'meal-morning',
        totalWeightKg: 85,
        headCount: 22,
      );
      expect(result.groupId, 'g1');
      expect(result.lowStockItems, isNotEmpty);
      final after = await hybrid.listTodaysFeedForGroup('g1');
      expect(after.length, greaterThan(before.length));
    });

    test('recordFeeding falls back offline when API fails', () async {
      final hybrid = repo(api: InventoryApiClient(
        baseUrl: 'http://test',
        bearerToken: 'token',
        dio: inventoryFailingDio(),
      ));
      final result = await hybrid.recordFeeding(
        groupId: 'g1',
        mealTypeId: 'meal-morning',
        totalWeightKg: 50,
        headCount: 10,
      );
      expect(result.groupId, 'g1');
    });

    test('listItems maps feed and medical with feedOnly filter', () async {
      final hybrid = repo(api: successClient());
      final all = await hybrid.listItems();
      expect(all.any((i) => i.isFeed), isTrue);
      expect(all.any((i) => !i.isFeed), isTrue);

      final feedOnly = await hybrid.listItems(feedOnly: true);
      expect(feedOnly.every((i) => i.isFeed), isTrue);

      final medOnly = await hybrid.listItems(feedOnly: false);
      expect(medOnly.every((i) => !i.isFeed), isTrue);
    });

    test('todays feed helpers delegate to offline', () async {
      final hybrid = repo(api: successClient());
      final entries = await hybrid.listTodaysFeedForGroup('g1');
      expect(entries, isNotEmpty);

      final entry = entries.first;
      final updated = await hybrid.updateTodaysFeedWeight(
        entryId: entry.id,
        weightKg: entry.effectiveWeightKg + 5,
      );
      expect(updated.weightKg, entry.effectiveWeightKg + 5);

      await hybrid.restoreSupplementInventory(
        feedInventoryItemId: 'feed-alfalfa',
        weightKg: 3,
      );
      await hybrid.removeTodaysFeedEntry(entry.id);
      expect(await hybrid.getTodaysFeedEntry(entry.id), isNull);
    });
  });

  group('LocalInventoryRepository extended', () {
    late LocalInventoryRepository inventory;

    setUp(() => inventory = LocalInventoryRepository());

    test('addFeed merges by product number and name', () async {
      final before = (await inventory.getFeed('feed-alfalfa'))!.quantityKg;
      final merged = await inventory.addFeed(
        const CreateFeedInventoryInput(
          name: 'Alfalfa hay (mid-bloom)',
          sourceType: InventorySourceType.standard,
          quantityKg: 50,
          purchasedVolumeKg: 50,
          feedProductNumber: 1001,
          estimatedDailyUsageKg: 10,
        ),
      );
      expect(merged.id, 'feed-alfalfa');
      expect(merged.quantityKg, greaterThan(before));
    });

    test('addFeed creates new item when no match', () async {
      final created = await inventory.addFeed(
        const CreateFeedInventoryInput(
          name: 'Custom silage',
          sourceType: InventorySourceType.custom,
          quantityKg: 30,
          purchasedVolumeKg: 30,
          feedType: InventoryFeedType.fodder,
          customNutrition: CustomNutritionInput(
            dryMatterPercent: 35,
            crudeProteinPercent: 8,
          ),
        ),
      );
      expect(created.name, 'Custom silage');
      expect(created.customNutrition['dry_matter_percent'], 35);
    });

    test('addMedical flags low stock from weekly usage', () async {
      final med = await inventory.addMedical(
        name: 'Oxytetracycline',
        medicineType: 'ANTIBIOTIC',
        quantity: 4,
        unit: 'dose',
        estimatedWeeklyUsage: 5,
      );
      expect(med.lowStock, isTrue);
    });

    test('recordSupplement deducts inventory and records entry', () async {
      final before = (await inventory.getFeed('feed-barley'))!.quantityKg;
      final entry = await inventory.recordSupplementToTodaysFeed(
        groupId: 'g1',
        productName: 'Barley top-up',
        weightKg: 5,
        feedInventoryItemId: 'feed-barley',
        unitCostPerKg: 2.1,
        headCount: 22,
      );
      expect(entry.title, contains('Barley'));
      final after = (await inventory.getFeed('feed-barley'))!.quantityKg;
      expect(after, lessThan(before));
    });

    test('recordFeeding deducts meal ingredients and returns low stock', () async {
      final result = await inventory.recordFeeding(
        groupId: 'g2',
        mealTypeId: 'meal-morning',
        totalWeightKg: 85,
        headCount: 22,
      );
      expect(result.lowStockItems, isNotEmpty);
      final entries = await inventory.listTodaysFeedForGroup('g2');
      expect(entries, isNotEmpty);
    });

    test('listItems respects feedOnly null and false', () async {
      final all = await inventory.listItems();
      expect(all.length, greaterThan(2));
      final feed = await inventory.listItems(feedOnly: true);
      expect(feed.every((i) => i.isFeed), isTrue);
      final notFeed = await inventory.listItems(feedOnly: false);
      expect(notFeed.every((i) => !i.isFeed), isTrue);
    });

    test('setMealIngredients warns on insufficient stock', () async {
      final result = await inventory.setMealIngredients(
        'meal-morning',
        const [
          MealIngredientInput(
            feedInventoryItemId: 'feed-alfalfa',
            amountKg: 9999,
          ),
        ],
      );
      expect(result.stockWarnings, isNotEmpty);
      expect(result.stockWarnings.first.insufficientForBatch, isTrue);
    });

    test('restockFeed rejects invalid volume and cost', () async {
      expect(
        () => inventory.restockFeed(
          feedId: 'feed-alfalfa',
          purchasedVolumeKg: 0,
          unitCost: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => inventory.restockFeed(
          feedId: 'feed-alfalfa',
          purchasedVolumeKg: 10,
          unitCost: 0,
        ),
        throwsArgumentError,
      );
    });

    test('addFeed merges by marketplace product id', () async {
      final merged = await inventory.addFeed(
        const CreateFeedInventoryInput(
          name: 'Other label',
          sourceType: InventorySourceType.marketplace,
          quantityKg: 20,
          purchasedVolumeKg: 20,
          marketplaceProductId: 'mp-barley-01',
        ),
      );
      expect(merged.id, 'feed-barley');
      expect(merged.quantityKg, greaterThan(80));
    });

    test('setMealIngredients uses placeholder feed name when id unknown', () async {
      final meal = await inventory.createMeal('Scratch');
      final result = await inventory.setMealIngredients(
        meal.id,
        const [
          MealIngredientInput(
            feedInventoryItemId: 'unknown-feed',
            amountKg: 5,
          ),
        ],
      );
      expect(result.meal.ingredients.single.feedItemName, 'Feed');
    });

    test('updateTodaysFeedWeight scales ingredients after meal edit', () async {
      final entries = await inventory.listTodaysFeedForGroup('g1');
      final morning = entries.firstWhere((e) => e.mealTypeId == 'meal-morning');
      await inventory.updateTodaysFeedMeal(
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
      );
      final updated = await inventory.updateTodaysFeedWeight(
        entryId: morning.id,
        weightKg: 170,
      );
      expect(updated.fedIngredients, isNotEmpty);
      expect(updated.weightKg, 170);
    });

    test('updateTodaysFeedMeal rejects empty ingredient list', () async {
      final entries = await inventory.listTodaysFeedForGroup('g1');
      expect(
        () => inventory.updateTodaysFeedMeal(
          entryId: entries.first.id,
          ingredients: const [],
        ),
        throwsArgumentError,
      );
    });

    test('getTodaysFeedEntry returns null when missing', () async {
      expect(await inventory.getTodaysFeedEntry('missing'), isNull);
    });
  });
}
