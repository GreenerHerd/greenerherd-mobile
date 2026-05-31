import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gh_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/models.dart';
import '../../../data/services/group_purpose_kpi.dart';
import '../../../shared/widgets/gh_design_icons.dart';
import '../../../shared/widgets/species_icon.dart';
import '../../groups/group_mock_extras.dart';

/// Groups list with purpose KPIs (per-species dashboard).
class DashboardGroupsKpiList extends ConsumerWidget {
  const DashboardGroupsKpiList({
    super.key,
    required this.species,
    required this.groups,
    required this.animals,
  });

  final Species species;
  final List<AnimalGroup> groups;
  final List<Animal> animals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = groups.where((g) => g.species == species).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                GhDesignIcons.animalGroup,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Groups · ${filtered.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/animals?species=${species.name}'),
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GhColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No groups for this species yet.',
                style: TextStyle(color: GhColors.textSecondary),
              ),
            )
          else
            for (var i = 0; i < filtered.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _GroupRow(
                group: filtered[i],
                headCount: animals.where((a) => a.groupId == filtered[i].id).length,
                kpi: GroupPurposeKpi.forGroup(
                  filtered[i],
                  animals.where((a) => a.groupId == filtered[i].id).toList(),
                ),
                onTap: () => context.push('/groups/${filtered[i].id}'),
              ),
            ],
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.headCount,
    required this.kpi,
    required this.onTap,
  });

  final AnimalGroup group;
  final int headCount;
  final GroupPurposeKpi kpi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final purpose = GroupMockExtras.purposeLabel(group.purpose);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GhColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SpeciesIcon.avatar(group.species, size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$purpose · $headCount head',
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${kpi.label.toUpperCase()} ${kpi.value.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GhColors.primary,
                  ),
                  textAlign: TextAlign.end,
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: GhColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
