import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/features/groups/group_detail_screen.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Multilingual UI', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    bddScenario(
      'Arabic locale shows Arabic nutrition and methane labels',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpScreen(
          tester,
          const GroupDetailScreen(groupId: 'g1'),
          locale: const Locale('ar'),
        );
        await tester.tap(find.text('التغذية'));
        await tester.pumpAndSettle();
        expect(find.text('اليوم مقابل الاحتياج'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('انبعاثات الميثان'), findsOneWidget);
        expect(find.text('متوسط المجموعة'), findsOneWidget);
      },
    );

    bddScenario(
      'French locale shows French nutrition tab on group detail',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpScreen(
          tester,
          const GroupDetailScreen(groupId: 'g1'),
          locale: const Locale('fr'),
        );
        await tester.tap(
          find.descendant(of: find.byType(TabBar), matching: find.text('Nutrition')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Aujourd\'hui vs besoins'), findsOneWidget);
      },
    );

    bddScenario(
      'Urdu locale shows Urdu methane card after scroll',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpScreen(
          tester,
          const GroupDetailScreen(groupId: 'g1'),
          locale: const Locale('ur'),
        );
        await tester.tap(
          find.descendant(of: find.byType(TabBar), matching: find.text('غذائیت')),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('میتھین اخراج'), findsOneWidget);
        expect(find.text('گروپ اوسط'), findsOneWidget);
      },
    );
  });
}
