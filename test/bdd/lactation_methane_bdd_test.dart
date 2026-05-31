import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/features/groups/group_detail_screen.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Lactation history and methane on nutrition', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    bddScenario(
      'Nutrition tab shows methane emissions for milking group',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpScreen(tester, const GroupDetailScreen(groupId: 'g1'));
        await tester.tap(
          find.descendant(of: find.byType(TabBar), matching: find.text('Nutrition')),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('Methane emissions'), findsOneWidget);
        expect(find.text('Emissions total'), findsOneWidget);
        expect(find.textContaining('g'), findsWidgets);
        expect(find.textContaining('CO₂e'), findsWidgets);
      },
    );

    bddScenario(
      'Mona animal profile shows lactation cycle and milk history chart',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpAnimalProfile(tester, animalId: 'a2', tabIndex: 3);
        expect(find.textContaining('Lactation 3'), findsOneWidget);
        expect(find.text('Lactation curve (milk vs day in milk)'), findsOneWidget);
        expect(find.byType(LineChart), findsOneWidget);
      },
    );

    bddDomainScenario(
      'Mona seed history includes mid-lactation records',
      tags: ['positive'],
      body: () {
        final history = harness.store.milkHistoryFor('a2');
        expect(history.length, greaterThan(10));
        expect(history.any((r) => r.lactationDay > 100), isTrue);
        expect(history.any((r) => r.litres > 15), isTrue);
        final cycle = harness.store.lactationCycleFor('a2');
        expect(cycle, isNotNull);
        expect(cycle!.cycleNumber, 3);
      },
    );
  });
}
