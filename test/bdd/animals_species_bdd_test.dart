import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/features/animals/animals_list_screen.dart';
import 'package:greenerherd_mobile/shared/widgets/gh_chip.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Animals list species filter', () {
    late BddHarness harness;

    setUp(() => harness = BddHarness());

    Future<void> openAnimals(tester) async {
      await harness.pumpScreen(tester, const AnimalsListScreen());
      await tester.pumpAndSettle();
    }

    Finder speciesChip(String labelPrefix) => find.byWidgetPredicate(
          (w) => w is GhChip && w.label.startsWith(labelPrefix),
        );

    bddScenario(
      'Animals screen shows species filter chips',
      tags: ['positive'],
      body: (tester) async {
        await openAnimals(tester);
        expect(speciesChip('All species'), findsOneWidget);
        expect(speciesChip('Cattle'), findsOneWidget);
        expect(speciesChip('Goats'), findsOneWidget);
        expect(speciesChip('Sheep'), findsOneWidget);
      },
    );

    bddScenario(
      'Animals list shows seeded cattle records',
      tags: ['positive'],
      body: (tester) async {
        await openAnimals(tester);
        expect(find.textContaining('Mona'), findsWidgets);
        expect(find.textContaining('#0438'), findsWidgets);
      },
    );

    bddScenario(
      'Selecting cattle chip filters the visible list',
      tags: ['positive'],
      body: (tester) async {
        await openAnimals(tester);
        await tester.tap(speciesChip('Cattle'));
        await tester.pumpAndSettle();
        expect(find.textContaining('#0438'), findsWidgets);
        expect(find.textContaining('#S009'), findsNothing);
      },
    );

    bddScenario(
      'Unknown species label is not shown on animals screen',
      tags: ['negative'],
      body: (tester) async {
        await openAnimals(tester);
        expect(find.text('Marsupials'), findsNothing);
      },
    );
  });
}
