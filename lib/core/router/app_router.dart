import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/animals/animal_profile_screen.dart';
import '../../features/animals/animals_list_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/commerce/buy_animals_screen.dart';
import '../../features/commerce/sell_animals_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/animals/record_birth_screen.dart';
import '../../features/animals/record_miscarriage_screen.dart';
import '../../features/animals/record_milk_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/finance/record_milk_sale_screen.dart';
import '../../features/groups/group_detail_screen.dart';
import '../../features/groups/group_milk_record_screen.dart';
import '../../features/groups/groups_list_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/inventory/add_feed_route_args.dart';
import '../../features/inventory/add_feed_screen.dart';
import '../../features/inventory/add_medicine_screen.dart';
import '../../features/groups/todays_feed_meal_screen.dart';
import '../../features/inventory/edit_meal_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/inventory/meal_plans_screen.dart';
import '../../features/inventory/restock_feed_screen.dart';
import '../../features/inventory/record_feeding_screen.dart';
import '../../features/nutrition/feed_recommendations_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/profile/notification_settings_screen.dart';
import '../../features/profile/profile_screen.dart'
    show ProfileAppSettingsScreen, ProfileScreen;
import '../../features/reports/report_detail_screen.dart';
import '../../features/reports/reports_list_screen.dart';
import '../../features/settings/alerts_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../auth/role_access.dart';
import '../providers/providers.dart';

/// Root navigator for full-screen routes (e.g. animal profile from group detail).
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/auth/sign-in',
    redirect: (context, state) async {
      final auth = ref.read(authRepositoryProvider);
      final session = await auth.currentSession();
      final onAuth = state.matchedLocation.startsWith('/auth');
      final onOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (session == null && !onAuth) return '/auth/sign-in';
      if (session != null && onAuth) {
        return auth.isOnboardingComplete ? '/home' : '/onboarding';
      }
      if (session != null && !auth.isOnboardingComplete && !onOnboarding) {
        return '/onboarding';
      }
      if (session != null &&
          state.matchedLocation == '/finance' &&
          !RoleAccess.canAccessFinance(session.role)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const DashboardScreen(),
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
                    builder: (_, state) =>
                        AnimalProfileScreen(animalId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'record-birth',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => RecordBirthScreen(
                          animalId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'record-miscarriage',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => RecordMiscarriageScreen(
                          animalId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'record-milk',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => RecordMilkScreen(
                          animalId: state.pathParameters['id']!,
                        ),
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
                builder: (_, __) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                builder: (_, __) => const FinanceScreen(),
                routes: [
                  GoRoute(
                    path: 'record-milk-sale',
                    builder: (_, __) => const RecordMilkSaleScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, __) => const ReportsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => ReportDetailScreen(
                      reportId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/profile/notifications',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/app-settings',
        builder: (_, __) => const ProfileAppSettingsScreen(),
      ),
      GoRoute(path: '/groups', builder: (_, __) => const GroupsListScreen()),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'record-milk',
            builder: (_, state) => GroupMilkRecordScreen(
              groupId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'todays-feed/:entryId',
            builder: (_, state) => TodaysFeedMealScreen(
              groupId: state.pathParameters['id']!,
              entryId: state.pathParameters['entryId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/inventory',
        builder: (_, __) => const InventoryScreen(),
        routes: [
          GoRoute(
            path: 'add-feed',
            builder: (_, state) {
              final extra = state.extra;
              return AddFeedScreen(
                prefill: extra is AddFeedRouteArgs ? extra : null,
              );
            },
          ),
          GoRoute(
            path: 'add-medicine',
            builder: (_, __) => const AddMedicineScreen(),
          ),
          GoRoute(
            path: 'meals',
            builder: (_, __) => const MealPlansScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => EditMealScreen(
                  mealId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'restock/:id',
            builder: (_, state) => RestockFeedScreen(
              feedId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'record-feeding',
            builder: (_, state) => RecordFeedingScreen(
              initialGroupId:
                  state.uri.queryParameters['groupId'],
            ),
          ),
          GoRoute(
            path: 'buy',
            builder: (_, __) => const BuyAnimalsScreen(),
          ),
          GoRoute(
            path: 'sell',
            builder: (_, __) => const SellAnimalsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
      GoRoute(
        path: '/nutrition/:groupId',
        builder: (_, state) => FeedRecommendationsScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
      GoRoute(path: '/people', builder: (_, __) => const PeopleScreen()),
      // Legacy paths → inventory livestock flows
      GoRoute(
        path: '/buy',
        redirect: (_, __) => '/inventory/buy',
      ),
      GoRoute(
        path: '/sell',
        redirect: (_, __) => '/inventory/sell',
      ),
      GoRoute(
        path: '/subscription',
        builder: (_, __) => const SubscriptionScreen(),
      ),
    ],
  );
});
