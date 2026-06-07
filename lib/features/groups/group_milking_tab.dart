import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/models.dart';
import '../animals/lactation_cycle_editor.dart';
import 'group_detail_widgets.dart';
import 'group_kpis.dart';
import 'group_mock_extras.dart';
import 'group_milk_record.dart';

class GroupMilkingTab extends ConsumerWidget {
  const GroupMilkingTab({
    super.key,
    required this.group,
    required this.animals,
    required this.kpis,
    required this.groupId,
    required this.onAnimalsChanged,
  });

  final AnimalGroup group;
  final List<Animal> animals;
  final GroupKpis kpis;
  final String groupId;
  final VoidCallback onAnimalsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lactating = lactatingAnimalsInGroup(animals);
    final eligible = milkingEligibleFemales(animals);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GroupMilkingVolumeCard(
          kpis: kpis,
          onRecord: lactating.isEmpty
              ? null
              : () => context.push('/groups/$groupId/record-milk'),
        ),
        if (eligible.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.groupLactationCycleTitle, style: GhTypography.h03),
          const SizedBox(height: 4),
          Text(
            l10n.groupLactationCycleHint,
            style: const TextStyle(
              fontSize: 13,
              color: GhColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...eligible.map(
            (animal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: groupSectionCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${animal.name.isEmpty ? animal.tag : animal.name} #${animal.tag}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LactationCycleEditor(
                      animal: animal,
                      compact: true,
                      onUpdated: onAnimalsChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
