import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/gh_stat.dart';
import 'group_detail_widgets.dart';

/// Group breeding tab KPI: herd-level months since calving for lactation nutrition
/// and re-breeding cycle planning.
class GroupBreedingCycleKpiCard extends StatelessWidget {
  const GroupBreedingCycleKpiCard({
    super.key,
    required this.summary,
    required this.species,
  });

  final GroupBreedingCycleSummary summary;
  final Species species;

  String _lactationStageLabel(BuildContext context, String stageKey) {
    final l10n = context.l10n;
    return switch (stageKey) {
      'fresh' => l10n.lactationStageFresh,
      'peak' => l10n.lactationStagePeak,
      'mid' => l10n.lactationStageMid,
      'late' => l10n.lactationStageLate,
      _ => stageKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final median = summary.medianMonthsSinceCalving;
    final minRebreed =
        ReproductionStatusRules.minMonthsSinceCalvingForRebreeding(species);
    final stageEntries = summary.lactationStageCounts.entries
        .where((e) => e.value > 0)
        .toList();

    return groupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.groupBreedingCycleKpiTitle, style: GhTypography.h03),
          const SizedBox(height: 4),
          Text(
            l10n.groupBreedingCycleKpiSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: GhColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GhStat(
                  label: l10n.groupMedianMonthsSinceCalving,
                  value: median?.toString() ?? '—',
                  valueColor: GhColors.primary,
                  dense: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhStat(
                  label: l10n.groupLactatingFemales,
                  value: '${summary.lactatingCount}',
                  dense: true,
                ),
              ),
            ],
          ),
          if (median != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.monthsSinceCalvingValue(median),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GhStat(
                  label: l10n.groupReadyForRebreeding,
                  value: '${summary.readyForRebreedingCount}',
                  valueColor: GhColors.success,
                  dense: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhStat(
                  label: l10n.groupWaitingForRebreeding,
                  value: '${summary.waitingCount}',
                  valueColor: GhColors.warning,
                  dense: true,
                ),
              ),
            ],
          ),
          if (stageEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.groupLactationStageBreakdown, style: GhTypography.h05),
            const SizedBox(height: 8),
            for (final entry in stageEntries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _lactationStageLabel(context, entry.key),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      l10n.groupAnimalsCount(entry.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.groupBreedingCycleNutritionNote(minRebreed),
            style: const TextStyle(
              fontSize: 12,
              color: GhColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
