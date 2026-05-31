import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/methane_emissions_calculator.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../nutrition/methane_emissions_card.dart';
import '../nutrition/nutrition_providers.dart' show groupAnimalsForNutritionProvider, groupNutritionDisplayGapProvider, groupTodaysFeedProvider, nutritionGapProvider;
import '../../shared/widgets/gh_app_bar.dart';
import '../../data/mock/profile_mock_data.dart';
import 'group_breeding_tab.dart';
import 'group_detail_widgets.dart';
import 'group_kpis.dart';
import 'group_mock_extras.dart';
import 'group_milk_record.dart';
import 'group_providers.dart';

enum _GroupSection { overview, animals, nutrition, breeding, milking, health }

extension _GroupSectionL10n on _GroupSection {
  String label(AppLocalizations l10n) => switch (this) {
        _GroupSection.overview => l10n.tabOverview,
        _GroupSection.animals => l10n.tabAnimals,
        _GroupSection.nutrition => l10n.tabNutrition,
        _GroupSection.breeding => l10n.tabBreeding,
        _GroupSection.milking => l10n.tabMilking,
        _GroupSection.health => l10n.tabHealth,
      };
}

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<_GroupSection> _sections = [];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  bool _sameSections(List<_GroupSection> a, List<_GroupSection> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _syncTabs(List<_GroupSection> sections) {
    if (_sameSections(_sections, sections)) return;
    final previousIndex = _tabController?.index ?? 0;
    _sections = sections;
    _tabController?.dispose();
    _tabController = TabController(
      length: sections.length,
      vsync: this,
      initialIndex: previousIndex.clamp(0, sections.length - 1),
    );
  }

  List<_GroupSection> _sectionsFor(AnimalGroup group, List<Animal> animals) {
    final sections = <_GroupSection>[
      _GroupSection.overview,
      _GroupSection.animals,
      _GroupSection.nutrition,
    ];
    if (_showBreeding(group, animals)) {
      sections.add(_GroupSection.breeding);
    }
    if (_showMilking(group, animals)) {
      sections.add(_GroupSection.milking);
    }
    sections.add(_GroupSection.health);
    return sections;
  }

  bool _showBreeding(AnimalGroup group, List<Animal> animals) =>
      group.purpose == GroupPurpose.breeding ||
      group.purpose == GroupPurpose.pregnant ||
      animals.any(
        (a) =>
            a.tags.contains(AnimalTagType.pregnant) ||
            a.tags.contains(AnimalTagType.readyToBreed) ||
            ReproductionStatusRules.showsBreedingCycleKpi(a),
      );

  bool _showMilking(AnimalGroup group, List<Animal> animals) =>
      group.purpose == GroupPurpose.milk ||
      animals.any((a) => a.tags.contains(AnimalTagType.lactating));

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupProvider(widget.groupId));
    final animalsAsync = ref.watch(groupAnimalsProvider(widget.groupId));

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: GhAppBar(
          title: context.l10n.groupTitle,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text('$e')),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            appBar: GhAppBar(
              title: context.l10n.groupTitle,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(context.l10n.groupNotFound),
            ),
          );
        }

        return animalsAsync.when(
          loading: () => Scaffold(
            appBar: _appBar(context, group),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: _appBar(context, group),
            body: Center(child: Text('$e')),
          ),
          data: (animals) {
            final l10n = context.l10n;
            final kpis = GroupKpis.from(group, animals);
            final sections = _sectionsFor(group, animals);
            _syncTabs(sections);
            final controller = _tabController!;

            return Scaffold(
              backgroundColor: GhColors.pageBackground,
              appBar: _appBar(context, group),
              body: Column(
                children: [
                  Material(
                    color: GhColors.surface,
                    child: TabBar(
                      controller: controller,
                      isScrollable: true,
                      labelColor: GhColors.primary,
                      unselectedLabelColor: GhColors.textSecondary,
                      indicatorColor: GhColors.primary,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        for (final s in sections) Tab(text: s.label(l10n)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        for (final s in sections)
                          _GroupTabBody(
                            section: s,
                            group: group,
                            animals: animals,
                            kpis: kpis,
                            groupId: widget.groupId,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  GhAppBar _appBar(BuildContext context, AnimalGroup group) {
    final purpose = GroupMockExtras.purposeLabel(group.purpose);
    return GhAppBar(
      title: group.name,
      subtitle: '${group.headCount} cattle · $purpose',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }
}

class _GroupTabBody extends ConsumerWidget {
  const _GroupTabBody({
    required this.section,
    required this.group,
    required this.animals,
    required this.kpis,
    required this.groupId,
  });

  final _GroupSection section;
  final AnimalGroup group;
  final List<Animal> animals;
  final GroupKpis kpis;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (section) {
      _GroupSection.overview => _OverviewTab(
          group: group,
          kpis: kpis,
          groupId: groupId,
        ),
      _GroupSection.animals => _AnimalsTab(animals: animals),
      _GroupSection.nutrition => _NutritionTab(groupId: groupId),
      _GroupSection.breeding => GroupBreedingTab(
          group: group,
          animals: animals,
          kpis: kpis,
          groupId: groupId,
        ),
      _GroupSection.milking => _MilkingTab(
          group: group,
          animals: animals,
          kpis: kpis,
        ),
      _GroupSection.health => _HealthTab(
          animals: animals,
          kpis: kpis,
          groupId: groupId,
        ),
    };
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.group,
    required this.kpis,
    required this.groupId,
  });

  final AnimalGroup group;
  final GroupKpis kpis;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gapAsync = ref.watch(groupNutritionDisplayGapProvider(groupId));
    final showMilking = group.purpose == GroupPurpose.milk;
    final breedingKpis = ProfileMockData.groupOverviewBreeding(groupId);

    return gapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (gap) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GroupPurposeDescriptionCard(group: group, onEdit: () {}),
          if (showMilking) ...[
            const SizedBox(height: 12),
            GroupMilkingKpisCard(kpis: kpis),
          ],
          if (breedingKpis != null) ...[
            const SizedBox(height: 12),
            GroupBreedingKpisCard(
              pregnancyRatePct: breedingKpis.pregnancyRatePct,
              aiAttempts30d: breedingKpis.aiAttempts30d,
              confirmed: breedingKpis.confirmed,
            ),
          ],
          const SizedBox(height: 12),
          GroupOverviewStatGrid(
            kpis: kpis,
            registeredHeadCount: group.headCount,
          ),
          const SizedBox(height: 12),
          GroupNutritionSummaryCard(
            gap: gap,
            onTap: () async {
              final updated = await openGroupNutritionFix(context, groupId);
              if (updated == true) {
                ref.invalidate(nutritionGapProvider(groupId));
                ref.invalidate(groupNutritionDisplayGapProvider(groupId));
                ref.invalidate(groupTodaysFeedProvider(groupId));
              }
            },
          ),
          const SizedBox(height: 12),
          GroupTasksPreviewCard(
            preview: GroupMockExtras.tasksPreview(groupId),
          ),
        ],
      ),
    );
  }
}

class _AnimalsTab extends StatelessWidget {
  const _AnimalsTab({required this.animals});

  final List<Animal> animals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (animals.isEmpty) {
      return Center(
        child: Text(
          l10n.noAnimalsInGroup,
          style: GhTypography.muted,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final a in animals)
          GroupAnimalCard(
            animal: a,
            onTap: () => context.push('/animals/${a.id}'),
          ),
      ],
    );
  }
}

class _NutritionTab extends ConsumerWidget {
  const _NutritionTab({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayGapAsync = ref.watch(groupNutritionDisplayGapProvider(groupId));
    final gapAsync = ref.watch(nutritionGapProvider(groupId));
    final animalsAsync = ref.watch(groupAnimalsForNutritionProvider(groupId));
    final feedAsync = ref.watch(groupTodaysFeedProvider(groupId));

    return displayGapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (displayGap) {
        return gapAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (gap) {
            return animalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (animals) {
                final active = animals
                    .where((a) => a.status == AnimalStatus.active)
                    .toList();
                final methaneTotal =
                    MethaneEmissionsCalculator.groupTotal(active);

                return feedAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (feed) => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GroupNutritionTodayCard(
                        gap: displayGap,
                        hasLoggedFeedToday: feed.isNotEmpty,
                        onFixGap: () async {
                      final updated =
                          await openGroupNutritionFix(context, groupId);
                      if (updated == true) {
                        ref.invalidate(nutritionGapProvider(groupId));
                        ref.invalidate(groupTodaysFeedProvider(groupId));
                        ref.invalidate(groupNutritionDisplayGapProvider(groupId));
                      }
                        },
                      ),
                      const SizedBox(height: 12),
                      GroupTodaysFeedCard(
                        entries: feed,
                        groupId: groupId,
                        onRecord: () async {
                          final updated = await context.push<bool>(
                            '/inventory/record-feeding?groupId=$groupId',
                          );
                          if (updated == true) {
                            ref.invalidate(groupTodaysFeedProvider(groupId));
                            ref.invalidate(groupNutritionDisplayGapProvider(groupId));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      GroupDailyCostCard(gap: gap),
                      const SizedBox(height: 16),
                      MethaneEmissionsCard.summary(
                        groupTotal: methaneTotal,
                        headCount: active.length,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MilkingTab extends ConsumerWidget {
  const _MilkingTab({
    required this.group,
    required this.animals,
    required this.kpis,
  });

  final AnimalGroup group;
  final List<Animal> animals;
  final GroupKpis kpis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lactating = lactatingAnimalsInGroup(animals);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GroupMilkingVolumeCard(
          kpis: kpis,
          onRecord: lactating.isEmpty
              ? null
              : () => context.push('/groups/${group.id}/record-milk'),
        ),
        const SizedBox(height: 12),
        GroupTopProducersCard(animals: animals),
        const SizedBox(height: 12),
        GroupMilkTrendCard(
          values: GroupMockExtras.milkTrend30Day(group.id),
        ),
      ],
    );
  }
}

class _HealthTab extends StatelessWidget {
  const _HealthTab({
    required this.animals,
    required this.kpis,
    required this.groupId,
  });

  final List<Animal> animals;
  final GroupKpis kpis;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sick = GroupMockExtras.displaySickCount(groupId, kpis.sick);
    final withdrawal =
        GroupMockExtras.displayWithdrawalCount(groupId, kpis.onWithdrawal);
    final alert = GroupMockExtras.healthAlert(groupId);
    final vaccinations = GroupMockExtras.vaccinations(groupId);
    final treatments = GroupMockExtras.treatments(groupId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GroupHealthStatusRow(
          sick: sick,
          onWithdrawal: withdrawal,
          avgWithdrawalDays: withdrawal > 0 ? 4 : null,
        ),
        if (alert != null) ...[
          const SizedBox(height: 12),
          GroupHealthAlertCard(alert: alert),
        ],
        if (vaccinations.isNotEmpty) ...[
          const SizedBox(height: 12),
          groupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.recentVaccinations, style: GhTypography.h03),
                const SizedBox(height: 12),
                for (var i = 0; i < vaccinations.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vaccinations[i].name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            vaccinations[i].dateLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            vaccinations[i].cycleLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: GhColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        if (treatments.isNotEmpty) ...[
          const SizedBox(height: 12),
          groupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.activeTreatments, style: GhTypography.h03),
                const SizedBox(height: 12),
                for (final t in treatments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                t.detail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: GhColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          t.progressLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (sick > 0) ...[
          const SizedBox(height: 12),
          Text(l10n.sickAnimals, style: GhTypography.h03),
          const SizedBox(height: 8),
          for (final a in animals.where((x) => x.tags.contains(AnimalTagType.sick)))
            GroupAnimalCard(
              animal: a,
              onTap: () => context.push('/animals/${a.id}?tab=4'),
            ),
        ],
      ],
    );
  }
}
