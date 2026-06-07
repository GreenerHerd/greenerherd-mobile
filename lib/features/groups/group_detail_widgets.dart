import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/animal_avatar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import '../../shared/widgets/gh_status_tag.dart';
import '../../shared/widgets/nutrition_rating_card.dart';
import '../../shared/widgets/nutrition_today_vs_requirement_panel.dart';
import '../nutrition/nutrition_providers.dart';
import 'group_kpis.dart';
import 'group_mock_extras.dart';

Widget groupSectionCard({required Widget child, EdgeInsets? padding}) {
  return Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: GhColors.border),
    ),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    ),
  );
}

class GroupPurposeDescriptionCard extends StatelessWidget {
  const GroupPurposeDescriptionCard({
    super.key,
    required this.group,
    this.onEdit,
  });

  final AnimalGroup group;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.purposeHeading,
                      style: GhTypography.labelXs.copyWith(
                        color: GhColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: GhColors.primaryLight.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        GroupMockExtras.purposeLabel(group.purpose),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: GhColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.edit),
                  style: TextButton.styleFrom(
                    foregroundColor: GhColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.descriptionHeading,
            style: GhTypography.labelXs.copyWith(color: GhColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            group.description ?? l10n.noDescriptionRecorded,
            style: GhTypography.body,
          ),
        ],
      ),
    );
  }
}

class GroupBreedingKpisCard extends StatelessWidget {
  const GroupBreedingKpisCard({
    super.key,
    required this.pregnancyRatePct,
    required this.aiAttempts30d,
    required this.confirmed,
  });

  final int pregnancyRatePct;
  final int aiAttempts30d;
  final int confirmed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.breedingKpis, style: GhTypography.h03),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GhColors.successLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: GhColors.success),
                    const SizedBox(width: 6),
                    Text(
                      l10n.live,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: GhColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.pregnancyRate.toUpperCase(),
                    value: '$pregnancyRatePct%',
                  ),
                ),
                const VerticalDivider(width: 24, color: GhColors.border),
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.aiAttempts30d.toUpperCase(),
                    value: '$aiAttempts30d',
                  ),
                ),
                const VerticalDivider(width: 24, color: GhColors.border),
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.confirmed.toUpperCase(),
                    value: '$confirmed',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupMilkingKpisCard extends StatelessWidget {
  const GroupMilkingKpisCard({super.key, required this.kpis});

  final GroupKpis kpis;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final avg = kpis.avgMilkLitres ?? 0;
    final total = kpis.todayTotalMilkLitres ?? 0;

    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.milkingKpis, style: GhTypography.h03),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GhColors.successLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: GhColors.success),
                    const SizedBox(width: 6),
                    Text(
                      l10n.live,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: GhColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.avgPerHead.toUpperCase(),
                    value: '${avg.toStringAsFixed(1)} L',
                  ),
                ),
                const VerticalDivider(width: 24, color: GhColors.border),
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.todayTotal.toUpperCase(),
                    value: '${total.toStringAsFixed(0)} L',
                  ),
                ),
                const VerticalDivider(width: 24, color: GhColors.border),
                Expanded(
                  child: _MilkingKpiColumn(
                    label: l10n.onWithdrawal.toUpperCase(),
                    value: '${kpis.onWithdrawal}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilkingKpiColumn extends StatelessWidget {
  const _MilkingKpiColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GhTypography.labelXs.copyWith(color: GhColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class GroupOverviewStatGrid extends StatelessWidget {
  const GroupOverviewStatGrid({
    super.key,
    required this.kpis,
    required this.registeredHeadCount,
  });

  final GroupKpis kpis;
  final int registeredHeadCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _OverviewStatTile(
                icon: Icons.list_alt_outlined,
                label: l10n.animalsCount.toUpperCase(),
                value: '$registeredHeadCount',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewStatTile(
                icon: Icons.favorite_border,
                label: l10n.females.toUpperCase(),
                value: '${kpis.femaleCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _OverviewStatTile(
                designIcon: GhDesignIcons.welfare,
                label: l10n.pregnant.toUpperCase(),
                value: '${kpis.pregnant}',
                valueColor: GhColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewStatTile(
                designIcon: GhDesignIcons.medication,
                label: l10n.sick.toUpperCase(),
                value: '${kpis.sick}',
                valueColor: kpis.sick > 0 ? GhColors.error : GhColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewStatTile extends StatelessWidget {
  const _OverviewStatTile({
    this.icon,
    this.designIcon,
    required this.label,
    required this.value,
    this.valueColor,
  }) : assert(icon != null || designIcon != null);

  final IconData? icon;
  final String? designIcon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return groupSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GhTypography.labelXs
                      .copyWith(color: GhColors.textSecondary),
                ),
              ),
              const SizedBox(width: 4),
              if (designIcon != null)
                GhDesignIcon(
                  assetPath: designIcon!,
                  size: 18,
                  opacity: 0.85,
                )
              else
                Icon(icon, size: 18, color: GhColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: valueColor ?? GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class GroupAnimalCard extends StatelessWidget {
  const GroupAnimalCard({
    super.key,
    required this.animal,
    required this.onTap,
  });

  final Animal animal;
  final VoidCallback onTap;

  AnimalTagType? get _primaryTag {
    if (animal.tags.contains(AnimalTagType.lactating)) {
      return AnimalTagType.lactating;
    }
    if (animal.tags.isNotEmpty) return animal.tags.first;
    return null;
  }

  static String _subtitleLine(Animal animal) {
    final parts = <String>[
      animal.breed,
      '${animal.weightKg.toInt()} kg',
    ];
    final age = animal.ageLabel.trim();
    if (age.isNotEmpty && age != '—') parts.add(age);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: groupSectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              AnimalAvatar(animal: animal, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${animal.name} #${animal.tag}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleLine(animal),
                      style: const TextStyle(
                        fontSize: 13,
                        color: GhColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_primaryTag != null) GhStatusTag(tag: _primaryTag!),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupNutritionTodayCard extends StatelessWidget {
  const GroupNutritionTodayCard({
    super.key,
    required this.gap,
    this.hasLoggedFeedToday = true,
    this.onFixGap,
  });

  final NutritionGap gap;
  final bool hasLoggedFeedToday;
  final VoidCallback? onFixGap;

  @override
  Widget build(BuildContext context) {
    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NutritionTodayVsRequirementPanel(
            gap: gap,
            hasLoggedFeedToday: hasLoggedFeedToday,
          ),
          if (hasLoggedFeedToday &&
              gap.hasGap &&
              gap.fixGapMessage != null) ...[
            const SizedBox(height: 16),
            _EnergyGapInsightCard(
              message: gap.fixGapMessage!,
              onFixGap: onFixGap,
            ),
          ],
        ],
      ),
    );
  }
}

class _EnergyGapInsightCard extends StatelessWidget {
  const _EnergyGapInsightCard({
    required this.message,
    this.onFixGap,
  });

  final String message;
  final VoidCallback? onFixGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GhColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco_outlined, color: GhColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                context.l10n.energyGapDetected,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
          if (onFixGap != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFixGap,
                child: Text(context.l10n.fixTheGap),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Saves today's feed weight edits when invoked.
typedef FeedWeightSaver = Future<void> Function();

class GroupTodaysFeedCard extends ConsumerStatefulWidget {
  const GroupTodaysFeedCard({super.key, 
    required this.entries,
    required this.groupId,
    this.onRecord,
  });

  final List<GroupFeedEntry> entries;
  final String groupId;
  final VoidCallback? onRecord;

  @override
  ConsumerState<GroupTodaysFeedCard> createState() =>
      _GroupTodaysFeedCardState();
}

class _GroupTodaysFeedCardState extends ConsumerState<GroupTodaysFeedCard> {
  final _savers = <FeedWeightSaver>[];

  void _registerSaver(FeedWeightSaver saver) {
    if (!_savers.contains(saver)) _savers.add(saver);
  }

  void _unregisterSaver(FeedWeightSaver saver) {
    _savers.remove(saver);
  }

  Future<void> _saveAllAndRefresh() async {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final save in List<FeedWeightSaver>.from(_savers)) {
      await save();
    }
    ref.invalidate(groupTodaysFeedProvider(widget.groupId));
    ref.invalidate(groupNutritionDisplayGapProvider(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.todaysFeed, style: GhTypography.h03),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  if (widget.entries.isEmpty) {
                    widget.onRecord?.call();
                    return;
                  }
                  await _saveAllAndRefresh();
                },
                child: Text(l10n.updateAction),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.entries.isEmpty)
            Text(l10n.noFeedToday, style: GhTypography.muted)
          else
            for (var i = 0; i < widget.entries.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _EditableFeedRow(
                key: ValueKey(widget.entries[i].id),
                entry: widget.entries[i],
                groupId: widget.groupId,
                registerSaver: _registerSaver,
                unregisterSaver: _unregisterSaver,
              ),
            ],
        ],
      ),
    );
  }
}

class _EditableFeedRow extends ConsumerStatefulWidget {
  const _EditableFeedRow({
    super.key,
    required this.entry,
    required this.groupId,
    required this.registerSaver,
    required this.unregisterSaver,
  });

  final GroupFeedEntry entry;
  final String groupId;
  final void Function(FeedWeightSaver saver) registerSaver;
  final void Function(FeedWeightSaver saver) unregisterSaver;

  @override
  ConsumerState<_EditableFeedRow> createState() => _EditableFeedRowState();
}

class _EditableFeedRowState extends ConsumerState<_EditableFeedRow> {
  late final TextEditingController _kgController;
  late final FocusNode _focusNode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController(text: _formatKg(widget.entry.weightKg));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.registerSaver(_saveWeight);
  }

  @override
  void didUpdateWidget(covariant _EditableFeedRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.weightKg != widget.entry.weightKg &&
        oldWidget.entry.id == widget.entry.id) {
      final next = _formatKg(widget.entry.weightKg);
      if (!_focusNode.hasFocus && _kgController.text != next) {
        _kgController.text = next;
      }
    }
  }

  @override
  void dispose() {
    widget.unregisterSaver(_saveWeight);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _kgController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveWeight();
    }
  }

  static String _formatKg(double kg) =>
      kg == kg.roundToDouble() ? '${kg.toInt()}' : kg.toStringAsFixed(1);

  void _refreshNutrition() {
    ref.invalidate(groupTodaysFeedProvider(widget.groupId));
    ref.invalidate(groupNutritionDisplayGapProvider(widget.groupId));
  }

  Future<void> _saveWeight() async {
    if (_saving) return;
    final kg = double.tryParse(_kgController.text.trim());
    if (kg == null || kg <= 0) {
      if (!mounted) return;
      if (_focusNode.hasFocus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid weight (kg)')),
        );
      }
      return;
    }
    if ((kg - widget.entry.weightKg).abs() < 0.01) return;

    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).updateTodaysFeedWeight(
            entryId: widget.entry.id,
            weightKg: kg,
          );
      if (!mounted) return;
      _refreshNutrition();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.grass, color: GhColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final updated = await context.push<bool>(
                '/groups/${widget.groupId}/todays-feed/${entry.id}',
              );
              if (updated == true) {
                _refreshNutrition();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    entry.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_saving)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          SizedBox(
            width: 92,
            child: TextField(
              controller: _kgController,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              decoration: const InputDecoration(
                isDense: true,
                suffixText: 'kg',
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              onSubmitted: (_) => _saveWeight(),
              onEditingComplete: _saveWeight,
            ),
          ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(
            'SAR ${entry.costSar.toInt()}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class GroupHerdRequirementsCard extends ConsumerWidget {
  const GroupHerdRequirementsCard({super.key, required this.groupId});

  final String groupId;

  static String _formatNum(num value) =>
      value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final aggregatedAsync =
        ref.watch(groupAggregatedRequirementsProvider(groupId));

    return aggregatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (aggregated) {
        if (aggregated == null || aggregated.headCount == 0) {
          return const SizedBox.shrink();
        }
        final totals = aggregated.groupTotals;
        final isSmallRuminant = aggregated.optimizer == 'small_ruminant';
        final profileCodes =
            aggregated.members.map((m) => m.profileCode).toSet();

        return groupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.groupHerdRequirementsTitle, style: GhTypography.h03),
              const SizedBox(height: 4),
              Text(
                l10n.groupHerdRequirementsSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: GhColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.groupHerdRequirementsProfiles(aggregated.headCount),
                style: const TextStyle(
                  fontSize: 11,
                  color: GhColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _HerdRequirementRow(
                label: l10n.dryMatter,
                value:
                    '${_formatNum(totals['dry_matter_kg'] ?? 0)} kg/day',
              ),
              _HerdRequirementRow(
                label: l10n.crudeProtein,
                value:
                    '${_formatNum(isSmallRuminant ? totals['protein_kg'] ?? 0 : totals['crude_protein_kg'] ?? 0)} kg/day',
              ),
              if (isSmallRuminant)
                _HerdRequirementRow(
                  label: 'TDN',
                  value: '${_formatNum(totals['tdn_kg'] ?? 0)} kg/day',
                )
              else
                _HerdRequirementRow(
                  label: 'Energy (NEm)',
                  value: '${_formatNum(totals['nem_mcal'] ?? 0)} Mcal/day',
                ),
              if (profileCodes.length > 1) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final code in profileCodes.take(4))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GhColors.primaryLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code.replaceAll('_', ' '),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: GhColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HerdRequirementRow extends StatelessWidget {
  const _HerdRequirementRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: GhColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class GroupDailyCostCard extends StatelessWidget {
  const GroupDailyCostCard({super.key, required this.gap});

  final NutritionGap gap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (gap.dailyCostPerHeadSar == null) return const SizedBox.shrink();
    final change = gap.dailyCostChangePct;

    return groupSectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyCostPerHead.toUpperCase(),
                  style: GhTypography.labelXs.copyWith(
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SAR ${gap.dailyCostPerHeadSar!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (change != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GhColors.successLight,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${change > 0 ? '+' : ''}${change.toStringAsFixed(0)}% vs last week',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GhColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GroupMilkingVolumeCard extends StatelessWidget {
  const GroupMilkingVolumeCard({
    super.key,
    required this.kpis,
    this.onRecord,
  });

  final GroupKpis kpis;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = kpis.todayTotalMilkLitres ?? 0;
    final avg = kpis.avgMilkLitres ?? 0;
    final milking = kpis.lactating;

    return groupSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaysVolume.toUpperCase(),
                  style: GhTypography.labelXs.copyWith(
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${total.toStringAsFixed(1)} L',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.avgLitresMilking(avg.toStringAsFixed(1), milking),
                  style: GhTypography.muted.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onRecord,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text('+ ${l10n.recordAction}'),
          ),
        ],
      ),
    );
  }
}

class GroupTopProducersCard extends StatelessWidget {
  const GroupTopProducersCard({super.key, required this.animals});

  final List<Animal> animals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final producers = animals
        .where((a) => a.milkTodayLitres != null)
        .toList()
      ..sort((a, b) => b.milkTodayLitres!.compareTo(a.milkTodayLitres!));

    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.topProducers, style: GhTypography.h03),
          const SizedBox(height: 12),
          if (producers.isEmpty)
            Text(l10n.noMilkToday, style: GhTypography.muted)
          else
            for (var i = 0; i < producers.length && i < 5; i++) ...[
              if (i > 0) const Divider(height: 20),
              _ProducerRow(animal: producers[i]),
            ],
        ],
      ),
    );
  }
}

class _ProducerRow extends StatelessWidget {
  const _ProducerRow({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final milk = animal.milkTodayLitres!;
    final sub = (animal.withdrawalDays ?? 0) > 0
        ? l10n.withdrawalDays(animal.withdrawalDays!)
        : animal.breed;

    return Row(
      children: [
        Expanded(
          child: Text(
            animal.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${milk.toStringAsFixed(1)} L',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: (animal.withdrawalDays ?? 0) > 0
                    ? GhColors.warning
                    : GhColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GroupMilkTrendCard extends StatelessWidget {
  const GroupMilkTrendCard({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('30-day group total', style: GhTypography.h03),
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((v) {
                final h = max > 0 ? (v / max) * 64 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: h,
                      decoration: BoxDecoration(
                        color: GhColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupHealthStatusRow extends StatelessWidget {
  const GroupHealthStatusRow({super.key, 
    required this.sick,
    required this.onWithdrawal,
    this.avgWithdrawalDays,
  });

  final int sick;
  final int onWithdrawal;
  final double? avgWithdrawalDays;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: groupSectionCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      l10n.sick.toUpperCase(),
                      style: GhTypography.labelXs.copyWith(
                        color: GhColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$sick',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: GhColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: groupSectionCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onWithdrawal.toUpperCase(),
                  style: GhTypography.labelXs.copyWith(
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$onWithdrawal',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: GhColors.warning,
                  ),
                ),
                if (avgWithdrawalDays != null)
                  Text(
                    l10n.avgWithdrawalRemaining(
                      avgWithdrawalDays!.toStringAsFixed(0),
                    ),
                    style: GhTypography.muted.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GroupHealthAlertCard extends StatelessWidget {
  const GroupHealthAlertCard({super.key, required this.alert});

  final GroupHealthAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.warning),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: GhColors.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule, color: GhColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: GhColors.warning,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.body,
                      style: const TextStyle(fontSize: 13, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              foregroundColor: GhColors.primary,
              side: const BorderSide(color: GhColors.primary),
            ),
            child: Text(alert.actionLabel),
          ),
        ],
      ),
    );
  }
}

class GroupTasksPreviewCard extends StatelessWidget {
  const GroupTasksPreviewCard({super.key, required this.preview});

  final GroupTaskPreview preview;

  @override
  Widget build(BuildContext context) {
    if (preview.count == 0) return const SizedBox.shrink();
    return groupSectionCard(
      child: Row(
        children: [
          Text(preview.label, style: GhTypography.h03),
          const Spacer(),
          Text(
            '${preview.count} open',
            style: GhTypography.muted.copyWith(fontSize: 13),
          ),
          const Icon(Icons.chevron_right, color: GhColors.textSecondary),
        ],
      ),
    );
  }
}

/// Compact nutrition summary for overview tab.
class GroupNutritionSummaryCard extends StatelessWidget {
  const GroupNutritionSummaryCard({
    super.key,
    required this.gap,
    this.onTap,
  });

  final NutritionGap gap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: NutritionRatingCard(gap: gap),
    );
  }
}

Future<bool?> openGroupNutritionFix(BuildContext context, String groupId) =>
    context.push<bool>('/nutrition/$groupId');
