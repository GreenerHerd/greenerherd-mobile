import '../models/breed_reference.dart';
import '../models/lactation_models.dart';
import '../models/invite_models.dart';
import '../models/enums.dart';
import '../models/inventory_models.dart';
import '../models/models.dart';
import '../services/group_nutrition_mapper.dart';
import '../services/supplement_nutrition.dart';
import 'hybrid_nutrition_repository.dart';

abstract class AuthRepository {
  Future<AuthSession?> currentSession();
  Future<AuthSession> signInMock({String email = 'owner@alfalah.test'});
  Future<AuthSession> signInWithProvider(AuthProvider provider);
  Future<void> signOut();
  bool get isOnboardingComplete;
  Future<void> setOnboardingComplete(bool value);
  AuthProvider? get linkedProvider;
}

abstract class OnboardingRepository {
  Future<AuthSession> createFarmProfile({
    required String name,
    required String currency,
    String country,
    HousingType housing,
  });

  Future<void> addSpecies({
    required Species species,
    required SpeciesPurpose purpose,
  });

  Future<void> completeOnboarding({bool skipAnimals = false});

  Future<bool> fetchOnboardingComplete();
}

abstract class FarmRepository {
  Future<Farm> getCurrentFarm();
  Future<List<FarmUser>> getUsers();
}

abstract class AnimalRepository {
  Future<List<Animal>> listAnimals({
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  });
  Future<Animal?> getAnimal(String id);
  Future<Animal> updateAnimal(Animal animal);
  Future<Animal> createAnimal(Animal animal, {bool purchased = false});
  Future<Animal> flagCull(String id);
  Future<Animal> markSold(String id, {double? saleAmount});
}

abstract class GroupRepository {
  Future<List<AnimalGroup>> listGroups({Species? species});
  Future<AnimalGroup?> getGroup(String id);
  Future<AnimalGroup> createGroup(AnimalGroup group);
  Future<({AnimalGroup group, List<Animal> animals})> createGroupBulk({
    required Species species,
    required String breed,
    required String sex,
    required String ageRangeWire,
    required int count,
    required String name,
    required GroupPurpose purpose,
    String? notes,
  });
}

abstract class TaskRepository {
  Future<List<TaskItem>> listTasks({String? dueBucket});
  Future<void> addTask(TaskItem task);
  Future<void> deleteTask(String id);
  Future<void> completeTask(String id);
  Future<void> dismissTask(String id);
}

abstract class FinanceRepository {
  Future<FinanceSummary> getSummary();
  Future<void> addEntry(FinanceEntry entry);
}

abstract class ReportRepository {
  Future<List<ReportDefinition>> listReports();
}

class InventoryFeedingResult {
  const InventoryFeedingResult({
    required this.groupId,
    required this.lowStockItems,
  });

  final String groupId;
  final List<FeedInventoryItem> lowStockItems;
}

abstract class InventoryRepository {
  Future<List<InventoryItem>> listItems({bool? feedOnly});
  Future<List<FeedInventoryItem>> listFeed();
  Future<List<MedicalInventoryItem>> listMedical();
  Future<List<FeedInventoryItem>> listLowStock();
  Future<FeedInventoryItem?> getFeed(String id);
  Future<FeedInventoryItem> addFeed(CreateFeedInventoryInput input);
  Future<FeedInventoryItem> restockFeed({
    required String feedId,
    required double purchasedVolumeKg,
    required double unitCost,
    String? supplierName,
    String? supplierPhone,
  });
  Future<MedicalInventoryItem> addMedical({
    required String name,
    required String medicineType,
    required double quantity,
    required String unit,
    String? supplierName,
    double? unitCost,
    String? purpose,
    double? estimatedWeeklyUsage,
    List<WithdrawalPeriod> withdrawalPeriods,
  });
  Future<List<MealPlan>> listMeals();
  Future<MealPlan> createMeal(String name, {String? description});
  Future<SetMealIngredientsResult> setMealIngredients(
    String mealId,
    List<MealIngredientInput> ingredients,
  );
  Future<InventoryFeedingResult> recordFeeding({
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
  });

  /// Feed recorded today for [groupId] (local calendar day).
  Future<List<TodaysFeedEntry>> listTodaysFeedForGroup(String groupId);

  /// Logs a supplement on today's feed (not the meal plan). Deducts inventory when [feedInventoryItemId] is set.
  Future<TodaysFeedEntry> recordSupplementToTodaysFeed({
    required String groupId,
    required String productName,
    required double weightKg,
    String? feedInventoryItemId,
    double? unitCostPerKg,
    int? headCount,
  });

  Future<void> removeTodaysFeedEntry(String entryId);

  /// Updates total kg for a today's feed row; recalculates subtitle and cost.
  Future<TodaysFeedEntry> updateTodaysFeedWeight({
    required String entryId,
    required double weightKg,
  });

  Future<TodaysFeedEntry?> getTodaysFeedEntry(String entryId);

  /// Updates today's meal feeding with per-ingredient kg and recalculated total.
  Future<TodaysFeedEntry> updateTodaysFeedMeal({
    required String entryId,
    required List<MealIngredientInput> ingredients,
    int? headCount,
  });

  Future<void> restoreSupplementInventory({
    required String feedInventoryItemId,
    required double weightKg,
  });
}

abstract class NutritionRepository {
  Future<NutritionGap> getGap(String groupId);
  Future<List<FeedRecommendation>> getRecommendations(String groupId);
  Future<List<NutrientBridgeGap>> getBridgeGaps(String groupId);
  Future<void> updateRecommendation(FeedRecommendation item);
  Future<ApplyFeedPlanResult> applyFeedPlan(String groupId);

  /// Adjusts group nutrition totals for a supplement feeding (not meal plan).
  Future<void> applySupplement({
    required String groupId,
    required SupplementNutritionInput input,
    bool subtract = false,
  });
}

abstract class LactationRepository {
  Future<LactationCycle?> activeCycle(String animalId);
  Future<List<MilkYieldRecord>> milkHistory(String animalId);
  Future<void> recordDailyMilk({
    required String animalId,
    required double litres,
    DateTime? onDate,
  });
}

abstract class PeopleRepository {
  Future<List<FarmUser>> listPeople();
  Future<InviteUserResult> inviteUser(InviteUserRequest request);
}

abstract class CommerceRepository {
  Future<List<PurchaseRecord>> listPurchases();
  Future<List<SaleRecord>> listSales();
  Future<PurchaseRecord> recordPurchase(PurchaseRecord record);
  Future<SaleRecord> recordSale(SaleRecord record);
}

abstract class SubscriptionRepository {
  Future<SubscriptionPlan> getPlan();
}

abstract class MarketplaceRepository {
  Future<List<MarketplaceProduct>> listProducts();
}

abstract class DashboardRepository {
  Future<DashboardStats> getStats({Species? species});
}

abstract class BreedReferenceRepository {
  Future<List<BreedReference>> listBreeds(Species species);
  Future<BreedReference?> findByName(Species species, String name);
}
