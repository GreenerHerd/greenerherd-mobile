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

    test('breeding cycle KPI shows for lactating cows and hides for heifers', () {
      final lactating = Animal(
        id: 'c1',
        tag: 'C1',
        name: 'Cow',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'g',
        tags: [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      );
      expect(ReproductionStatusRules.showsBreedingCycleKpi(lactating), isTrue);
      expect(ReproductionStatusRules.effectiveMonthsSinceCalving(lactating), 5);

      final heifer = lactating.copyWith(
        isHeifer: true,
        clearMonthsSinceCalving: true,
        tags: const [],
      );
      expect(ReproductionStatusRules.showsBreedingCycleKpi(heifer), isFalse);
    });

    test('re-breeding eligibility respects voluntary waiting period', () {
      final fresh = Animal(
        id: 'c2',
        tag: 'C2',
        name: 'Fresh',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'g',
        tags: [AnimalTagType.lactating],
        monthsSinceCalving: 0,
      );
      expect(ReproductionStatusRules.isEligibleForNextBreeding(fresh), isFalse);

      final ready = fresh.copyWith(monthsSinceCalving: 2);
      expect(ReproductionStatusRules.isEligibleForNextBreeding(ready), isTrue);

      final pregnant = ready.copyWith(
        tags: [AnimalTagType.lactating, AnimalTagType.pregnant],
      );
      expect(
        ReproductionStatusRules.isEligibleForNextBreeding(pregnant),
        isFalse,
      );

      final marked = fresh.copyWith(
        tags: [AnimalTagType.lactating, AnimalTagType.readyToBreed],
      );
      expect(ReproductionStatusRules.isEligibleForNextBreeding(marked), isTrue);
    });

    test('lactation stage keys map months since calving', () {
      expect(ReproductionStatusRules.lactationStageKey(0), 'fresh');
      expect(ReproductionStatusRules.lactationStageKey(2), 'peak');
      expect(ReproductionStatusRules.lactationStageKey(5), 'mid');
      expect(ReproductionStatusRules.lactationStageKey(8), 'late');
    });

    test('needsReadyToBreedTag when past waiting period and not tagged', () {
      final eligible = Animal(
        id: 'c1',
        tag: 'C1',
        name: 'Cow',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'g',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      );
      expect(ReproductionStatusRules.needsReadyToBreedTag(eligible), isTrue);

      final tagged = eligible.copyWith(
        tags: [AnimalTagType.lactating, AnimalTagType.readyToBreed],
      );
      expect(ReproductionStatusRules.needsReadyToBreedTag(tagged), isFalse);

      final waiting = eligible.copyWith(monthsSinceCalving: 1);
      expect(ReproductionStatusRules.needsReadyToBreedTag(waiting), isFalse);
    });
  });
}
