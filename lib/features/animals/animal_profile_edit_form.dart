import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_input_validation.dart';
import 'animal_form_helpers.dart';
import 'animal_providers.dart';

/// Editable identity fields for an animal profile (overview tab).
class AnimalProfileEditForm extends ConsumerStatefulWidget {
  const AnimalProfileEditForm({
    super.key,
    required this.animal,
    required this.onSaved,
    required this.onCancel,
  });

  final Animal animal;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<AnimalProfileEditForm> createState() =>
      AnimalProfileEditFormState();
}

class AnimalProfileEditFormState extends ConsumerState<AnimalProfileEditForm> {
  late final TextEditingController _tagCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _bcsCtrl;
  late final TextEditingController _ageLabelCtrl;
  late final TextEditingController _sireCtrl;
  late final TextEditingController _damCtrl;

  late String _sex;
  late String? _groupId;
  DateTime? _dob;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _tagCtrl = TextEditingController(text: a.tag);
    _nameCtrl = TextEditingController(text: a.name);
    _breedCtrl = TextEditingController(text: a.breed == '—' ? '' : a.breed);
    _weightCtrl = TextEditingController(
      text: a.weightKg > 0 ? a.weightKg.toStringAsFixed(0) : '',
    );
    _bcsCtrl = TextEditingController(
      text: a.bcs != null ? a.bcs!.toStringAsFixed(1) : '',
    );
    _ageLabelCtrl = TextEditingController(text: a.ageLabel);
    _sireCtrl = TextEditingController(text: a.sire ?? '');
    _damCtrl = TextEditingController(text: a.dam ?? '');
    _sex = switch (a.sex) {
      'F' || 'Female' => 'Female',
      'M' || 'Male' => 'Male',
      _ => a.sex,
    };
    _groupId = a.groupId.isEmpty ? null : a.groupId;
    _dob = a.dob;
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _weightCtrl.dispose();
    _bcsCtrl.dispose();
    _ageLabelCtrl.dispose();
    _sireCtrl.dispose();
    _damCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() => _save();

  Future<void> _save() async {
    if (_saving) return;
    final validation = ref.read(animalInputValidationProvider);
    final existingTags = (await ref.read(animalRepositoryProvider).listAnimals())
        .map((a) => a.tag)
        .where((t) => t != widget.animal.tag);

    final issues = <AnimalValidationIssue>[
      ...validation.validateTag(
        _tagCtrl.text,
        existingTags: existingTags,
      ),
      ...validation.validateWeightText(
        _weightCtrl.text,
        species: widget.animal.species,
      ),
      ...validation.validateDateOfBirth(_dob, species: widget.animal.species),
      ...validation.validateBcs(double.tryParse(_bcsCtrl.text.trim())),
    ];
    if (issues.isNotEmpty) {
      setState(() => _error = issues.first.message);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final l10n = context.l10n;

    try {
      final weight = double.parse(_weightCtrl.text.trim());
      final bcsText = _bcsCtrl.text.trim();
      final bcs = bcsText.isEmpty ? null : double.tryParse(bcsText);
      final ageLabel = _dob != null
          ? ageLabelFromDob(_dob!, DateTime.now(), l10n)
          : _ageLabelCtrl.text.trim().isEmpty
              ? '—'
              : _ageLabelCtrl.text.trim();

      final updated = widget.animal.copyWith(
        tag: _tagCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        breed: _breedCtrl.text.trim().isEmpty ? '—' : _breedCtrl.text.trim(),
        sex: _sex,
        weightKg: weight,
        weightIndicative: false,
        bcs: bcs,
        dob: _dob,
        clearDob: _dob == null,
        ageLabel: ageLabel,
        groupId: _groupId ?? '',
        sire: _sireCtrl.text.trim().isEmpty ? null : _sireCtrl.text.trim(),
        dam: _damCtrl.text.trim().isEmpty ? null : _damCtrl.text.trim(),
        clearSire: _sireCtrl.text.trim().isEmpty,
        clearDam: _damCtrl.text.trim().isEmpty,
      );

      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      if (!mounted) return;
      ref.invalidate(animalProvider(widget.animal.id));
      refreshAnimalAfterMutation(
        ref,
        animalId: widget.animal.id,
        groupId: updated.groupId.isNotEmpty ? updated.groupId : null,
      );
      widget.onSaved();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groupsAsync = ref.watch(groupsListProvider);
    final groups = groupsAsync.whenOrNull(
          data: (list) =>
              list.where((g) => g.species == widget.animal.species).toList(),
        ) ??
        [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _tagCtrl,
            decoration: const InputDecoration(labelText: 'Ear tag'),
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _breedCtrl,
            decoration: const InputDecoration(labelText: 'Breed'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _sex,
            decoration: const InputDecoration(labelText: 'Sex'),
            items: const [
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Male', child: Text('Male')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sex = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            decoration: const InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bcsCtrl,
            decoration: const InputDecoration(
              labelText: 'BCS (optional)',
              hintText: '1.0 – 5.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date of birth'),
              child: Text(
                _dob == null
                    ? 'Not set — tap to choose'
                    : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: _dob == null ? GhColors.textFaint : GhColors.textPrimary,
                ),
              ),
            ),
          ),
          if (_dob == null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _ageLabelCtrl,
              decoration: const InputDecoration(
                labelText: 'Age range',
                hintText: 'e.g. 2y or 18m',
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (groups.isNotEmpty)
            DropdownButtonFormField<String?>(
              value: _groupId,
              decoration: const InputDecoration(labelText: 'Group'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No group'),
                ),
                for (final g in groups)
                  DropdownMenuItem(value: g.id, child: Text(g.name)),
              ],
              onChanged: (v) => setState(() => _groupId = v),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _sireCtrl,
            decoration: const InputDecoration(labelText: 'Sire (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _damCtrl,
            decoration: const InputDecoration(labelText: 'Dam (optional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: GhColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : widget.onCancel,
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
