import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/core/persistence/entity_json_codec.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';

void main() {
  const lifecycle = AnimalLifecycleService();
  const base = Animal(
    id: '1',
    tag: 'T1',
    name: 'Bess',
    species: Species.cattle,
    sex: 'F',
    breed: 'Holstein',
    weightKg: 500,
    ageLabel: '3y',
    groupId: 'g1',
  );

  final treatment = AnimalTreatmentDetails(
    medicineName: 'Penicillin G',
    dosage: '5 ml IM',
    frequency: TreatmentFrequency.daily,
    administeredBy: 'Dr Smith',
    administeredDate: DateTime(2026, 3, 1),
    milkWithdrawalDays: 3,
    meatWithdrawalDays: 7,
    notes: 'Complete course',
    batchNumber: 'LOT-99',
    sourceLabel: 'In stock',
  );

  test('displaySummary combines medicine dosage and frequency', () {
    expect(
      treatment.displaySummary(),
      contains('Penicillin G'),
    );
    expect(treatment.displaySummary(), contains('daily'));
  });

  test('maxWithdrawalDays uses the larger of milk and meat', () {
    expect(treatment.maxWithdrawalDays, 7);
    expect(
      AnimalTreatmentDetails(
        medicineName: 'X',
        dosage: '1 ml',
        frequency: TreatmentFrequency.once,
        administeredBy: 'A',
        administeredDate: DateTime(2026, 1, 1),
        milkWithdrawalDays: 5,
      ).maxWithdrawalDays,
      5,
    );
  });

  test('milk and meat safe dates are computed from administered date', () {
    expect(
      treatment.milkSafeDate(Species.cattle),
      DateTime(2026, 3, 4),
    );
    expect(
      treatment.meatSafeDate(Species.cattle),
      DateTime(2026, 3, 8),
    );
  });

  test('json round-trip preserves treatment fields', () {
    final json = treatment.toJson();
    final restored = AnimalTreatmentDetails.fromJson(json);
    expect(restored.medicineName, treatment.medicineName);
    expect(restored.dosage, treatment.dosage);
    expect(restored.frequency, TreatmentFrequency.daily);
    expect(restored.milkWithdrawalDays, 3);
    expect(restored.batchNumber, 'LOT-99');
  });

  test('TreatmentFrequency wire encoding', () {
    expect(TreatmentFrequency.daily.wire, 'DAILY');
    expect(TreatmentFrequency.fromWire('WEEKLY'), TreatmentFrequency.weekly);
    expect(TreatmentFrequency.fromWire('invalid'), isNull);
  });

  test('recordTreatment stores details and withdrawal on animal', () {
    final sick = lifecycle.recordTreatment(
      base,
      illnessNote: 'Mastitis',
      treatment: treatment,
    );
    expect(sick.isSick, isTrue);
    expect(sick.illnessNote, 'Mastitis');
    expect(sick.treatmentDetails?.medicineName, 'Penicillin G');
    expect(sick.withdrawalDays, 7);
    expect(sick.treatmentNote, contains('Penicillin G'));
  });

  test('EntityJsonCodec round-trips treatment_details on animals', () {
    final sick = lifecycle.recordTreatment(
      base,
      illnessNote: 'Pink eye',
      treatment: treatment,
    );
    final json = EntityJsonCodec.encodeAnimal(sick);
    final restored = EntityJsonCodec.decodeAnimal(json);
    expect(restored.treatmentDetails?.medicineName, 'Penicillin G');
    expect(restored.withdrawalDays, 7);
    expect(restored.illnessNote, 'Pink eye');
  });

  test('markCured clears treatment and withdrawal', () {
    final sick = lifecycle.recordTreatment(
      base,
      illnessNote: 'Mastitis',
      treatment: treatment,
    );
    final cured = lifecycle.markCured(sick);
    expect(cured.isSick, isFalse);
    expect(cured.treatmentDetails, isNull);
    expect(cured.withdrawalDays, 0);
  });
}
