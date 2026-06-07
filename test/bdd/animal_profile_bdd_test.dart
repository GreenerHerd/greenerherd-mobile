import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Animal profile interactions', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    Future<void> tapProfileTab(WidgetTester tester, String label) async {
      final tab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text(label),
      );
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    bddScenario(
      'Profile tabs switch without errors',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'a2');
        for (final tab in [
          'Weight',
          'Breeding',
          'Milking',
          'Health',
          'Tasks',
        ]) {
          await tapProfileTab(tester, tab);
          expect(tester.takeException(), isNull);
        }
        await tapProfileTab(tester, 'Overview');
        expect(find.text('Ear tag'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    bddScenario(
      'Lactating animal shows record milk quick action',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'a2');
        expect(find.text('Record milk'), findsOneWidget);
        await tester.tap(find.text('Record milk'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    bddScenario(
      'Animal purpose dropdown is editable on overview',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'a2');
        expect(
          find.byType(DropdownButtonFormField<SpeciesPurpose>),
          findsOneWidget,
        );
        await tester.tap(
          find.byType(DropdownButtonFormField<SpeciesPurpose>),
        );
        await tester.pumpAndSettle();
        expect(find.text('Milk').last, findsOneWidget);
        await tester.tap(find.text('Milk').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    bddScenario(
      'Record milk quick action opens record milk',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'a2');
        await tester.tap(find.text('Record milk'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    bddScenario(
      'Health tab record treatment opens treatment form',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'c1');
        await tapProfileTab(tester, 'Health');
        await tester.tap(find.widgetWithText(OutlinedButton, 'Update treatment'));
        await tester.pumpAndSettle();
        await tester.tap(find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Update treatment'),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Illness / symptoms'), findsOneWidget);
        expect(find.text('Select a medicine'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
