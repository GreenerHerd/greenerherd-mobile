import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/models.dart';
import '../../data/services/nutrition_traffic_light.dart';

/// Nutrition intake vs target with dry matter and energy progress bars.
class NutritionRatingCard extends StatelessWidget {
  const NutritionRatingCard({
    super.key,
    required this.gap,
    this.onFixGap,
  });

  final NutritionGap gap;
  final VoidCallback? onFixGap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final badge = _badgeStyle(gap.gapBadgeLabel);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GhColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Nutrition', style: GhTypography.h03),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badge.background,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badge.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gap.gapBadgeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: badge.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _NutrientRow(
              label: 'Dry matter',
              actual: gap.dryMatterActualKg,
              target: gap.dryMatterTargetKg,
              unit: 'kg',
            ),
            const SizedBox(height: 14),
            _NutrientRow(
              label: 'Energy',
              actual: gap.energyActualMj,
              target: gap.energyTargetMj,
              unit: 'MJ',
            ),
            if (gap.proteinActualKg != null && gap.proteinTargetKg != null) ...[
              const SizedBox(height: 14),
              _NutrientRow(
                label: 'Protein',
                actual: gap.proteinActualKg!,
                target: gap.proteinTargetKg!,
                unit: 'kg',
              ),
            ],
            if (gap.ndfActualKg != null && gap.ndfTargetKg != null) ...[
              const SizedBox(height: 14),
              _NutrientRow(
                label: l10n.ndf,
                actual: gap.ndfActualKg!,
                target: gap.ndfTargetKg!,
                unit: 'kg',
              ),
            ],
            if (gap.calciumActualKg != null && gap.calciumTargetKg != null) ...[
              const SizedBox(height: 14),
              _NutrientRow(
                label: l10n.calcium,
                actual: gap.calciumActualKg!,
                target: gap.calciumTargetKg!,
                unit: 'kg',
              ),
            ],
            if (gap.phosphorusActualKg != null &&
                gap.phosphorusTargetKg != null) ...[
              const SizedBox(height: 14),
              _NutrientRow(
                label: l10n.phosphorus,
                actual: gap.phosphorusActualKg!,
                target: gap.phosphorusTargetKg!,
                unit: 'kg',
              ),
            ],
            if (onFixGap != null && gap.hasGap) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onFixGap,
                  child: const Text('Fix the gap'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _BadgeStyle _badgeStyle(String label) {
    if (label == 'On target') {
      return _BadgeStyle(
        background: GhColors.successLight,
        dot: GhColors.success,
        text: GhColors.success,
      );
    }
    final light = nutritionTrafficLight(gap.energyDeviationPct);
    return switch (light) {
      NutritionTrafficLight.green => _BadgeStyle(
          background: GhColors.successLight,
          dot: GhColors.success,
          text: GhColors.success,
        ),
      NutritionTrafficLight.orange => _BadgeStyle(
          background: GhColors.warningLight,
          dot: GhColors.warning,
          text: GhColors.warning,
        ),
      NutritionTrafficLight.red => _BadgeStyle(
          background: GhColors.warningLight,
          dot: GhColors.warning,
          text: GhColors.warning,
        ),
    };
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.background,
    required this.dot,
    required this.text,
  });

  final Color background;
  final Color dot;
  final Color text;
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
  });

  final String label;
  final double actual;
  final double target;
  final String unit;

  Color _barColor() {
    if (target <= 0) return GhColors.border;
    final ratio = actual / target;
    if (ratio >= 0.9) return GhColors.primary;
    if (ratio >= 0.75) return GhColors.warning;
    return GhColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    final actualText = actual == actual.roundToDouble()
        ? actual.toInt().toString()
        : actual.toStringAsFixed(0);
    final targetText = target == target.roundToDouble()
        ? target.toInt().toString()
        : target.toStringAsFixed(0);

    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: _barColor(),
              backgroundColor: GhColors.border,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 108,
          child: Text(
            '$actualText / $targetText $unit',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GhColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
