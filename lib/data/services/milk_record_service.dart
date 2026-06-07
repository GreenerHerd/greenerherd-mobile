import '../models/lactation_models.dart';
import '../models/milking_session.dart';

/// Upserts and aggregates per-animal milk yield records.
abstract final class MilkRecordService {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      dateOnly(a) == dateOnly(b);

  static List<MilkYieldRecord> upsertRecord({
    required List<MilkYieldRecord> history,
    required MilkYieldRecord record,
    required MilkingSession session,
  }) {
    final day = dateOnly(record.date);
    final wire = session.wire;
    final kept = history.where((r) {
      if (!isSameDay(r.date, day)) return true;
      if (session == MilkingSession.daily) return false;
      if (r.milkingSession == 'DAILY') return false;
      if (r.milkingSession == wire) return false;
      return true;
    }).toList()
      ..add(record)
      ..sort((a, b) => a.date.compareTo(b.date));
    return kept;
  }

  /// Total litres for [day]: daily entry wins; otherwise AM + PM.
  static double? totalLitresForDay(
    List<MilkYieldRecord> history,
    DateTime day,
  ) {
    final dayOnly = dateOnly(day);
    final onDay =
        history.where((r) => isSameDay(r.date, dayOnly)).toList();
    if (onDay.isEmpty) return null;
    final daily = onDay.where((r) => r.milkingSession == 'DAILY').toList();
    if (daily.isNotEmpty) return daily.last.litres;
    var sum = 0.0;
    var n = 0;
    for (final r in onDay) {
      if (r.milkingSession == 'AM' || r.milkingSession == 'PM') {
        sum += r.litres;
        n++;
      }
    }
    return n == 0 ? null : sum;
  }
}
