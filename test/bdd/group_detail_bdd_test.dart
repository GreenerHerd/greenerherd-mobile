import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/features/groups/group_detail_screen.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Group detail tabs', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    Future<void> openGroup(tester, String groupId) async {
      await harness.pumpScreen(
        tester,
        GroupDetailScreen(groupId: groupId),
      );
    }

    Future<void> tapTab(tester, String label) async {
      final tab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text(label),
      );
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    bddScenario(
      'Milking group shows expected tabs',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        for (final tab in [
          'Overview',
          'Animals',
          'Nutrition',
          'Milking',
          'Health',
        ]) {
          expect(
            find.descendant(of: find.byType(TabBar), matching: find.text(tab)),
            findsOneWidget,
          );
        }
      },
    );

    bddScenario(
      'Overview shows purpose, milking KPIs, and nutrition summary',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        expect(find.text('PURPOSE'), findsOneWidget);
        expect(find.text('Milking KPIs'), findsOneWidget);
        expect(find.text('Nutrition'), findsWidgets);
      },
    );

    bddScenario(
      'Nutrition tab shows today vs requirement and feed',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        await tapTab(tester, 'Nutrition');
        expect(find.text('Today v Required Nutrition'), findsOneWidget);
        expect(find.text('Energy gap detected'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -280));
        await tester.pumpAndSettle();
        expect(find.text("Today's Feed"), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('Methane emissions'), findsOneWidget);
        expect(find.text('Emissions total'), findsOneWidget);
      },
    );

    bddScenario(
      'Nutrition tab shows zero actuals when no feed logged today',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g2');
        await tapTab(tester, 'Nutrition');
        expect(
          find.text(
            'Actual intake is zero until you log feed in Today\'s feed below.',
          ),
          findsOneWidget,
        );
        expect(find.text('No feed recorded today.'), findsOneWidget);
        expect(find.text('Energy gap detected'), findsNothing);
      },
    );

    bddScenario(
      'Nutrition tab allows editing today feed weights',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        await tapTab(tester, 'Nutrition');
        await tester.drag(find.byType(ListView), const Offset(0, -320));
        await tester.pumpAndSettle();
        expect(find.text("Today's Feed"), findsOneWidget);

        expect(find.text('148'), findsOneWidget);
        final weightField = find.widgetWithText(TextField, '148');
        await tester.enterText(weightField, '155');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('155 kg'), findsWidgets);
      },
    );

    bddScenario(
      'Breeding group shows breeding tab with animal list',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g2');
        expect(
          find.descendant(of: find.byType(TabBar), matching: find.text('Breeding')),
          findsOneWidget,
        );
        await tapTab(tester, 'Breeding');
        expect(find.textContaining('Noor #0462'), findsOneWidget);
        expect(find.byTooltip('Pregnancy'), findsWidgets);
      },
    );

    bddScenario(
      'Breeding tab marks female pregnant via welfare icon',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g2');
        await tapTab(tester, 'Breeding');
        await tester.pumpAndSettle();

        final pregnancyButton = find.byTooltip('Pregnancy');
        expect(pregnancyButton, findsWidgets);
        await tester.tap(pregnancyButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Pregnancy confirmed'), findsOneWidget);
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('pregnant'), findsWidgets);
      },
    );

    bddScenario(
      'Milking tab shows volume and top producers',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        await tapTab(tester, 'Milking');
        expect(find.text("TODAY'S VOLUME"), findsOneWidget);
        expect(find.text('Top producers'), findsOneWidget);
        expect(find.text('Mona'), findsWidgets);
      },
    );

    bddScenario(
      'Animals tab lists group members by name',
      tags: ['positive'],
      body: (tester) async {
        await openGroup(tester, 'g1');
        await tapTab(tester, 'Animals');
        expect(find.textContaining('Mona #0438'), findsOneWidget);
        expect(find.textContaining('Sara #0444'), findsOneWidget);
      },
    );

    bddScenario(
      'Tapping a young-stock animal opens its profile',
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
      },
    );

    bddScenario(
      'Unknown group shows not found',
      tags: ['negative'],
      body: (tester) async {
        await openGroup(tester, 'group-does-not-exist');
        expect(find.text('Group not found'), findsOneWidget);
      },
    );
  });
}
