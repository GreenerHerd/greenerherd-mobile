import '../models/enums.dart';
import '../models/models.dart';

/// Builds dashboard KPIs from live animal and task lists (API or cache).
class DashboardStatsBuilder {
  const DashboardStatsBuilder._();

  static DashboardStats fromLists({
    required List<Animal> animals,
    required List<TaskItem> tasks,
    List<AnimalGroup> groups = const [],
    Species? speciesFilter,
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
      sick: filtered.where((a) => a.tags.contains(AnimalTagType.sick)).length,
      cullFlagged:
          filtered.where((a) => a.tags.contains(AnimalTagType.cull)).length,
      lactating:
          filtered.where((a) => a.tags.contains(AnimalTagType.lactating)).length,
      tasksOverdue: tasks.where((t) => t.overdue).length,
      tasksToday: tasks.where((t) => t.dueBucket == 'today').length,
      tasksThisWeek: tasks.where((t) => t.dueBucket == 'week').length,
    );
  }
}
