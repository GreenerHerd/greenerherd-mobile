import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/services/group_purpose_kpi.dart';
import '../../../shared/widgets/gh_design_icons.dart';
import '../../../shared/widgets/group_purpose_badge.dart';
import '../../../shared/widgets/species_icon.dart';

/// Horizontal group filter strip from design_handoff `GroupsStrip`.
class HerdGroupsStrip extends ConsumerWidget {
  const HerdGroupsStrip({
    super.key,
    required this.groups,
    required this.animals,
  });

  final List<AnimalGroup> groups;
  final List<Animal> animals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesFilter = ref.watch(selectedSpeciesFilterProvider);
    final groupFilter = ref.watch(selectedGroupFilterProvider);
    final visible = speciesFilter == null
        ? groups
        : groups.where((g) => g.species == speciesFilter).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Image.asset(
                GhDesignIcons.animalGroup,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Groups · ${visible.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (groupFilter != null) ...[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: () => ref
                      .read(selectedGroupFilterProvider.notifier)
                      .state = null,
                  backgroundColor: GhColors.primaryLight,
                  labelStyle: const TextStyle(
                    color: GhColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/groups'),
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
        ),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final g = visible[i];
              final selected = groupFilter == g.id;
              final members =
                  animals.where((a) => a.groupId == g.id).toList();
              final kpi = GroupPurposeKpi.forGroup(g, members);
              final needsAttention = g.needsAttention(members);

              return GestureDetector(
                onTap: () => context.push('/groups/${g.id}'),
                child: Container(
                  width: 184,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? GhColors.primaryLight.withValues(alpha: 0.45)
                        : GhColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? GhColors.primary : GhColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SpeciesIcon.avatar(g.species, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GroupPurposeBadge(purpose: g.purpose),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kpi.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: GhColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kpi.value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: needsAttention
                                        ? GhColors.error
                                        : GhColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${members.isNotEmpty ? members.length : g.headCount} head',
                            style: const TextStyle(
                              fontSize: 11,
                              color: GhColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
