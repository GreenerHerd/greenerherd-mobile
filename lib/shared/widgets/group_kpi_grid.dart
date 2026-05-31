import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import '../../features/groups/group_kpis.dart';
import 'gh_stat.dart';

/// Compact group KPIs in a 3-column grid.
class GroupKpiGrid extends StatelessWidget {
  const GroupKpiGrid({super.key, required this.kpis});

  final GroupKpis kpis;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.65,
      children: [
        GhStat(label: 'In group', value: '${kpis.headCount}', dense: true),
        GhStat(
          label: 'Males',
          value: '${kpis.maleCount}',
          valueColor:
              kpis.maleCount > 0 ? GhColors.secondary : GhColors.textSecondary,
          dense: true,
        ),
        GhStat(label: 'Females', value: '${kpis.femaleCount}', dense: true),
        GhStat(
          label: 'Pregnant',
          value: '${kpis.pregnant}',
          valueColor: GhColors.primary,
          dense: true,
        ),
        GhStat(
          label: 'Sick',
          value: '${kpis.sick}',
          valueColor: kpis.sick > 0 ? GhColors.error : GhColors.textSecondary,
          dense: true,
        ),
        GhStat(label: 'Lactating', value: '${kpis.lactating}', dense: true),
        if (kpis.avgMilkLitres != null)
          GhStat(
            label: 'Avg milk',
            value: '${kpis.avgMilkLitres!.toStringAsFixed(1)} L',
            dense: true,
          ),
        GhStat(
          label: 'Avg weight',
          value: '${kpis.avgWeightKg.toInt()} kg',
          dense: true,
        ),
      ],
    );
  }
}
