import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/animal_lactation_cycle.dart';
import 'package:greenerherd_mobile/data/mock/mock_seed_data.dart';
import 'package:greenerherd_mobile/data/services/lactation_seed_builder.dart';

void main() {
  test('todayLitresForCycle increases from close through mid then falls late', () {
    final early = LactationSeedBuilder.todayLitresForCycle(
      AnimalLactationCycle.cattleEarly,
      breed: 'Holstein',
    );
    final mid = LactationSeedBuilder.todayLitresForCycle(
      AnimalLactationCycle.cattleMid,
      breed: 'Holstein',
    );
    final late = LactationSeedBuilder.todayLitresForCycle(
      AnimalLactationCycle.cattleLate,
      breed: 'Holstein',
    );
    final close = LactationSeedBuilder.todayLitresForCycle(
      AnimalLactationCycle.cattleClose,
      breed: 'Holstein',
    );

    expect(mid, greaterThan(early));
    expect(mid, greaterThan(late));
    expect(late, greaterThan(close));
    expect(close, greaterThan(10));
  });

  test('lactationSeed covers all milking cattle stages in Milking A', () {
    final seed = MockSeedData.lactationSeed();
    expect(seed.cycles.keys, containsAll(['a2', 'a3', 'a4', 'a9', 'a10', 'a11']));

    final milking = MockSeedData.animals()
        .where((a) => a.groupId == 'g1' && a.lactationCycle != null)
        .toList();
    expect(milking.length, greaterThanOrEqualTo(6));

    final stages = milking.map((a) => a.lactationCycle).toSet();
    expect(stages, contains(AnimalLactationCycle.cattleEarly));
    expect(stages, contains(AnimalLactationCycle.cattleMid));
    expect(stages, contains(AnimalLactationCycle.cattleLate));
    expect(stages, contains(AnimalLactationCycle.cattleClose));

    for (final cow in milking) {
      final history = seed.history[cow.id];
      expect(history, isNotNull);
      expect(history, isNotEmpty);
      expect(cow.milkTodayLitres, closeTo(history!.last.litres, 0.05));
    }
  });
}
