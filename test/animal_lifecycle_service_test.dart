import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/cull_reasons.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/nutrition_traffic_light.dart';

void main() {
  const lifecycle = AnimalLifecycleService();
  final base = Animal(
    id: '1',
    tag: 'T1',
    name: 'Test',
    species: Species.cattle,
    sex: 'F',
    breed: 'Holstein',
    weightKg: 400,
    ageLabel: '3y',
    groupId: 'g1',
    tags: [AnimalTagType.readyToBreed],
  );

  test('sell clears group and does not require cull', () {
    final sold = lifecycle.markSold(base);
    expect(sold.status, AnimalStatus.sold);
    expect(sold.groupId, isEmpty);
    expect(sold.tags, contains(AnimalTagType.sold));
  });

  test('cull flag is cleared when sold', () {
    final flagged = lifecycle.flagForCull(
      base,
      selection: CullReasonCatalog.defaultSelection,
    );
    final sold = lifecycle.markSold(flagged);
    expect(sold.tags, isNot(contains(AnimalTagType.cull)));
  });

  test('nutrition traffic light', () {
    expect(nutritionTrafficLight(5), NutritionTrafficLight.green);
    expect(nutritionTrafficLight(20), NutritionTrafficLight.orange);
    expect(nutritionTrafficLight(40), NutritionTrafficLight.red);
  });

  test('live calving resets months since calving and clears heifer', () {
    final pregnant = base.copyWith(
      tags: [AnimalTagType.pregnant],
      gestMonths: 8,
      isHeifer: true,
    );
    final calved = lifecycle.recordCalvingOutcome(
      pregnant,
      CalvingOutcome.bornLive,
    );
    expect(calved.monthsSinceCalving, 0);
    expect(calved.isHeifer, isFalse);
    expect(calved.tags, contains(AnimalTagType.lactating));
    expect(calved.tags, isNot(contains(AnimalTagType.pregnant)));
  });
}
