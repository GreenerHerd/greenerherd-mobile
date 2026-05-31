import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/animals/animal_providers.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../features/groups/group_providers.dart';
import '../../features/finance/finance_screen.dart';
import 'providers.dart';
import 'session_providers.dart';

/// Refreshes herd lists/stats after a single-animal mutation without touching auth.
void refreshAnimalAfterMutation(
  WidgetRef ref, {
  String? animalId,
  String? groupId,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(animalsListProvider);
    ref.invalidate(dashboardStatsProvider);
    if (animalId != null) {
      ref.invalidate(animalProvider(animalId));
    }
    if (groupId != null) {
      ref.invalidate(groupAnimalsProvider(groupId));
    }
  });
}

/// Invalidates finance tab and dashboard finance widgets.
void refreshFinanceProviders(WidgetRef ref) {
  ref.invalidate(financeSummaryProvider);
  ref.invalidate(dashboardFinanceProvider);
}

/// Invalidates Riverpod caches so lists re-fetch from API / offline cache.
void refreshHerdDataProviders(WidgetRef ref) {
  ref.invalidate(animalsListProvider);
  ref.invalidate(groupsListProvider);
  ref.invalidate(dashboardStatsProvider);
  ref.invalidate(selectedAnimalTagFilterProvider);
  ref.invalidate(authSessionProvider);
  ref.invalidate(animalProvider);
  refreshFinanceProviders(ref);
}

/// Call after sign-in, onboarding, or sync so hybrid clients use the new token/farm.
void refreshAllAppData(WidgetRef ref) {
  invalidateHybridApiProviders(ref);
  refreshHerdDataProviders(ref);
}
