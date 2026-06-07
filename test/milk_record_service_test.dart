import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/lactation_models.dart';
import 'package:greenerherd_mobile/data/models/milking_session.dart';
import 'package:greenerherd_mobile/data/services/milk_record_service.dart';

void main() {
  final day = DateTime(2026, 5, 20);

  test('totalLitresForDay sums AM and PM', () {
    final history = [
      MilkYieldRecord(date: day, litres: 12, lactationDay: 1, milkingSession: 'AM'),
      MilkYieldRecord(date: day, litres: 10, lactationDay: 1, milkingSession: 'PM'),
    ];
    expect(MilkRecordService.totalLitresForDay(history, day), 22);
  });

  test('daily entry overrides AM PM for same day', () {
    var history = [
      MilkYieldRecord(date: day, litres: 12, lactationDay: 1, milkingSession: 'AM'),
      MilkYieldRecord(date: day, litres: 10, lactationDay: 1, milkingSession: 'PM'),
    ];
    history = MilkRecordService.upsertRecord(
      history: history,
      record: MilkYieldRecord(
        date: day,
        litres: 25,
        lactationDay: 1,
        milkingSession: 'DAILY',
      ),
      session: MilkingSession.daily,
    );
    expect(MilkRecordService.totalLitresForDay(history, day), 25);
    expect(history.where((r) => r.milkingSession == 'AM'), isEmpty);
  });
}
