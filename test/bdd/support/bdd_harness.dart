import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:greenerherd_mobile/core/l10n/gen/app_localizations.dart';
import 'package:greenerherd_mobile/core/l10n/locale_controller.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/core/theme/gh_theme.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/breed_reference.dart';
import 'package:greenerherd_mobile/data/mock/mock_repositories.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'bdd_router.dart';
import 'package:greenerherd_mobile/features/animals/animal_profile_screen.dart';
import 'package:greenerherd_mobile/features/animals/record_birth_screen.dart';
import 'package:greenerherd_mobile/features/animals/record_milk_screen.dart';
import 'package:greenerherd_mobile/features/auth/sign_in_screen.dart';
import 'package:greenerherd_mobile/features/onboarding/onboarding_screen.dart';

/// Call once per test file `main()`.
void initBddTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Taps a horizontal tag filter chip on the animals list (scrolls into view first).
Future<void> tapAnimalsTagFilterChip(WidgetTester tester, String label) async {
  final row = find.byType(SingleChildScrollView).at(1);
  for (var attempt = 0; attempt < 6; attempt++) {
    final chip = find.descendant(of: row, matching: find.text(label));
    if (chip.evaluate().isNotEmpty) {
      final center = tester.getCenter(chip);
      if (center.dx >= 0 && center.dx <= tester.view.physicalSize.width / tester.view.devicePixelRatio) {
        await tester.tap(chip);
        await tester.pumpAndSettle();
        return;
      }
    }
    await tester.drag(row, const Offset(-140, 0));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.descendant(of: row, matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// Wraps a screen with Riverpod + localisation for BDD widget tests.
class BddHarness {
  BddHarness({MockDataStore? store})
      : store = store ?? (MockDataStore(seedDemoHerd: true).._seedSignedIn());

  final MockDataStore store;

  List<Override> get _defaultOverrides => [
        mockDataStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWith((ref) => MockAuthRepository(store)),
        onboardingRepositoryProvider.overrideWith(
          (ref) => MockOnboardingRepository(store),
        ),
        animalRepositoryProvider.overrideWith(
          (ref) => MockAnimalRepository(
            store,
            const AnimalLifecycleService(),
          ),
        ),
        groupRepositoryProvider.overrideWith((ref) => MockGroupRepository(store)),
        nutritionRepositoryProvider.overrideWith(
          (ref) => MockNutritionRepository(store),
        ),
        lactationRepositoryProvider.overrideWith(
          (ref) => MockLactationRepository(store),
        ),
        financeRepositoryProvider.overrideWith(
          (ref) => MockFinanceRepository(store),
        ),
        commerceRepositoryProvider.overrideWith(
          (ref) => MockCommerceRepository(store),
        ),
        breedsForSpeciesProvider.overrideWith((ref, species) async {
          return [
            BreedReference(
              id: 'holstein-bdd',
              species: species,
              code: 'HOLSTEIN',
              nameEn: 'Holstein',
              names: const {'en': 'Holstein'},
            ),
            BreedReference(
              id: 'jersey-bdd',
              species: species,
              code: 'JERSEY',
              nameEn: 'Jersey',
              names: const {'en': 'Jersey'},
            ),
          ];
        }),
      ];

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
    Size surfaceSize = const Size(800, 2400),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._defaultOverrides,
          localeProvider.overrideWith((ref) => LocaleController()..state = locale),
          ...overrides,
        ],
        child: MaterialApp(
          theme: GhTheme.light(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Animals list tab with production-like shell routing (root overlay for profile).
  Future<void> pumpAnimalsList(
    WidgetTester tester, {
    Size surfaceSize = const Size(800, 2400),
  }) async {
    await pumpShellNavigation(
      tester,
      initialLocation: '/animals',
      surfaceSize: surfaceSize,
    );
  }

  /// Stateful shell + root routes (matches [app_router] animal profile stacking).
  Future<void> pumpShellNavigation(
    WidgetTester tester, {
    required String initialLocation,
    Size surfaceSize = const Size(800, 2400),
  }) async {
    final rootKey = GlobalKey<NavigatorState>();
    final router = createBddShellRouter(
      rootNavigatorKey: rootKey,
      initialLocation: initialLocation,
    );

    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: _defaultOverrides,
        child: MaterialApp.router(
          theme: GhTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Animal profile with optional tab index (0=Overview, 1=Weight, 2=Breeding, 3=Milking, …).
  Future<void> pumpAnimalProfile(
    WidgetTester tester, {
    required String animalId,
    int? tabIndex,
    Size surfaceSize = const Size(800, 2400),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final path = tabIndex == null ? '/animals/$animalId' : '/animals/$animalId?tab=$tabIndex';
    final router = GoRouter(
      initialLocation: path,
      routes: [
        GoRoute(
          path: '/animals/:id',
          builder: (_, state) =>
              AnimalProfileScreen(animalId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'record-milk',
              builder: (_, state) => RecordMilkScreen(
                animalId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'record-birth',
              builder: (_, state) => RecordBirthScreen(
                animalId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _defaultOverrides,
        child: MaterialApp.router(
          theme: GhTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Screens that call [GoRouter.go] during flows (sign-in, onboarding).
  Future<void> pumpWithRouter(
    WidgetTester tester, {
    required String initialLocation,
    List<Override> overrides = const [],
  }) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/auth/sign-in',
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('BDD Home')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [..._defaultOverrides, ...overrides],
        child: MaterialApp.router(
          theme: GhTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void signOut() {
    store.session = null;
  }

  void completeOnboarding() => store.onboardingComplete = true;

  void resetOnboarding() {
    store.onboardingComplete = false;
    store.forceOnboarding = false;
  }
}

extension on MockDataStore {
  void _seedSignedIn() {
    session = const AuthSession(
      userId: 'u1',
      farmId: 'farm-1',
      role: UserRole.owner,
      displayName: 'Yusuf Al-Harbi',
      accessToken: 'test-token',
    );
    onboardingComplete = true;
  }
}

/// Tags: @positive @negative — mirrors Gherkin scenarios in test/bdd/features/.
void bddScenario(
  String name, {
  List<String> tags = const [],
  required Future<void> Function(WidgetTester tester) body,
}) {
  final label = tags.isEmpty ? name : '$name [${tags.join(', ')}]';
  testWidgets(label, body);
}

/// Domain-only BDD (validation, lifecycle) without widget binding.
void bddDomainScenario(
  String name, {
  List<String> tags = const [],
  required void Function() body,
}) {
  final label = tags.isEmpty ? name : '$name [${tags.join(', ')}]';
  test(label, body);
}

/// Async domain BDD (repositories, services) without widget binding.
void bddAsyncDomainScenario(
  String name, {
  List<String> tags = const [],
  required Future<void> Function() body,
}) {
  final label = tags.isEmpty ? name : '$name [${tags.join(', ')}]';
  test(label, body);
}
