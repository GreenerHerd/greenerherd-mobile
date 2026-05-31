import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../l10n/locale_controller.dart' show localeProvider;
export '../theme/theme_mode_controller.dart' show themeModeProvider;

import '../config/app_config.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/dashboard_stats_builder.dart';
import '../../data/mock/mock_breed_reference_repository.dart';
import '../../data/mock/mock_data_store.dart';
import '../../data/mock/mock_repositories.dart';
import '../../data/repositories/engine_nutrition_repository.dart';
import '../../data/repositories/hybrid_inventory_repository.dart';
import '../../data/repositories/hybrid_nutrition_repository.dart';
import '../../data/repositories/hybrid_animal_repository.dart';
import '../../data/repositories/hybrid_group_repository.dart';
import '../../data/repositories/hybrid_auth_repository.dart';
import '../../data/repositories/hybrid_commerce_repository.dart';
import '../../data/repositories/hybrid_finance_repository.dart';
import '../../data/repositories/hybrid_farm_repository.dart';
import '../../data/repositories/hybrid_onboarding_repository.dart';
import '../../data/repositories/hybrid_people_repository.dart';
import '../../data/repositories/hybrid_task_repository.dart';
import 'repository_binding.dart' as repository_binding;
import '../../data/services/group_nutrition_mapper.dart';
import '../../data/models/breed_reference.dart';
import '../../data/mock/mock_notification_preference_repository.dart';
import '../../data/repositories/notification_preference_repository.dart';
import '../../data/repositories/repositories.dart';
import '../../data/services/animal_input_validation.dart';
import '../../data/services/animal_lifecycle_service.dart';
import '../../data/services/finance_ledger_service.dart';

final mockDataStoreProvider = Provider<MockDataStore>((ref) => MockDataStore());

final financeLedgerProvider = Provider<FinanceLedgerService>((ref) {
  return FinanceLedgerService(ref.watch(financeRepositoryProvider));
});

final lifecycleServiceProvider =
    Provider<AnimalLifecycleService>((ref) => const AnimalLifecycleService());

final animalInputValidationProvider =
    Provider<AnimalInputValidation>((ref) => const AnimalInputValidation());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.useAuthApi) {
    return HybridAuthRepository(store: store);
  }
  return MockAuthRepository(store);
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.useFarmsApi) {
    return HybridOnboardingRepository(store: store);
  }
  return MockOnboardingRepository(store);
});

/// Rebuild hybrid API clients after session token or farm id changes.
void invalidateHybridApiProviders(WidgetRef ref) {
  ref.invalidate(farmRepositoryProvider);
  ref.invalidate(animalRepositoryProvider);
  ref.invalidate(groupRepositoryProvider);
  ref.invalidate(taskRepositoryProvider);
  ref.invalidate(peopleRepositoryProvider);
  ref.invalidate(inventoryRepositoryProvider);
  ref.invalidate(onboardingRepositoryProvider);
  ref.invalidate(financeRepositoryProvider);
  ref.invalidate(commerceRepositoryProvider);
}

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.useFarmsApi || AppConfig.usePeopleApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    return HybridFarmRepository(
      offlineStore: store,
      farmId: session?.farmId ?? 'farm-1',
      bearerToken: bearer,
    );
  }
  return MockFarmRepository(store);
});

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  final lifecycle = ref.watch(lifecycleServiceProvider);
  final farmId = store.session?.farmId ?? 'farm-1';
  final AnimalRepository inner;
  if (AppConfig.useAnimalsApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    inner = HybridAnimalRepository(
      offlineStore: store,
      farmId: farmId,
      bearerToken: bearer,
    );
  } else {
    inner = MockAnimalRepository(store, lifecycle);
  }
  if (!AppConfig.useOfflineCache) return inner;
  return repository_binding.wrapAnimalRepository(ref, inner, farmId);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  final farmId = store.session?.farmId ?? 'farm-1';
  final GroupRepository inner;
  if (AppConfig.useAnimalsApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    inner = HybridGroupRepository(
      offlineStore: store,
      farmId: farmId,
      bearerToken: bearer,
    );
  } else {
    inner = MockGroupRepository(store);
  }
  if (!AppConfig.useOfflineCache) return inner;
  return repository_binding.wrapGroupRepository(ref, inner, farmId);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  final farmId = store.session?.farmId ?? 'farm-1';
  final TaskRepository inner;
  if (AppConfig.useTasksApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    inner = HybridTaskRepository(
      offlineStore: store,
      farmId: farmId,
      bearerToken: bearer,
    );
  } else {
    inner = MockTaskRepository(store);
  }
  if (!AppConfig.useOfflineCache) return inner;
  return repository_binding.wrapTaskRepository(ref, inner, farmId);
});

final notificationPreferenceRepositoryProvider =
    Provider<NotificationPreferenceRepository>((ref) {
  return MockNotificationPreferenceRepository(ref.watch(mockDataStoreProvider));
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.useFinanceApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    return HybridFinanceRepository(
      offlineStore: store,
      farmId: session?.farmId ?? 'farm-1',
      bearerToken: bearer,
    );
  }
  return MockFinanceRepository(store);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return MockReportRepository(ref.watch(mockDataStoreProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  if (AppConfig.useInventoryApi) {
    final session = ref.watch(mockDataStoreProvider).session;
    final token = session?.accessToken;
    final bearer = token != null && token.isNotEmpty && token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    return HybridInventoryRepository(
      farmId: session?.farmId ?? 'farm-1',
      bearerToken: bearer,
    );
  }
  return MockInventoryRepository(ref.watch(mockDataStoreProvider));
});

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  if (AppConfig.useNutritionEngine) {
    return HybridNutritionRepository();
  }
  return MockNutritionRepository(ref.watch(mockDataStoreProvider));
});

final lactationRepositoryProvider = Provider<LactationRepository>((ref) {
  return MockLactationRepository(ref.watch(mockDataStoreProvider));
});

final bridgeGapsProvider =
    FutureProvider.family<List<NutrientBridgeGap>, String>((ref, groupId) async {
  final repo = ref.watch(nutritionRepositoryProvider);
  if (repo is HybridNutritionRepository) {
    return repo.getBridgeGaps(groupId);
  }
  if (repo is EngineNutritionRepository) {
    return repo.getBridgeGaps(groupId);
  }
  return [];
});

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.usePeopleApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    return HybridPeopleRepository(
      offlineStore: store,
      farmId: session?.farmId ?? 'farm-1',
      bearerToken: bearer,
    );
  }
  return MockPeopleRepository(store);
});

final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  if (AppConfig.useFinanceApi) {
    final session = store.session;
    final token = session?.accessToken;
    final bearer = token != null &&
            token.isNotEmpty &&
            token != 'mock-jwt-token'
        ? token
        : AppConfig.inventoryDevBearerToken;
    return HybridCommerceRepository(
      offlineStore: store,
      farmId: session?.farmId ?? 'farm-1',
      bearerToken: bearer,
    );
  }
  return MockCommerceRepository(store);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return MockSubscriptionRepository(ref.watch(mockDataStoreProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MockMarketplaceRepository(ref.watch(mockDataStoreProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepository(ref.watch(mockDataStoreProvider));
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final species = ref.watch(selectedSpeciesFilterProvider);
  if (AppConfig.useAnimalsApi || AppConfig.useTasksApi) {
    final store = ref.watch(mockDataStoreProvider);
    // Always load the full herd — species filter applies to status KPIs only,
    // not chip counts (All species / Cattle / Goats / Sheep).
    final animals = AppConfig.useAnimalsApi
        ? await ref.watch(animalRepositoryProvider).listAnimals()
        : store.animals;
    final groups = AppConfig.useAnimalsApi
        ? await ref.watch(groupRepositoryProvider).listGroups()
        : store.groups;
    final tasks = AppConfig.useTasksApi
        ? await ref.watch(taskRepositoryProvider).listTasks()
        : store.tasks;
    return DashboardStatsBuilder.fromLists(
      animals: animals,
      groups: groups,
      tasks: tasks,
      speciesFilter: species,
    );
  }
  return ref.watch(dashboardRepositoryProvider).getStats(species: species);
});

final breedReferenceRepositoryProvider =
    FutureProvider<BreedReferenceRepository>((ref) async {
  return MockBreedReferenceRepository.create();
});

final breedsForSpeciesProvider =
    FutureProvider.family<List<BreedReference>, Species>((ref, species) async {
  final repo = await ref.watch(breedReferenceRepositoryProvider.future);
  return repo.listBreeds(species);
});

/// All vaccination events recorded on the farm.
final vaccinationEventsProvider = Provider<List<VaccinationEvent>>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  return List<VaccinationEvent>.from(store.vaccinationEvents)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Active vaccination events (created within the last 48 hours).
final activeVaccinationEventsProvider = Provider<List<VaccinationEvent>>((ref) {
  return ref.watch(vaccinationEventsProvider).where((e) => e.isActive).toList();
});

final selectedSpeciesFilterProvider = StateProvider<Species?>((ref) => null);

final selectedGroupFilterProvider = StateProvider<String?>((ref) => null);

/// “Due soon” status chip on the animals list (pregnant cattle near term).
final dueSoonFilterProvider = StateProvider<bool>((ref) => false);

final selectedAnimalTagFilterProvider =
    StateProvider<AnimalTagType?>((ref) => null);

final burgerMenuOpenProvider = StateProvider<bool>((ref) => false);

final sheetRouteProvider = StateProvider<String?>((ref) => null);
