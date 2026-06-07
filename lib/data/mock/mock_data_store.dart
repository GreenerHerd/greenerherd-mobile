import '../../core/config/app_config.dart';
import '../models/enums.dart';
import '../models/lactation_models.dart';
import '../models/models.dart';
import '../models/notification_preference.dart';
import '../services/animal_mapper.dart';
import '../services/dashboard_milk_metrics.dart';
import '../services/reproduction_status_rules.dart';
import '../services/supplement_nutrition.dart';
import 'mock_seed_data.dart';

/// In-memory mutable store for mock phase.
class MockDataStore {
  MockDataStore({bool seedDemoHerd = false}) {
    if (!AppConfig.useAnimalsApi) {
      _animals.addAll(MockSeedData.animals());
    } else if (seedDemoHerd) {
      seedDemoHerdData();
    }
    _tasks.addAll(MockSeedData.tasks);
    _feedRecommendations.addAll(MockSeedData.feedRecommendations);
    final lactationSeed = MockSeedData.lactationSeed();
    _lactationCycles.addAll(lactationSeed.cycles);
    for (final e in lactationSeed.history.entries) {
      _milkHistory[e.key] = List.from(e.value);
    }
    purchases.add(PurchaseRecord(
      id: 'pr1',
      purchaseDate: DateTime(2026, 4, 1),
      totalAmount: 12000,
      animalIds: const ['legacy-1'],
    ));
    final now = DateTime.now();
    vaccinationEvents.addAll([
      VaccinationEvent(
        id: 've1',
        name: 'FMD Booster',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      VaccinationEvent(
        id: 've2',
        name: 'Brucellosis Annual',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ]);
    estimateMissingDobs();
  }

  final Farm farm = MockSeedData.farm;
  final List<FarmUser> users = List.from(MockSeedData.users);
  final List<AnimalGroup> groups = AppConfig.useAnimalsApi
      ? <AnimalGroup>[]
      : List.from(MockSeedData.groups);
  final List<Animal> _animals = [];
  final List<TaskItem> _tasks = [];
  FinanceSummary finance = MockSeedData.finance;
  final List<ReportDefinition> reports = List.from(MockSeedData.reports);
  final List<InventoryItem> inventory = List.from(MockSeedData.inventory);
  final List<FeedRecommendation> _feedRecommendations = [];
  final List<MarketplaceProduct> marketplace = List.from(MockSeedData.marketplace);
  SubscriptionPlan subscription = MockSeedData.subscription;
  final List<PurchaseRecord> purchases = [];
  final List<SaleRecord> sales = [];
  final List<VaccinationEvent> vaccinationEvents = [];
  AuthSession? session;
  AuthProvider? linkedAuthProvider;
  bool onboardingComplete = true;
  /// When true, router keeps user on onboarding even if the demo farm is complete.
  bool forceOnboarding = false;
  Map<String, NotificationPreferenceItem> notificationPreferenceOverrides = {};
  final Map<String, LactationCycle> _lactationCycles = {};
  final Map<String, List<MilkYieldRecord>> _milkHistory = {};
  final Map<String, NutritionGap> _nutritionGapOverrides = {};

  LactationCycle? lactationCycleFor(String animalId) => _lactationCycles[animalId];

  List<MilkYieldRecord> milkHistoryFor(String animalId) {
    final list = _milkHistory[animalId];
    if (list == null) return [];
    return List<MilkYieldRecord>.from(list)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void setLactationCycle(LactationCycle cycle) {
    _lactationCycles[cycle.animalId] = cycle;
  }

  void addMilkRecord(String animalId, MilkYieldRecord record) {
    _milkHistory.putIfAbsent(animalId, () => []).add(record);
    _milkHistory[animalId]!.sort((a, b) => a.date.compareTo(b.date));
  }

  void setMilkHistory(String animalId, List<MilkYieldRecord> records) {
    _milkHistory[animalId] = List.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Animal> get animals => List.unmodifiable(_animals);
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<FeedRecommendation> get feedRecommendations => _feedRecommendations;

  void setFeedRecommendation(int index, FeedRecommendation item) {
    _feedRecommendations[index] = item;
  }

  NutritionGap nutritionGapFor(String groupId) =>
      _nutritionGapOverrides[groupId] ?? MockSeedData.nutritionGapFor(groupId);

  void applyNutritionSupplement(
    String groupId,
    SupplementNutritionContribution delta, {
    bool subtract = false,
  }) {
    final base = nutritionGapFor(groupId);
    final sign = subtract ? -1.0 : 1.0;
    _nutritionGapOverrides[groupId] = NutritionGap(
      groupId: groupId,
      dryMatterActualKg: base.dryMatterActualKg + sign * delta.dryMatterKg,
      dryMatterTargetKg: base.dryMatterTargetKg,
      energyActualMj: base.energyActualMj + sign * delta.energyMj,
      energyTargetMj: base.energyTargetMj,
      proteinActualKg: (base.proteinActualKg ?? 0) + sign * delta.proteinKg,
      proteinTargetKg: base.proteinTargetKg,
      ndfActualKg: (base.ndfActualKg ?? 0) + sign * delta.ndfKg,
      ndfTargetKg: base.ndfTargetKg,
      calciumActualKg: base.calciumActualKg,
      calciumTargetKg: base.calciumTargetKg,
      phosphorusActualKg: base.phosphorusActualKg,
      phosphorusTargetKg: base.phosphorusTargetKg,
      fixGapMessage: base.fixGapMessage,
      dailyCostPerHeadSar: base.dailyCostPerHeadSar,
      dailyCostChangePct: base.dailyCostChangePct,
      optimizerPass: base.optimizerPass,
      profileCode: base.profileCode,
      planDryMatterKg: base.planDryMatterKg,
      needsMarketSupplement: base.needsMarketSupplement,
    );
  }

  Animal? animalById(String id) {
    try {
      return _animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateAnimal(Animal animal) {
    final i = _animals.indexWhere((a) => a.id == animal.id);
    if (i >= 0) {
      _animals[i] = animal;
    } else {
      _animals.add(animal);
    }
  }

  void addAnimal(Animal animal) {
    _animals.add(animal.dob != null ? animal : _withEstimatedDob(animal));
  }

  /// Patches any animals that are missing a dob with an estimated value.
  void estimateMissingDobs() {
    for (var i = 0; i < _animals.length; i++) {
      if (_animals[i].dob == null) {
        _animals[i] = _withEstimatedDob(_animals[i]);
      }
    }
  }

  static Animal _withEstimatedDob(Animal a) {
    final dob = AnimalMapper.dobFromAgeLabel(a.ageLabel);
    return a.copyWith(dob: dob);
  }

  /// Seeds Al-Falah demo herd for widget tests and offline API fallback tests.
  void seedDemoHerdData() {
    if (_animals.isEmpty) {
      _animals.addAll(MockSeedData.animals());
    }
    if (groups.isEmpty) {
      for (final g in MockSeedData.groups) {
        groups.add(g);
      }
    }
  }

  void addGroup(AnimalGroup group) => groups.add(group);

  /// Replaces offline groups with the latest API snapshot (avoids duplicate chips).
  void replaceGroups(List<AnimalGroup> next) {
    groups
      ..clear()
      ..addAll(next);
  }

  void addTask(TaskItem task) => _tasks.add(task);

  void removeTask(String id) => _tasks.removeWhere((t) => t.id == id);

  DashboardStats dashboardStats({Species? speciesFilter}) {
    final filtered = speciesFilter == null
        ? _animals
        : _animals.where((a) => a.species == speciesFilter).toList();
    return DashboardStats(
      totalAnimals: filtered.length,
      bySpecies: {
        null: _animals.length,
        Species.cattle: _animals.where((a) => a.species == Species.cattle).length,
        Species.goat: _animals.where((a) => a.species == Species.goat).length,
        Species.sheep: _animals.where((a) => a.species == Species.sheep).length,
      },
      pregnant: filtered.where((a) => a.tags.contains(AnimalTagType.pregnant)).length,
      readyToBreed:
          filtered.where((a) => a.tags.contains(AnimalTagType.readyToBreed)).length,
      readyToBreedEligibleUntagged: filtered
          .where(ReproductionStatusRules.needsReadyToBreedTag)
          .length,
      sick: filtered.where((a) => a.tags.contains(AnimalTagType.sick)).length,
      cullFlagged: filtered.where((a) => a.tags.contains(AnimalTagType.cull)).length,
      lactating: filtered.where(DashboardMilkMetrics.isLactatingAnimal).length,
      avgLactatingMilkLitres: DashboardMilkMetrics.herdAvgLactatingDailyMilk(
        animals: filtered,
        historyFor: milkHistoryFor,
      ),
      weaning: filtered
          .where(ReproductionStatusRules.isWeaningForDashboard)
          .length,
      tasksOverdue: _tasks.where((t) => t.overdue).length,
      tasksToday: _tasks.where((t) => t.dueBucket == 'today').length,
      tasksThisWeek: _tasks.where((t) => t.dueBucket == 'week').length,
    );
  }
}
