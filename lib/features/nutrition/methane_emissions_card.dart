import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/services/methane_emissions_calculator.dart';

class MethaneEmissionsCard extends StatelessWidget {
  const MethaneEmissionsCard({
    super.key,
    required this.individuals,
    required this.groupAverage,
  })  : groupTotal = null,
        headCount = null,
        summaryOnly = false;

  const MethaneEmissionsCard.summary({
    super.key,
    required this.groupTotal,
    required this.headCount,
  })  : individuals = const [],
        groupAverage = null,
        summaryOnly = true;

  final List<MethaneEmissionEstimate> individuals;
  final MethaneEmissionEstimate? groupAverage;
  final MethaneEmissionEstimate? groupTotal;
  final int? headCount;
  final bool summaryOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = summaryOnly ? groupTotal! : groupAverage!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_outlined, color: GhColors.secondary, size: 22),
                const SizedBox(width: 8),
                Text(l10n.methaneEmissions, style: GhTypography.h03),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.methaneRegionMiddleEast,
              style: GhTypography.muted.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              estimate: summary,
              summaryOnly: summaryOnly,
              headCount: headCount ?? individuals.length,
            ),
            if (!summaryOnly && individuals.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                l10n.methaneByAnimal,
                style: GhTypography.labelXs.copyWith(color: GhColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ...individuals.take(12).map(_AnimalRow.new),
              if (individuals.length > 12)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.methaneMoreAnimals(individuals.length - 12),
                    style: GhTypography.muted.copyWith(fontSize: 11),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.estimate,
    required this.summaryOnly,
    required this.headCount,
  });

  final MethaneEmissionEstimate estimate;
  final bool summaryOnly;
  final int headCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ch4Display = summaryOnly
        ? '${estimate.ch4GPerDay.toStringAsFixed(0)} g'
        : l10n.methaneCh4Grams(estimate.ch4GPerDay.toStringAsFixed(0));
    final subtitle = summaryOnly
        ? l10n.methaneCo2eGroupTotal(
            estimate.co2eKgPerDay.toStringAsFixed(1),
            headCount,
          )
        : l10n.methaneCo2eSummary(
            estimate.co2eKgPerDay.toStringAsFixed(1),
            estimate.weightKg.toStringAsFixed(0),
          );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryOnly ? l10n.emissionsTotal : l10n.groupAverage,
                  style: GhTypography.labelXs.copyWith(
                    color: GhColors.textSecondary,
                  ),
                ),
                Text(
                  ch4Display,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GhTypography.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalRow extends StatelessWidget {
  const _AnimalRow(this.estimate);

  final MethaneEmissionEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#${estimate.tag}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Text(
            l10n.methaneGramsShort(estimate.ch4GPerDay.toStringAsFixed(0)),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.methaneAgeMonths(estimate.ageMonths),
            style: GhTypography.muted.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
