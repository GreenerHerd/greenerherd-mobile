import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../data/models/breed_reference.dart';
import '../../../data/models/breeding_methods.dart';
import '../../../data/models/enums.dart';
import '../../../data/services/reproduction_status_rules.dart';
import '../../../shared/widgets/gh_design_icon.dart';
import '../../../shared/widgets/gh_design_icons.dart';
import '../add_group_sheet.dart' show BreedDropdownField;
import '../add_group_wizard.dart';
import 'member_status_dialogs.dart';

enum _AgeInputMode { months, dateOfBirth }

/// Compact per-animal row for bulk group onboarding (100+ animals).
class GroupMemberCompactRow extends StatefulWidget {
  const GroupMemberCompactRow({
    super.key,
    required this.draft,
    required this.species,
    required this.defaultSex,
    required this.defaultBreed,
    required this.l10n,
    this.breeds = const [],
    this.showBreedOverride = true,
    this.autoReadyToBreed = false,
  });

  final GroupMemberDraft draft;
  final Species species;
  final String defaultSex;
  final String defaultBreed;
  final AppLocalizations l10n;
  final List<BreedReference> breeds;
  final bool showBreedOverride;
  final bool autoReadyToBreed;

  @override
  State<GroupMemberCompactRow> createState() => _GroupMemberCompactRowState();
}

class _GroupMemberCompactRowState extends State<GroupMemberCompactRow> {
  late _AgeInputMode _ageMode;

  GroupMemberDraft get draft => widget.draft;

  bool get _hasNotes =>
      draft.memberNotes != null && draft.memberNotes!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ageMode = draft.dob != null && draft.ageMonths == null
        ? _AgeInputMode.dateOfBirth
        : _AgeInputMode.months;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reconcileReproductionTags();
    });
  }

  String _formatDob(DateTime d) {
    final y = d.year % 100;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${y.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dob ?? now.subtract(const Duration(days: 365 * 2)),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      draft.dob = picked;
      draft.ageMonths = null;
      _ageMode = _AgeInputMode.dateOfBirth;
      _reconcileReproductionTags();
    });
  }

  Future<void> _editNotes() async {
    if (_hasNotes) {
      setState(() => draft.memberNotes = null);
      return;
    }
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => MemberNotesDialog(initialNote: draft.memberNotes),
    );
    if (!mounted || note == null) return;
    setState(() {
      draft.memberNotes = note.isEmpty ? null : note;
    });
  }

  Future<void> _toggleIllness() async {
    if (draft.sick) {
      setState(() {
        draft.sick = false;
        draft.sickNote = null;
      });
      return;
    }
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => IllnessNoteDialog(initialNote: draft.sickNote),
    );
    if (!mounted || note == null) return;
    setState(() {
      draft.sick = true;
      draft.sickNote = note;
    });
  }

  Future<void> _togglePregnancy() async {
    if (!_canBePregnant) return;
    if (draft.pregnant) {
      setState(() {
        draft.pregnant = false;
        draft.gestMonths = null;
        draft.dueDate = null;
        draft.prolificacy = null;
        draft.isTwin = false;
        draft.breedingMethod = null;
      });
      return;
    }
    final result = await showDialog<PregnancyDialogResult>(
      context: context,
      builder: (ctx) => PregnancyDetailsDialog(
        species: widget.species,
        initialGestMonths: draft.gestMonths,
        initialDueDate: draft.dueDate,
        initialProlificacy: draft.prolificacy,
        initialTwin: draft.isTwin,
        initialBreedingMethod: draft.breedingMethod,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      draft.pregnant = true;
      draft.gestMonths = result.gestMonths;
      draft.dueDate = result.dueDate;
      draft.prolificacy = result.prolificacy;
      draft.isTwin = result.isTwin;
      draft.breedingMethod = result.breedingMethod;
    });
  }

  Future<void> _toggleReadyToBreed() async {
    if (!_canReadyToBreed) return;
    if (draft.readyToBreed) {
      setState(() {
        draft.readyToBreed = false;
        draft.breedingMethod = null;
      });
      return;
    }
    final result = await showDialog<ReadyToBreedDialogResult>(
      context: context,
      builder: (ctx) => ReadyToBreedDialog(
        species: widget.species,
        initialMethod: draft.breedingMethod,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      draft.readyToBreed = true;
      draft.breedingMethod = result.method;
    });
  }

  void _toggleAgeMode(_AgeInputMode mode) {
    if (_ageMode == mode) return;
    setState(() {
      _ageMode = mode;
      if (mode == _AgeInputMode.months) {
        draft.dob = null;
      } else {
        draft.ageMonths = null;
        draft.dob ??= DateTime.now().subtract(const Duration(days: 365 * 2));
      }
      _reconcileReproductionTags();
    });
  }

  int? get _ageMonths => draft.effectiveAgeMonths;

  bool get _canBePregnant => ReproductionStatusRules.canBePregnant(
        species: widget.species,
        sex: draft.sex,
        ageMonths: _ageMonths,
      );

  bool get _canLactate => ReproductionStatusRules.canLactate(
        species: widget.species,
        sex: draft.sex,
        ageMonths: _ageMonths,
      );

  bool get _canReadyToBreed => ReproductionStatusRules.canMarkReadyToBreed(
        species: widget.species,
        sex: draft.sex,
        ageMonths: _ageMonths,
      );

  void _reconcileReproductionTags() {
    var changed = false;
    if (!_canBePregnant && draft.pregnant) {
      draft.pregnant = false;
      draft.gestMonths = null;
      draft.isTwin = false;
      changed = true;
    }
    if (!_canLactate && draft.lactating) {
      draft.lactating = false;
      changed = true;
    }
    if (!_canReadyToBreed && draft.readyToBreed) {
      draft.readyToBreed = false;
      draft.breedingMethod = null;
      changed = true;
    }
    if (widget.autoReadyToBreed &&
        _canReadyToBreed &&
        !draft.pregnant &&
        !draft.readyToBreed) {
      draft.readyToBreed = true;
      if (BreedingMethodCatalog.requiresMethodOnReadyToBreed(widget.species)) {
        draft.breedingMethod ??= BreedingMethod.natural;
      }
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  Widget _buildAgeValueField() {
    if (_ageMode == _AgeInputMode.months) {
      return TextFormField(
        key: ValueKey('age-${draft.id}'),
        initialValue: draft.ageMonths == null ? '' : '${draft.ageMonths}',
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          isDense: true,
          suffixText: 'm',
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        ),
        onChanged: (v) {
          draft.ageMonths = int.tryParse(v.trim());
          draft.dob = null;
          _reconcileReproductionTags();
        },
      );
    }
    return InkWell(
      onTap: _pickDateOfBirth,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        child: Text(
          draft.dob == null ? 'Select date' : _formatDob(draft.dob!),
          style: TextStyle(
            fontSize: 13,
            color: draft.dob == null ? GhColors.textFaint : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<Widget> _statusButtons() {
    return [
      GhDesignStatusButton(
        assetPath: GhDesignIcons.records,
        active: _hasNotes,
        tooltip: 'Notes',
        onTap: _editNotes,
        size: 40,
        iconVisualScale: 0.88,
      ),
      GhDesignStatusButton(
        assetPath: GhDesignIcons.medication,
        active: draft.sick,
        tooltip: 'Illness',
        onTap: _toggleIllness,
        size: 40,
        iconVisualScale: 0.82,
      ),
      GhDesignStatusButton(
        assetPath: GhDesignIcons.cullTag,
        active: draft.cull,
        tooltip: 'Cull tag',
        onTap: () => setState(() => draft.cull = !draft.cull),
        size: 40,
      ),
      GhDesignStatusButton(
        assetPath: GhDesignIcons.bottle,
        active: draft.lactating,
        enabled: _canLactate,
        tooltip: ReproductionStatusRules.disabledLactatingTooltip(
          species: widget.species,
          sex: draft.sex,
          ageMonths: _ageMonths,
        ),
        onTap: () => setState(() => draft.lactating = !draft.lactating),
        size: 40,
      ),
      GhDesignStatusButton(
        assetPath: GhDesignIcons.readyToBreed,
        active: draft.readyToBreed,
        enabled: _canReadyToBreed,
        tooltip: _canReadyToBreed
            ? 'Ready to breed'
            : 'Minimum ${ReproductionStatusRules.minReproductionAgeMonths(widget.species)} months',
        onTap: _toggleReadyToBreed,
        size: 40,
      ),
      GhDesignStatusButton(
        assetPath: GhDesignIcons.welfare,
        active: draft.pregnant,
        enabled: _canBePregnant,
        tooltip: ReproductionStatusRules.disabledPregnancyTooltip(
          species: widget.species,
          sex: draft.sex,
          ageMonths: _ageMonths,
        ),
        onTap: _togglePregnancy,
        size: 40,
      ),
    ];
  }

  static const _ageClusterWidth = 118.0;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final showBreed =
        widget.showBreedOverride && widget.breeds.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _Field(
                      label: l10n.tagNumber,
                      child: TextFormField(
                        key: ValueKey('tag-${draft.id}'),
                        initialValue: draft.tag,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (v) => draft.tag = v,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: _Field(
                      label: l10n.sex,
                      child: DropdownButtonFormField<String>(
                        initialValue: draft.sex == 'Male' ? 'M' : 'F',
                        isDense: true,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'F', child: Text('F')),
                          DropdownMenuItem(value: 'M', child: Text('M')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            draft.sex = v == 'M' ? 'Male' : 'Female';
                            _reconcileReproductionTags();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 62,
                    child: _Field(
                      label: l10n.weightKg,
                      child: TextFormField(
                        key: ValueKey('wt-${draft.id}'),
                        initialValue: draft.weightKg == null
                            ? ''
                            : '${draft.weightKg}',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (v) =>
                            draft.weightKg = double.tryParse(v.trim()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showBreed) ...[
                    Expanded(
                      child: _Field(
                        label: l10n.breed,
                        child: BreedDropdownField(
                          breeds: widget.breeds,
                          value: draft.breed.isEmpty
                              ? widget.defaultBreed
                              : draft.breed,
                          l10n: l10n,
                          isDense: true,
                          showFieldLabel: false,
                          onChanged: (name) =>
                              setState(() => draft.breed = name),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  SizedBox(
                    width: _ageClusterWidth,
                    child: _Field(
                      label: 'Age',
                      child: Row(
                        children: [
                          _AgeModeToggle(
                            mode: _ageMode,
                            onSelectMonths: () =>
                                _toggleAgeMode(_AgeInputMode.months),
                            onSelectDob: () =>
                                _toggleAgeMode(_AgeInputMode.dateOfBirth),
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: _buildAgeValueField()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _StatusIconPanel(buttons: _statusButtons()),
      ],
    );
  }
}

/// Six status icons in a 2×3 panel on the right of the member row.
class _StatusIconPanel extends StatelessWidget {
  const _StatusIconPanel({required this.buttons});

  final List<Widget> buttons;

  static const _columns = 2;
  static const _rows = 3;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    assert(buttons.length == _columns * _rows);
    final tableRows = <Widget>[];
    for (var r = 0; r < _rows; r++) {
      tableRows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttons[r * _columns],
            const SizedBox(width: _gap),
            buttons[r * _columns + 1],
          ],
        ),
      );
      if (r < _rows - 1) {
        tableRows.add(const SizedBox(height: _gap));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: tableRows,
    );
  }
}

class _AgeModeToggle extends StatelessWidget {
  const _AgeModeToggle({
    required this.mode,
    required this.onSelectMonths,
    required this.onSelectDob,
  });

  final _AgeInputMode mode;
  final VoidCallback onSelectMonths;
  final VoidCallback onSelectDob;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        border: Border.all(color: GhColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AgeModeChip(
              label: 'm',
              selected: mode == _AgeInputMode.months,
              onTap: onSelectMonths,
            ),
          ),
          Expanded(
            child: _AgeModeChip(
              label: 'DoB',
              selected: mode == _AgeInputMode.dateOfBirth,
              onTap: onSelectDob,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeModeChip extends StatelessWidget {
  const _AgeModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? GhColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? GhColors.primary : GhColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  static const _labelHeight = 15.0;
  /// Room for dense dropdown/text descenders (e.g. breed names like "Cypriot").
  static const _inputHeight = 48.0;

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _labelHeight,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: GhColors.textFaint,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _inputHeight),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: child,
          ),
        ),
      ],
    );
  }
}
