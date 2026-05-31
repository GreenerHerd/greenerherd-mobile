import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Mobile farm onboarding', () {
    late BddHarness harness;

    setUp(() {
      harness = BddHarness();
      harness.resetOnboarding();
      harness.store.linkedAuthProvider = AuthProvider.google;
    });

    bddScenario(
      'Onboarding shows linked account, farm, and species steps',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpWithRouter(tester, initialLocation: '/onboarding');
        expect(find.textContaining('Linked to Google'), findsOneWidget);
        expect(find.text('Farm name'), findsOneWidget);
        expect(find.text('Select the species on your farm'), findsNothing);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Select the species on your farm'), findsOneWidget);
        expect(find.text('Cattle'), findsOneWidget);
      },
    );

    bddScenario(
      'Completing onboarding marks farm ready',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpWithRouter(tester, initialLocation: '/onboarding');
        // Step 0 → 1: Farm details
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        // Step 1 → 2: Select species
        await tester.tap(find.text('Cattle'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        // Step 2 → 3: Purpose per species
        expect(find.text('Milk & Meat'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        // Step 3: Choose how to add animals
        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();
        expect(harness.store.onboardingComplete, isTrue);
        expect(find.text('BDD Home'), findsOneWidget);
      },
    );

    bddScenario(
      'Species step requires a selection',
      tags: ['negative'],
      body: (tester) async {
        await harness.pumpWithRouter(tester, initialLocation: '/onboarding');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Select at least one species'), findsOneWidget);
      },
    );
  });
}
