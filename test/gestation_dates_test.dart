import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/gestation_dates.dart';

void main() {
  test('prolificacy options are 1 through 4 with default 1', () {
    expect(GestationDates.prolificacyOptions, [1, 2, 3, 4]);
    expect(GestationDates.defaultProlificacy, 1);
  });

  test('clampProlificacy bounds invalid values to default', () {
    expect(GestationDates.clampProlificacy(0), 1);
    expect(GestationDates.clampProlificacy(9), 1);
    expect(GestationDates.clampProlificacy(3), 3);
  });

  test('effectiveProlificacy prefers stored value then twin flag', () {
    const withValue = Animal(
      id: 'a',
      tag: '1',
      name: '',
      species: Species.goat,
      sex: 'F',
      breed: 'Boer',
      weightKg: 40,
      ageLabel: '2y',
      groupId: 'g',
      prolificacy: 3,
    );
    expect(GestationDates.effectiveProlificacy(withValue), 3);

    const twinLegacy = Animal(
      id: 'b',
      tag: '2',
      name: '',
      species: Species.sheep,
      sex: 'F',
      breed: 'Suffolk',
      weightKg: 50,
      ageLabel: '2y',
      groupId: 'g',
      isTwin: true,
    );
    expect(GestationDates.effectiveProlificacy(twinLegacy), 2);

    const unset = Animal(
      id: 'c',
      tag: '3',
      name: '',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 500,
      ageLabel: '3y',
      groupId: 'g',
    );
    expect(GestationDates.effectiveProlificacy(unset), 1);
  });

  test('due date and gest months are reciprocal for cattle', () {
    final ref = DateTime(2026, 6, 1);
    final due = GestationDates.dueDateFromGestMonths(
      Species.cattle,
      5,
      ref,
    );
    final months = GestationDates.gestMonthsFromDueDate(
      Species.cattle,
      due,
      ref,
    );
    expect(months, 5);
  });
}
