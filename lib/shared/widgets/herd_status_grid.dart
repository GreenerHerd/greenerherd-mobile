import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import 'gh_stat.dart';

/// Herd status counts in a 3-column compact grid.
class HerdStatusGrid extends StatelessWidget {
  const HerdStatusGrid({
    super.key,
    required this.pregnant,
    required this.readyToBreed,
    required this.sick,
    required this.cullFlagged,
    required this.lactating,
    this.onStatTap,
    this.labels = const HerdStatusLabels(),
  });

  final int pregnant;
  final int readyToBreed;
  final int sick;
  final int cullFlagged;
  final int lactating;
  final VoidCallback? onStatTap;
  final HerdStatusLabels labels;

  @override
  Widget build(BuildContext context) {
    final l = labels;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GhStat(
                label: l.pregnant,
                value: '$pregnant',
                compact: true,
                onTap: onStatTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GhStat(
                label: l.readyToBreed,
                value: '$readyToBreed',
                compact: true,
                onTap: onStatTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GhStat(
                label: l.sick,
                value: '$sick',
                valueColor: sick > 0 ? GhColors.error : null,
                compact: true,
                onTap: onStatTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GhStat(
                label: l.cullFlagged,
                value: '$cullFlagged',
                valueColor: cullFlagged > 0 ? GhColors.warning : null,
                compact: true,
                onTap: onStatTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GhStat(
                label: l.lactating,
                value: '$lactating',
                compact: true,
                onTap: onStatTap,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class HerdStatusLabels {
  const HerdStatusLabels({
    this.pregnant = 'Pregnant',
    this.readyToBreed = 'Ready to breed',
    this.sick = 'Sick',
    this.cullFlagged = 'Cull flagged',
    this.lactating = 'Lactating',
  });

  final String pregnant;
  final String readyToBreed;
  final String sick;
  final String cullFlagged;
  final String lactating;
}
