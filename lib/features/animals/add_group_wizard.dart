import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/models/breed_reference.dart';
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_input_validation.dart';
import '../../data/services/animal_mapper.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/gh_design_icons.dart';
import '../../shared/widgets/gh_group_name_field.dart';
import 'add_group_sheet.dart';
import 'animal_form_helpers.dart';
import 'widgets/group_member_compact_row.dart';
import 'widgets/group_wizard_confirmation_step.dart';
import 'widgets/member_status_dialogs.dart';

const ageRangeLabels = [
  '0-3m',
  '4-6m',
  '7-11m',
  '1-2yr',
  '2-3yr',
  '3-5yr',
  '5+yr',
];

// DoB estimation uses AnimalMapper.dobFromAgeLabel

/// Opens the multi-stage group creation wizard.
Future<void> showAddGroupWizard(
  BuildContext context,
  WidgetRef ref, {
  Species? initialSpecies,
}) async {
  final container = ProviderScope.containerOf(context);
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: AddGroupWizardScreen(initialSpecies: initialSpecies),
      ),
    ),
  );
}

class GroupMemberDraft {
  GroupMemberDraft({
    required this.id,
    required this.index,
    required this.tag,
    required this.sex,
    required this.breed,
    this.dob,
    this.ageMonths,
    this.weightKg,
    this.pregnant = false,
    this.gestMonths,
    this.dueDate,
    this.prolificacy,
    this.isTwin = false,
    this.lactating = false,
    this.sick = false,
    this.sickNote,
    this.memberNotes,
    this.cull = false,
    this.readyToBreed = false,
    this.breedingMethod,
    this.damTag,
    this.weaning = false,
    this.productionPurpose = SpeciesPurpose.both,
  });

  final String id;
  final int index;
  String tag;
  String sex;
  String breed;
  SpeciesPurpose productionPurpose;
  DateTime? dob;
  int? ageMonths;
  double? weightKg;
  bool pregnant;
  int? gestMonths;
  DateTime? dueDate;
  int? prolificacy;
  bool isTwin;
  bool lactating;
  bool sick;
  String? sickNote;
  String? memberNotes;
  bool cull;
  bool readyToBreed;
  BreedingMethod? breedingMethod;
  String? damTag;
  bool weaning;

  int? get effectiveAgeMonths =>
      ageMonths ?? ReproductionStatusRules.ageMonthsFromDob(dob);

  List<AnimalTagType> buildTags(Species species) {
    final age = effectiveAgeMonths;
    final tags = <AnimalTagType>[];
    if (pregnant &&
        ReproductionStatusRules.canBePregnant(
          species: species,
          sex: sex,
          ageMonths: age,
        )) {
      tags.add(AnimalTagType.pregnant);
    }
    if (lactating &&
        ReproductionStatusRules.canLactate(
          species: species,
          sex: sex,
          ageMonths: age,
        )) {
      tags.add(AnimalTagType.lactating);
    }
    if (sick) tags.add(AnimalTagType.sick);
    if (cull) tags.add(AnimalTagType.cull);
    if (readyToBreed &&
        ReproductionStatusRules.canMarkReadyToBreed(
          species: species,
          sex: sex,
          ageMonths: age,
        )) {
      tags.add(AnimalTagType.readyToBreed);
    }
    if (weaning) tags.add(AnimalTagType.weaning);
    return tags;
  }

  /// Default ready-to-breed when the group purpose is breeding.
  void applyBreedingGroupDefaults({
    required GroupPurpose purpose,
    required Species species,
    int? fallbackAgeMonths,
  }) {
    if (purpose != GroupPurpose.breeding) {
      if (readyToBreed) {
        readyToBreed = false;
        breedingMethod = null;
      }
      return;
    }
    if (pregnant) return;

    final age = effectiveAgeMonths ?? fallbackAgeMonths;
    if (!ReproductionStatusRules.canMarkReadyToBreed(
      species: species,
      sex: sex,
      ageMonths: age,
    )) {
      readyToBreed = false;
      breedingMethod = null;
      return;
    }

    readyToBreed = true;
    if (BreedingMethodCatalog.requiresMethodOnReadyToBreed(species)) {
      breedingMethod ??= BreedingMethod.natural;
    }
  }
}

class AddGroupWizardScreen extends ConsumerStatefulWidget {
  const AddGroupWizardScreen({super.key, this.initialSpecies});

  final Species? initialSpecies;

  @override
  ConsumerState<AddGroupWizardScreen> createState() =>
      _AddGroupWizardScreenState();
}

class _AddGroupWizardScreenState extends ConsumerState<AddGroupWizardScreen> {
  static const _totalSteps = 4;
  var _step = 0;
  var _busy = false;
  AnimalGroup? _createdGroup;
  GroupWizardConfirmPhase _confirmPhase = GroupWizardConfirmPhase.overview;

  // Group details
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late Species _species;
  var _purpose = GroupPurpose.breeding;
  var _defaultAnimalPurpose = SpeciesPurpose.both;

  // Origin — selected on the first screen
  var _origin = GroupLivestockOrigin.existing;

  // Purchase details (purchased origin only)
  final _supplierCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();

  // Demographics
  final _countCtrl = TextEditingController(text: '10');
  List<BreedReference> _breeds = [];
  BreedReference? _selectedBreed;
  var _sex = 'Female';
  var _ageRangeLabel = '1-2yr';
  var _vaccinated = false;
  VaccinationEvent? _selectedVaccinationEvent;

  String? _validationMessage;
  List<GroupMemberDraft> _members = [];

  @override
  void initState() {
    super.initState();
    _species = widget.initialSpecies ?? Species.cattle;
    _loadBreeds(_species);
  }

  Future<void> _loadBreeds(Species species) async {
    final breeds = [
      ...await ref.read(breedsForSpeciesProvider(species).future),
    ];
    breeds.sort(
        (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
    if (!mounted) return;
    setState(() {
      _breeds = breeds;
      _selectedBreed =
          breeds.isEmpty ? null : breeds.firstWhere(
            (b) => b.nameEn == 'Holstein',
            orElse: () => breeds.first,
          );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _countCtrl.dispose();
    _supplierCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(l10n)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              GhDesignIcons.animalGroup,
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_showBackButton)
                  TextButton(
                    onPressed: _busy ? null : _onBack,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                if (_showFooterPrimary)
                  FilledButton(
                    onPressed: _busy ? null : _onPrimary,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_primaryLabel(l10n)),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.wizardStepOf(_step + 1, _totalSteps),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (_step + 1) / _totalSteps),
              ],
            ),
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  bool get _showBackButton {
    if (_step == 0) return false;
    if (_step == 3 && _confirmPhase != GroupWizardConfirmPhase.addMeal) {
      return false;
    }
    return true;
  }

  bool get _showFooterPrimary => _step < 3;

  String _primaryLabel(AppLocalizations l10n) {
    if (_step < 3) return l10n.continueButton;
    return l10n.finishGroup;
  }

  String _stepTitle(AppLocalizations l10n) => switch (_step) {
        0 => _origin == GroupLivestockOrigin.purchased
            ? l10n.purchaseWizardDetails
            : l10n.groupWizardDetails,
        1 => l10n.groupWizardHerd,
        2 => l10n.groupWizardAnimals,
        _ => l10n.groupWizardSummary,
      };

  Widget _buildStep() => switch (_step) {
        0 => _buildStep0(),
        1 => _buildStep1(),
        2 => _buildStep2(),
        _ => _buildStep3Confirmation(),
      };

  Widget _buildStep3Confirmation() {
    final group = _createdGroup;
    if (group == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return GroupWizardConfirmationStep(
      group: group,
      species: _species,
      purpose: _purpose,
      breedName: _selectedBreed?.nameEn ?? 'Holstein',
      sex: _sex,
      ageRangeLabel: _ageRangeLabel,
      members: _members,
      phase: _confirmPhase,
      onPhaseChanged: (p) => setState(() => _confirmPhase = p),
      onSkipMeal: () {},
      onMealSaved: _recordMealForGroup,
      onAddAnotherGroup: _startAnotherGroup,
      onClose: () => Navigator.pop(context),
    );
  }

  void _startAnotherGroup() {
    setState(() {
      _step = 0;
      _createdGroup = null;
      _confirmPhase = GroupWizardConfirmPhase.overview;
      _members = [];
      _validationMessage = null;
      _nameCtrl.clear();
      _descCtrl.clear();
      _countCtrl.text = '10';
      _supplierCtrl.clear();
      _priceCtrl.clear();
      _vaccinated = false;
      _selectedVaccinationEvent = null;
    });
  }

  Future<void> _recordMealForGroup(String mealId, double kg) async {
    final groupId = _createdGroup?.id;
    if (groupId == null) return;
    await ref.read(inventoryRepositoryProvider).recordFeeding(
          groupId: groupId,
          mealTypeId: mealId,
          totalWeightKg: kg,
          headCount: _members.length,
        );
    refreshHerdDataProviders(ref);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordFeeding)),
      );
    }
  }

  // ── Step 0: Origin + contextual details ──
  // Existing / Born  → origin selector + group details
  // Purchased        → origin selector + purchase details

  Widget _buildStep0() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.groupOfLivestock.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: GhColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          GroupOriginSegmented(
            origin: _origin,
            l10n: l10n,
            onChanged: (origin) {
              setState(() {
                _origin = origin;
                _validationMessage = null;
                if (origin == GroupLivestockOrigin.born) {
                  _ageRangeLabel = '0-3m';
                }
              });
            },
          ),
          const SizedBox(height: 20),
          if (_origin == GroupLivestockOrigin.purchased)
            ..._purchaseDetailFields(l10n)
          else
            ..._groupDetailFields(l10n),
        ],
      ),
    );
  }

  List<Widget> _groupDetailFields(AppLocalizations l10n) => [
        GhGroupNameField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.groupName,
            hintText: 'e.g. Breeding herd',
          ),
          onChanged: (_) => setState(() => _validationMessage = null),
        ),
        if (_validationMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _validationMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Species>(
                value: _species,
                decoration: InputDecoration(
                  labelText: l10n.species,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: Species.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(localizedSpecies(s, l10n)),
                        ))
                    .toList(),
                onChanged: (v) async {
                  if (v != null) {
                    setState(() => _species = v);
                    await _loadBreeds(v);
                    _applyBreedingGroupDefaultsToAllMembers();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GroupPurposeField(
          value: _purpose,
          l10n: l10n,
          onChanged: (p) => setState(() {
            _purpose = p;
            _applyBreedingGroupDefaultsToAllMembers();
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          decoration: InputDecoration(labelText: l10n.descriptionOptional),
          maxLines: 2,
        ),
      ];

  List<Widget> _purchaseDetailFields(AppLocalizations l10n) => [
        TextField(
          controller: _supplierCtrl,
          decoration: InputDecoration(
            labelText: l10n.supplierSource,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _priceCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.purchasePrice,
            suffixText: 'SAR',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _purchaseDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _purchaseDate = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.purchaseDate,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(
              '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
            ),
          ),
        ),
      ];

  // ── Step 1: Demographics (+ group details for purchased) ──

  Widget _buildStep1() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_origin == GroupLivestockOrigin.purchased) ...[
            ..._groupDetailFields(l10n),
            const SizedBox(height: 20),
          ],
          ..._demographicFields(l10n),
        ],
      ),
    );
  }

  List<Widget> _demographicFields(AppLocalizations l10n) => [
        AnimalPurposeField(
          value: _defaultAnimalPurpose,
          l10n: l10n,
          onChanged: (p) => setState(() {
            _defaultAnimalPurpose = p;
            for (final m in _members) {
              m.productionPurpose = p;
            }
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _countCtrl,
          decoration: InputDecoration(labelText: l10n.headCount),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        BreedDropdownField(
          breeds: _breeds,
          value: _selectedBreed?.nameEn ?? '',
          l10n: l10n,
          onChanged: (name) {
            if (_breeds.isEmpty) return;
            setState(() {
              _selectedBreed = _breeds.firstWhere(
                (b) => b.nameEn == name,
                orElse: () => _breeds.first,
              );
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sex,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _sex = v;
                      for (final m in _members) {
                        m.sex = v;
                      }
                      _applyBreedingGroupDefaultsToAllMembers();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _ageRangeLabel,
                decoration: InputDecoration(
                  labelText: l10n.ageRange,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: ageRangeLabels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _ageRangeLabel = v;
                      final ageMonths = AnimalMapper.ageMidpointMonths(v);
                      for (final m in _members) {
                        m.ageMonths = ageMonths;
                        m.dob = null;
                      }
                      _applyBreedingGroupDefaultsToAllMembers();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _vaccinated,
          onChanged: (v) => setState(() {
            _vaccinated = v;
            if (!v) _selectedVaccinationEvent = null;
          }),
          title: Text(l10n.vaccinated),
        ),
        if (_vaccinated) ...[
          const SizedBox(height: 8),
          _buildVaccinationEventPicker(l10n),
          if (_selectedVaccinationEvent != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${l10n.vaccinationEvent}: ${_selectedVaccinationEvent!.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ];

  // ── Step 2: Individual animals ──

  Widget _buildStep2() {
    final l10n = context.l10n;
    final isBorn = _origin == GroupLivestockOrigin.born;
    final defaultBreed = _selectedBreed?.nameEn ?? 'Holstein';
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: _members.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Review ${_members.length} animals. '
                  'Defaults from previous step: $defaultBreed · '
                  '${localizedSpeciesPurpose(_defaultAnimalPurpose, l10n)}. '
                  'Edit tags, weight, or status icons below.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: GhColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }
        final memberIndex = i - 1;
        final m = _members[memberIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GhColors.border),
          ),
          child: Column(
            children: [
              GroupMemberCompactRow(
                draft: m,
                species: _species,
                defaultSex: _sex,
                defaultBreed: defaultBreed,
                l10n: l10n,
                breeds: _breeds,
                autoReadyToBreed: _purpose == GroupPurpose.breeding,
              ),
              if (isBorn)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    key: ValueKey('dam-${m.id}'),
                    initialValue: m.damTag ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.mothersTag,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      prefixIcon:
                          const Icon(Icons.family_restroom, size: 18),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) {
                      m.damTag = v.trim().isEmpty ? null : v.trim();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ──

  Widget _buildVaccinationEventPicker(AppLocalizations l10n) {
    final activeEvents = ref.watch(activeVaccinationEventsProvider);

    if (activeEvents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: GhColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GhColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: GhColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.noActiveVaccinationEvents,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GhColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _promptCreateVaccination(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.createVaccinationEvent),
          ),
        ],
      );
    }

    return DropdownButtonFormField<VaccinationEvent>(
      value: _selectedVaccinationEvent,
      decoration: InputDecoration(
        labelText: l10n.selectVaccinationEvent,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        ...activeEvents.map(
          (e) {
            final ago = DateTime.now().difference(e.createdAt).inHours;
            final timeLabel = ago < 1 ? 'just now' : '${ago}h ago';
            return DropdownMenuItem(
              value: e,
              child: Text('${e.name}  ·  $timeLabel'),
            );
          },
        ),
        DropdownMenuItem<VaccinationEvent>(
          value: null,
          child: Row(
            children: [
              const Icon(Icons.add, size: 16, color: GhColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n.createVaccinationEvent,
                style: const TextStyle(color: GhColors.primary),
              ),
            ],
          ),
        ),
      ],
      onChanged: (v) async {
        if (v == null) {
          await _promptCreateVaccination(context);
        } else {
          setState(() => _selectedVaccinationEvent = v);
        }
      },
    );
  }

  Future<void> _promptCreateVaccination(BuildContext context) async {
    final l10n = context.l10n;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => VaccinationEventNameDialog(
        titleLabel: l10n.createVaccinationEvent,
      ),
    );
    if (name == null || !mounted) return;
    final event = VaccinationEvent(
      id: 've-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
    );
    ref.read(mockDataStoreProvider).vaccinationEvents.add(event);
    ref.invalidate(activeVaccinationEventsProvider);
    ref.invalidate(vaccinationEventsProvider);
    setState(() => _selectedVaccinationEvent = event);
  }

  // ── Navigation ──

  void _onBack() {
    if (_step == 3 && _confirmPhase == GroupWizardConfirmPhase.addMeal) {
      setState(() => _confirmPhase = GroupWizardConfirmPhase.overview);
      return;
    }
    setState(() {
      _step -= 1;
      _validationMessage = null;
    });
  }

  Future<void> _onPrimary() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = context.l10n;
    final validation = ref.read(animalInputValidationProvider);

    if (_step == 0) {
      if (_origin == GroupLivestockOrigin.purchased) {
        if (_supplierCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.supplierSource)),
          );
          return;
        }
      } else {
        final name = syncGroupNameController(_nameCtrl);
        final issues = validation.validateGroupName(name);
        if (issues.isNotEmpty) {
          setState(() => _validationMessage = issues.first.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(issues.first.message)),
          );
          return;
        }
      }
      if (_breeds.isEmpty) {
        await _loadBreeds(_species);
      }
      if (!mounted) return;
      setState(() {
        _validationMessage = null;
        _step = 1;
      });
      return;
    }

    if (_step == 1) {
      if (_origin == GroupLivestockOrigin.purchased) {
        final name = syncGroupNameController(_nameCtrl);
        final issues = validation.validateGroupName(name);
        if (issues.isNotEmpty) {
          setState(() => _validationMessage = issues.first.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(issues.first.message)),
          );
          return;
        }
      }
      if (!_validateDemographics(l10n)) return;
      if (_breeds.isEmpty) {
        await _loadBreeds(_species);
      }
      if (!mounted) return;
      if (_breeds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadingBreeds)),
        );
        return;
      }
      _prepareMemberDrafts(int.parse(_countCtrl.text.trim()));
      setState(() {
        _validationMessage = null;
        _step = 2;
      });
      return;
    }

    if (_step == 2) {
      final group = await _finishNewGroup();
      if (group == null || !mounted) return;
      setState(() {
        _createdGroup = group;
        _confirmPhase = GroupWizardConfirmPhase.overview;
        _step = 3;
      });
      return;
    }
  }

  bool _validateDemographics(AppLocalizations l10n) {
    final count = int.tryParse(_countCtrl.text.trim());
    if (count == null || count < 1 || count > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid head count (1–500)')),
      );
      return false;
    }
    if (_vaccinated && _selectedVaccinationEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectVaccinationEvent)),
      );
      return false;
    }
    return true;
  }

  static String _ageLabelFromDob(DateTime dob) {
    final months = (DateTime.now().difference(dob).inDays / 30).round();
    if (months < 24) return '${months}m';
    return '${months ~/ 12}y';
  }

  void _applyBreedingGroupDefaultsToAllMembers() {
    if (_members.isEmpty) return;
    final fallbackAge = AnimalMapper.ageMidpointMonths(_ageRangeLabel);
    for (final m in _members) {
      m.applyBreedingGroupDefaults(
        purpose: _purpose,
        species: _species,
        fallbackAgeMonths: fallbackAge,
      );
    }
  }

  void _prepareMemberDrafts(int count) {
    if (_members.length != count) {
      final prefix = _nameCtrl.text
          .trim()
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .toUpperCase();
      final tagPrefix = prefix.length >= 3 ? prefix.substring(0, 3) : 'GRP';
      final breed = _selectedBreed?.nameEn ?? 'Holstein';
      final isBorn = _origin == GroupLivestockOrigin.born;
      final defaultAgeMonths = AnimalMapper.ageMidpointMonths(_ageRangeLabel);
      _members = List.generate(
        count,
        (i) => GroupMemberDraft(
          id: const Uuid().v4(),
          index: i,
          tag: '$tagPrefix-${(i + 1).toString().padLeft(3, '0')}',
          sex: _sex,
          breed: breed,
          ageMonths: defaultAgeMonths,
          weaning: isBorn,
          productionPurpose: _defaultAnimalPurpose,
        ),
      );
    }
    _applyBreedingGroupDefaultsToAllMembers();
  }

  Future<AnimalGroup?> _finishNewGroup() async {
    setState(() => _busy = true);
    try {
      final validation = ref.read(animalInputValidationProvider);
      final existingTags =
          (await ref.read(animalRepositoryProvider).listAnimals())
              .map((a) => a.tag)
              .toList();

      for (final m in _members) {
        final tagIssues = validation.validateTag(
          m.tag,
          existingTags: [
            ...existingTags,
            ..._members.where((x) => x.id != m.id).map((x) => x.tag),
          ],
        );
        if (tagIssues.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Animal ${m.index + 1}: ${tagIssues.first.message}')),
            );
          }
          return null;
        }
        if (m.weightKg != null) {
          final wIssues =
              validation.validateWeightKg(m.weightKg!, species: _species);
          if (wIssues.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Animal ${m.index + 1}: ${wIssues.first.message}')),
              );
            }
            return null;
          }
        }
        if (m.dob != null) {
          final dIssues =
              validation.validateDateOfBirth(m.dob, species: _species);
          if (dIssues.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Animal ${m.index + 1}: ${dIssues.first.message}')),
              );
            }
            return null;
          }
        }
      }

      final notes = StringBuffer();
      if (_descCtrl.text.trim().isNotEmpty) {
        notes.writeln(_descCtrl.text.trim());
      }
      if (_vaccinated && _selectedVaccinationEvent != null) {
        notes.writeln('Vaccination: ${_selectedVaccinationEvent!.name}');
      }
      if (_origin == GroupLivestockOrigin.purchased) {
        if (_supplierCtrl.text.trim().isNotEmpty) {
          notes.writeln('Supplier: ${_supplierCtrl.text.trim()}');
        }
        if (_priceCtrl.text.trim().isNotEmpty) {
          notes.writeln('Price: ${_priceCtrl.text.trim()} SAR');
        }
        notes.writeln(
            'Purchased: ${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}');
      }

      final count = _members.length;
      final result = await ref.read(groupRepositoryProvider).createGroupBulk(
            species: _species,
            breed: _selectedBreed?.nameEn ?? 'Holstein',
            sex: _sex,
            ageRangeWire: AnimalMapper.ageRangeWireFromLabel(_ageRangeLabel),
            count: count,
            name: normalizeGroupName(_nameCtrl.text),
            purpose: _purpose,
            notes: notes.isEmpty ? null : notes.toString().trim(),
          );

      final animalRepo = ref.read(animalRepositoryProvider);
      final animals = result.animals;

      for (var i = 0; i < _members.length; i++) {
        final draft = _members[i];
        draft.applyBreedingGroupDefaults(
          purpose: _purpose,
          species: _species,
          fallbackAgeMonths: AnimalMapper.ageMidpointMonths(_ageRangeLabel),
        );
        final base = i < animals.length
            ? animals[i]
            : Animal(
                id: draft.id,
                tag: draft.tag,
                name: '',
                species: _species,
                sex: _sex,
                breed: _selectedBreed?.nameEn ?? 'Holstein',
                weightKg: 0,
                ageLabel: _ageRangeLabel,
                groupId: result.group.id,
                weightIndicative: true,
              );

        final dob = draft.dob ??
            (draft.ageMonths != null
                ? DateTime.now()
                    .subtract(Duration(days: draft.ageMonths! * 30))
                : AnimalMapper.dobFromAgeLabel(_ageRangeLabel));
        final updated = Animal(
          id: base.id,
          tag: draft.tag.trim(),
          name: base.name,
          species: base.species,
          sex: draft.sex,
          breed: draft.breed,
          weightKg: draft.weightKg ?? base.weightKg,
          ageLabel: draft.ageMonths != null
              ? '${draft.ageMonths}m'
              : draft.dob != null
                  ? _ageLabelFromDob(draft.dob!)
                  : _ageRangeLabel,
          dob: dob,
          groupId: result.group.id,
          tags: draft.buildTags(_species),
          illnessNote: draft.sick ? draft.sickNote : null,
          gestMonths: draft.pregnant ? draft.gestMonths : null,
          dueDate: draft.pregnant ? draft.dueDate : null,
          prolificacy: draft.pregnant ? draft.prolificacy : null,
          isTwin: draft.isTwin,
          breedingMethod: draft.breedingMethod,
          weightIndicative: draft.weightKg == null,
          status: draft.cull ? AnimalStatus.culled : base.status,
          dam: draft.damTag,
          productionPurpose: draft.productionPurpose,
        );

        if (i < animals.length) {
          await animalRepo.updateAnimal(updated);
        } else {
          await animalRepo.createAnimal(updated);
        }
      }

      refreshHerdDataProviders(ref);
      return result.group;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
