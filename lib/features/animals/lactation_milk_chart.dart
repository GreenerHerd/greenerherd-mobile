import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/lactation_models.dart';
import '../../data/services/lactation_seed_builder.dart';

String _lactationStageLabel(AppLocalizations l10n, LactationStage stage) =>
    switch (stage) {
      LactationStage.fresh => l10n.lactationStageFresh,
      LactationStage.peak => l10n.lactationStagePeak,
      LactationStage.mid => l10n.lactationStageMid,
      LactationStage.late => l10n.lactationStageLate,
      LactationStage.dry => l10n.lactationStageDry,
    };

class LactationCycleCard extends StatelessWidget {
  const LactationCycleCard({super.key, required this.cycle});

  final LactationCycle cycle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dim = cycle.daysInMilk(DateTime.now());
    final expected = LactationSeedBuilder.expectedYieldLitres(dim);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lactationNumber(cycle.cycleNumber),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.lactationDayOf305(
                _lactationStageLabel(l10n, cycle.stageOn(DateTime.now())),
                dim,
              ),
              style: const TextStyle(fontSize: 13, color: GhColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.lactationCalvingExpected(
                _fmt(cycle.calvingDate),
                expected.toStringAsFixed(1),
              ),
              style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class LactationMilkLineChart extends StatelessWidget {
  const LactationMilkLineChart({
    super.key,
    required this.history,
    this.height = 220,
  });

  final List<MilkYieldRecord> history;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (history.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            l10n.lactationChartNeedsData,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GhColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final sorted = List<MilkYieldRecord>.from(history)
      ..sort((a, b) => a.lactationDay.compareTo(b.lactationDay));
    final maxY = sorted.map((r) => r.litres).reduce((a, b) => a > b ? a : b) * 1.15;

    final spots = sorted
        .map((r) => FlSpot(r.lactationDay.toDouble(), r.litres))
        .toList();

    final expectedSpots = <FlSpot>[];
    for (var dim = sorted.first.lactationDay; dim <= sorted.last.lactationDay; dim += 7) {
      expectedSpots.add(
        FlSpot(dim.toDouble(), LactationSeedBuilder.expectedYieldLitres(dim)),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: sorted.first.lactationDay.toDouble(),
          maxX: sorted.last.lactationDay.toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(fontSize: 10, color: GhColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: ((sorted.last.lactationDay - sorted.first.lactationDay) / 4)
                    .clamp(14, 90)
                    .toDouble(),
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(fontSize: 10, color: GhColors.textSecondary),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: expectedSpots,
              isCurved: true,
              color: GhColors.textSecondary.withOpacity(0.35),
              barWidth: 2,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: GhColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: GhColors.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: GhColors.primaryLight.withOpacity(0.35),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched.map((t) {
                final dim = t.x.toInt();
                return LineTooltipItem(
                  l10n.chartDayLitres(dim, t.y.toStringAsFixed(1)),
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
