import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/nutrition_today_vs_requirement_panel.dart';
import '../tasks/task_item_extensions.dart';
import 'gap_supplement_recommendations.dart';
import 'nutrition_providers.dart';

String _formatDosageKg(double kg) =>
    kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);

double _maxKgForOption(GapSupplementOption option) {
  if (option.groupDosageCapKg != null) {
    return option.groupDosageCapKg!.clamp(1, 50);
  }
  return 50;
}

class _SupplementDosageCapHint extends StatelessWidget {
  const _SupplementDosageCapHint({required this.option});

  final GapSupplementOption option;

  @override
  Widget build(BuildContext context) {
    if (!option.hasDosageCap) return const SizedBox.shrink();
    final l10n = context.l10n;
    final perAnimal = option.perAnimalDosageCapKg;
    final groupCap = option.groupDosageCapKg;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: GhColors.warningLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GhColors.warning.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (option.isDosageCapped)
              Text(
                l10n.supplementDosageCappedHint,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: GhColors.textSecondary,
                ),
              ),
            if (perAnimal != null) ...[
              if (option.isDosageCapped) const SizedBox(height: 4),
              Text(
                l10n.supplementDosageCapPerAnimal(_formatDosageKg(perAnimal)),
                style: const TextStyle(fontSize: 11, color: GhColors.textSecondary),
              ),
            ],
            if (groupCap != null)
              Text(
                l10n.supplementDosageCapGroup(_formatDosageKg(groupCap)),
                style: const TextStyle(fontSize: 11, color: GhColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppliedSupplement {
  const _AppliedSupplement({
    required this.option,
    required this.kg,
    this.todaysFeedEntryId,
  });

  final GapSupplementOption option;
  final double kg;
  final String? todaysFeedEntryId;
}

class FeedRecommendationsScreen extends ConsumerStatefulWidget {
  const FeedRecommendationsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<FeedRecommendationsScreen> createState() =>
      _FeedRecommendationsScreenState();
}

class _FeedRecommendationsScreenState
    extends ConsumerState<FeedRecommendationsScreen> {
  bool _busy = false;
  GapSupplementSource _source = GapSupplementSource.inventory;
  final Map<String, double> _pickedKg = {};
  final Map<String, _AppliedSupplement> _applied = {};
  final Set<String> _buyTasksCreated = {};

  String get _supplementsKey => '${widget.groupId}|${_source.name}';

  double _dailyCost(GapSupplementOption opt, double kg) =>
      (opt.unitCostPerKg ?? 0) * kg;

  Future<int> _headCount() async {
    final animals = await ref.read(
      groupAnimalsForNutritionProvider(widget.groupId).future,
    );
    return animals.where((a) => a.status == AnimalStatus.active).length;
  }

  Future<void> _toggleSupplement(GapSupplementOption opt) async {
    if (_busy) return;
    if (_applied.containsKey(opt.id)) {
      await _removeSupplement(opt);
      return;
    }
    await _addSupplement(opt, opt.suggestedKgPerDay);
  }

  Future<void> _addSupplement(GapSupplementOption opt, double kg) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      if (opt.recordsToTodaysFeed) {
        final headCount = await _headCount();
        final entry = await ref.read(inventoryRepositoryProvider).recordSupplementToTodaysFeed(
              groupId: widget.groupId,
              productName: opt.name,
              weightKg: kg,
              feedInventoryItemId: opt.inventoryItemId,
              unitCostPerKg: opt.unitCostPerKg,
              headCount: headCount > 0 ? headCount : null,
            );
        await ref.read(nutritionRepositoryProvider).applySupplement(
              groupId: widget.groupId,
              input: opt.nutritionInputFor(kg),
            );
        _applied[opt.id] = _AppliedSupplement(
          option: opt,
          kg: kg,
          todaysFeedEntryId: entry.id,
        );
        ref.invalidate(nutritionGapProvider(widget.groupId));
        ref.invalidate(groupNutritionDisplayGapProvider(widget.groupId));
        ref.invalidate(gapSupplementsProvider(_supplementsKey));
        ref.invalidate(groupTodaysFeedProvider(widget.groupId));
        ref.invalidate(feedInventoryForGapProvider);
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      } else if (opt.createsBuyTask && !_buyTasksCreated.contains(opt.id)) {
        final subtitle = switch (opt.source) {
          GapSupplementSource.standard => l10n.standard,
          GapSupplementSource.marketplace =>
            opt.supplierName ?? l10n.marketplace,
          GapSupplementSource.inventory => l10n.inventory,
        };
        await ref.read(taskRepositoryProvider).addTask(
              TaskItem(
                id: const Uuid().v4(),
                title: l10n.buyProductTaskTitle(opt.name),
                subtitle: subtitle,
                whenLabel: l10n.today,
                dueBucket: 'today',
                overdue: false,
                tone: TaskTone.neutral,
                iconName: 'wallet',
                type: TaskType.manual,
                groupId: widget.groupId,
                actionKind: kTaskActionBuyFeed,
                feedProductName: opt.name,
                feedPurchaseSource: opt.source.name,
                feedCatalogProductNumber: opt.catalogProductNumber,
                feedMarketplaceProductId: opt.marketplaceProductId,
                feedSupplierName: opt.supplierName,
                feedDryMatterPercent: opt.dryMatterPercent,
                feedCrudeProteinPercent: opt.crudeProteinPercent,
                feedNemMcalPerKg: opt.nemMcalPerKg,
              ),
            );
        _buyTasksCreated.add(opt.id);
        ref.invalidate(dashboardStatsProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.buyTaskCreated)),
        );
      }

      setState(() => _pickedKg[opt.id] = kg);
      ref.invalidate(nutritionGapProvider(widget.groupId));
      ref.invalidate(gapSupplementsProvider(_supplementsKey));
      ref.invalidate(groupTodaysFeedProvider(widget.groupId));
      ref.invalidate(feedInventoryForGapProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeSupplement(GapSupplementOption opt) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      final applied = _applied.remove(opt.id);
      _pickedKg.remove(opt.id);
      if (applied != null && applied.option.recordsToTodaysFeed) {
        final inventory = ref.read(inventoryRepositoryProvider);
        if (applied.todaysFeedEntryId != null) {
          await inventory.removeTodaysFeedEntry(applied.todaysFeedEntryId!);
        }
        if (applied.option.inventoryItemId != null) {
          await inventory.restoreSupplementInventory(
            feedInventoryItemId: applied.option.inventoryItemId!,
            weightKg: applied.kg,
          );
        }
        await ref.read(nutritionRepositoryProvider).applySupplement(
              groupId: widget.groupId,
              input: applied.option.nutritionInputFor(applied.kg),
              subtract: true,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.supplementRemoved)),
          );
        }
      }
      ref.invalidate(nutritionGapProvider(widget.groupId));
      ref.invalidate(groupNutritionDisplayGapProvider(widget.groupId));
      ref.invalidate(gapSupplementsProvider(_supplementsKey));
      ref.invalidate(groupTodaysFeedProvider(widget.groupId));
      ref.invalidate(feedInventoryForGapProvider);
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onKgChanged(GapSupplementOption opt, double kg) async {
    if (!_applied.containsKey(opt.id)) {
      setState(() => _pickedKg[opt.id] = kg);
      return;
    }
    final previous = _applied[opt.id]!;
    await _removeSupplement(previous.option);
    await _addSupplement(opt, kg);
  }

  double _projectedDailyCost() {
    var total = 0.0;
    for (final applied in _applied.values) {
      total += _dailyCost(applied.option, applied.kg);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gapAsync = ref.watch(groupNutritionDisplayGapProvider(widget.groupId));
    final feedAsync = ref.watch(groupTodaysFeedProvider(widget.groupId));
    final supplementsAsync = ref.watch(gapSupplementsProvider(_supplementsKey));

    return Scaffold(
      appBar: GhAppBar(
        title: l10n.fixTheGap,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _applied.isNotEmpty),
        ),
      ),
      body: gapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (gap) {
          return feedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (feed) {
              return supplementsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (supplements) {
              final projectedCost = _projectedDailyCost();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  nutritionTodaySectionCard(
                    child: NutritionTodayVsRequirementPanel(
                      gap: gap,
                      hasLoggedFeedToday: feed.isNotEmpty,
                    ),
                  ),
                  if (gap.needsMarketSupplement ||
                      gap.optimizerPass == 'partial')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _MarketSupplementBanner(gap: gap),
                    ),
                  const SizedBox(height: 16),
                  Text(l10n.addSupplement, style: GhTypography.h03),
                  const SizedBox(height: 10),
                  _SourceTabs(
                    source: _source,
                    onChanged: (s) => setState(() => _source = s),
                  ),
                  const SizedBox(height: 12),
                  if (supplements.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.nothingForFilter,
                        style: const TextStyle(color: GhColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...supplements.map(
                      (opt) => _SupplementCard(
                        option: opt,
                        isPicked: _applied.containsKey(opt.id),
                        kgPerDay: _pickedKg[opt.id] ?? opt.suggestedKgPerDay,
                        busy: _busy,
                        onToggle: () => _toggleSupplement(opt),
                        onKgChanged: (kg) => _onKgChanged(opt, kg),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _CostSummaryCard(
                    projectedCost: projectedCost,
                    hint: l10n.recomputeGapHint,
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
              );
            },
          );
        },
      ),
    );
  }
}

class _SourceTabs extends StatelessWidget {
  const _SourceTabs({required this.source, required this.onChanged});

  final GapSupplementSource source;
  final ValueChanged<GapSupplementSource> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      (
        GapSupplementSource.inventory,
        l10n.inventory,
        l10n.useFromInventory,
      ),
      (
        GapSupplementSource.standard,
        l10n.standard,
        l10n.preFormulatedMixes,
      ),
      (
        GapSupplementSource.marketplace,
        l10n.marketplace,
        l10n.suppliersNearYou,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GhColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final tab in tabs)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Material(
                    color: source == tab.$1
                        ? GhColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onChanged(tab.$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Column(
                          children: [
                            Text(
                              tab.$2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: source == tab.$1
                                    ? Colors.white
                                    : GhColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.$3,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: source == tab.$1
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : GhColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _SupplementNutrientSummary extends StatelessWidget {
  const _SupplementNutrientSummary({
    required this.option,
    required this.kg,
  });

  final GapSupplementOption option;
  final double kg;

  String _formatKg(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contrib = option.contributionAt(kg);
    final energy = contrib.energyMj.toStringAsFixed(1);
    final protein = option.crudeProteinPercent != null
        ? contrib.proteinKg.toStringAsFixed(1)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recommendedFeedWeight(_formatKg(kg)),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: GhColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.supplementNutrientsAtWeight(energy, protein),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: GhColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SupplementCard extends StatelessWidget {
  const _SupplementCard({
    required this.option,
    required this.isPicked,
    required this.kgPerDay,
    required this.busy,
    required this.onToggle,
    required this.onKgChanged,
  });

  final GapSupplementOption option;
  final bool isPicked;
  final double kgPerDay;
  final bool busy;
  final VoidCallback onToggle;
  final ValueChanged<double> onKgChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxKg = _maxKgForOption(option);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: option.isTopPick
            ? const BorderSide(color: GhColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: option.isTopPick
                        ? GhColors.primary
                        : GhColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    size: 20,
                    color: option.isTopPick ? Colors.white : GhColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              option.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (option.isTopPick) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GhColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.topPick,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: GhColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SupplementNutrientSummary(
                        option: option,
                        kg: isPicked ? kgPerDay : option.suggestedKgPerDay,
                      ),
                      _SupplementDosageCapHint(option: option),
                      const SizedBox(height: 6),
                      Text(
                        option.costLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: busy ? null : onToggle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isPicked ? GhColors.primary : Colors.white,
                    foregroundColor:
                        isPicked ? Colors.white : GhColors.textPrimary,
                    side: BorderSide(
                      color: isPicked ? GhColors.primary : GhColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    isPicked ? l10n.supplementAdded : l10n.supplementAdd,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isPicked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GhColors.pageBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.quantity,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: GhColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          onKgChanged((kgPerDay - 1).clamp(1, maxKg)),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${kgPerDay == kgPerDay.roundToDouble() ? kgPerDay.toInt() : kgPerDay.toStringAsFixed(1)} ${l10n.kgPerDay}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          onKgChanged((kgPerDay + 1).clamp(1, maxKg)),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({
    required this.projectedCost,
    required this.hint,
  });

  final double projectedCost;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.projectedDailyCost,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GhColors.textSecondary,
                  ),
                ),
                Text(
                  '${projectedCost.toStringAsFixed(2)} SAR',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: GhColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketSupplementBanner extends StatelessWidget {
  const _MarketSupplementBanner({required this.gap});

  final NutritionGap gap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GhColors.warningLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          gap.fixGapMessage ??
              'Catalog feeds may not close all nutrient gaps. Add market supplements as needed.',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
