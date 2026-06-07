import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../data/models/breeding_methods.dart';
import '../../../data/models/enums.dart';
import '../../../data/services/gestation_dates.dart';

/// Member notes dialog; owns [TextEditingController] until route is disposed.
class MemberNotesDialog extends StatefulWidget {
  const MemberNotesDialog({super.key, this.initialNote});

  final String? initialNote;

  @override
  State<MemberNotesDialog> createState() => _MemberNotesDialogState();
}

class _MemberNotesDialogState extends State<MemberNotesDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notes'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Notes',
          hintText: 'Observations, treatments, reminders…',
        ),
        maxLines: 3,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Illness note dialog; owns [TextEditingController] until route is disposed.
class IllnessNoteDialog extends StatefulWidget {
  const IllnessNoteDialog({super.key, this.initialNote});

  final String? initialNote;

  @override
  State<IllnessNoteDialog> createState() => _IllnessNoteDialogState();
}

class _IllnessNoteDialogState extends State<IllnessNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    Navigator.pop(
      context,
      text.isEmpty ? 'Under treatment' : text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Illness'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Description',
          hintText: 'Symptoms, treatment started…',
        ),
        maxLines: 3,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Pregnancy details dialog; owns controllers until route is disposed.
class PregnancyDetailsDialog extends StatefulWidget {
  const PregnancyDetailsDialog({
    super.key,
    required this.species,
    this.initialGestMonths,
    this.initialDueDate,
    this.initialProlificacy,
    this.initialTwin = false,
    this.initialBreedingMethod,
  });

  final Species species;
  final int? initialGestMonths;
  final DateTime? initialDueDate;
  final int? initialProlificacy;
  final bool initialTwin;
  final BreedingMethod? initialBreedingMethod;

  @override
  State<PregnancyDetailsDialog> createState() => _PregnancyDetailsDialogState();
}

class _PregnancyDetailsDialogState extends State<PregnancyDetailsDialog> {
  late DateTime? _dueDate;
  late int _prolificacy;
  late BreedingMethod _method;
  String? _error;

  List<BreedingMethod> get _methods =>
      BreedingMethodCatalog.forSpecies(widget.species);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dueDate = widget.initialDueDate ??
        (widget.initialGestMonths != null
            ? GestationDates.dueDateFromGestMonths(
                widget.species,
                widget.initialGestMonths!,
                now,
              )
            : GestationDates.dueDateFromGestMonths(
                widget.species,
                5,
                now,
              ));
    _prolificacy = GestationDates.clampProlificacy(
      widget.initialProlificacy ??
          (widget.initialTwin ? 2 : GestationDates.defaultProlificacy),
    );
    _method = widget.initialBreedingMethod ?? _methods.first;
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

  void _save() {
    if (_dueDate == null) {
      setState(() => _error = 'Choose a due date');
      return;
    }
    final gestMonths = GestationDates.gestMonthsFromDueDate(
      widget.species,
      _dueDate!,
      DateTime.now(),
    );
    Navigator.pop(
      context,
      PregnancyDialogResult(
        dueDate: _dueDate!,
        gestMonths: gestMonths,
        prolificacy: _prolificacy,
        isTwin: _prolificacy >= 2,
        breedingMethod: _method,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pregnancyConfirmed),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _pickDueDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.dueDateLabel,
                errorText: _error,
              ),
              child: Text(
                _dueDate == null
                    ? l10n.chooseDueDate
                    : GestationDates.formatDate(_dueDate!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.prolificacyLabel,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: [
              for (final n in GestationDates.prolificacyOptions)
                ButtonSegment(value: n, label: Text('$n')),
            ],
            selected: {_prolificacy},
            onSelectionChanged: (values) {
              setState(() => _prolificacy = values.first);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BreedingMethod>(
            initialValue: _method,
            decoration: InputDecoration(labelText: l10n.fertilityMethodLabel),
            items: [
              for (final method in _methods)
                DropdownMenuItem(
                  value: method,
                  child: Text(BreedingMethodCatalog.label(method, l10n)),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class PregnancyDialogResult {
  const PregnancyDialogResult({
    required this.dueDate,
    required this.gestMonths,
    required this.prolificacy,
    required this.isTwin,
    required this.breedingMethod,
  });

  final DateTime dueDate;
  final int gestMonths;
  final int prolificacy;
  final bool isTwin;
  final BreedingMethod breedingMethod;
}

/// Ready-to-breed dialog for goats and sheep — fertility method is required.
class ReadyToBreedDialog extends StatefulWidget {
  const ReadyToBreedDialog({
    super.key,
    required this.species,
    this.initialMethod,
  });

  final Species species;
  final BreedingMethod? initialMethod;

  @override
  State<ReadyToBreedDialog> createState() => _ReadyToBreedDialogState();
}

class _ReadyToBreedDialogState extends State<ReadyToBreedDialog> {
  late BreedingMethod _method;

  List<BreedingMethod> get _methods =>
      BreedingMethodCatalog.forSpecies(widget.species);

  @override
  void initState() {
    super.initState();
    _method = widget.initialMethod ?? _methods.first;
  }

  void _save() {
    Navigator.pop(context, ReadyToBreedDialogResult(method: _method));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.markReadyToBreed),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.readyToBreedMethodHint,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BreedingMethod>(
            initialValue: _method,
            decoration: InputDecoration(labelText: l10n.fertilityMethodLabel),
            items: [
              for (final method in _methods)
                DropdownMenuItem(
                  value: method,
                  child: Text(BreedingMethodCatalog.label(method, l10n)),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class ReadyToBreedDialogResult {
  const ReadyToBreedDialogResult({required this.method});

  final BreedingMethod method;
}

/// Vaccination event name dialog for group wizard step 2.
class VaccinationEventNameDialog extends StatefulWidget {
  const VaccinationEventNameDialog({super.key, required this.titleLabel});

  final String titleLabel;

  @override
  State<VaccinationEventNameDialog> createState() =>
      _VaccinationEventNameDialogState();
}

class _VaccinationEventNameDialogState extends State<VaccinationEventNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleLabel),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.titleLabel),
        autofocus: true,
        onSubmitted: (v) {
          final t = v.trim();
          if (t.isNotEmpty) Navigator.pop(context, t);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final t = _controller.text.trim();
            if (t.isNotEmpty) Navigator.pop(context, t);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
