import '../models/lactation_models.dart';

/// Builds realistic lactation curves for demo / BDD seed data.
abstract final class LactationSeedBuilder {
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
}
