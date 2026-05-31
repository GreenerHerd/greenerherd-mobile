import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../animals/animal_providers.dart';
import '../../shared/widgets/gh_chip.dart';
import '../../shared/widgets/species_icon.dart';
import '../../shared/widgets/gh_logo.dart';
import 'dashboard_providers.dart';
import 'widgets/dashboard_status_grid.dart';
import 'widgets/demographics_card.dart';
import 'widgets/greener_herd_suggestion_banner.dart';
import 'widgets/groups_kpi_list.dart';
import 'widgets/livestock_value_card.dart';
import 'widgets/tasks_due_card.dart';
import 'widgets/upcoming_events_card.dart';

final _farmProvider = FutureProvider<Farm>((ref) async {
  return ref.watch(farmRepositoryProvider).getCurrentFarm();
});

Map<Species, double> _livestockValueBySpecies(
  double total,
  Map<Species?, int> bySpecies,
) {
  final heads = Species.values
      .map((s) => bySpecies[s] ?? 0)
      .fold<int>(0, (a, b) => a + b);
  if (heads == 0) {
    return {for (final s in Species.values) s: 0};
  }
  return {
    for (final s in Species.values)
      s: total * (bySpecies[s] ?? 0) / heads,
  };
}

String? _pregnantSubtitle(List<Animal> animals) {
  final counts = <Species, int>{};
  for (final a in animals) {
    if (!a.tags.contains(AnimalTagType.pregnant)) continue;
    counts[a.species] = (counts[a.species] ?? 0) + 1;
  }
  final parts = <String>[];
  if (counts[Species.cattle] != null) {
    parts.add('${counts[Species.cattle]} cattle');
  }
  if (counts[Species.goat] != null) {
    parts.add('${counts[Species.goat]} goats');
  }
  if (counts[Species.sheep] != null) {
    parts.add('${counts[Species.sheep]} sheep');
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

String _readySubtitle(List<Animal> animals) {
  final groupIds = animals
      .where((a) => a.tags.contains(AnimalTagType.readyToBreed))
      .map((a) => a.groupId)
      .toSet();
  return 'across ${groupIds.length} groups';
}

String _profileInitials(String? displayName) {
  final parts = displayName?.trim().split(RegExp(r'\s+')) ?? [];
  if (parts.isEmpty) return 'YA';
  return parts.take(2).map((p) => p[0]).join().toUpperCase();
}

bool _showFeedSuggestion(
  DashboardFeedSuggestion? suggestion,
  List<AnimalGroup> groups,
  Species? speciesFilter,
) {
  if (suggestion == null) return false;
  if (speciesFilter == null) return true;
  final group = groups.where((g) => g.id == suggestion.groupId).firstOrNull;
  return group?.species == speciesFilter;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(dashboardStatsProvider);
    final farm = ref.watch(_farmProvider);
    final speciesFilter = ref.watch(selectedSpeciesFilterProvider);
    final animals = ref.watch(animalsListProvider);
    final groups = ref.watch(groupsListProvider);
    final finance = ref.watch(dashboardFinanceProvider);
    final feedSuggestion = ref.watch(dashboardFeedSuggestionProvider);

    return Scaffold(
      backgroundColor: context.ghPageBackground,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _Header(
              onMenu: () => ref.read(burgerMenuOpenProvider.notifier).state = true,
              onAlerts: () => context.push('/alerts'),
              onProfile: () => context.push('/profile'),
              profileInitials: _profileInitials(
                ref.watch(authSessionProvider).valueOrNull?.displayName,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                refreshHerdDataProviders(ref);
                ref.invalidate(_farmProvider);
                ref.invalidate(dashboardFeedSuggestionProvider);
                ref.invalidate(dashboardFinanceProvider);
                await Future.wait([
                  ref.read(dashboardStatsProvider.future),
                  ref.read(groupsListProvider.future),
                  ref.read(animalsListProvider.future),
                  ref.read(dashboardFinanceProvider.future),
                  ref.read(dashboardFeedSuggestionProvider.future),
                ]);
              },
              child: stats.when(
                data: (s) => farm.when(
                  data: (f) => animals.when(
                    data: (animalList) => groups.when(
                      data: (groupList) => finance.when(
                        data: (fin) {
                          final visibleTotal = speciesFilter == null
                              ? s.totalAnimals
                              : (s.bySpecies[speciesFilter] ?? 0);
                          final events = dashboardUpcomingEvents(
                            speciesFilter: speciesFilter,
                          );
                          final suggestion = feedSuggestion.valueOrNull;
                          final showSuggestion = _showFeedSuggestion(
                            suggestion,
                            groupList,
                            speciesFilter,
                          );

                          return ListView(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Text(
                                'Riyadh · ${f.name}',
                                style: GhTypography.muted.copyWith(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => context.push('/profile'),
                                child: Text(
                                  l10n.goodMorning('Yusuf'),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${f.name} · $visibleTotal animals',
                                style: GhTypography.muted.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    GhChip(
                                      label:
                                          '${l10n.allSpecies} ${s.bySpecies[null]}',
                                      selected: speciesFilter == null,
                                      onTap: () => ref
                                          .read(selectedSpeciesFilterProvider
                                              .notifier)
                                          .state = null,
                                    ),
                                    GhChip(
                                      label:
                                          '${l10n.cattle} ${s.bySpecies[Species.cattle]}',
                                      selected:
                                          speciesFilter == Species.cattle,
                                      leading: SpeciesIcon.chipLeading(
                                        Species.cattle,
                                        selected:
                                            speciesFilter == Species.cattle,
                                      ),
                                      onTap: () => ref
                                          .read(selectedSpeciesFilterProvider
                                              .notifier)
                                          .state = Species.cattle,
                                    ),
                                    GhChip(
                                      label:
                                          '${l10n.goats} ${s.bySpecies[Species.goat]}',
                                      selected: speciesFilter == Species.goat,
                                      leading: SpeciesIcon.chipLeading(
                                        Species.goat,
                                        selected:
                                            speciesFilter == Species.goat,
                                      ),
                                      onTap: () => ref
                                          .read(selectedSpeciesFilterProvider
                                              .notifier)
                                          .state = Species.goat,
                                    ),
                                    GhChip(
                                      label:
                                          '${l10n.sheep} ${s.bySpecies[Species.sheep]}',
                                      selected: speciesFilter == Species.sheep,
                                      leading: SpeciesIcon.chipLeading(
                                        Species.sheep,
                                        selected:
                                            speciesFilter == Species.sheep,
                                      ),
                                      onTap: () => ref
                                          .read(selectedSpeciesFilterProvider
                                              .notifier)
                                          .state = Species.sheep,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              DashboardStatusGrid(
                                stats: s,
                                pregnantSubtitle: speciesFilter == null
                                    ? _pregnantSubtitle(animalList)
                                    : null,
                                readySubtitle: _readySubtitle(animalList),
                              ),
                              if (speciesFilter != null) ...[
                                const SizedBox(height: 16),
                                DashboardDemographicsCard(
                                  species: speciesFilter,
                                  animals: animalList,
                                ),
                                const SizedBox(height: 16),
                                DashboardGroupsKpiList(
                                  species: speciesFilter,
                                  groups: groupList,
                                  animals: animalList,
                                ),
                              ],
                              const SizedBox(height: 16),
                              UpcomingEventsCard(events: events),
                              const SizedBox(height: 16),
                              TasksDueCard(
                                overdue: s.tasksOverdue,
                                today: s.tasksToday,
                                thisWeek: s.tasksThisWeek,
                              ),
                              if (speciesFilter == null) ...[
                                const SizedBox(height: 16),
                                LivestockValueCard(
                                  totalSar: fin.livestockValue,
                                  bySpecies: _livestockValueBySpecies(
                                    fin.livestockValue,
                                    s.bySpecies,
                                  ),
                                ),
                              ],
                              if (showSuggestion && suggestion != null) ...[
                                const SizedBox(height: 16),
                                GreenerHerdSuggestionBanner(
                                  suggestion: suggestion,
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('$e')),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onMenu,
    required this.onAlerts,
    required this.onProfile,
    this.profileInitials = 'YA',
  });

  final VoidCallback onMenu;
  final VoidCallback onAlerts;
  final VoidCallback onProfile;
  final String profileInitials;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GhColors.surface,
      elevation: 1,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.menu), onPressed: onMenu),
            const Spacer(),
            const GhLogo(size: 36, showRing: false),
            const SizedBox(width: 8),
            const Text(
              'Greener Herd',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: GhColors.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onAlerts,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onProfile,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: GhColors.primaryLight,
                  child: Text(
                    profileInitials,
                    style: GhTypography.h05.copyWith(color: GhColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
