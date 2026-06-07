import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/cull_reasons.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/nutrition_traffic_light.dart';

void main() {
  const lifecycle = AnimalLifecycleService();
  const base = Animal(
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

  test('recordTreatment applies sick tag and withdrawal days', () {
    final treatment = AnimalTreatmentDetails(
      medicineName: 'Oxytetracycline',
      dosage: '10 ml',
      frequency: TreatmentFrequency.once,
      administeredBy: 'Vet',
      administeredDate: DateTime(2026, 1, 15),
      milkWithdrawalDays: 4,
      meatWithdrawalDays: 0,
    );
    final sick = lifecycle.recordTreatment(
      base,
      illnessNote: 'Lameness',
      treatment: treatment,
    );
    expect(sick.tags, contains(AnimalTagType.sick));
    expect(sick.withdrawalDays, 4);
    expect(sick.treatmentDetails?.medicineName, 'Oxytetracycline');
    final cured = lifecycle.markCured(sick);
    expect(cured.tags, isNot(contains(AnimalTagType.sick)));
    expect(cured.withdrawalDays, 0);
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
    // Default post-calving cycle for cattle is early lactation (month 1).
    expect(calved.monthsSinceCalving, 1);
    expect(calved.isHeifer, isFalse);
    expect(calved.tags, contains(AnimalTagType.lactating));
    expect(calved.tags, isNot(contains(AnimalTagType.pregnant)));
  });
}
