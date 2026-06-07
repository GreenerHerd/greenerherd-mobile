import '../models/animal_lactation_cycle.dart';
import '../models/lactation_models.dart';

/// Builds realistic lactation curves for demo / BDD seed data.
abstract final class LactationSeedBuilder {
  /// Typical days in milk for demo cows at each farmer-selected cattle stage.
  static int dimForFarmerCycle(AnimalLactationCycle cycle) => switch (cycle) {
        AnimalLactationCycle.cattleEarly => 24,
        AnimalLactationCycle.cattleMid => 128,
        AnimalLactationCycle.cattleLate => 215,
        AnimalLactationCycle.cattleClose => 278,
        _ => 128,
      };

  /// Representative daily milk (litres) for mock UI / KPIs at each stage.
  static double todayLitresForCycle(
    AnimalLactationCycle cycle, {
    String? breed,
  }) {
    final scale = _breedMilkScale(breed);
    final base = switch (cycle) {
      AnimalLactationCycle.cattleEarly => 26.0,
      AnimalLactationCycle.cattleMid => 32.5,
      AnimalLactationCycle.cattleLate => 23.5,
      AnimalLactationCycle.cattleClose => 14.8,
      AnimalLactationCycle.cattleDry ||
      AnimalLactationCycle.cattlePreCalvingCloseToDryOff ||
      AnimalLactationCycle.nonLactating =>
        0.0,
      AnimalLactationCycle.lactatingSingle => 2.4,
      AnimalLactationCycle.lactatingTwin => 3.6,
    };
    return double.parse((base * scale).toStringAsFixed(1));
  }

  static double _breedMilkScale(String? breed) {
    final b = breed?.toLowerCase() ?? '';
    if (b.contains('jersey')) return 0.82;
    if (b.contains('holstein')) return 1.0;
    return 0.92;
  }
  /// Typical 305-day lactation curve (litres/day) by DIM.
  static double expectedYieldLitres(int dim) {
    if (dim <= 0) return 0;
    if (dim <= 14) return 18 + dim * 0.35;
    if (dim <= 60) return 28 + (dim - 14) * 0.08;
    if (dim <= 120) return 32 - (dim - 60) * 0.05;
    if (dim <= 200) return 26 - (dim - 120) * 0.04;
    if (dim <= 305) return 18 - (dim - 200) * 0.06;
    return 8;
  }

  /// Historical milk records every 7 days from [calvingDate] through [toDate].
  static List<MilkYieldRecord> weeklyHistory({
    required DateTime calvingDate,
    required DateTime toDate,
    double noise = 0.08,
  }) {
    final records = <MilkYieldRecord>[];
    var cursor = calvingDate.add(const Duration(days: 7));
    while (!cursor.isAfter(toDate)) {
      final dim = cursor.difference(calvingDate).inDays;
      if (dim > 305) break;
      final base = expectedYieldLitres(dim);
      final jitter = 1 + (dim % 5 - 2) * noise;
      records.add(
        MilkYieldRecord(
          date: DateTime(cursor.year, cursor.month, cursor.day),
          litres: (base * jitter).clamp(4.0, 42.0),
          lactationDay: dim,
          milkingSession: 'AM',
        ),
      );
      cursor = cursor.add(const Duration(days: 7));
    }
    return records;
  }

  static LactationCycle cycleFor({
    required String animalId,
    required int cycleNumber,
    required DateTime calvingDate,
  }) {
    return LactationCycle(
      id: 'lc-$animalId-$cycleNumber',
      animalId: animalId,
      cycleNumber: cycleNumber,
      calvingDate: calvingDate,
    );
  }

  /// Today's yield aligned with [cycle] (uses [dimForFarmerCycle] + curve noise).
  static double todayLitresFromCurve(AnimalLactationCycle cycle) {
    final dim = dimForFarmerCycle(cycle);
    return double.parse(expectedYieldLitres(dim).toStringAsFixed(1));
  }

  /// Weekly milk history for a cow at a given farmer lactation stage.
  static ({LactationCycle cycle, List<MilkYieldRecord> history}) seedForFarmerCycle({
    required String animalId,
    required AnimalLactationCycle cycle,
    required int cycleNumber,
    required DateTime now,
    int weeksOfHistory = 16,
    String? breed,
  }) {
    final dim = dimForFarmerCycle(cycle);
    final calving = now.subtract(Duration(days: dim));
    final cycleModel = cycleFor(
      animalId: animalId,
      cycleNumber: cycleNumber,
      calvingDate: calving,
    );
    var history = weeklyHistory(calvingDate: calving, toDate: now);
    if (history.length > weeksOfHistory) {
      history = history.sublist(history.length - weeksOfHistory);
    }
    if (history.isNotEmpty) {
      final target = todayLitresForCycle(cycle, breed: breed);
      final last = history.last;
      history[history.length - 1] = MilkYieldRecord(
        date: last.date,
        litres: target,
        lactationDay: last.lactationDay,
        milkingSession: last.milkingSession,
      );
    }
    return (cycle: cycleModel, history: history);
  }
}
