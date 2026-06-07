import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';
import '../models/models.dart';
import '../services/meal_stock_analyzer.dart';
import 'repositories.dart';

/// Offline inventory with demo data matching gh-api-inventory seeds.
class LocalInventoryRepository implements InventoryRepository {
  LocalInventoryRepository() {
    _feed.addAll(_seedFeed);
    _medical.addAll(_seedMedical);
    _meals.add(_seedMeal);
    _seedTodaysFeedDemos();
  }

  final _uuid = const Uuid();
  final List<FeedInventoryItem> _feed = [];
  final List<MedicalInventoryItem> _medical = [];
  final List<MealPlan> _meals = [];
  final List<TodaysFeedEntry> _todaysFeed = [];

  void _seedTodaysFeedDemos() {
    final now = DateTime.now();
    _todaysFeed.addAll([
      TodaysFeedEntry(
        id: 'feed-demo-1',
        groupId: 'g1',
        recordedAt: now.subtract(const Duration(hours: 6)),
        title: 'Morning mix · alfalfa + barley',
        subtitle: '148 kg · 6.7 kg/head',
        costSar: 412,
        weightKg: 148,
        headCount: 22,
        mealTypeId: 'meal-morning',
      ),
      TodaysFeedEntry(
        id: 'feed-demo-2',
        groupId: 'g1',
        recordedAt: now.subtract(const Duration(hours: 2)),
        title: 'Afternoon · corn silage',
        subtitle: '46 kg · 2.1 kg/head',
        costSar: 138,
        weightKg: 46,
        headCount: 22,
      ),
    ]);
  }

  static bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  static final _seedFeed = [
    const FeedInventoryItem(
      id: 'feed-alfalfa',
      name: 'Alfalfa hay (mid-bloom)',
      sourceType: InventorySourceType.standard,
      feedProductNumber: 1001,
      feedType: InventoryFeedType.fodder,
      quantityKg: 120,
      purchasedVolumeKg: 500,
      unitCost: 1.8,
      supplierName: 'Local Fodder Co.',
      weeklyUsageKg: 200,
      customNutrition: {
        'dry_matter_percent': 89.0,
        'crude_protein_percent': 17.0,
        'nem_mcal_per_kg': 1.24,
        'ndf_percent': 42.0,
      },
      reorderThresholdKg: 200,
      lowStock: true,
      weeksOfSupply: 0.6,
      unit: 'kg',
    ),
    const FeedInventoryItem(
      id: 'feed-barley',
      name: 'Barley concentrate',
      sourceType: InventorySourceType.marketplace,
      marketplaceProductId: 'mp-barley-01',
      feedType: InventoryFeedType.concentrate,
      quantityKg: 80,
      purchasedVolumeKg: 200,
      unitCost: 2.1,
      weeklyUsageKg: 110,
      reorderThresholdKg: 110,
      customNutrition: {
        'dry_matter_percent': 88.0,
        'crude_protein_percent': 11.5,
        'nem_mcal_per_kg': 2.0,
        'ndf_percent': 18.0,
      },
      lowStock: true,
      weeksOfSupply: 0.7,
      unit: 'kg',
    ),
  ];

  static final _seedMedical = [
    const MedicalInventoryItem(
      id: 'med-penicillin',
      name: 'Penicillin',
      medicineType: 'ANTIBIOTIC',
      quantity: 12,
      unit: 'dose',
      unitCost: 45,
      supplierName: 'Vet Supplies KSA',
      purpose: 'Mastitis treatment',
      lowStock: true,
      withdrawalPeriods: [
        WithdrawalPeriod(species: 'cattle', meatDays: 14, milkDays: 72),
        WithdrawalPeriod(species: 'goat', meatDays: 14, milkDays: 60),
        WithdrawalPeriod(species: 'sheep', meatDays: 14, milkDays: 60),
      ],
    ),
  ];

  static const _seedMeal = MealPlan(
    id: 'meal-morning',
    name: 'Morning mix',
    description: 'Milking group ration',
    totalKgPerBatch: 85,
    ingredients: [
      MealIngredientLine(
        feedInventoryItemId: 'feed-alfalfa',
        amountKg: 60,
        feedItemName: 'Alfalfa hay (mid-bloom)',
      ),
      MealIngredientLine(
        feedInventoryItemId: 'feed-barley',
        amountKg: 25,
        feedItemName: 'Barley concentrate',
      ),
    ],
  );

  FeedInventoryItem _withStockFlags(FeedInventoryItem item) {
    final low = item.reorderThresholdKg > 0 &&
        item.quantityKg <= item.reorderThresholdKg;
    final weeks = item.weeklyUsageKg > 0
        ? (item.quantityKg / item.weeklyUsageKg * 10).round() / 10
        : null;
    return FeedInventoryItem(
      id: item.id,
      name: item.name,
      sourceType: item.sourceType,
      feedProductNumber: item.feedProductNumber,
      marketplaceProductId: item.marketplaceProductId,
      feedType: item.feedType,
      quantityKg: item.quantityKg,
      purchasedVolumeKg: item.purchasedVolumeKg,
      unitCost: item.unitCost,
      currency: item.currency,
      supplierName: item.supplierName,
      supplierPhone: item.supplierPhone,
      supplierNotes: item.supplierNotes,
      weeklyUsageKg: item.weeklyUsageKg,
      reorderThresholdKg: item.reorderThresholdKg,
      lowStock: low,
      weeksOfSupply: weeks,
      unit: item.unit,
      expiryDate: item.expiryDate,
      notes: item.notes,
      customNutrition: item.customNutrition,
    );
  }

  @override
  Future<List<FeedInventoryItem>> listFeed() async =>
      _feed.map(_withStockFlags).toList();

  @override
  Future<List<MedicalInventoryItem>> listMedical() async => List.from(_medical);

  @override
  Future<List<FeedInventoryItem>> listLowStock() async {
    final all = await listFeed();
    return all.where((f) => f.lowStock).toList();
  }

  @override
  Future<FeedInventoryItem?> getFeed(String id) async {
    final idx = _feed.indexWhere((f) => f.id == id);
    if (idx < 0) return null;
    return _withStockFlags(_feed[idx]);
  }

  @override
  Future<FeedInventoryItem> restockFeed({
    required String feedId,
    required double purchasedVolumeKg,
    required double unitCost,
    String? supplierName,
    String? supplierPhone,
  }) async {
    final purchaseKg = clampFeedQuantityKg(purchasedVolumeKg);
    if (purchaseKg <= 0) {
      throw ArgumentError.value(
        purchasedVolumeKg,
        'purchasedVolumeKg',
        'must be positive',
      );
    }
    if (unitCost <= 0) {
      throw ArgumentError.value(unitCost, 'unitCost', 'must be positive');
    }
    final idx = _feed.indexWhere((f) => f.id == feedId);
    if (idx < 0) throw StateError('Feed item not found');
    final existing = _feed[idx];
    final updated = FeedInventoryItem(
      id: existing.id,
      name: existing.name,
      sourceType: existing.sourceType,
      feedProductNumber: existing.feedProductNumber,
      marketplaceProductId: existing.marketplaceProductId,
      feedType: existing.feedType,
      quantityKg: clampFeedQuantityKg(existing.quantityKg + purchaseKg),
      purchasedVolumeKg: purchaseKg,
      unitCost: unitCost,
      currency: existing.currency,
      supplierName: supplierName ?? existing.supplierName,
      supplierPhone: supplierPhone ?? existing.supplierPhone,
      supplierNotes: existing.supplierNotes,
      weeklyUsageKg: existing.weeklyUsageKg,
      reorderThresholdKg: existing.reorderThresholdKg,
      unit: existing.unit,
      customNutrition: existing.customNutrition,
      photoPath: existing.photoPath,
    );
    _feed[idx] = _withStockFlags(updated);
    return _feed[idx];
  }

  int? _indexMatchingFeedInput(CreateFeedInventoryInput input) {
    if (input.feedProductNumber != null) {
      final i = _feed.indexWhere(
        (f) => f.feedProductNumber == input.feedProductNumber,
      );
      if (i >= 0) return i;
    }
    if (input.marketplaceProductId != null) {
      final i = _feed.indexWhere(
        (f) => f.marketplaceProductId == input.marketplaceProductId,
      );
      if (i >= 0) return i;
    }
    final nameKey = input.name.trim().toLowerCase();
    if (nameKey.isNotEmpty) {
      final i = _feed.indexWhere(
        (f) => f.name.trim().toLowerCase() == nameKey,
      );
      if (i >= 0) return i;
    }
    return null;
  }

  @override
  Future<FeedInventoryItem> addFeed(CreateFeedInventoryInput input) async {
    final purchaseKg = clampFeedQuantityKg(input.purchasedVolumeKg);
    final weekly = (input.estimatedDailyUsageKg ?? 0) * 7;
    final existingIdx = _indexMatchingFeedInput(input);
    if (existingIdx != null) {
      final existing = _feed[existingIdx];
      final merged = FeedInventoryItem(
        id: existing.id,
        name: existing.name,
        sourceType: existing.sourceType,
        feedProductNumber: existing.feedProductNumber,
        marketplaceProductId: existing.marketplaceProductId,
        feedType: existing.feedType ?? input.feedType,
        quantityKg: clampFeedQuantityKg(existing.quantityKg + purchaseKg),
        purchasedVolumeKg: purchaseKg,
        unitCost: input.unitCost ?? existing.unitCost,
        currency: input.currency,
        supplierName: input.supplierName ?? existing.supplierName,
        supplierPhone: input.supplierPhone ?? existing.supplierPhone,
        supplierNotes: input.supplierNotes ?? existing.supplierNotes,
        weeklyUsageKg: weekly > 0 ? weekly : existing.weeklyUsageKg,
        reorderThresholdKg:
            weekly > 0 ? weekly : existing.reorderThresholdKg,
        unit: existing.unit,
        customNutrition: existing.customNutrition.isNotEmpty
            ? existing.customNutrition
            : input.customNutrition?.toJson() ?? {},
        photoPath: input.photoPath ?? existing.photoPath,
      );
      _feed[existingIdx] = _withStockFlags(merged);
      return _feed[existingIdx];
    }

    final item = FeedInventoryItem(
      id: _uuid.v4(),
      name: input.name,
      sourceType: input.sourceType,
      feedProductNumber: input.feedProductNumber,
      marketplaceProductId: input.marketplaceProductId,
      feedType: input.feedType,
      quantityKg: clampFeedQuantityKg(input.quantityKg),
      purchasedVolumeKg: purchaseKg,
      unitCost: input.unitCost,
      currency: input.currency,
      supplierName: input.supplierName,
      supplierPhone: input.supplierPhone,
      supplierNotes: input.supplierNotes,
      weeklyUsageKg: weekly,
      reorderThresholdKg: weekly,
      unit: 'kg',
      customNutrition: input.customNutrition?.toJson() ?? {},
      photoPath: input.photoPath,
    );
    _feed.add(item);
    return _withStockFlags(item);
  }

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
  }) async {
    final item = MedicalInventoryItem(
      id: _uuid.v4(),
      name: name,
      medicineType: medicineType,
      quantity: quantity,
      unit: unit,
      supplierName: supplierName,
      unitCost: unitCost,
      purpose: purpose,
      lowStock: estimatedWeeklyUsage != null &&
          quantity <= (estimatedWeeklyUsage),
      withdrawalPeriods: withdrawalPeriods,
    );
    _medical.add(item);
    return item;
  }

  @override
  Future<List<MealPlan>> listMeals() async => List.from(_meals);

  @override
  Future<MealPlan> createMeal(String name, {String? description}) async {
    final meal = MealPlan(
      id: _uuid.v4(),
      name: name,
      description: description,
      ingredients: const [],
      totalKgPerBatch: 0,
    );
    _meals.add(meal);
    return meal;
  }

  @override
  Future<SetMealIngredientsResult> setMealIngredients(
    String mealId,
    List<MealIngredientInput> ingredients,
  ) async {
    final idx = _meals.indexWhere((m) => m.id == mealId);
    if (idx < 0) throw StateError('Meal not found');
    final lines = ingredients.map((ing) {
      final feed = _feed.firstWhere(
        (f) => f.id == ing.feedInventoryItemId,
        orElse: () => FeedInventoryItem(
          id: ing.feedInventoryItemId,
          name: 'Feed',
          sourceType: InventorySourceType.custom,
          quantityKg: 0,
          unit: 'kg',
        ),
      );
      return MealIngredientLine(
        feedInventoryItemId: ing.feedInventoryItemId,
        amountKg: ing.amountKg,
        feedItemName: feed.name,
      );
    }).toList();
    final total = lines.fold(0.0, (s, l) => s + l.amountKg);
    final updated = MealPlan(
      id: mealId,
      name: _meals[idx].name,
      description: _meals[idx].description,
      ingredients: lines,
      totalKgPerBatch: total,
    );
    _meals[idx] = updated;
    final warnings = analyzeMealIngredientStock(
      _feed.map(_withStockFlags).toList(),
      ingredients,
    ).map(
      (w) => MealStockWarningLine(
        feedInventoryItemId: w.feedInventoryItemId,
        feedItemName: w.feedItemName,
        availableKg: w.availableKg,
        requestedKg: w.requestedKg,
        lowStock: w.lowStock,
        insufficientForBatch: w.insufficientForBatch,
      ),
    );
    return SetMealIngredientsResult(
      meal: MealPlan(
        id: updated.id,
        name: updated.name,
        description: updated.description,
        ingredients: updated.ingredients,
        totalKgPerBatch: updated.totalKgPerBatch,
        stockWarnings: warnings.toList(),
      ),
      stockWarnings: warnings.toList(),
    );
  }

  @override
  Future<List<TodaysFeedEntry>> listTodaysFeedForGroup(String groupId) async {
    return _todaysFeed
        .where((e) => e.groupId == groupId && _isToday(e.recordedAt))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  @override
  Future<TodaysFeedEntry> recordSupplementToTodaysFeed({
    required String groupId,
    required String productName,
    required double weightKg,
    String? feedInventoryItemId,
    double? unitCostPerKg,
    int? headCount,
  }) async {
    if (feedInventoryItemId != null) {
      final fi = _feed.indexWhere((f) => f.id == feedInventoryItemId);
      if (fi >= 0) {
        final f = _feed[fi];
        final nextQty = clampFeedQuantityKg(f.quantityKg - weightKg);
        _feed[fi] = FeedInventoryItem(
          id: f.id,
          name: f.name,
          sourceType: f.sourceType,
          feedProductNumber: f.feedProductNumber,
          marketplaceProductId: f.marketplaceProductId,
          feedType: f.feedType,
          quantityKg: nextQty,
          purchasedVolumeKg: f.purchasedVolumeKg,
          unitCost: f.unitCost,
          currency: f.currency,
          supplierName: f.supplierName,
          supplierPhone: f.supplierPhone,
          supplierNotes: f.supplierNotes,
          weeklyUsageKg: f.weeklyUsageKg,
          reorderThresholdKg: f.reorderThresholdKg,
          unit: f.unit,
          customNutrition: f.customNutrition,
        );
      }
    }

    final costSar = (unitCostPerKg ?? 0) * weightKg;
    final entry = TodaysFeedEntry(
      id: _uuid.v4(),
      groupId: groupId,
      recordedAt: DateTime.now(),
      title: 'Supplement · $productName',
      subtitle: _mealSubtitle(weightKg, headCount),
      costSar: costSar.roundToDouble(),
      weightKg: weightKg,
      headCount: headCount,
      unitCostPerKg: unitCostPerKg,
    );
    _todaysFeed.add(entry);
    return entry;
  }

  @override
  Future<void> removeTodaysFeedEntry(String entryId) async {
    final idx = _todaysFeed.indexWhere((e) => e.id == entryId);
    if (idx < 0) return;
    _todaysFeed.removeAt(idx);
  }

  @override
  Future<TodaysFeedEntry?> getTodaysFeedEntry(String entryId) async {
    final idx = _todaysFeed.indexWhere((e) => e.id == entryId);
    if (idx < 0) return null;
    return _todaysFeed[idx];
  }

  double _costForIngredients(List<MealIngredientLine> ingredients) {
    var cost = 0.0;
    for (final ing in ingredients) {
      final fi = _feed.indexWhere((f) => f.id == ing.feedInventoryItemId);
      if (fi < 0) continue;
      cost += ing.amountKg * (_feed[fi].unitCost ?? 0);
    }
    return cost;
  }

  List<MealIngredientLine> _scaledFedIngredients(
    MealPlan meal,
    double totalWeightKg,
  ) {
    if (meal.totalKgPerBatch <= 0) return const [];
    final scale = totalWeightKg / meal.totalKgPerBatch;
    return [
      for (final ing in meal.ingredients)
        MealIngredientLine(
          feedInventoryItemId: ing.feedInventoryItemId,
          amountKg: ing.amountKg * scale,
          feedItemName: ing.feedItemName,
        ),
    ];
  }

  List<MealIngredientLine> _linesFromInputs(
    List<MealIngredientInput> ingredients,
    List<FeedInventoryItem> feedItems,
  ) {
    return [
      for (final ing in ingredients)
        MealIngredientLine(
          feedInventoryItemId: ing.feedInventoryItemId,
          amountKg: ing.amountKg,
          feedItemName: _feedName(feedItems, ing.feedInventoryItemId),
        ),
    ];
  }

  String _feedName(List<FeedInventoryItem> feedItems, String id) {
    for (final f in feedItems) {
      if (f.id == id) return f.name;
    }
    return 'Feed';
  }

  @override
  Future<TodaysFeedEntry> updateTodaysFeedMeal({
    required String entryId,
    required List<MealIngredientInput> ingredients,
    int? headCount,
  }) async {
    final idx = _todaysFeed.indexWhere((e) => e.id == entryId);
    if (idx < 0) throw StateError('Feed entry not found');
    final existing = _todaysFeed[idx];
    final filtered = [
      for (final ing in ingredients)
        if (ing.amountKg > 0) ing,
    ];
    if (filtered.isEmpty) {
      throw ArgumentError('Add at least one feed ingredient');
    }
    final feedItems = await listFeed();
    final lines = _linesFromInputs(filtered, feedItems);
    final totalWeightKg =
        lines.fold<double>(0, (sum, line) => sum + line.amountKg);
    final resolvedHeadCount = headCount ?? existing.headCount;
    final costSar = _costForIngredients(lines).roundToDouble();
    final updated = TodaysFeedEntry(
      id: existing.id,
      groupId: existing.groupId,
      recordedAt: existing.recordedAt,
      title: existing.title,
      subtitle: _mealSubtitle(totalWeightKg, resolvedHeadCount),
      costSar: costSar > 0
          ? costSar
          : existing.unitCostPerKg != null
              ? (existing.unitCostPerKg! * totalWeightKg).roundToDouble()
              : existing.costSar,
      weightKg: totalWeightKg,
      headCount: resolvedHeadCount,
      mealTypeId: existing.mealTypeId,
      unitCostPerKg: existing.unitCostPerKg,
      fedIngredients: lines,
    );
    _todaysFeed[idx] = updated;
    return updated;
  }

  @override
  Future<TodaysFeedEntry> updateTodaysFeedWeight({
    required String entryId,
    required double weightKg,
  }) async {
    if (weightKg <= 0) {
      throw ArgumentError.value(weightKg, 'weightKg', 'must be positive');
    }
    final idx = _todaysFeed.indexWhere((e) => e.id == entryId);
    if (idx < 0) throw StateError('Feed entry not found');
    final existing = _todaysFeed[idx];
    final meal = _mealById(existing.mealTypeId);
    final costSar = meal != null
        ? _estimateMealCost(meal, weightKg).roundToDouble()
        : existing.unitCostPerKg != null
            ? (existing.unitCostPerKg! * weightKg).roundToDouble()
            : () {
                final oldKg = existing.effectiveWeightKg;
                return oldKg > 0
                    ? (existing.costSar * weightKg / oldKg).roundToDouble()
                    : existing.costSar;
              }();
    final fedIngredients = existing.fedIngredients.isNotEmpty && meal != null
        ? _scaledFedIngredients(meal, weightKg)
        : existing.fedIngredients;
    final updated = TodaysFeedEntry(
      id: existing.id,
      groupId: existing.groupId,
      recordedAt: existing.recordedAt,
      title: existing.title,
      subtitle: _mealSubtitle(weightKg, existing.headCount),
      costSar: costSar,
      weightKg: weightKg,
      headCount: existing.headCount,
      mealTypeId: existing.mealTypeId,
      unitCostPerKg: existing.unitCostPerKg,
      fedIngredients: fedIngredients,
    );
    _todaysFeed[idx] = updated;
    return updated;
  }

  @override
  Future<void> restoreSupplementInventory({
    required String feedInventoryItemId,
    required double weightKg,
  }) async {
    final fi = _feed.indexWhere((f) => f.id == feedInventoryItemId);
    if (fi < 0) return;
    final f = _feed[fi];
    _feed[fi] = FeedInventoryItem(
      id: f.id,
      name: f.name,
      sourceType: f.sourceType,
      feedProductNumber: f.feedProductNumber,
      marketplaceProductId: f.marketplaceProductId,
      feedType: f.feedType,
      quantityKg: f.quantityKg + weightKg,
      purchasedVolumeKg: f.purchasedVolumeKg,
      unitCost: f.unitCost,
      currency: f.currency,
      supplierName: f.supplierName,
      supplierPhone: f.supplierPhone,
      supplierNotes: f.supplierNotes,
      weeklyUsageKg: f.weeklyUsageKg,
      reorderThresholdKg: f.reorderThresholdKg,
      unit: f.unit,
      customNutrition: f.customNutrition,
    );
  }

  double _estimateMealCost(MealPlan meal, double totalWeightKg) {
    if (meal.totalKgPerBatch <= 0) return 0;
    final scale = totalWeightKg / meal.totalKgPerBatch;
    var cost = 0.0;
    for (final ing in meal.ingredients) {
      final fi = _feed.indexWhere((f) => f.id == ing.feedInventoryItemId);
      if (fi < 0) continue;
      cost += ing.amountKg * scale * (_feed[fi].unitCost ?? 0);
    }
    return cost;
  }

  String _mealSubtitle(double totalWeightKg, int? headCount) {
    final kg = totalWeightKg == totalWeightKg.roundToDouble()
        ? totalWeightKg.toInt().toString()
        : totalWeightKg.toStringAsFixed(1);
    if (headCount != null && headCount > 0) {
      final perHead = totalWeightKg / headCount;
      final perHeadText = perHead == perHead.roundToDouble()
          ? perHead.toInt().toString()
          : perHead.toStringAsFixed(1);
      return '$kg kg · $perHeadText kg/head';
    }
    return '$kg kg';
  }

  MealPlan? _mealById(String? mealTypeId) {
    if (mealTypeId == null) return null;
    final idx = _meals.indexWhere((m) => m.id == mealTypeId);
    if (idx < 0) return null;
    return _meals[idx];
  }

  void _appendTodaysFeedEntry({
    required String groupId,
    MealPlan? meal,
    required double totalWeightKg,
    int? headCount,
  }) {
    final costSar = meal != null ? _estimateMealCost(meal, totalWeightKg) : 0.0;
    _todaysFeed.add(
      TodaysFeedEntry(
        id: _uuid.v4(),
        groupId: groupId,
        recordedAt: DateTime.now(),
        title: meal?.name ?? 'Feed ration',
        subtitle: _mealSubtitle(totalWeightKg, headCount),
        costSar: costSar.roundToDouble(),
        weightKg: totalWeightKg,
        headCount: headCount,
        mealTypeId: meal?.id,
      ),
    );
  }

  /// Records today's feed for the UI without changing inventory (API already deducted).
  Future<void> recordTodaysFeedEntry({
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
  }) async {
    _appendTodaysFeedEntry(
      groupId: groupId,
      meal: _mealById(mealTypeId),
      totalWeightKg: totalWeightKg,
      headCount: headCount,
    );
  }

  @override
  Future<InventoryFeedingResult> recordFeeding({
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
  }) async {
    final meal = _mealById(mealTypeId);
    final lowStock = <FeedInventoryItem>[];
    if (meal != null && meal.totalKgPerBatch > 0) {
      final scale = totalWeightKg / meal.totalKgPerBatch;
      for (final ing in meal.ingredients) {
        final used = ing.amountKg * scale;
        final fi = _feed.indexWhere((f) => f.id == ing.feedInventoryItemId);
        if (fi < 0) continue;
        final f = _feed[fi];
        final nextQty = clampFeedQuantityKg(f.quantityKg - used);
        final updated = FeedInventoryItem(
          id: f.id,
          name: f.name,
          sourceType: f.sourceType,
          feedProductNumber: f.feedProductNumber,
          marketplaceProductId: f.marketplaceProductId,
          feedType: f.feedType,
          quantityKg: nextQty,
          purchasedVolumeKg: f.purchasedVolumeKg,
          unitCost: f.unitCost,
          currency: f.currency,
          supplierName: f.supplierName,
          supplierPhone: f.supplierPhone,
          supplierNotes: f.supplierNotes,
          weeklyUsageKg: f.weeklyUsageKg,
          reorderThresholdKg: f.reorderThresholdKg,
          unit: f.unit,
          customNutrition: f.customNutrition,
        );
        _feed[fi] = updated;
        final flagged = _withStockFlags(updated);
        if (flagged.lowStock) lowStock.add(flagged);
      }
    }
    _appendTodaysFeedEntry(
      groupId: groupId,
      meal: meal,
      totalWeightKg: totalWeightKg,
      headCount: headCount,
    );
    return InventoryFeedingResult(
      groupId: groupId,
      lowStockItems: lowStock,
    );
  }

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
