import '../models/enums.dart';
import '../models/lactation_models.dart';
import '../models/models.dart';
import 'dashboard_milk_metrics.dart';
import 'reproduction_status_rules.dart';

/// Builds dashboard KPIs from live animal and task lists (API or cache).
class DashboardStatsBuilder {
  const DashboardStatsBuilder._();

  static DashboardStats fromLists({
    required List<Animal> animals,
    required List<TaskItem> tasks,
    List<AnimalGroup> groups = const [],
    Species? speciesFilter,
    List<MilkYieldRecord> Function(String animalId)? milkHistoryFor,
  }) {
    final active = animals.where((a) => a.status == AnimalStatus.active);
    final filtered = speciesFilter == null
        ? active.toList()
        : active.where((a) => a.species == speciesFilter).toList();

    final activeGroups = speciesFilter == null
        ? groups
        : groups.where((g) => g.species == speciesFilter).toList();

    // When API returns no animal rows yet, derive head counts from groups.
    final useGroupHeadCounts = active.isEmpty && activeGroups.isNotEmpty;
    final totalAnimals = useGroupHeadCounts
        ? activeGroups.fold<int>(0, (s, g) => s + g.headCount)
        : filtered.length;

    int speciesCount(Species? s) {
      if (!useGroupHeadCounts) {
        if (s == null) return active.length;
        return active.where((a) => a.species == s).length;
      }
      if (s == null) {
        return groups.fold<int>(0, (sum, g) => sum + g.headCount);
      }
      return groups
          .where((g) => g.species == s)
          .fold<int>(0, (sum, g) => sum + g.headCount);
    }

    return DashboardStats(
      totalAnimals: totalAnimals,
      bySpecies: {
        null: speciesCount(null),
        Species.cattle: speciesCount(Species.cattle),
        Species.goat: speciesCount(Species.goat),
        Species.sheep: speciesCount(Species.sheep),
      },
      pregnant:
          filtered.where((a) => a.tags.contains(AnimalTagType.pregnant)).length,
      readyToBreed: filtered
          .where((a) => a.tags.contains(AnimalTagType.readyToBreed))
          .length,
      readyToBreedEligibleUntagged: filtered
          .where(ReproductionStatusRules.needsReadyToBreedTag)
          .length,
      sick: filtered.where((a) => a.tags.contains(AnimalTagType.sick)).length,
      cullFlagged:
          filtered.where((a) => a.tags.contains(AnimalTagType.cull)).length,
      lactating: filtered.where(DashboardMilkMetrics.isLactatingAnimal).length,
      avgLactatingMilkLitres: milkHistoryFor == null
          ? _avgMilkFromTodayOnly(filtered)
          : DashboardMilkMetrics.herdAvgLactatingDailyMilk(
              animals: filtered,
              historyFor: milkHistoryFor,
            ),
      weaning: filtered
          .where(ReproductionStatusRules.isWeaningForDashboard)
          .length,
      tasksOverdue: tasks.where((t) => t.overdue).length,
      tasksToday: tasks.where((t) => t.dueBucket == 'today').length,
      tasksThisWeek: tasks.where((t) => t.dueBucket == 'week').length,
    );
  }

  static double? _avgMilkFromTodayOnly(List<Animal> animals) {
    final litres = animals
        .where(DashboardMilkMetrics.isLactatingAnimal)
        .map((a) => a.milkTodayLitres)
        .whereType<double>()
        .where((l) => l > 0)
        .toList();
    if (litres.isEmpty) return null;
    return litres.reduce((a, b) => a + b) / litres.length;
  }
}
