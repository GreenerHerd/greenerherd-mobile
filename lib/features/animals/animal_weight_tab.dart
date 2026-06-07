import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/mock/profile_mock_data.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_kv_list.dart';

class AnimalWeightTab extends StatelessWidget {
  const AnimalWeightTab({super.key, required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = ProfileMockData.weightHistoryChronological(animal);
    final history = ProfileMockData.weightHistoryNewestFirst(animal);
    final growth = ProfileMockData.weightGrowthPct(animal);
    final maxKg = points.map((p) => p.kg).reduce((a, b) => a > b ? a : b);
    final minKg = points.map((p) => p.kg).reduce((a, b) => a < b ? a : b);
    final range = (maxKg - minKg).clamp(1, 999);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GhColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.weightMonthsTitle, style: GhTypography.h03),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GhColors.successLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        l10n.weightGrowthPct(growth),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GhColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final p in points) ...[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${p.kg}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: GhColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: ((p.kg - minKg) / range) * 100 + 12,
                                decoration: const BoxDecoration(
                                  color: GhColors.primary,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.monthLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: GhColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (p != points.last) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GhKvListCard(
          rows: history
              .map(
                (p) => GhKvEntry(
                  label: p.yearLabel ?? p.monthLabel,
                  value: '${p.kg} kg',
                  subtitle: p.isCurrent
                      ? l10n.currentWeightLabel
                      : p.deltaKg != null
                          ? l10n.weightDeltaKg(p.deltaKg!)
                          : null,
                  isLast: p == history.last,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
