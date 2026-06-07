import 'package:flutter/foundation.dart';

import 'platform_info.dart';

/// Feature flags for incremental rollout.
abstract final class AppConfig {
  static const useMockData = true;
  /// When true, nutrition uses optimizer assets/API instead of static mock gaps.
  static const useNutritionEngine = true;
  /// When true, calls gh-api-nutrition before falling back to bundled JSON.
  static const useNutritionApi = true;
  /// When true, inventory uses gh-api-inventory before local fallback.
  static const useInventoryApi = true;
  /// When true, tasks tab loads from gh-api-tasks (scheduler-generated + events).
  static const useTasksApi = true;
  /// When true, animals/groups load from gh-api-animals before mock fallback.
  static const useAnimalsApi = true;
  /// When true, sign-in uses gh-api-auth before mock fallback.
  static const useAuthApi = true;
  /// When true, farm profile loads from gh-api-farms before mock fallback.
  static const useFarmsApi = true;
  /// When true, people tab loads from gh-api-people before mock fallback.
  static const usePeopleApi = true;
  /// When true, finance and buy/sell use gh-api-finance.
  static const useFinanceApi = true;
  /// Deep link / universal link base returned in invite payloads.
  static const inviteAppLinkBaseUrl = 'https://greenerherd.app/join';
  /// When true, animals/groups/tasks read from Drift cache when offline or API fails.
  static const useOfflineCache = true;
  /// When true, mutations enqueue to [SyncQueue] and drain via [SyncService].
  static const useOfflineSync = true;
  /// Fallback when no auth session token (matches gh-api-inventory JWT_SECRET default).
  static const inventoryDevBearerToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLTEiXSwicm9sZSI6Ik9XTkVSIiwiaWF0IjoxNzc5MTI1NzQzLCJleHAiOjE4MTA2NjE3NDN9.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo';
  static const enableMarketplace = true;
  static const enableSubscription = true;
  static const enableBuySell = true;

  /// Override with `--dart-define=API_HOST=10.0.2.2` (Android emulator) or your LAN IP.
  static const _apiHostOverride = String.fromEnvironment('API_HOST');

  /// Host reachable from the device: Android emulator uses 10.0.2.2 for Mac localhost.
  static String get apiDevHost {
    if (_apiHostOverride.isNotEmpty) return _apiHostOverride;
    if (kIsWeb) return 'localhost';
    if (platformIsAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get nutritionApiBaseUrl => 'http://$apiDevHost:3003';
  static String get inventoryApiBaseUrl => 'http://$apiDevHost:3005';
  static String get tasksApiBaseUrl => 'http://$apiDevHost:3004';
  static String get animalsApiBaseUrl => 'http://$apiDevHost:3006';
  static String get authApiBaseUrl => 'http://$apiDevHost:3001';
  static String get farmsApiBaseUrl => 'http://$apiDevHost:3002';
  static String get peopleApiBaseUrl => 'http://$apiDevHost:3007';
  static String get financeApiBaseUrl => 'http://$apiDevHost:3008';
}
