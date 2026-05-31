import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../../data/models/enums.dart';
import '../animals/animal_providers.dart';

final dashboardFinanceProvider = FutureProvider<FinanceSummary>((ref) async {
  return ref.watch(financeRepositoryProvider).getSummary();
});

/// First group with a significant energy shortfall (for home-screen nudge).
final dashboardFeedSuggestionProvider =
    FutureProvider<DashboardFeedSuggestion?>((ref) async {
  final groups = await ref.watch(groupsListProvider.future);
  final nutrition = ref.watch(nutritionRepositoryProvider);
  for (final group in groups) {
    final gap = await nutrition.getGap(group.id);
    if (gap.energyDeviationPct < -10) {
      final pct = gap.energyDeviationPct.abs().round();
      final body = gap.fixGapMessage ??
          'Energy gap detected on ${group.name} — $pct% below target.';
      return DashboardFeedSuggestion(
        groupId: group.id,
        groupName: group.name,
        body: body,
        energyGapPct: pct,
      );
    }
  }
  return null;
});

class DashboardFeedSuggestion {
  const DashboardFeedSuggestion({
    required this.groupId,
    required this.groupName,
    required this.body,
    required this.energyGapPct,
  });

  final String groupId;
  final String groupName;
  final String body;
  final int energyGapPct;
}

/// Static upcoming events aligned with design handoff demo data.
List<DashboardUpcomingEvent> dashboardUpcomingEvents({
  Species? speciesFilter,
}) {
  const all = [
    DashboardUpcomingEvent(
      icon: Icons.child_care_outlined,
      title: '3 births due',
      subtitle: 'Bessie · Layla · Khulud',
      tone: DashboardEventTone.primary,
      route: '/animals/a1',
      species: Species.cattle,
    ),
    DashboardUpcomingEvent(
      icon: Icons.vaccines_outlined,
      title: 'FMD booster · 14 head',
      subtitle: 'Goats: Maintenance B',
      tone: DashboardEventTone.warning,
      route: '/groups/g5',
      species: Species.goat,
    ),
    DashboardUpcomingEvent(
      icon: Icons.check_circle_outline,
      title: 'Pregnancy scan · 6 cattle',
      subtitle: 'Cattle: Breeding',
      tone: DashboardEventTone.primary,
      route: '/groups/g2',
      species: Species.cattle,
    ),
  ];
  if (speciesFilter == null) return all;
  return all.where((e) => e.species == speciesFilter).toList();
}

class DashboardUpcomingEvent {
  const DashboardUpcomingEvent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.route,
    this.species,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final DashboardEventTone tone;
  final String route;
  final Species? species;
}

enum DashboardEventTone { primary, warning }
