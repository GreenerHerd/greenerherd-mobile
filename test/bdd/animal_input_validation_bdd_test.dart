import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/animal_input_validation.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  final refDay = DateTime(2026, 5, 17);
  late AnimalInputValidation validation;

  setUp(() {
    validation = AnimalInputValidation(referenceNow: refDay);
  });

  group('Feature: Animal input validation', () {
    bddDomainScenario(
      'Valid tag passes validation',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateTag('0999'),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'Empty tag is rejected',
      tags: ['negative'],
      body: () {
        final issues = validation.validateTag('   ');
        expect(issues, isNotEmpty);
        expect(issues.first.message, contains('Tag number is required'));
        expect(issues.first.code, AnimalValidationCode.tagEmpty);
      },
    );

    bddDomainScenario(
      'Duplicate tag is rejected',
      tags: ['negative'],
      body: () {
        final issues = validation.validateTag(
          '0438',
          existingTags: ['0438', '0444'],
        );
        expect(issues.first.code, AnimalValidationCode.tagDuplicate);
        expect(issues.first.message, contains('0438'));
      },
    );

    bddDomainScenario(
      'Valid cattle weight passes',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateWeightText('412', species: Species.cattle),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'Small calf weight passes',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateWeightText('45', species: Species.cattle),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'Zero weight is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('0', species: Species.cattle);
        expect(issues.first.code, AnimalValidationCode.weightNonPositive);
        expect(issues.first.message, contains('greater than zero'));
      },
    );

    bddDomainScenario(
      'Negative weight is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('-12', species: Species.cattle);
        expect(issues.first.code, AnimalValidationCode.weightNonPositive);
      },
    );

    bddDomainScenario(
      'Non-numeric weight is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('heavy', species: Species.cattle);
        expect(issues.first.code, AnimalValidationCode.weightNotANumber);
      },
    );

    bddDomainScenario(
      'Missing weight is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('', species: Species.cattle);
        expect(issues.first.code, AnimalValidationCode.weightMissing);
      },
    );

    bddDomainScenario(
      'Weight above cattle maximum is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('2000', species: Species.cattle);
        expect(issues.first.code, AnimalValidationCode.weightExceedsSpeciesMax);
      },
    );

    bddDomainScenario(
      'Weight above goat maximum is rejected',
      tags: ['negative'],
      body: () {
        final issues =
            validation.validateWeightText('250', species: Species.goat);
        expect(issues.first.code, AnimalValidationCode.weightExceedsSpeciesMax);
      },
    );

    bddDomainScenario(
      'Birth date in the past passes',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateDateOfBirth(
            DateTime(2020, 3, 15),
            species: Species.cattle,
          ),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'Birth date today passes',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateDateOfBirth(refDay, species: Species.cattle),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'Future birth date is rejected',
      tags: ['negative'],
      body: () {
        final issues = validation.validateDateOfBirth(
          DateTime(2026, 6, 1),
          species: Species.cattle,
        );
        expect(issues.first.code, AnimalValidationCode.dobInFuture);
        expect(issues.first.message, contains('future'));
      },
    );

    bddDomainScenario(
      'Implausibly old cattle birth date is rejected',
      tags: ['negative'],
      body: () {
        final issues = validation.validateDateOfBirth(
          DateTime(1990, 1, 1),
          species: Species.cattle,
        );
        expect(issues.first.code, AnimalValidationCode.dobTooOld);
      },
    );

    bddDomainScenario(
      'Implausibly old goat birth date is rejected',
      tags: ['negative'],
      body: () {
        final issues = validation.validateDateOfBirth(
          DateTime(2000, 1, 1),
          species: Species.goat,
        );
        expect(issues.first.code, AnimalValidationCode.dobTooOld);
      },
    );

    bddDomainScenario(
      'BCS 3.5 passes',
      tags: ['positive'],
      body: () {
        expect(validation.validateBcs(3.5), isEmpty);
      },
    );

    bddDomainScenario(
      'BCS at boundaries passes',
      tags: ['positive'],
      body: () {
        expect(validation.validateBcs(1.0), isEmpty);
        expect(validation.validateBcs(5.0), isEmpty);
      },
    );

    bddDomainScenario(
      'BCS below minimum is rejected',
      tags: ['negative'],
      body: () {
        expect(
          validation.validateBcs(0.5).first.code,
          AnimalValidationCode.bcsBelowMin,
        );
      },
    );

    bddDomainScenario(
      'BCS above maximum is rejected',
      tags: ['negative'],
      body: () {
        expect(
          validation.validateBcs(5.5).first.code,
          AnimalValidationCode.bcsAboveMax,
        );
      },
    );

    bddDomainScenario(
      'BCS not on half-step is rejected',
      tags: ['negative'],
      body: () {
        expect(
          validation.validateBcs(3.3).first.code,
          AnimalValidationCode.bcsNotHalfStep,
        );
      },
    );

    bddDomainScenario(
      'Complete valid new animal passes',
      tags: ['positive'],
      body: () {
        expect(
          validation.validateNewAnimal(
            tag: 'NEW1',
            weightText: '400',
            dob: DateTime(2022, 1, 10),
            species: Species.cattle,
            existingTags: const ['0438'],
          ),
          isEmpty,
        );
      },
    );

    bddDomainScenario(
      'New animal with negative weight and future DOB fails',
      tags: ['negative'],
      body: () {
        final issues = validation.validateNewAnimal(
          tag: 'NEW2',
          weightText: '-5',
          dob: DateTime(2027, 1, 1),
          species: Species.cattle,
          existingTags: const [],
        );
        expect(issues.length, greaterThanOrEqualTo(2));
        expect(
          issues.map((i) => i.code),
          containsAll([
            AnimalValidationCode.weightNonPositive,
            AnimalValidationCode.dobInFuture,
          ]),
        );
      },
    );

    bddDomainScenario(
      'Empty group name is rejected',
      tags: ['negative'],
      body: () {
        expect(
          validation.validateGroupName('  ').first.code,
          AnimalValidationCode.groupNameEmpty,
        );
      },
    );

    bddDomainScenario(
      'Lowercase group name is accepted after normalization',
      tags: ['positive'],
      body: () {
        expect(validation.validateGroupName('newbies'), isEmpty);
        expect(normalizeGroupName('newbies'), 'Newbies');
        expect(normalizeGroupName('  breeding herd '), 'Breeding herd');
      },
    );
  });
}
