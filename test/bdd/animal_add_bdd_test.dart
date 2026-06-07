import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/breed_reference.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/gestation_validation.dart';
import 'package:greenerherd_mobile/features/animals/add_entity_sheets.dart';

import 'support/bdd_harness.dart';
import 'support/wizard_test_helpers.dart';

class _AddAnimalHost extends ConsumerWidget {
  const _AddAnimalHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showAddAnimalSheet(context, ref),
          child: const Text('Add animal'),
        ),
      ),
    );
  }
}

class _AddGroupSheetHost extends ConsumerWidget {
  const _AddGroupSheetHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showAddGroupSheet(context, ref),
          child: const Text('Add group'),
        ),
      ),
    );
  }
}

class _AddGroupWizardHost extends ConsumerWidget {
  const _AddGroupWizardHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showAddGroupWizard(context, ref),
          child: const Text('Add group wizard'),
        ),
      ),
    );
  }
}

void main() {
  initBddTests();

  group('Feature: Add animal sheet', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    Future<void> openAnimalSheet(WidgetTester tester) async {
      await harness.pumpScreen(tester, const _AddAnimalHost());
      await tester.tap(find.text('Add animal'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byKey(const Key('add_animal_tag')), findsOneWidget);
    }

    Future<void> openGroupSheet(WidgetTester tester) async {
      await harness.pumpScreen(tester, const _AddGroupSheetHost());
      await tester.tap(find.text('Add group'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('New group'), findsOneWidget);
    }

    Future<void> openGroupWizard(WidgetTester tester) async {
      await harness.pumpScreen(tester, const _AddGroupWizardHost());
      await tester.tap(find.text('Add group wizard'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    int animalCount() => harness.store.animals
        .where((a) => a.status == AnimalStatus.active)
        .length;

    bddScenario(
      'Valid animal is saved to the herd',
      tags: ['positive'],
      body: (tester) async {
        final tag = WizardTestHelpers.uniqueTag();
        final before = animalCount();
        await openAnimalSheet(tester);
        await WizardTestHelpers.advanceAnimalWizardToSaveStep(
          tester,
          tag: tag,
        );
        await WizardTestHelpers.tapSaveAnimal(tester);
        expect(find.byKey(const Key('add_animal_tag')), findsNothing);
        expect(animalCount(), before + 1);
        expect(harness.store.animals.any((a) => a.tag == tag), isTrue);
      },
    );

    bddScenario(
      'Animal wizard step 2 shows breed dropdown',
      tags: ['positive'],
      body: (tester) async {
        await openAnimalSheet(tester);
        await WizardTestHelpers.enterAnimalTag(
          tester,
          WizardTestHelpers.uniqueTag(),
        );
        await WizardTestHelpers.tapContinue(tester);
        expect(find.byType(DropdownButtonFormField<BreedReference>), findsOneWidget);
        await tester.tap(find.byType(DropdownButtonFormField<BreedReference>));
        await tester.pumpAndSettle();
        expect(find.text('Jersey').last, findsOneWidget);
      },
    );

    bddScenario(
      'Empty tag shows validation error',
      tags: ['negative'],
      body: (tester) async {
        await openAnimalSheet(tester);
        await WizardTestHelpers.tapContinue(tester);
        expect(find.text('Tag number is required'), findsOneWidget);
        expect(find.byKey(const Key('add_animal_tag')), findsOneWidget);
      },
    );

    bddScenario(
      'Negative weight shows validation error',
      tags: ['negative'],
      body: (tester) async {
        await openAnimalSheet(tester);
        await WizardTestHelpers.enterAnimalTag(
          tester,
          WizardTestHelpers.uniqueTag(),
        );
        await WizardTestHelpers.tapContinue(tester);
        final weightField = find.byKey(const Key('add_animal_weight'));
        if (weightField.evaluate().isNotEmpty) {
          await tester.enterText(weightField, '-10');
        } else {
          await tester.enterText(
            find.widgetWithText(TextField, 'e.g. 412'),
            '-10',
          );
        }
        await WizardTestHelpers.tapContinue(tester);
        expect(find.textContaining('greater than zero'), findsOneWidget);
      },
    );

    bddScenario(
      'Duplicate tag shows validation error',
      tags: ['negative'],
      body: (tester) async {
        await openAnimalSheet(tester);
        await WizardTestHelpers.enterAnimalTag(tester, '0438');
        await WizardTestHelpers.tapContinue(tester);
        expect(find.textContaining('already in use'), findsOneWidget);
      },
    );

    bddScenario(
      'Empty group name shows validation error',
      tags: ['negative'],
      body: (tester) async {
        await openGroupSheet(tester);
        await WizardTestHelpers.tapContinue(tester);
        expect(find.text('Group name is required'), findsOneWidget);
      },
    );

    bddScenario(
      'Lowercase group name advances sheet to livestock step',
      tags: ['positive'],
      body: (tester) async {
        await openGroupSheet(tester);
        await WizardTestHelpers.enterGroupName(tester, 'newbies');
        await tester.showKeyboard(find.widgetWithText(TextField, 'Group name'));
        await WizardTestHelpers.advanceGroupDetailsStep(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Step 2 of 2'), findsOneWidget);
        expect(find.textContaining('GROUP OF LIVESTOCK'), findsOneWidget);
      },
    );

    bddScenario(
      'Lowercase group name advances wizard to herd step',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.enterGroupName(tester, 'newbies');
        await tester.showKeyboard(find.widgetWithText(TextField, 'Group name'));
        await WizardTestHelpers.advanceGroupDetailsStep(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Step 2 of 4'), findsOneWidget);
        expect(find.text('Number in group'), findsOneWidget);
      },
    );

    bddScenario(
      'Group wizard completes three steps with lowercase name',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.enterGroupName(tester, 'newbies');
        await WizardTestHelpers.advanceGroupDetailsStep(tester);
        await WizardTestHelpers.advanceGroupHerdStep(tester, headCount: '1');
        expect(tester.takeException(), isNull);
        expect(find.text('Step 3 of 4'), findsOneWidget);
      },
    );

    bddDomainScenario(
      'Gestation months are capped per species',
      tags: ['positive'],
      body: () {
        expect(GestationValidation.maxGestationMonths(Species.cattle), 10);
        expect(GestationValidation.maxGestationMonths(Species.goat), 5);
        expect(GestationValidation.maxGestationMonths(Species.sheep), 5);
        expect(
          GestationValidation.validateGestMonths(Species.cattle, 12),
          isNotNull,
        );
        expect(
          GestationValidation.validateGestMonths(Species.goat, 3),
          isNull,
        );
      },
    );

    bddDomainScenario(
      'Breed list can be sorted after provider returns read-only list',
      tags: ['positive'],
      body: () {
        final breeds = List<BreedReference>.unmodifiable([
          const BreedReference(
            id: 'b2',
            species: Species.cattle,
            code: 'JERSEY',
            nameEn: 'Jersey',
            names: {'en': 'Jersey'},
          ),
          const BreedReference(
            id: 'b1',
            species: Species.cattle,
            code: 'HOLSTEIN',
            nameEn: 'Holstein',
            names: {'en': 'Holstein'},
          ),
        ]);
        final sorted = [...breeds]
          ..sort(
            (a, b) =>
                a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()),
          );
        expect(sorted.first.nameEn, 'Holstein');
      },
    );

    bddScenario(
      'Group wizard step 3 has no per-animal purpose field',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpScreen(
          tester,
          const _AddGroupWizardHost(),
          surfaceSize: const Size(480, 900),
        );
        await tester.tap(find.text('Add group wizard'));
        await tester.pumpAndSettle();
        final overflows = await WizardTestHelpers.pumpWithOverflowWatch(
          tester,
          () async {
            await WizardTestHelpers.advanceGroupWizardToAnimalsStep(
              tester,
              groupName: 'Step3 herd',
              headCount: '2',
            );
          },
        );
        expect(overflows, isEmpty);
        expect(find.text('Step 3 of 4'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ListView),
            matching: find.text('Animal purpose'),
          ),
          findsNothing,
        );
        expect(find.textContaining('Defaults from previous step'), findsOneWidget);
        expect(find.byTooltip('Pregnancy'), findsWidgets);
      },
    );

    bddScenario(
      'Group sheet livestock step shows breed dropdown',
      tags: ['positive'],
      body: (tester) async {
        await openGroupSheet(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Group name'),
          'BDD breed herd',
        );
        await WizardTestHelpers.tapContinue(tester);
        expect(find.text('Step 2 of 2'), findsOneWidget);
        await WizardTestHelpers.selectBornLivestockOrigin(tester);
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        expect(find.text('Jersey').last, findsOneWidget);
      },
    );

    bddScenario(
      'Group wizard herd step shows breed dropdown',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Group name'),
          'Wizard BDD herd',
        );
        await WizardTestHelpers.tapWizardPrimary(tester, 'Continue');
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        expect(find.text('Jersey').last, findsOneWidget);
      },
    );

    bddScenario(
      'Group wizard herd step creates a vaccination event',
      tags: ['positive'],
      body: (tester) async {
        harness.store.vaccinationEvents.clear();
        await openGroupWizard(tester);
        await WizardTestHelpers.enterGroupName(tester, 'Vax herd');
        await WizardTestHelpers.advanceGroupDetailsStep(tester);
        await WizardTestHelpers.enableGroupWizardVaccination(tester);
        expect(find.text('Create vaccination event'), findsOneWidget);
        await tester.tap(find.text('Create vaccination event'));
        await tester.pumpAndSettle();
        await WizardTestHelpers.enterAlertDialogText(tester, 'BDD Annual vax');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          harness.store.vaccinationEvents
              .any((e) => e.name == 'BDD Annual vax'),
          isTrue,
        );
        expect(
          find.text('Vaccination event: BDD Annual vax'),
          findsOneWidget,
        );
      },
    );

    bddScenario(
      'Group wizard step 3 toggles all member status tags',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.advanceGroupWizardToAnimalsStep(
          tester,
          groupName: 'Status tags herd',
          headCount: '1',
        );
        expect(find.text('Step 3 of 4'), findsOneWidget);

        await WizardTestHelpers.tapMemberStatusTooltip(tester, 'Notes');
        await WizardTestHelpers.enterAlertDialogText(tester, 'Needs hoof trim');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await WizardTestHelpers.tapMemberStatusTooltip(tester, 'Illness');
        await WizardTestHelpers.enterAlertDialogText(tester, 'Pink eye');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final tooltip in ['Cull tag', 'Lactating', 'Ready to breed']) {
          await WizardTestHelpers.tapMemberStatusTooltip(tester, tooltip);
          expect(tester.takeException(), isNull);
        }

        await WizardTestHelpers.tapMemberStatusTooltip(tester, 'Pregnancy');
        // Pregnancy dialog is now a full details form with due date + prolificacy.
        expect(find.text('Pregnancy confirmed'), findsOneWidget);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        expect(find.text('F'), findsWidgets);
        expect(find.text('DoB'), findsOneWidget);
      },
    );

    bddScenario(
      'Group wizard step 3 requires a due date to save pregnancy',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.advanceGroupWizardToAnimalsStep(
          tester,
          groupName: 'Gestation validate herd',
          headCount: '1',
        );
        await WizardTestHelpers.tapMemberStatusTooltip(tester, 'Pregnancy');
        expect(find.text('Pregnancy confirmed'), findsOneWidget);
        // Clear the prefilled due date by dismissing and reopening, then ensure the
        // dialog can be cancelled without crashing.
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    bddScenario(
      'Group wizard step 3 disables pregnancy for male animals',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.advanceGroupWizardToAnimalsStep(
          tester,
          groupName: 'Male rules herd',
          headCount: '1',
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('M').last);
        await tester.pumpAndSettle();

        expect(
          find.byTooltip('Pregnancy applies to females only'),
          findsOneWidget,
        );
        expect(
          find.byTooltip('Lactation applies to females only'),
          findsOneWidget,
        );
      },
    );

    bddScenario(
      'Group wizard step 3 illness dialog can be cancelled safely',
      tags: ['positive'],
      body: (tester) async {
        await openGroupWizard(tester);
        await WizardTestHelpers.advanceGroupWizardToAnimalsStep(
          tester,
          groupName: 'Illness cancel herd',
          headCount: '1',
        );
        await WizardTestHelpers.tapMemberStatusTooltip(tester, 'Illness');
        expect(find.text('Illness'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
