import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Animals list interactions', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    bddScenario(
      'Tag filter chips toggle without errors',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalsList(tester);
        final tagFilterRow = find.byType(SingleChildScrollView).at(1);
        final pregnantChip = find.descendant(
          of: tagFilterRow,
          matching: find.text('Pregnant'),
        );
        expect(pregnantChip, findsOneWidget);
        await tester.tap(pregnantChip);
        await tester.pumpAndSettle();
        expect(
          refOf(tester).read(selectedAnimalTagFilterProvider),
          AnimalTagType.pregnant,
        );
        await tester.tap(find.text('Any status'));
        await tester.pumpAndSettle();
        expect(refOf(tester).read(selectedAnimalTagFilterProvider), isNull);
      },
    );

    bddScenario(
      'Animal row opens profile',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalsList(tester);
        await tester.tap(find.textContaining('Mona').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.textContaining('0438'), findsWidgets);
      },
    );

    bddScenario(
      'Weaning filter then animal opens profile',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalsList(tester);
        await tapAnimalsTagFilterChip(tester, 'Weaning');
        await tester.tap(find.textContaining('Yara').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Overview'), findsOneWidget);
      },
    );

    bddScenario(
      'Species filter chips switch list',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalsList(tester);
        await tester.tap(find.textContaining('Goat').first);
        await tester.pumpAndSettle();
        expect(
          refOf(tester).read(selectedSpeciesFilterProvider),
          Species.goat,
        );
      },
    );
  });
}

/// Reads Riverpod state from the widget under test.
ProviderContainer refOf(WidgetTester tester) {
  final element = tester.element(find.byType(MaterialApp).first);
  return ProviderScope.containerOf(element);
}
