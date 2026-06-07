import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/breed_reference.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_mapper.dart';
import '../../shared/widgets/gh_chip.dart';
import '../../shared/widgets/species_icon.dart';
import 'animal_form_helpers.dart';

enum _AnimalOrigin { born, purchased }

/// Design handoff: 3-step Add animal sheet ([Sheets.jsx] AddAnimalSheet).
Future<void> showAddAnimalSheet(BuildContext context, WidgetRef ref) =>
    showAddAnimalWizard(context, ref);

Future<void> showAddAnimalWizard(BuildContext context, WidgetRef ref) async {
  final initialSpecies =
      ref.read(selectedSpeciesFilterProvider) ?? Species.cattle;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _AddAnimalWizardSheet(
        initialSpecies: initialSpecies,
        scrollController: scrollController,
      ),
    ),
  );
}

class _AddAnimalWizardSheet extends ConsumerStatefulWidget {
  const _AddAnimalWizardSheet({
    required this.initialSpecies,
    required this.scrollController,
  });

  final Species initialSpecies;
  final ScrollController scrollController;

  @override
  ConsumerState<_AddAnimalWizardSheet> createState() =>
      _AddAnimalWizardSheetState();
}

class _AddAnimalWizardSheetState extends ConsumerState<_AddAnimalWizardSheet> {
  static const _steps = 3;
  var _step = 0;
  var _busy = false;
  var _loading = true;

  late final TextEditingController _tagCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _sireCtrl;
  late final TextEditingController _damCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _purchasePriceCtrl;

  late Species _species;
  var _origin = _AnimalOrigin.born;
  var _sex = 'Female';
  BreedReference? _breed;
  var _productionPurpose = SpeciesPurpose.both;
  DateTime? _dob;
  DateTime? _purchaseDate;
  String? _ageRangeLabel;
  var _birthSize = 'Medium';
  var _vigour = 'Average';
  var _assistance = 'None';
  var _twin = false;
  String? _groupId;
  String? _validationMessage;

  List<AnimalGroup> _groups = [];
  List<BreedReference> _breeds = [];
  List<String> _existingTags = [];

  static const _ageRanges = [
    '0-3m',
    '4-6m',
    '7-11m',
    '1-2yr',
    '2-3yr',
    '3-5yr',
    '5+yr',
  ];

  @override
  void initState() {
    super.initState();
    _species = widget.initialSpecies;
    _tagCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _sireCtrl = TextEditingController();
    _damCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _supplierCtrl = TextEditingController();
    _purchasePriceCtrl = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _sireCtrl.dispose();
    _damCtrl.dispose();
    _notesCtrl.dispose();
    _supplierCtrl.dispose();
    _purchasePriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final groups = await ref
        .read(groupRepositoryProvider)
        .listGroups(species: _species);
    final breeds = await ref.read(breedsForSpeciesProvider(_species).future);
    final tags = (await ref.read(animalRepositoryProvider).listAnimals())
        .map((a) => a.tag)
        .toList();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _breeds = breeds;
      _existingTags = tags;
      _groupId = groups.isNotEmpty ? groups.first.id : null;
      _breed = breeds.isEmpty
          ? null
          : breeds.firstWhere(
              (b) => b.nameEn == 'Holstein',
              orElse: () => breeds.first,
            );
      _loading = false;
    });
  }

  Future<void> _reloadForSpecies(Species species) async {
    final groups =
        await ref.read(groupRepositoryProvider).listGroups(species: species);
    final breeds = await ref.read(breedsForSpeciesProvider(species).future);
    if (!mounted) return;
    setState(() {
      _species = species;
      _groups = groups;
      _breeds = breeds;
      _breed = breeds.isEmpty ? null : breeds.first;
      if (_groupId != null &&
          _groupId != createNewGroupOption &&
          !_groups.any((g) => g.id == _groupId)) {
        _groupId = _groups.isNotEmpty ? _groups.first.id : null;
      }
    });
  }

  String _speciesTileLabel(Species s, AppLocalizations l10n) => switch (s) {
        Species.cattle => l10n.cattle,
        Species.goat => l10n.goat,
        Species.sheep => l10n.sheep,
      };

  String _groupLabel(AnimalGroup g, AppLocalizations l10n) {
    final sp = localizedSpecies(g.species, l10n);
    return l10n.groupSpeciesLabel(g.name, sp.toLowerCase());
  }

  Future<void> _pickDate({required bool purchase}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (purchase ? _purchaseDate : _dob) ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    final validation = ref.read(animalInputValidationProvider);
    setState(() {
      if (purchase) {
        _purchaseDate = picked;
      } else {
        _dob = picked;
        _validationMessage = validation.firstMessage(
          validation.validateDateOfBirth(picked, species: _species),
        );
      }
    });
  }

  Future<void> _onGroupChanged(String? value) async {
    if (value == createNewGroupOption) {
      final created =
          await promptCreateGroupForAnimal(context, ref, species: _species);
      if (!mounted) return;
      if (created != null) {
        setState(() {
          _groups = [..._groups, created];
          _groupId = created.id;
          _validationMessage = null;
        });
      } else {
        setState(() {
          _groupId = _groups.isNotEmpty ? _groups.first.id : null;
        });
      }
      return;
    }
    setState(() => _groupId = value);
  }

  bool _validateStep(int step) {
    final l10n = context.l10n;
    final validation = ref.read(animalInputValidationProvider);
    if (step == 0) {
      final issues = validation.validateTag(
        _tagCtrl.text,
        existingTags: _existingTags,
      );
      if (issues.isNotEmpty) {
        setState(() => _validationMessage = issues.first.message);
        return false;
      }
      setState(() => _validationMessage = null);
      return true;
    }
    if (step == 1) {
      final issues = validation.validateNewAnimal(
        tag: _tagCtrl.text,
        weightText: _weightCtrl.text,
        dob: _dob,
        species: _species,
        existingTags: _existingTags,
      );
      if (issues.isNotEmpty) {
        setState(() => _validationMessage = issues.first.message);
        return false;
      }
      if (_breed == null) {
        setState(() => _validationMessage = l10n.loadingBreeds);
        return false;
      }
      setState(() => _validationMessage = null);
      return true;
    }
    return true;
  }

  void _onContinue() {
    if (!_validateStep(_step)) return;
    setState(() => _step += 1);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final validation = ref.read(animalInputValidationProvider);
    final issues = validation.validateNewAnimal(
      tag: _tagCtrl.text,
      weightText: _weightCtrl.text,
      dob: _dob,
      species: _species,
      existingTags: _existingTags,
    );
    if (issues.isNotEmpty) {
      setState(() => _validationMessage = issues.first.message);
      return;
    }
    final gid = _groupId;
    if (gid == null || gid.isEmpty || gid == createNewGroupOption) {
      setState(() => _validationMessage = l10n.selectGroupRequired);
      return;
    }
    final weight =
        double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.'));
    if (weight == null || _breed == null) return;

    setState(() => _busy = true);
    try {
      final tag = _tagCtrl.text.trim();
      final displayName =
          _nameCtrl.text.trim().isEmpty ? tag : _nameCtrl.text.trim();
      final now = DateTime.now();
      final estimatedDob = _dob ??
          (_ageRangeLabel != null
              ? AnimalMapper.dobFromAgeLabel(_ageRangeLabel!)
              : null);
      var animal = Animal(
        id: const Uuid().v4(),
        tag: tag,
        name: displayName,
        species: _species,
        sex: _sex,
        breed: _breed!.nameEn,
        weightKg: weight,
        ageLabel: estimatedDob != null
            ? ageLabelFromDob(estimatedDob, now, l10n)
            : (_ageRangeLabel ?? l10n.ageNew),
        dob: estimatedDob,
        groupId: gid,
        sire: _sireCtrl.text.trim().isEmpty ? null : _sireCtrl.text.trim(),
        dam: _damCtrl.text.trim().isEmpty ? null : _damCtrl.text.trim(),
        isTwin: _twin,
        productionPurpose: _productionPurpose,
      );
      animal = await syncAnimalReadyToBreedWithGroup(
        ref,
        animal,
        context: context,
      );
      await ref.read(animalRepositoryProvider).createAnimal(animal);
      if (!mounted) return;
      Navigator.pop(context);
      refreshHerdDataProviders(ref);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _validationMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GhColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      l10n.addAnimalTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _busy ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: List.generate(_steps, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: i < _steps - 1 ? 6 : 0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? GhColors.primary : GhColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_validationMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _validationMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if (_step == 0) _buildStep1(l10n),
                      if (_step == 1) _buildStep2(l10n),
                      if (_step == 2) _buildStep3(l10n),
                    ],
                  ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: GhColors.border)),
            ),
            child: _step == 0
                ? FilledButton(
                    onPressed: _busy ? null : _onContinue,
                    child: Text(l10n.continueButton),
                  )
                : Row(
                    children: [
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() => _step -= 1),
                        child: Text(l10n.backButton),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy
                              ? null
                              : (_step == 2 ? _save : _onContinue),
                          child: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _step == 2
                                      ? l10n.saveAnimal
                                      : l10n.continueButton,
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: GhTypography.labelXs.copyWith(
            color: GhColors.textFaint,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _buildStep1(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(l10n.species),
        Row(
          children: Species.values.map((s) {
            final selected = _species == s;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: s != Species.sheep ? 8 : 0,
                ),
                child: Material(
                  color: selected ? const Color(0xFFF0F7EB) : GhColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? GhColors.primary : GhColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _reloadForSpecies(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        children: [
                          SpeciesIcon.avatar(s, size: 40),
                          const SizedBox(height: 6),
                          Text(
                            _speciesTileLabel(s, l10n),
                            style: GhTypography.h05.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _sectionLabel(l10n.origin),
        Wrap(
          children: [
            GhChip(
              label: l10n.bornOnFarm,
              selected: _origin == _AnimalOrigin.born,
              onTap: () => setState(() => _origin = _AnimalOrigin.born),
            ),
            GhChip(
              label: l10n.purchased,
              selected: _origin == _AnimalOrigin.purchased,
              onTap: () => setState(() => _origin = _AnimalOrigin.purchased),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _sectionLabel(l10n.earTag),
        TextField(
          key: const Key('add_animal_tag'),
          controller: _tagCtrl,
          decoration: InputDecoration(hintText: l10n.earTagHint),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 14),
        _sectionLabel(l10n.nameOptional),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(hintText: l10n.nameOptionalPlaceholder),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.nameOptionalHint,
          style: GhTypography.labelXs.copyWith(color: GhColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStep2(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(l10n.sex),
        Wrap(
          children: [
            GhChip(
              label: l10n.female,
              selected: _sex == 'Female',
              onTap: () => setState(() => _sex = 'Female'),
            ),
            GhChip(
              label: l10n.male,
              selected: _sex == 'Male',
              onTap: () => setState(() => _sex = 'Male'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_breeds.isEmpty)
          Text(l10n.loadingBreeds)
        else
          DropdownButtonFormField<BreedReference>(
            initialValue: _breed,
            decoration: InputDecoration(
              labelText: l10n.breedForSpecies(
                _speciesTileLabel(_species, l10n).toLowerCase(),
              ),
            ),
            items: _breeds
                .map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(b.displayName(locale)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _breed = v),
          ),
        const SizedBox(height: 14),
        AnimalPurposeField(
          value: _productionPurpose,
          l10n: l10n,
          onChanged: (p) => setState(() => _productionPurpose = p),
        ),
        const SizedBox(height: 14),
        if (_origin == _AnimalOrigin.born) ...[
          _sectionLabel(l10n.dateOfBirth),
          OutlinedButton.icon(
            onPressed: () => _pickDate(purchase: false),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              _dob == null
                  ? 'dd/mm/yyyy'
                  : l10n.bornOnDate(_dob!.day, _dob!.month, _dob!.year),
            ),
          ),
          const SizedBox(height: 14),
          _buildNewbornCard(l10n),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel(l10n.weight),
                    TextField(
                      key: const Key('add_animal_weight'),
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: 'kg',
                        hintText: l10n.weightHint,
                      ),
                    ),
                    Text(
                      l10n.birthWeightHint,
                      style: GhTypography.labelXs
                          .copyWith(color: GhColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel(l10n.heightCm),
                    TextField(
                      controller: _heightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: 'cm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          _sectionLabel(l10n.purchaseDate),
          OutlinedButton.icon(
            onPressed: () => _pickDate(purchase: true),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              _purchaseDate == null
                  ? 'dd/mm/yyyy'
                  : l10n.bornOnDate(
                      _purchaseDate!.day,
                      _purchaseDate!.month,
                      _purchaseDate!.year,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          _sectionLabel(l10n.dobIfKnown),
          OutlinedButton.icon(
            onPressed: () => _pickDate(purchase: false),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              _dob == null
                  ? 'dd/mm/yyyy'
                  : l10n.bornOnDate(_dob!.day, _dob!.month, _dob!.year),
            ),
          ),
          Text(
            l10n.dobOrAgeRangeHint,
            style: GhTypography.labelXs.copyWith(color: GhColors.textSecondary),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _ageRangeLabel,
            decoration: InputDecoration(labelText: l10n.ageRangeIfUnknown),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.pickAgeRange)),
              ..._ageRanges.map(
                (r) => DropdownMenuItem(value: r, child: Text(r)),
              ),
            ],
            onChanged: (v) => setState(() => _ageRangeLabel = v),
          ),
          const SizedBox(height: 14),
          _sectionLabel(l10n.supplierSource),
          TextField(
            controller: _supplierCtrl,
            decoration: InputDecoration(hintText: l10n.supplierHint),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel(l10n.purchasePrice),
                    TextField(
                      controller: _purchasePriceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: 'SAR'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel(l10n.weight),
                    TextField(
                      key: const Key('add_animal_weight'),
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: 'kg',
                        hintText: l10n.weightHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNewbornCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.child_care_outlined,
                  size: 18, color: GhColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.newbornDetails,
                style: GhTypography.h05.copyWith(
                  color: GhColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _birthSize,
                  decoration: InputDecoration(labelText: l10n.sizeAtBirth),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'Small',
                      child: Text(l10n.birthSizeSmall),
                    ),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Text(l10n.birthSizeMedium),
                    ),
                    DropdownMenuItem(
                      value: 'Large',
                      child: Text(l10n.birthSizeLarge),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _birthSize = v ?? _birthSize),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _vigour,
                  decoration: InputDecoration(labelText: l10n.vigour),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'Weak',
                      child: Text(l10n.vigourWeak),
                    ),
                    DropdownMenuItem(
                      value: 'Average',
                      child: Text(l10n.vigourAverage),
                    ),
                    DropdownMenuItem(
                      value: 'Strong',
                      child: Text(l10n.vigourStrong),
                    ),
                  ],
                  onChanged: (v) => setState(() => _vigour = v ?? _vigour),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _assistance,
            decoration: InputDecoration(labelText: l10n.birthingAssistance),
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'None', child: Text(l10n.assistanceNone)),
              DropdownMenuItem(
                value: 'Easy pull',
                child: Text(l10n.assistanceEasyPull),
              ),
              DropdownMenuItem(
                value: 'Hard pull',
                child: Text(l10n.assistanceHardPull),
              ),
              DropdownMenuItem(
                value: 'Vet assisted',
                child: Text(l10n.assistanceVet),
              ),
              DropdownMenuItem(
                value: 'C-section',
                child: Text(l10n.assistanceCSection),
              ),
            ],
            onChanged: (v) => setState(() => _assistance = v ?? _assistance),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: _twin,
              onChanged: (v) => setState(() => _twin = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                l10n.animalIsTwin,
                style: GhTypography.body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(AppLocalizations l10n) {
    final tag = _tagCtrl.text.trim();
    final originLine = _origin == _AnimalOrigin.born
        ? l10n.summaryOriginBorn
        : _supplierCtrl.text.trim().isEmpty
            ? l10n.summaryOriginPurchased
            : l10n.summaryOriginPurchasedFrom(_supplierCtrl.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _groupId,
          decoration: InputDecoration(labelText: l10n.group),
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: createNewGroupOption,
              child: Text('+ ${l10n.newGroup}'),
            ),
            ..._groups.map(
              (g) => DropdownMenuItem(
                value: g.id,
                child: Text(_groupLabel(g, l10n)),
              ),
            ),
          ],
          onChanged: _onGroupChanged,
        ),
        if (_groups.isEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _onGroupChanged(createNewGroupOption),
            icon: const Icon(Icons.add),
            label: Text(l10n.newGroup),
          ),
        ],
        const SizedBox(height: 14),
        _sectionLabel(l10n.sireOptional),
        TextField(
          controller: _sireCtrl,
          decoration: InputDecoration(hintText: l10n.parentSearchHint),
        ),
        const SizedBox(height: 14),
        _sectionLabel(l10n.damOptional),
        TextField(
          controller: _damCtrl,
          decoration: InputDecoration(hintText: l10n.parentSearchHint),
        ),
        const SizedBox(height: 14),
        _sectionLabel(l10n.notes),
        TextField(
          controller: _notesCtrl,
          decoration: InputDecoration(hintText: l10n.notesHint),
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GhColors.pageBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.youreAdding,
                style: GhTypography.h05.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '1 ${_speciesTileLabel(_species, l10n).toLowerCase()} · '
                '${_sex == 'Female' ? l10n.female : l10n.male} · '
                '${_breed?.nameEn ?? ''}',
                style: GhTypography.body.copyWith(color: GhColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                'Origin: $originLine${tag.isNotEmpty ? ' · #$tag' : ''}',
                style: GhTypography.body.copyWith(color: GhColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
