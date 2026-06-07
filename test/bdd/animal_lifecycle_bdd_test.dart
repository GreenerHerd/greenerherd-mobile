import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/breeding_methods.dart';
import 'package:greenerherd_mobile/data/models/cull_reasons.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  const lifecycle = AnimalLifecycleService();
  const cullSelection =
      CullReasonSelection(type: 'Health', reason: 'Injury');
  const deathSelection =
      CullReasonSelection(type: 'Health', reason: 'Metabolic');

  Animal cow({
    String sex = 'F',
    List<AnimalTagType> tags = const [],
    AnimalStatus status = AnimalStatus.active,
    int? withdrawalDays,
    double? milkTodayLitres,
  }) =>
      Animal(
        id: 'bdd-1',
        tag: 'T99',
        name: 'BDD Cow',
        species: Species.cattle,
        sex: sex,
        breed: 'Holstein',
        weightKg: 400,
        ageLabel: '4y',
        groupId: 'g1',
        tags: tags,
        status: status,
        withdrawalDays: withdrawalDays,
        milkTodayLitres: milkTodayLitres,
      );

  group('Feature: Animal lifecycle rules', () {
    bddDomainScenario(
      'Cull flag can be added to active animal',
      tags: ['positive'],
      body: () {
        final updated = lifecycle.flagForCull(
          cow(tags: [AnimalTagType.readyToBreed]),
          selection: cullSelection,
        );
        expect(updated.tags, contains(AnimalTagType.cull));
        expect(updated.cullType, 'Health');
        expect(updated.cullReason, 'Injury');
      },
    );

    bddDomainScenario(
      'Active animal can be marked sold without cull flag',
      tags: ['positive'],
      body: () {
        final sold = lifecycle.markSold(cow());
        expect(sold.status, AnimalStatus.sold);
        expect(sold.tags, contains(AnimalTagType.sold));
        expect(sold.groupId, isEmpty);
      },
    );

    bddDomainScenario(
      'Cull-flagged animal can be marked sold',
      tags: ['positive'],
      body: () {
        final flagged = lifecycle.flagForCull(cow(), selection: cullSelection);
        final sold = lifecycle.markSold(flagged);
        expect(sold.status, AnimalStatus.sold);
        expect(sold.tags, contains(AnimalTagType.sold));
        expect(sold.tags, isNot(contains(AnimalTagType.cull)));
      },
    );

    bddDomainScenario(
      'Sold animal can be returned to active',
      tags: ['positive'],
      body: () {
        final sold = lifecycle.markSold(
          lifecycle.flagForCull(cow(), selection: cullSelection),
        );
        final restored = lifecycle.undoSale(sold);
        expect(restored.status, AnimalStatus.active);
        expect(restored.tags, isNot(contains(AnimalTagType.sold)));
      },
    );

    bddDomainScenario(
      'Female can be marked ready to breed',
      tags: ['positive'],
      body: () {
        final updated = lifecycle.markReadyToBreed(
          cow(),
          method: BreedingMethod.ai,
        );
        expect(updated.tags, contains(AnimalTagType.readyToBreed));
        expect(updated.breedingMethod, BreedingMethod.ai);
      },
    );

    bddDomainScenario(
      'Live birth adds lactating without duplicate',
      tags: ['positive'],
      body: () {
        final pregnant = cow(tags: [AnimalTagType.pregnant]);
        final once = lifecycle.recordCalvingOutcome(
          pregnant,
          CalvingOutcome.bornLive,
        );
        expect(once.tags.where((t) => t == AnimalTagType.lactating).length, 1);
        final twice = lifecycle.recordCalvingOutcome(
          once,
          CalvingOutcome.bornLive,
        );
        expect(
          twice.tags.where((t) => t == AnimalTagType.lactating).length,
          1,
        );
      },
    );

    bddDomainScenario(
      'Stillborn does not add lactating',
      tags: ['positive'],
      body: () {
        final updated = lifecycle.recordCalvingOutcome(
          cow(tags: [AnimalTagType.pregnant]),
          CalvingOutcome.stillborn,
        );
        expect(updated.tags, contains(AnimalTagType.stillborn));
        expect(updated.tags, isNot(contains(AnimalTagType.lactating)));
      },
    );

    bddDomainScenario(
      'Cannot cull a sold animal',
      tags: ['negative'],
      body: () {
        final sold = lifecycle.markSold(
          lifecycle.flagForCull(cow(), selection: cullSelection),
        );
        expect(
          () => lifecycle.flagForCull(sold, selection: cullSelection),
          throwsA(isA<StateError>()),
        );
      },
    );

    bddDomainScenario(
      'Cannot sell an animal that is already sold',
      tags: ['negative'],
      body: () {
        final sold = lifecycle.markSold(cow());
        expect(
          () => lifecycle.markSold(sold),
          throwsA(isA<StateError>()),
        );
      },
    );

    bddDomainScenario(
      'Bull cattle cannot be marked ready to breed',
      tags: ['negative'],
      body: () {
        expect(
          () => lifecycle.markReadyToBreed(cow(sex: 'M')),
          throwsA(isA<StateError>()),
        );
      },
    );

    bddDomainScenario(
      'Pregnant cow cannot be marked ready to breed',
      tags: ['negative'],
      body: () {
        expect(
          () => lifecycle.markReadyToBreed(
            cow(tags: [AnimalTagType.pregnant]),
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    bddDomainScenario(
      'Milk is blocked during withdrawal',
      tags: ['negative'],
      body: () {
        final animal = cow(
          tags: [AnimalTagType.lactating],
          withdrawalDays: 5,
          milkTodayLitres: 10,
        );
        expect(lifecycle.canRecordMilk(animal), isTrue);
        expect(lifecycle.milkBlockedByWithdrawal(animal), isTrue);
      },
    );

    bddDomainScenario(
      'Milk allowed when lactating and no withdrawal',
      tags: ['positive'],
      body: () {
        final animal = cow(
          tags: [AnimalTagType.lactating],
          withdrawalDays: 0,
        );
        expect(lifecycle.canRecordMilk(animal), isTrue);
        expect(lifecycle.milkBlockedByWithdrawal(animal), isFalse);
      },
    );

    bddDomainScenario(
      'Male sheep can be marked ready to breed',
      tags: ['positive'],
      body: () {
        const ram = Animal(
          id: 's1',
          tag: 'S100',
          name: 'Ram',
          species: Species.sheep,
          sex: 'M',
          breed: 'Najdi',
          weightKg: 80,
          ageLabel: '3y',
          groupId: 'g-s',
        );
        final updated = lifecycle.markReadyToBreed(
          ram,
          method: BreedingMethod.natural,
        );
        expect(updated.tags, contains(AnimalTagType.readyToBreed));
      },
    );

    bddDomainScenario(
      'Breeding group purpose marks eligible animals ready to breed',
      tags: ['positive'],
      body: () {
        const ewe = Animal(
          id: 'bdd-sheep',
          tag: 'S1',
          name: 'Ewe',
          species: Species.sheep,
          sex: 'F',
          breed: 'Najdi',
          weightKg: 50,
          ageLabel: '18m',
          groupId: 'g1',
        );
        final updated = lifecycle.applyBreedingGroupPurpose(
          ewe,
          GroupPurpose.breeding,
        );
        expect(updated.tags, contains(AnimalTagType.readyToBreed));
        expect(updated.breedingMethod, BreedingMethod.natural);

        final bull = cow(sex: 'M', tags: const []);
        final unchanged = lifecycle.applyBreedingGroupPurpose(
          bull,
          GroupPurpose.breeding,
        );
        expect(unchanged.tags, isNot(contains(AnimalTagType.readyToBreed)));

        final milkGroup = lifecycle.applyBreedingGroupPurpose(
          ewe.copyWith(tags: const []),
          GroupPurpose.milk,
        );
        expect(milkGroup.tags, isNot(contains(AnimalTagType.readyToBreed)));
      },
    );

    bddDomainScenario(
      'Treatment marks sick and cure clears sick',
      tags: ['positive'],
      body: () {
        final sick = lifecycle.recordTreatment(
          cow(),
          illnessNote: 'Mastitis',
          treatment: AnimalTreatmentDetails(
            medicineName: 'Penicillin G',
            dosage: '5 ml IM',
            frequency: TreatmentFrequency.daily,
            administeredBy: 'Test vet',
            administeredDate: DateTime(2026, 1, 1),
            milkWithdrawalDays: 3,
            meatWithdrawalDays: 7,
          ),
        );
        expect(sick.tags, contains(AnimalTagType.sick));
        final cured = lifecycle.markCured(sick);
        expect(cured.tags, isNot(contains(AnimalTagType.sick)));
      },
    );

    bddDomainScenario(
      'Death removes animal from group and stores reason',
      tags: ['positive'],
      body: () {
        final deceased = lifecycle.markDeceased(
          cow(tags: [AnimalTagType.sick, AnimalTagType.pregnant]),
          selection: deathSelection,
        );
        expect(deceased.status, AnimalStatus.deceased);
        expect(deceased.groupId, isEmpty);
        expect(deceased.cullType, 'Health');
        expect(deceased.cullReason, 'Metabolic');
        expect(deceased.deathReason, deathSelection.label);
        expect(deceased.tags, isNot(contains(AnimalTagType.sick)));
        expect(deceased.tags, isNot(contains(AnimalTagType.pregnant)));
      },
    );
  });
}
