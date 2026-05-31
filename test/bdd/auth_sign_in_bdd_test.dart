import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Mobile sign-in', () {
    late BddHarness harness;

    setUp(() {
      harness = BddHarness();
      harness.signOut();
    });

    bddScenario(
      'Sign-in screen shows social providers and branding',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpWithRouter(tester, initialLocation: '/auth/sign-in');
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.text('Continue with Facebook'), findsOneWidget);
        expect(find.text('New farm setup'), findsOneWidget);
        expect(find.text('Greener Herd'), findsOneWidget);
      },
    );

    bddScenario(
      'Google sign-in creates session when onboarding complete',
      tags: ['positive'],
      body: (tester) async {
        harness.completeOnboarding();
        await harness.pumpWithRouter(tester, initialLocation: '/auth/sign-in');
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        expect(harness.store.session, isNotNull);
        expect(harness.store.linkedAuthProvider, AuthProvider.google);
        expect(find.text('BDD Home'), findsOneWidget);
      },
    );

    bddScenario(
      'New farm setup links Google and resets onboarding',
      tags: ['positive'],
      body: (tester) async {
        await harness.pumpWithRouter(tester, initialLocation: '/auth/sign-in');
        await tester.tap(find.text('New farm setup'));
        await tester.pumpAndSettle();
        expect(harness.store.onboardingComplete, isFalse);
        expect(harness.store.linkedAuthProvider, AuthProvider.google);
        expect(harness.store.session, isNotNull);
        expect(find.text('Farm name'), findsOneWidget);
      },
    );

    bddScenario(
      'Signed-out user has no session',
      tags: ['negative'],
      body: (tester) async {
        expect(harness.store.session, isNull);
      },
    );
  });
}
