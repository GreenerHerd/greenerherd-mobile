import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/gh_stat.dart';

/// Breeding tab KPI: months since calving drives nutrition stage and re-breeding readiness.
class BreedingCycleKpiCard extends ConsumerStatefulWidget {
  const BreedingCycleKpiCard({
    super.key,
    required this.animal,
    required this.onUpdated,
  });

  final Animal animal;
  final VoidCallback onUpdated;

  @override
  ConsumerState<BreedingCycleKpiCard> createState() =>
      _BreedingCycleKpiCardState();
}

class _BreedingCycleKpiCardState extends ConsumerState<BreedingCycleKpiCard> {
  late int _months;
  bool _saving = false;

  Animal get _animal => widget.animal;

  @override
  void initState() {
    super.initState();
    _months = ReproductionStatusRules.effectiveMonthsSinceCalving(_animal) ?? 0;
  }

  @override
  void didUpdateWidget(covariant BreedingCycleKpiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animal.monthsSinceCalving != widget.animal.monthsSinceCalving ||
        oldWidget.animal.tags != widget.animal.tags) {
      _months =
          ReproductionStatusRules.effectiveMonthsSinceCalving(_animal) ?? 0;
    }
  }

  Future<void> _persist(int months) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _months = months;
    });
    try {
      final updated = _animal.copyWith(monthsSinceCalving: months);
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      if (!mounted) return;
      widget.onUpdated();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _adjust(int delta) {
    final next = (_months + delta).clamp(0, 120);
    if (next == _months) return;
    _persist(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minRebreed =
        ReproductionStatusRules.minMonthsSinceCalvingForRebreeding(
      _animal.species,
    );
    final eligible = ReproductionStatusRules.isEligibleForNextBreeding(
      _animal.copyWith(monthsSinceCalving: _months),
    );
    final pregnant = _animal.tags.contains(AnimalTagType.pregnant);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.breedingCycleKpiTitle, style: GhTypography.h03),
            const SizedBox(height: 4),
            Text(
              l10n.breedingCycleKpiSubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: GhColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GhStat(
              label: l10n.monthsSinceCalvingLabel,
              value: '$_months',
              valueColor: GhColors.primary,
              dense: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _saving || _months <= 0
                      ? null
                      : () => _adjust(-1),
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l10n.decreaseMonthsSinceCalving,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.monthsSinceCalvingValue(_months),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => _adjust(1),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: l10n.increaseMonthsSinceCalving,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (eligible ? GhColors.success : GhColors.warning)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    eligible ? Icons.check_circle_outline : Icons.schedule,
                    size: 20,
                    color: eligible ? GhColors.success : GhColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pregnant
                          ? l10n.breedingCycleBlockedPregnant
                          : eligible
                              ? l10n.breedingCycleReadyForRebreeding
                              : l10n.breedingCycleWaitingPeriod(
                                  minRebreed - _months,
                                ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: eligible ? GhColors.success : GhColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
