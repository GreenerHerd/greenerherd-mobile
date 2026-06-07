import '../models/cull_reasons.dart';
import '../models/enums.dart';
import '../models/invite_models.dart';
import '../models/inventory_models.dart';
import '../models/lactation_models.dart';
import '../models/milking_session.dart';
import '../models/models.dart';
import '../services/milk_record_service.dart';
import '../services/finance_summary_apply.dart';
import '../repositories/hybrid_nutrition_repository.dart';
import '../repositories/local_inventory_repository.dart';
import '../repositories/repositories.dart';
import '../services/group_nutrition_mapper.dart';
import '../services/supplement_nutrition.dart';
import '../services/animal_lifecycle_service.dart';
import '../services/animal_mapper.dart';
import 'mock_data_store.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._store);
  final MockDataStore _store;

  @override
  Future<AuthSession?> currentSession() async => _store.session;

  @override
  AuthProvider? get linkedProvider => _store.linkedAuthProvider;

  @override
  Future<AuthSession> signInMock({String email = 'owner@alfalah.test'}) async {
    final session = AuthSession(
      userId: 'u1',
      farmId: _store.farm.id,
      role: UserRole.owner,
      displayName: 'Yusuf Al-Harbi',
      accessToken: 'mock-jwt-token',
    );
    _store.session = session;
    return session;
  }

  @override
  Future<AuthSession> signInWithProvider(AuthProvider provider) async {
    _store.linkedAuthProvider = provider;
    return signInMock();
  }

  @override
  Future<void> signOut() async {
    _store.session = null;
    _store.linkedAuthProvider = null;
  }

  @override
  bool get isOnboardingComplete =>
      !_store.forceOnboarding && _store.onboardingComplete;

  @override
  Future<void> setOnboardingComplete(bool value) async {
    _store.onboardingComplete = value;
  }
}

class MockOnboardingRepository implements OnboardingRepository {
  MockOnboardingRepository(this._store);
  final MockDataStore _store;

  @override
  Future<AuthSession> createFarmProfile({
    required String name,
    required String currency,
    String country = 'SA',
    HousingType housing = HousingType.indoorFans,
  }) async {
    return _store.session!;
  }

  @override
  Future<void> addSpecies({
    required Species species,
    required SpeciesPurpose purpose,
  }) async {}

  @override
  Future<void> completeOnboarding({bool skipAnimals = false}) async {
    _store.onboardingComplete = true;
    _store.forceOnboarding = false;
  }

  @override
  Future<bool> fetchOnboardingComplete() async => _store.onboardingComplete;
}

class MockFarmRepository implements FarmRepository {
  MockFarmRepository(this._store);
  final MockDataStore _store;

  @override
  Future<Farm> getCurrentFarm() async => _store.farm;

  @override
  Future<List<FarmUser>> getUsers() async => _store.users;
}

class MockAnimalRepository implements AnimalRepository {
  MockAnimalRepository(this._store, this._lifecycle);
  final MockDataStore _store;
  final AnimalLifecycleService _lifecycle;

  @override
  Future<List<Animal>> listAnimals({
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  }) async {
    var list = _store.animals.where((a) => a.status == AnimalStatus.active);
    if (species != null) list = list.where((a) => a.species == species);
    if (statusTag != null) {
      list = list.where((a) => a.tags.contains(statusTag));
    }
    if (groupId != null) list = list.where((a) => a.groupId == groupId);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where(
        (a) =>
            a.name.toLowerCase().contains(q) ||
            a.tag.toLowerCase().contains(q) ||
            a.breed.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  @override
  Future<Animal?> getAnimal(String id) async => _store.animalById(id);

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    _store.updateAnimal(animal);
    return animal;
  }

  @override
  Future<Animal> createAnimal(Animal animal, {bool purchased = false}) async {
    _store.addAnimal(animal);
    return animal;
  }

  @override
  Future<Animal> flagCull(String id) async {
    final animal = await getAnimal(id);
    if (animal == null) throw StateError('Animal not found');
    final updated = _lifecycle.flagForCull(
      animal,
      selection: CullReasonCatalog.defaultSelection,
    );
    _store.updateAnimal(updated);
    return updated;
  }

  @override
  Future<Animal> markSold(String id, {double? saleAmount}) async {
    final animal = await getAnimal(id);
    if (animal == null) throw StateError('Animal not found');
    final updated = _lifecycle.markSold(animal);
    _store.updateAnimal(updated);
    return updated;
  }

  AnimalLifecycleService get lifecycle => _lifecycle;
}

class MockGroupRepository implements GroupRepository {
  MockGroupRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<AnimalGroup>> listGroups({Species? species}) async {
    if (species == null) return _store.groups;
    return _store.groups.where((g) => g.species == species).toList();
  }

  @override
  Future<AnimalGroup?> getGroup(String id) async {
    try {
      return _store.groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AnimalGroup> createGroup(AnimalGroup group) async {
    _store.addGroup(group);
    return group;
  }

  @override
  Future<({AnimalGroup group, List<Animal> animals})> createGroupBulk({
    required Species species,
    required String breed,
    required String sex,
    required String ageRangeWire,
    required int count,
    required String name,
    required GroupPurpose purpose,
    String? notes,
  }) async {
    final group = AnimalGroup(
      id: 'g-${_store.groups.length + 1}',
      name: name,
      species: species,
      purpose: purpose,
      headCount: count,
      description: notes,
    );
    _store.addGroup(group);
    final prefix = name.trim().isEmpty
        ? 'GRP'
        : name.trim().replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final tagPrefix = prefix.length >= 3 ? prefix.substring(0, 3) : 'GRP';
    final ageLabel = _ageLabelFromWire(ageRangeWire);
    final estimatedDob = AnimalMapper.dobFromAgeLabel(ageLabel);
    final animals = List<Animal>.generate(count, (i) {
      final n = i + 1;
      return Animal(
        id: 'a-${group.id}-$n',
        tag: '$tagPrefix-${n.toString().padLeft(3, '0')}',
        name: '',
        species: species,
        sex: sex,
        breed: breed,
        weightKg: 0,
        ageLabel: ageLabel,
        dob: estimatedDob,
        groupId: group.id,
        weightIndicative: true,
      );
    });
    for (final a in animals) {
      _store.addAnimal(a);
    }
    return (group: group, animals: animals);
  }

  static String _ageLabelFromWire(String wire) => switch (wire) {
        '0_3M' => '0-3m',
        '3_6M' || '4_6M' => '4-6m',
        '6_12M' || '7_11M' => '7-11m',
        '2_3Y' => '2-3yr',
        '3_5Y' => '3-5yr',
        '5PLUS_Y' => '5+yr',
        _ => '1-2yr',
      };
}

class MockTaskRepository implements TaskRepository {
  MockTaskRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<TaskItem>> listTasks({String? dueBucket}) async {
    if (dueBucket == null) return _store.tasks;
    return _store.tasks.where((t) => t.dueBucket == dueBucket).toList();
  }

  @override
  Future<void> addTask(TaskItem task) async => _store.addTask(task);

  @override
  Future<void> deleteTask(String id) async => _store.removeTask(id);

  @override
  Future<void> completeTask(String id) async => _store.removeTask(id);

  @override
  Future<void> dismissTask(String id) async => _store.removeTask(id);
}

class MockFinanceRepository implements FinanceRepository {
  MockFinanceRepository(this._store);
  final MockDataStore _store;

  @override
  Future<FinanceSummary> getSummary() async => _store.finance;

  @override
  Future<void> addEntry(FinanceEntry entry) async {
    _store.finance = applyFinanceEntry(_store.finance, entry);
  }
}

class MockLactationRepository implements LactationRepository {
  MockLactationRepository(this._store);

  final MockDataStore _store;

  @override
  Future<LactationCycle?> activeCycle(String animalId) async {
    return _store.lactationCycleFor(animalId);
  }

  @override
  Future<List<MilkYieldRecord>> milkHistory(String animalId) async {
    return _store.milkHistoryFor(animalId);
  }

  @override
  Future<void> recordDailyMilk({
    required String animalId,
    required double litres,
    DateTime? onDate,
  }) async {
    await recordMilk(
      animalId: animalId,
      litres: litres,
      onDate: onDate ?? DateTime.now(),
      session: MilkingSession.daily,
    );
  }

  @override
  Future<void> recordMilk({
    required String animalId,
    required double litres,
    required DateTime onDate,
    required MilkingSession session,
  }) async {
    final day = DateTime(onDate.year, onDate.month, onDate.day);
    final cycle = _store.lactationCycleFor(animalId);
    final dim = cycle?.daysInMilk(day) ?? 0;
    final record = MilkYieldRecord(
      date: day,
      litres: litres,
      lactationDay: dim,
      milkingSession: session.wire,
    );
    final history = _store.milkHistoryFor(animalId);
    _store.setMilkHistory(
      animalId,
      MilkRecordService.upsertRecord(
        history: history,
        record: record,
        session: session,
      ),
    );
    final animal = _store.animalById(animalId);
    if (animal != null && MilkRecordService.isSameDay(day, DateTime.now())) {
      final total = MilkRecordService.totalLitresForDay(
        _store.milkHistoryFor(animalId),
        day,
      );
      if (total != null) {
        _store.updateAnimal(animal.copyWith(milkTodayLitres: total));
      }
    }
  }
}

class MockReportRepository implements ReportRepository {
  MockReportRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<ReportDefinition>> listReports() async => _store.reports;
}

class MockInventoryRepository implements InventoryRepository {
  MockInventoryRepository(this._store) : _delegate = LocalInventoryRepository();

  final MockDataStore _store;
  final LocalInventoryRepository _delegate;

  @override
  Future<List<InventoryItem>> listItems({bool? feedOnly}) async =>
      _delegate.listItems(feedOnly: feedOnly);

  @override
  Future<List<FeedInventoryItem>> listFeed() => _delegate.listFeed();

  @override
  Future<List<MedicalInventoryItem>> listMedical() => _delegate.listMedical();

  @override
  Future<List<FeedInventoryItem>> listLowStock() => _delegate.listLowStock();

  @override
  Future<FeedInventoryItem?> getFeed(String id) => _delegate.getFeed(id);

  @override
  Future<FeedInventoryItem> addFeed(CreateFeedInventoryInput input) =>
      _delegate.addFeed(input);

  @override
  Future<FeedInventoryItem> restockFeed({
    required String feedId,
    required double purchasedVolumeKg,
    required double unitCost,
    String? supplierName,
    String? supplierPhone,
  }) =>
      _delegate.restockFeed(
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
      _delegate.addMedical(
        name: name,
        medicineType: medicineType,
        quantity: quantity,
        unit: unit,
        supplierName: supplierName,
        unitCost: unitCost,
        purpose: purpose,
        estimatedWeeklyUsage: estimatedWeeklyUsage,
        withdrawalPeriods: withdrawalPeriods,
      );

  @override
  Future<List<MealPlan>> listMeals() => _delegate.listMeals();

  @override
  Future<MealPlan> createMeal(String name, {String? description}) =>
      _delegate.createMeal(name, description: description);

  @override
  Future<SetMealIngredientsResult> setMealIngredients(
    String mealId,
    List<MealIngredientInput> ingredients,
  ) =>
      _delegate.setMealIngredients(mealId, ingredients);

  @override
  Future<InventoryFeedingResult> recordFeeding({
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
  }) =>
      _delegate.recordFeeding(
        groupId: groupId,
        mealTypeId: mealTypeId,
        totalWeightKg: totalWeightKg,
        headCount: headCount,
      );

  @override
  Future<List<TodaysFeedEntry>> listTodaysFeedForGroup(String groupId) =>
      _delegate.listTodaysFeedForGroup(groupId);

  @override
  Future<TodaysFeedEntry> recordSupplementToTodaysFeed({
    required String groupId,
    required String productName,
    required double weightKg,
    String? feedInventoryItemId,
    double? unitCostPerKg,
    int? headCount,
  }) =>
      _delegate.recordSupplementToTodaysFeed(
        groupId: groupId,
        productName: productName,
        weightKg: weightKg,
        feedInventoryItemId: feedInventoryItemId,
        unitCostPerKg: unitCostPerKg,
        headCount: headCount,
      );

  @override
  Future<void> removeTodaysFeedEntry(String entryId) =>
      _delegate.removeTodaysFeedEntry(entryId);

  @override
  Future<TodaysFeedEntry> updateTodaysFeedWeight({
    required String entryId,
    required double weightKg,
  }) =>
      _delegate.updateTodaysFeedWeight(
        entryId: entryId,
        weightKg: weightKg,
      );

  @override
  Future<TodaysFeedEntry?> getTodaysFeedEntry(String entryId) =>
      _delegate.getTodaysFeedEntry(entryId);

  @override
  Future<TodaysFeedEntry> updateTodaysFeedMeal({
    required String entryId,
    required List<MealIngredientInput> ingredients,
    int? headCount,
  }) =>
      _delegate.updateTodaysFeedMeal(
        entryId: entryId,
        ingredients: ingredients,
        headCount: headCount,
      );

  @override
  Future<void> restoreSupplementInventory({
    required String feedInventoryItemId,
    required double weightKg,
  }) =>
      _delegate.restoreSupplementInventory(
        feedInventoryItemId: feedInventoryItemId,
        weightKg: weightKg,
      );
}

class MockNutritionRepository implements NutritionRepository {
  MockNutritionRepository(this._store);
  final MockDataStore _store;

  @override
  Future<NutritionGap> getGap(String groupId) async =>
      _store.nutritionGapFor(groupId);

  @override
  Future<List<FeedRecommendation>> getRecommendations(String groupId) async =>
      _store.feedRecommendations;

  @override
  Future<List<NutrientBridgeGap>> getBridgeGaps(String groupId) async => [];

  @override
  Future<void> updateRecommendation(FeedRecommendation item) async {
    final i = _store.feedRecommendations.indexWhere((r) => r.id == item.id);
    if (i >= 0) _store.setFeedRecommendation(i, item);
  }

  @override
  Future<ApplyFeedPlanResult> applyFeedPlan(String groupId) async {
    return const ApplyFeedPlanResult(
      applied: true,
      source: 'offline',
      message: 'Mock plan applied',
    );
  }

  @override
  Future<void> applySupplement({
    required String groupId,
    required SupplementNutritionInput input,
    bool subtract = false,
  }) async {
    final delta = SupplementNutrition.contribution(input);
    _store.applyNutritionSupplement(groupId, delta, subtract: subtract);
  }
}

class MockPeopleRepository implements PeopleRepository {
  MockPeopleRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<FarmUser>> listPeople() async => _store.users;

  @override
  Future<InviteUserResult> inviteUser(InviteUserRequest request) async {
    final id = 'u-${_store.users.length + 1}';
    final member = FarmUser(
      id: id,
      name: request.name,
      role: request.role,
      initials: request.name
          .split(' ')
          .where((p) => p.isNotEmpty)
          .map((p) => p[0])
          .take(2)
          .join()
          .toUpperCase(),
    );
    _store.users.add(member);
    final link = 'https://greenerherd.app/join?invite=mock-$id';
    final message =
        'Hi ${request.name}, join ${_store.farm.name} on GreenerHerd: $link';
    return InviteUserResult(
      member: member,
      inviteLink: link,
      message: message,
      emailSent: request.channel != InviteDeliveryChannel.whatsapp,
      whatsappUrl: request.phone != null
          ? 'https://wa.me/${request.phone!.replaceAll(RegExp(r'\D'), '')}'
          : null,
    );
  }
}

class MockCommerceRepository implements CommerceRepository {
  MockCommerceRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<PurchaseRecord>> listPurchases() async => _store.purchases;

  @override
  Future<List<SaleRecord>> listSales() async => _store.sales;

  @override
  Future<PurchaseRecord> recordPurchase(PurchaseRecord record) async {
    _store.purchases.add(record);
    return record;
  }

  @override
  Future<SaleRecord> recordSale(SaleRecord record) async {
    _store.sales.add(record);
    return record;
  }
}

class MockSubscriptionRepository implements SubscriptionRepository {
  MockSubscriptionRepository(this._store);
  final MockDataStore _store;

  @override
  Future<SubscriptionPlan> getPlan() async => _store.subscription;
}

class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository(this._store);
  final MockDataStore _store;

  @override
  Future<List<MarketplaceProduct>> listProducts() async => _store.marketplace;
}

class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository(this._store);
  final MockDataStore _store;

  @override
  Future<DashboardStats> getStats({Species? species}) async =>
      _store.dashboardStats(speciesFilter: species);
}
