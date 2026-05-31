import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Cross-screen animal navigation', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    Future<void> tapTab(WidgetTester tester, String label) async {
      final tab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text(label),
      );
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    bddScenario(
      'Young stock group animal opens profile without navigator errors',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpShellNavigation(
          tester,
          initialLocation: '/groups/g4',
        );
        await tapTab(tester, 'Animals');
        await tester.tap(find.textContaining('Yara').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.textContaining('0512'), findsWidgets);
      },
    );

    bddScenario(
      'Milking group animal opens profile from animals tab',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpShellNavigation(
          tester,
          initialLocation: '/groups/g1',
        );
        await tapTab(tester, 'Animals');
        await tester.tap(find.textContaining('Mona').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('0438'), findsWidgets);
      },
    );

    bddScenario(
      'Animals list opens weaning calf profile',
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
      'Opening two animals in sequence does not duplicate route keys',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpShellNavigation(
          tester,
          initialLocation: '/groups/g4',
        );
        await tapTab(tester, 'Animals');
        await tester.tap(find.textContaining('Yara').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Yara').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
