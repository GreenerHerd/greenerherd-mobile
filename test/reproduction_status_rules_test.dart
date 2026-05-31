import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/reproduction_status_rules.dart';

void main() {
  group('ReproductionStatusRules', () {
    test('males cannot be pregnant or lactating', () {
      expect(
        ReproductionStatusRules.canBePregnant(
          species: Species.cattle,
          sex: 'Male',
          ageMonths: 24,
        ),
        isFalse,
      );
      expect(
        ReproductionStatusRules.canLactate(
          species: Species.cattle,
          sex: 'Male',
          ageMonths: 24,
        ),
        isFalse,
      );
    });

    test('young females cannot be pregnant or lactating', () {
      expect(
        ReproductionStatusRules.canBePregnant(
          species: Species.cattle,
          sex: 'Female',
          ageMonths: 10,
        ),
        isFalse,
      );
      expect(
        ReproductionStatusRules.canBePregnant(
          species: Species.cattle,
          sex: 'Female',
          ageMonths: 15,
        ),
        isTrue,
      );
      expect(
        ReproductionStatusRules.canLactate(
          species: Species.goat,
          sex: 'Female',
          ageMonths: 6,
        ),
        isFalse,
      );
    });

    test('male goat and sheep may be ready to breed at breeding age', () {
      expect(
        ReproductionStatusRules.canMarkReadyToBreed(
          species: Species.goat,
          sex: 'Male',
          ageMonths: 10,
        ),
        isTrue,
      );
      expect(
        ReproductionStatusRules.showsBreedingStatusTab(
          Animal(
            id: 'g1',
            tag: 'G1',
            name: 'Buck',
            species: Species.goat,
            sex: 'M',
            breed: 'Boer',
            weightKg: 60,
            ageLabel: '10m',
            groupId: 'g',
          ),
        ),
        isTrue,
      );
      expect(
        ReproductionStatusRules.canMarkReadyToBreed(
          species: Species.sheep,
          sex: 'Male',
          ageMonths: 8,
        ),
        isTrue,
      );
      expect(
        ReproductionStatusRules.canMarkReadyToBreed(
          species: Species.cattle,
          sex: 'Male',
          ageMonths: 24,
        ),
        isFalse,
      );
    });
  });
}
