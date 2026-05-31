import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_lifecycle_service.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import 'lactation_milk_chart.dart';
import 'lactation_providers.dart';

class AnimalMilkingTab extends ConsumerWidget {
  const AnimalMilkingTab({
    super.key,
    required this.animal,
    required this.onUpdated,
  });

  final Animal animal;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycle = ref.watch(lifecycleServiceProvider);
    final canRecord = lifecycle.canRecordMilk(animal);
    final blocked = lifecycle.milkBlockedByWithdrawal(animal);
    final litres = animal.milkTodayLitres;
    final cycleAsync = ref.watch(lactationCycleProvider(animal.id));
    final historyAsync = ref.watch(milkHistoryProvider(animal.id));
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        cycleAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (cycle) =>
              cycle == null ? const SizedBox.shrink() : LactationCycleCard(cycle: cycle),
        ),
        const SizedBox(height: 12),
        _StatusRow(
          label: l10n.milkingTodayVolume,
          value: litres == null
              ? l10n.notRecorded
              : l10n.litresValue(litres.toStringAsFixed(1)),
        ),
        if (blocked)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.withdrawalMilkBlocked,
              style: const TextStyle(color: GhColors.error, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: canRecord && !blocked
              ? () => context.push('/animals/${animal.id}/record-milk').then((_) => onUpdated())
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GhDesignIcon(assetPath: GhDesignIcons.bottle, size: 20),
              const SizedBox(width: 8),
              Text(l10n.recordMilk),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.lactationCurveTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.lactationCurveLegend,
          style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (history) => LactationMilkLineChart(history: history),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: GhColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
