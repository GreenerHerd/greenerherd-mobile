import '../models/animal_lactation_cycle.dart';
import '../models/enums.dart';
import '../models/lactation_models.dart';
import '../models/models.dart';

/// Lactation / milk KPI helpers for the farm dashboard.
abstract final class DashboardMilkMetrics {
  static bool isLactatingAnimal(Animal animal) {
    if (animal.lactationCycle != null) {
      return LactationCycleCatalog.isLactating(animal.lactationCycle!);
    }
    return animal.tags.contains(AnimalTagType.lactating);
  }

  /// Mean daily yield from records strictly before [onDate] within [lookbackDays].
  static double? averagePriorDailyMilk(
    List<MilkYieldRecord> history, {
    DateTime? onDate,
    int lookbackDays = 14,
  }) {
    if (history.isEmpty) return null;
    final now = onDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(Duration(days: lookbackDays));
    final prior = history.where((r) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      return d.isBefore(today) && !d.isBefore(cutoff);
    });
    if (prior.isEmpty) return null;
    var sum = 0.0;
    var n = 0;
    for (final r in prior) {
      sum += r.litres;
      n++;
    }
    return sum / n;
  }

  /// Herd average of per-animal daily milk (prior records, else today's volume).
  static double? herdAvgLactatingDailyMilk({
    required List<Animal> animals,
    required List<MilkYieldRecord> Function(String animalId) historyFor,
    DateTime? onDate,
    int lookbackDays = 14,
  }) {
    final perAnimal = <double>[];
    for (final animal in animals) {
      if (!isLactatingAnimal(animal)) continue;
      final fromHistory = averagePriorDailyMilk(
        historyFor(animal.id),
        onDate: onDate,
        lookbackDays: lookbackDays,
      );
      final litres = fromHistory ?? animal.milkTodayLitres;
      if (litres != null && litres > 0) {
        perAnimal.add(litres);
      }
    }
    if (perAnimal.isEmpty) return null;
    return perAnimal.reduce((a, b) => a + b) / perAnimal.length;
  }
}
