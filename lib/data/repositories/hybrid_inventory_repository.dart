import '../../core/config/app_config.dart';
import '../models/inventory_models.dart';
import '../models/models.dart';
import '../services/inventory_api_client.dart';
import 'local_inventory_repository.dart';
import 'repositories.dart';

/// Uses gh-api-inventory when reachable; falls back to local demo store.
class HybridInventoryRepository implements InventoryRepository {
  HybridInventoryRepository({
    InventoryApiClient? apiClient,
    LocalInventoryRepository? offline,
    String? farmId,
    String? bearerToken,
  })  : _api = apiClient ??
            InventoryApiClient(
              baseUrl: AppConfig.inventoryApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            ),
        _offline = offline ?? LocalInventoryRepository(),
        _farmId = farmId ?? 'farm-1';

  final InventoryApiClient _api;
  final LocalInventoryRepository _offline;
  final String _farmId;
  bool _useApi = AppConfig.useInventoryApi;

  Future<T> _withApi<T>(
    Future<T> Function() apiCall,
    Future<T> Function() offlineCall,
  ) async {
    if (!_useApi) return offlineCall();
    try {
      return await apiCall();
    } on InventoryApiException {
      _useApi = false;
      return offlineCall();
    }
  }

  @override
  Future<List<FeedInventoryItem>> listFeed() => _withApi(
        () => _api.listFeed(_farmId),
        _offline.listFeed,
      );

  @override
  Future<List<MedicalInventoryItem>> listMedical() => _withApi(
        () => _api.listMedical(_farmId),
        _offline.listMedical,
      );

  @override
  Future<List<FeedInventoryItem>> listLowStock() => _withApi(
        () => _api.listLowStock(_farmId),
        _offline.listLowStock,
      );

  @override
  Future<FeedInventoryItem?> getFeed(String id) => _offline.getFeed(id);

  @override
  Future<FeedInventoryItem> addFeed(CreateFeedInventoryInput input) =>
      _withApi(
        () => _api.createFeed(_farmId, input),
        () => _offline.addFeed(input),
      );

  @override
  Future<FeedInventoryItem> restockFeed({
    required String feedId,
    required double purchasedVolumeKg,
    required double unitCost,
    String? supplierName,
    String? supplierPhone,
  }) =>
      _offline.restockFeed(
        feedId: feedId,
        purchasedVolumeKg: purchasedVolumeKg,
        unitCost: unitCost,
        supplierName: supplierName,
        supplierPhone: supplierPhone,
      );

  @override
  Future<MedicalInventoryItem> addMedical({
    required String name,
    required String medicineType,
    required double quantity,
    required String unit,
    String? supplierName,
    double? unitCost,
    String? purpose,
    double? estimatedWeeklyUsage,
    List<WithdrawalPeriod> withdrawalPeriods = const [],
  }) =>
      _withApi(
        () => _api.createMedical(_farmId, {
          'name': name,
          'medicine_type': medicineType,
          'quantity': quantity,
          'unit': unit,
          if (supplierName != null) 'supplier_name': supplierName,
          if (unitCost != null) 'unit_cost': unitCost,
          if (purpose != null) 'purpose': purpose,
          if (estimatedWeeklyUsage != null)
            'estimated_weekly_usage': estimatedWeeklyUsage,
          if (withdrawalPeriods.isNotEmpty)
            'withdrawal_periods':
                withdrawalPeriods.map((w) => w.toJson()).toList(),
        }),
        () => _offline.addMedical(
          name: name,
          medicineType: medicineType,
          quantity: quantity,
          unit: unit,
          supplierName: supplierName,
          unitCost: unitCost,
          purpose: purpose,
          estimatedWeeklyUsage: estimatedWeeklyUsage,
          withdrawalPeriods: withdrawalPeriods,
        ),
      );

  @override
  Future<List<MealPlan>> listMeals() => _withApi(
        () => _api.listMeals(_farmId),
        _offline.listMeals,
      );

  @override
  Future<MealPlan> createMeal(String name, {String? description}) =>
      _withApi(
        () => _api.createMeal(_farmId, name: name, description: description),
        () => _offline.createMeal(name, description: description),
      );

  @override
  Future<SetMealIngredientsResult> setMealIngredients(
    String mealId,
    List<MealIngredientInput> ingredients,
  ) =>
      _withApi(
        () => _api.setMealIngredients(_farmId, mealId, ingredients),
        () => _offline.setMealIngredients(mealId, ingredients),
      );

  @override
  Future<InventoryFeedingResult> recordFeeding({
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
  }) async {
    if (!_useApi) {
      return _offline.recordFeeding(
        groupId: groupId,
        mealTypeId: mealTypeId,
        totalWeightKg: totalWeightKg,
        headCount: headCount,
      );
    }
    try {
      final result = await _api.recordFeeding(
        _farmId,
        groupId: groupId,
        mealTypeId: mealTypeId,
        totalWeightKg: totalWeightKg,
        headCount: headCount,
      );
      await _offline.recordTodaysFeedEntry(
        groupId: groupId,
        mealTypeId: mealTypeId,
        totalWeightKg: totalWeightKg,
        headCount: headCount,
      );
      return InventoryFeedingResult(
        groupId: groupId,
        lowStockItems: result.lowStockItems,
      );
    } on InventoryApiException {
      _useApi = false;
      return _offline.recordFeeding(
        groupId: groupId,
        mealTypeId: mealTypeId,
        totalWeightKg: totalWeightKg,
        headCount: headCount,
      );
    }
  }

  @override
  Future<List<TodaysFeedEntry>> listTodaysFeedForGroup(String groupId) =>
      _offline.listTodaysFeedForGroup(groupId);

  @override
  Future<TodaysFeedEntry> recordSupplementToTodaysFeed({
    required String groupId,
    required String productName,
    required double weightKg,
    String? feedInventoryItemId,
    double? unitCostPerKg,
    int? headCount,
  }) =>
      _offline.recordSupplementToTodaysFeed(
        groupId: groupId,
        productName: productName,
        weightKg: weightKg,
        feedInventoryItemId: feedInventoryItemId,
        unitCostPerKg: unitCostPerKg,
        headCount: headCount,
      );

  @override
  Future<void> removeTodaysFeedEntry(String entryId) =>
      _offline.removeTodaysFeedEntry(entryId);

  @override
  Future<TodaysFeedEntry> updateTodaysFeedWeight({
    required String entryId,
    required double weightKg,
  }) =>
      _offline.updateTodaysFeedWeight(
        entryId: entryId,
        weightKg: weightKg,
      );

  @override
  Future<TodaysFeedEntry?> getTodaysFeedEntry(String entryId) =>
      _offline.getTodaysFeedEntry(entryId);

  @override
  Future<TodaysFeedEntry> updateTodaysFeedMeal({
    required String entryId,
    required List<MealIngredientInput> ingredients,
    int? headCount,
  }) =>
      _offline.updateTodaysFeedMeal(
        entryId: entryId,
        ingredients: ingredients,
        headCount: headCount,
      );

  @override
  Future<void> restoreSupplementInventory({
    required String feedInventoryItemId,
    required double weightKg,
  }) =>
      _offline.restoreSupplementInventory(
        feedInventoryItemId: feedInventoryItemId,
        weightKg: weightKg,
      );

  @override
  Future<List<InventoryItem>> listItems({bool? feedOnly}) async {
    final feed = await listFeed();
    final med = await listMedical();
    final legacy = <InventoryItem>[
      ...feed.map(
        (f) => InventoryItem(
          id: f.id,
          name: f.name,
          isFeed: true,
          quantity: f.quantityKg,
          unit: f.unit,
          lowStock: f.lowStock,
          subtitle: f.lowStock
              ? 'Less than 1 week supply'
              : f.sourceLabel,
        ),
      ),
      ...med.map(
        (m) => InventoryItem(
          id: m.id,
          name: m.name,
          isFeed: false,
          quantity: m.quantity,
          unit: m.unit,
          lowStock: m.lowStock,
          subtitle: m.purpose ?? m.medicineType,
        ),
      ),
    ];
    if (feedOnly == null) return legacy;
    return legacy.where((i) => i.isFeed == feedOnly).toList();
  }
}
