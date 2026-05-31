import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/models.dart';
import '../../data/services/nutrition_traffic_light.dart';

/// Shared "Today v Required Nutrition" rows used on the group tab and Fix the gap.
class NutritionTodayVsRequirementPanel extends StatelessWidget {
  const NutritionTodayVsRequirementPanel({
    super.key,
    required this.gap,
    this.hasLoggedFeedToday = true,
  });

  final NutritionGap gap;
  final bool hasLoggedFeedToday;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(l10n.todayVsRequirement, style: GhTypography.h03),
            const Spacer(),
            Text(
              l10n.perHead,
              style: GhTypography.muted.copyWith(fontSize: 12),
            ),
          ],
        ),
        if (!hasLoggedFeedToday) ...[
          const SizedBox(height: 8),
          Text(
            l10n.nutritionNoFeedLoggedHint,
            style: GhTypography.muted.copyWith(fontSize: 12, height: 1.35),
          ),
        ],
        const SizedBox(height: 16),
        NutritionRequirementRow(
          label: l10n.dryMatter,
          actual: gap.dryMatterActualKg,
          target: gap.dryMatterTargetKg,
          unit: 'kg',
        ),
        const SizedBox(height: 12),
        if (gap.proteinActualKg != null && gap.proteinTargetKg != null)
          NutritionRequirementRow(
            label: l10n.crudeProtein,
            actual: gap.proteinActualKg!,
            target: gap.proteinTargetKg!,
            unit: 'kg',
          ),
        if (gap.proteinActualKg != null) const SizedBox(height: 12),
        NutritionRequirementRow(
          label: l10n.energyMe,
          actual: gap.energyActualMj,
          target: gap.energyTargetMj,
          unit: 'MJ',
        ),
        if (gap.ndfActualKg != null && gap.ndfTargetKg != null) ...[
          const SizedBox(height: 12),
          NutritionRequirementRow(
            label: l10n.ndf,
            actual: gap.ndfActualKg!,
            target: gap.ndfTargetKg!,
            unit: 'kg',
          ),
        ],
        if (gap.calciumActualKg != null && gap.calciumTargetKg != null) ...[
          const SizedBox(height: 12),
          NutritionRequirementRow(
            label: l10n.calcium,
            actual: gap.calciumActualKg!,
            target: gap.calciumTargetKg!,
            unit: 'kg',
          ),
        ],
        if (gap.phosphorusActualKg != null &&
            gap.phosphorusTargetKg != null) ...[
          const SizedBox(height: 12),
          NutritionRequirementRow(
            label: l10n.phosphorus,
            actual: gap.phosphorusActualKg!,
            target: gap.phosphorusTargetKg!,
            unit: 'kg',
          ),
        ],
        const SizedBox(height: 14),
        const NutritionTrafficLightLegend(),
      ],
    );
  }
}

class NutritionRequirementRow extends StatelessWidget {
  const NutritionRequirementRow({
    super.key,
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
  });

  final String label;
  final double actual;
  final double target;
  final String unit;

  Color _color() {
    final dev = target == 0 ? 0.0 : ((actual - target) / target) * 100;
    return switch (nutritionTrafficLight(dev)) {
      NutritionTrafficLight.green => GhColors.primary,
      NutritionTrafficLight.orange => GhColors.warning,
      NutritionTrafficLight.red => GhColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (actual / target).clamp(0.0, 1.05) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 8,
              color: _color(),
              backgroundColor: GhColors.border,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_fmt(actual)} / ${_fmt(target)} $unit',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class NutritionTrafficLightLegend extends StatelessWidget {
  const NutritionTrafficLightLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        _LegendDot(color: GhColors.primary, label: l10n.legendOk),
        const SizedBox(width: 12),
        _LegendDot(color: GhColors.warning, label: l10n.legendWarning),
        const SizedBox(width: 12),
        _LegendDot(color: GhColors.error, label: l10n.legendAction),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: GhColors.textSecondary),
        ),
      ],
    );
  }
}

/// Bordered card wrapper matching group nutrition sections.
Widget nutritionTodaySectionCard({required Widget child}) {
  return Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: GhColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}
