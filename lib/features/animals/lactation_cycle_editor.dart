import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/animal_lactation_cycle.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/lactation_cycle_service.dart';
import '../../data/services/reproduction_status_rules.dart';

final lactationCycleServiceProvider =
    Provider<LactationCycleService>((ref) => const LactationCycleService());

/// Milking-tab lactation cycle dropdown for one animal.
class LactationCycleEditor extends ConsumerStatefulWidget {
  const LactationCycleEditor({
    super.key,
    required this.animal,
    required this.onUpdated,
    this.compact = false,
  });

  final Animal animal;
  final VoidCallback onUpdated;
  final bool compact;

  @override
  ConsumerState<LactationCycleEditor> createState() =>
      _LactationCycleEditorState();
}

class _LactationCycleEditorState extends ConsumerState<LactationCycleEditor> {
  bool _saving = false;

  int? get _ageMonths =>
      ReproductionStatusRules.ageMonthsFromAnimal(widget.animal);

  bool get _canEdit => ReproductionStatusRules.canLactate(
        species: widget.animal.species,
        sex: widget.animal.sex,
        ageMonths: _ageMonths,
      );

  AnimalLactationCycle? get _value {
    final service = ref.read(lactationCycleServiceProvider);
    return service.effectiveCycle(widget.animal);
  }

  Future<void> _onChanged(AnimalLactationCycle? cycle) async {
    if (cycle == null || _saving) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(lactationCycleServiceProvider);
      final updated = service.applyCycle(widget.animal, cycle);
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      refreshHerdDataProviders(ref);
      if (mounted) widget.onUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_canEdit) {
      return const SizedBox.shrink();
    }

    final options = LactationCycleCatalog.forSpecies(widget.animal.species);
    final current = _value ?? options.first;

    if (widget.compact) {
      return DropdownButtonFormField<AnimalLactationCycle>(
        initialValue: options.contains(current) ? current : options.first,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.lactationPhaseLabel,
          isDense: true,
        ),
        items: [
          for (final cycle in options)
            DropdownMenuItem(
              value: cycle,
              child: Text(LactationCycleCatalog.label(cycle, l10n)),
            ),
        ],
        onChanged: _saving ? null : _onChanged,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.lactationPhaseLabel, style: GhTypography.h03),
            const SizedBox(height: 4),
            Text(
              l10n.lactationCycleHint,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AnimalLactationCycle>(
              initialValue: options.contains(current) ? current : options.first,
              decoration: InputDecoration(
                labelText: l10n.lactationPhaseLabel,
              ),
              items: [
                for (final cycle in options)
                  DropdownMenuItem(
                    value: cycle,
                    child: Text(LactationCycleCatalog.label(cycle, l10n)),
                  ),
              ],
              onChanged: _saving ? null : _onChanged,
            ),
            if (_saving) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Females old enough for lactation management in a group milking tab.
List<Animal> milkingEligibleFemales(List<Animal> animals) {
  return animals
      .where(
        (a) =>
            a.status == AnimalStatus.active &&
            ReproductionStatusRules.canLactate(
              species: a.species,
              sex: a.sex,
              ageMonths: ReproductionStatusRules.ageMonthsFromAnimal(a),
            ),
      )
      .toList()
    ..sort((a, b) => a.tag.compareTo(b.tag));
}
