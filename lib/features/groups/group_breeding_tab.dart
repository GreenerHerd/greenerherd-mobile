import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/mock/profile_mock_data.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/gh_stat.dart';
import 'group_breeding_animal_row.dart';
import 'group_breeding_cycle_kpi_card.dart';
import 'group_detail_widgets.dart';
import 'group_kpis.dart';

class GroupBreedingTab extends ConsumerWidget {
  const GroupBreedingTab({
    super.key,
    required this.group,
    required this.animals,
    required this.kpis,
    required this.groupId,
  });

  final AnimalGroup group;
  final List<Animal> animals;
  final GroupKpis kpis;
  final String groupId;

  bool get _isBreedingPurpose =>
      group.purpose == GroupPurpose.breeding ||
      group.purpose == GroupPurpose.pregnant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dash = ProfileMockData.groupBreedingDashboard(group.id);
    final cycleSummary = GroupBreedingCycleSummary.fromMembers(animals);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cycleSummary != null) ...[
          GroupBreedingCycleKpiCard(
            summary: cycleSummary,
            species: group.species,
          ),
          const SizedBox(height: 16),
        ],
        if (dash != null) ...[
          Row(
            children: [
              Expanded(
                child: GhStat(
                  label: l10n.aiAttempts30d,
                  value: '${dash.aiAttempts30d}',
                  dense: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhStat(
                  label: l10n.confirmed,
                  value: '${dash.confirmedPregnant}',
                  valueColor: GhColors.success,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GhStat(
                  label: l10n.successRate,
                  value: '${dash.successRatePct}%',
                  valueColor: GhColors.success,
                  dense: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GhStat(
                  label: l10n.miscarriagesCount,
                  value: '${dash.miscarriages}',
                  valueColor: GhColors.warning,
                  dense: true,
                ),
              ),
            ],
          ),
          if (dash.successThresholdNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dash.successThresholdNote,
              style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          groupSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.aiProviderPerformance, style: GhTypography.h03),
                const SizedBox(height: 12),
                for (final p in dash.providers) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              p.detail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: GhColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${p.ratePct}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: GhColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (p != dash.providers.last) const Divider(height: 20),
                ],
              ],
            ),
          ),
          if (dash.failedAiAlert != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GhColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GhColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: GhColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dash.failedAiAlert!.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: GhColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dash.failedAiAlert!.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: GhColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ] else if (!_isBreedingPurpose) ...[
          Text(
            l10n.openAnimalsForBreeding,
            style: const TextStyle(color: GhColors.textSecondary),
          ),
          const SizedBox(height: 16),
        ],
        if (_isBreedingPurpose) ...[
          Text(l10n.tabAnimals, style: GhTypography.h03),
          const SizedBox(height: 12),
          if (animals.isEmpty)
            Text(
              l10n.noAnimalsInGroup,
              style: const TextStyle(color: GhColors.textSecondary),
            )
          else
            for (final animal in animals)
              GroupBreedingAnimalRow(
                key: ValueKey(animal.id),
                animal: animal,
                species: group.species,
                groupId: groupId,
              ),
        ],
      ],
    );
  }
}
