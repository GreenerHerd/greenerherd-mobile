import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../data/services/gestation_dates.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';

/// Inline breeding status editor: ready-to-breed, method, pregnancy, due date, prolificacy.
class BreedingStatusSection extends ConsumerStatefulWidget {
  const BreedingStatusSection({
    super.key,
    required this.animal,
    required this.onUpdated,
  });

  final Animal animal;
  final VoidCallback onUpdated;

  @override
  ConsumerState<BreedingStatusSection> createState() =>
      _BreedingStatusSectionState();
}

class _BreedingStatusSectionState extends ConsumerState<BreedingStatusSection> {
  late bool _readyToBreed;
  late bool _pregnant;
  late bool _isHeifer;
  late BreedingMethod? _method;
  late DateTime? _dueDate;
  late int _prolificacy;
  String? _error;
  bool _saving = false;

  static const _prolificacyOptions = [2, 3, 4];

  Animal get _animal => widget.animal;

  List<BreedingMethod> get _methods =>
      BreedingMethodCatalog.forSpecies(_animal.species);

  @override
  void initState() {
    super.initState();
    _syncFromAnimal();
  }

  @override
  void didUpdateWidget(covariant BreedingStatusSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animal.id != widget.animal.id ||
        oldWidget.animal.tags != widget.animal.tags ||
        oldWidget.animal.breedingMethod != widget.animal.breedingMethod ||
        oldWidget.animal.dueDate != widget.animal.dueDate ||
        oldWidget.animal.prolificacy != widget.animal.prolificacy ||
        oldWidget.animal.isHeifer != widget.animal.isHeifer) {
      _syncFromAnimal();
    }
  }

  void _syncFromAnimal() {
    final now = DateTime.now();
    _readyToBreed = _animal.tags.contains(AnimalTagType.readyToBreed);
    _pregnant = _animal.tags.contains(AnimalTagType.pregnant);
    _isHeifer = _animal.isHeifer == true;
    _method = _animal.breedingMethod ?? _methods.firstOrNull;
    _dueDate = GestationDates.effectiveDueDate(_animal, now) ??
        GestationDates.dueDateFromGestMonths(_animal.species, 5, now);
    _prolificacy = GestationDates.effectiveProlificacy(_animal);
    if (!_prolificacyOptions.contains(_prolificacy)) _prolificacy = 2;
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _error = null;
      });
    }
  }

  bool get _isFemale => ReproductionStatusRules.isFemaleSex(_animal.sex);

  Future<void> _save() async {
    if (_saving) return;
    final lifecycle = ref.read(lifecycleServiceProvider);
    final l10n = context.l10n;

    if (_readyToBreed && _pregnant) {
      setState(() => _error = l10n.breedingStatusConflict);
      return;
    }

    if (_readyToBreed &&
        BreedingMethodCatalog.requiresMethodOnReadyToBreed(_animal.species) &&
        _method == null) {
      setState(() => _error = l10n.fertilityMethodRequired);
      return;
    }

    if (_pregnant && _dueDate == null) {
      setState(() => _error = l10n.chooseDueDate);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      Animal updated = _animal;

      if (_pregnant) {
        updated = lifecycle.markPregnant(
          updated,
          dueDate: _dueDate,
          prolificacy: _prolificacy,
          method: _method,
        );
      } else if (_readyToBreed) {
        updated = lifecycle.markReadyToBreed(updated, method: _method);
      } else {
        var tags = updated.tags
            .where(
              (t) =>
                  t != AnimalTagType.readyToBreed &&
                  t != AnimalTagType.pregnant,
            )
            .toList();
        updated = updated.copyWith(
          tags: tags,
          clearBreedingMethod: true,
          clearGestMonths: true,
          clearDueDate: true,
          clearProlificacy: true,
          isTwin: false,
        );
      }

      if (ReproductionStatusRules.canMarkHeifer(
        species: _animal.species,
        sex: _animal.sex,
      )) {
        updated = updated.copyWith(isHeifer: _pregnant ? false : _isHeifer);
      }

      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      if (!mounted) return;
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.breedingStatusUpdated)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canBreed =
        ReproductionStatusRules.canMarkReadyToBreedForAnimal(_animal);
    final canMarkHeifer = _isFemale &&
        ReproductionStatusRules.canMarkHeifer(
          species: _animal.species,
          sex: _animal.sex,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.breedingStatusSection, style: GhTypography.h03),
            const SizedBox(height: 12),
            if (canMarkHeifer && !_pregnant) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.markAsHeifer),
                subtitle: Text(
                  l10n.heiferHint,
                  style: const TextStyle(fontSize: 12),
                ),
                value: _isHeifer,
                onChanged: (v) => setState(() {
                  _isHeifer = v;
                  _error = null;
                }),
              ),
              const SizedBox(height: 8),
            ],
            if (canBreed && !_pregnant) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    const GhDesignIcon(
                      assetPath: GhDesignIcons.readyToBreed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.markReadyToBreed)),
                  ],
                ),
                value: _readyToBreed,
                onChanged: (v) {
                  setState(() {
                    _readyToBreed = v;
                    if (v) _pregnant = false;
                    _error = null;
                  });
                },
              ),
              if (_readyToBreed) ...[
                const SizedBox(height: 4),
                DropdownButtonFormField<BreedingMethod>(
                  initialValue: _method ?? _methods.first,
                  decoration: InputDecoration(
                    labelText: l10n.fertilityMethodLabel,
                    helperText: BreedingMethodCatalog.requiresMethodOnReadyToBreed(
                      _animal.species,
                    )
                        ? l10n.readyToBreedMethodHint
                        : null,
                  ),
                  items: [
                    for (final method in _methods)
                      DropdownMenuItem(
                        value: method,
                        child: Text(
                          BreedingMethodCatalog.label(method, l10n),
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _method = value),
                ),
              ],
              const SizedBox(height: 8),
            ],
            if (_isFemale) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    const GhDesignIcon(
                      assetPath: GhDesignIcons.welfare,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.pregnancyConfirmed)),
                  ],
                ),
                value: _pregnant,
                onChanged: (v) {
                  setState(() {
                    _pregnant = v;
                    if (v) {
                      _readyToBreed = false;
                      _isHeifer = false;
                    }
                    _error = null;
                  });
                },
              ),
            ],
            if (_isFemale && _pregnant) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.dueDateLabel),
                  child: Text(
                    _dueDate == null
                        ? l10n.chooseDueDate
                        : GestationDates.formatDate(_dueDate!),
                    style: TextStyle(
                      color: _dueDate == null
                          ? GhColors.textFaint
                          : GhColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.prolificacyLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                segments: [
                  for (final n in _prolificacyOptions)
                    ButtonSegment(value: n, label: Text('$n')),
                ],
                selected: {_prolificacy},
                onSelectionChanged: (values) {
                  setState(() => _prolificacy = values.first);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<BreedingMethod>(
                initialValue: _method ?? _methods.first,
                decoration: InputDecoration(labelText: l10n.fertilityMethodLabel),
                items: [
                  for (final method in _methods)
                    DropdownMenuItem(
                      value: method,
                      child: Text(
                        BreedingMethodCatalog.label(method, l10n),
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _method = value),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: GhColors.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
