import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenerherd_mobile/features/animals/animal_profile_screen.dart';
import 'package:greenerherd_mobile/features/animals/animals_list_screen.dart';
import 'package:greenerherd_mobile/features/animals/record_birth_screen.dart';
import 'package:greenerherd_mobile/features/animals/record_milk_screen.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/features/animals/record_treatment_screen.dart';
import 'package:greenerherd_mobile/features/groups/group_detail_screen.dart';
import 'package:greenerherd_mobile/features/shell/app_shell.dart';

/// Mirrors production shell routing (including [parentNavigatorKey]) for BDD tests.
GoRouter createBddShellRouter({
  required GlobalKey<NavigatorState> rootNavigatorKey,
  required String initialLocation,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(
                  body: Center(child: Text('BDD Home')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/animals',
                builder: (_, __) => const AnimalsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => AnimalProfileScreen(
                      animalId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'record-milk',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => RecordMilkScreen(
                          animalId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'record-birth',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => RecordBirthScreen(
                          animalId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'record-treatment',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final extra = state.extra as Map<String, dynamic>?;
                          return RecordTreatmentScreen(
                            animalId: state.pathParameters['id']!,
                            initialIllnessNote:
                                extra?['illnessNote'] as String?,
                            initialTreatment: extra?['treatment']
                                as AnimalTreatmentDetails?,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, __) => const Scaffold(
                  body: Center(child: Text('BDD Tasks')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                builder: (_, __) => const Scaffold(
                  body: Center(child: Text('BDD Finance')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, __) => const Scaffold(
                  body: Center(child: Text('BDD Reports')),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
    ],
  );
}
