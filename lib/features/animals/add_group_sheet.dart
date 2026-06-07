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
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_input_validation.dart';
import '../../shared/widgets/gh_group_name_field.dart';
import '../../shared/widgets/species_icon.dart';
import '../groups/group_mock_extras.dart';
import 'animal_form_helpers.dart';
import '../tasks/task_completion.dart';
enum GroupLivestockOrigin { existing, born, purchased }

/// Group purpose (milking, breeding, pregnant, etc.).
class GroupPurposeField extends StatelessWidget {
  const GroupPurposeField({
    super.key,
    required this.value,
    required this.l10n,
    required this.onChanged,
  });

  final GroupPurpose value;
  final AppLocalizations l10n;
  final ValueChanged<GroupPurpose> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GroupPurpose>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.groupPurpose,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: GroupPurpose.values
          .map(
            (p) => DropdownMenuItem(
              value: p,
              child: Text(GroupMockExtras.purposeLabel(p)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// Breed picker for a species (always a dropdown when breeds are loaded).
class BreedDropdownField extends StatelessWidget {
  const BreedDropdownField({
    super.key,
    required this.breeds,
    required this.value,
    required this.l10n,
    required this.onChanged,
    this.isDense = true,
    this.showFieldLabel = true,
  });

  final List<BreedReference> breeds;
  final String value;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final bool isDense;

  /// When false, omit [InputDecoration.labelText] (parent supplies a label).
  final bool showFieldLabel;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final padding = isDense
        ? EdgeInsets.symmetric(
            horizontal: 12,
            vertical: showFieldLabel ? 12 : 10,
          )
        : null;
    if (breeds.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: showFieldLabel ? l10n.breed : null,
          hintText: l10n.loadingBreeds,
          isDense: isDense,
          contentPadding: padding,
        ),
      );
    }

    final selected = value.isNotEmpty && breeds.any((b) => b.nameEn == value)
        ? value
        : breeds.first.nameEn;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      style: TextStyle(
        fontSize: isDense ? 14 : 16,
        height: 1.25,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: showFieldLabel ? l10n.breed : null,
        isDense: isDense,
        contentPadding: padding,
      ),
      items: breeds
          .map(
            (b) => DropdownMenuItem(
              value: b.nameEn,
              child: Text(
                b.displayName(locale),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isDense ? 14 : 16,
                  height: 1.25,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// Design handoff: single-sheet [AddGroupSheet] with existing / new livestock.
Future<void> showAddGroupSheet(BuildContext context, WidgetRef ref) async {
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
      builder: (_, scrollController) => _AddGroupSheet(
        initialSpecies: initialSpecies,
        scrollController: scrollController,
      ),
    ),
  );
}

class _NewGroupAnimalDraft {
  _NewGroupAnimalDraft({required this.id});

  final String id;
  final tagCtrl = TextEditingController();
  var sex = 'Female';
  var breed = '';
  var animalPurpose = SpeciesPurpose.both;
  final weightCtrl = TextEditingController();
  final damCtrl = TextEditingController();
  final sireCtrl = TextEditingController();
  final supplierCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  void dispose() {
    tagCtrl.dispose();
    weightCtrl.dispose();
    damCtrl.dispose();
    sireCtrl.dispose();
    supplierCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _AddGroupSheet extends ConsumerStatefulWidget {
  const _AddGroupSheet({
    required this.initialSpecies,
    required this.scrollController,
  });

  final Species initialSpecies;
  final ScrollController scrollController;

  @override
  ConsumerState<_AddGroupSheet> createState() => _AddGroupSheetState();
}

class _AddGroupSheetState extends ConsumerState<_AddGroupSheet> {
  static const _totalSteps = 2;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late Species _species;
  var _purpose = GroupPurpose.milk;
  late BreedingMethod _groupBreedingMethod;
  var _defaultAnimalPurpose = SpeciesPurpose.both;
  var _step = 0;
  var _origin = GroupLivestockOrigin.existing;
  final _selectedExisting = <String>{};
  final _newDrafts = <_NewGroupAnimalDraft>[];
  String? _validationMessage;
  var _busy = false;

  List<Animal> _allAnimals = [];
  List<BreedReference> _breeds = [];
  var _herdBreed = '';
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _species = widget.initialSpecies;
    _groupBreedingMethod = BreedingMethodCatalog.defaultForSpecies(_species);
    _load();
    _loadBreeds();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (final d in _newDrafts) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final animals = await ref.read(animalRepositoryProvider).listAnimals();
    if (!mounted) return;
    setState(() {
      _allAnimals = animals;
      _loading = false;
    });
  }

  List<Animal> get _eligibleExisting => _allAnimals
      .where(
        (a) =>
            a.species == _species &&
            a.status == AnimalStatus.active,
      )
      .toList()
    ..sort((a, b) => a.tag.compareTo(b.tag));

  int get _livestockCount => _origin == GroupLivestockOrigin.existing
      ? _selectedExisting.length
      : _newDrafts.length;

  Future<void> _loadBreeds() async {
    final breeds =
        await ref.read(breedsForSpeciesProvider(_species).future);
    if (!mounted) return;
    setState(() {
      _breeds = breeds;
      _herdBreed = _defaultBreedName();
    });
  }

  String _defaultBreedName() {
    if (_breeds.isNotEmpty) {
      final preferred = switch (_species) {
        Species.cattle => 'Holstein',
        Species.goat => 'Aardi',
        Species.sheep => 'Najdi',
      };
      for (final b in _breeds) {
        if (b.nameEn == preferred) return b.nameEn;
      }
      return _breeds.first.nameEn;
    }
    return switch (_species) {
      Species.cattle => 'Holstein',
      Species.goat => 'Aardi',
      Species.sheep => 'Najdi',
    };
  }

  void _onSpeciesChanged(Species? value) {
    if (value == null) return;
    setState(() {
      _species = value;
      _groupBreedingMethod = BreedingMethodCatalog.defaultForSpecies(value);
      _selectedExisting.clear();
      _clearNewDrafts();
    });
    _loadBreeds();
  }

  void _onOriginChanged(GroupLivestockOrigin origin) {
    setState(() {
      _origin = origin;
      _selectedExisting.clear();
      _clearNewDrafts();
    });
  }

  void _clearNewDrafts() {
    for (final d in _newDrafts) {
      d.dispose();
    }
    _newDrafts.clear();
  }

  void _addNewDraft() {
    setState(() {
      final breed = _herdBreed.isEmpty ? _defaultBreedName() : _herdBreed;
      final d = _NewGroupAnimalDraft(id: const Uuid().v4())
        ..breed = breed
        ..animalPurpose = _defaultAnimalPurpose;
      _newDrafts.add(d);
    });
  }

  void _removeNewDraft(String id) {
    setState(() {
      final idx = _newDrafts.indexWhere((d) => d.id == id);
      if (idx < 0) return;
      _newDrafts[idx].dispose();
      _newDrafts.removeAt(idx);
    });
  }

  String _speciesLower(AppLocalizations l10n) =>
      localizedSpecies(_species, l10n).toLowerCase();

  Future<void> _advanceFromDetails() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final validation = ref.read(animalInputValidationProvider);
    final name = syncGroupNameController(_nameCtrl);
    final nameIssues = validation.validateGroupName(name);
    if (nameIssues.isNotEmpty) {
      setState(() => _validationMessage = nameIssues.first.message);
      return;
    }
    if (_breeds.isEmpty) {
      await _loadBreeds();
    }
    if (!mounted) return;
    setState(() {
      _validationMessage = null;
      _step = 1;
    });
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final validation = ref.read(animalInputValidationProvider);

    if (_origin != GroupLivestockOrigin.existing) {
      if (_newDrafts.isEmpty) {
        setState(
          () => _validationMessage = l10n.tapToRegisterLivestock(
            _origin == GroupLivestockOrigin.born
                ? l10n.livestockNewBorn.toLowerCase()
                : l10n.livestockNewPurchased.toLowerCase(),
            _speciesLower(l10n),
          ),
        );
        return;
      }
      final existingTags =
          _allAnimals.map((a) => a.tag).toList(growable: false);
      for (var i = 0; i < _newDrafts.length; i++) {
        final d = _newDrafts[i];
        final tagIssues = validation.validateTag(
          d.tagCtrl.text,
          existingTags: [
            ...existingTags,
            ..._newDrafts
                .where((x) => x.id != d.id)
                .map((x) => x.tagCtrl.text),
          ],
        );
        if (tagIssues.isNotEmpty) {
          setState(
            () => _validationMessage =
                '${i + 1}: ${tagIssues.first.message}',
          );
          return;
        }
        final wIssues = validation.validateWeightText(
          d.weightCtrl.text,
          species: _species,
        );
        if (wIssues.isNotEmpty) {
          setState(
            () => _validationMessage = '${i + 1}: ${wIssues.first.message}',
          );
          return;
        }
      }
    }

    setState(() {
      _busy = true;
      _validationMessage = null;
    });

    try {
      final groupId = const Uuid().v4();
      final headCount = _livestockCount;
      final group = AnimalGroup(
        id: groupId,
        name: normalizeGroupName(_nameCtrl.text),
        species: _species,
        purpose: _purpose,
        headCount: headCount,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      await ref.read(groupRepositoryProvider).createGroup(group);

      final animalRepo = ref.read(animalRepositoryProvider);
      final lifecycle = ref.read(lifecycleServiceProvider);
      final savedMembers = <Animal>[];
      final breedingMethod = _purpose == GroupPurpose.breeding
          ? _groupBreedingMethod
          : null;

      for (final animalId in _selectedExisting) {
        final animal = _allAnimals.firstWhere((a) => a.id == animalId);
        var updated = lifecycle.applyBreedingGroupPurpose(
          animal.copyWith(groupId: groupId),
          _purpose,
          method: breedingMethod,
        );
        updated = lifecycle.applyMilkingGroupPurpose(updated, _purpose);
        updated = lifecycle.syncLactationForGroupMembership(
          updated,
          group: group,
        );
        await animalRepo.updateAnimal(updated);
        savedMembers.add(updated);
      }

      for (final d in _newDrafts) {
        final weight = double.parse(
          d.weightCtrl.text.trim().replaceAll(',', '.'),
        );
        final tag = d.tagCtrl.text.trim();
        final breed = d.breed.trim().isEmpty ? _defaultBreedName() : d.breed.trim();
        var animal = lifecycle.applyBreedingGroupPurpose(
          Animal(
            id: const Uuid().v4(),
            tag: tag,
            name: tag,
            species: _species,
            sex: d.sex,
            breed: breed,
            weightKg: weight,
            ageLabel: l10n.ageNew,
            groupId: groupId,
            sire: d.sireCtrl.text.trim().isEmpty ? null : d.sireCtrl.text.trim(),
            dam: d.damCtrl.text.trim().isEmpty ? null : d.damCtrl.text.trim(),
            productionPurpose: d.animalPurpose,
          ),
          _purpose,
          method: breedingMethod,
        );
        animal = lifecycle.applyMilkingGroupPurpose(animal, _purpose);
        animal = lifecycle.syncLactationForGroupMembership(animal, group: group);
        await animalRepo.createAnimal(animal);
        savedMembers.add(animal);
      }

      if (_purpose == GroupPurpose.breeding && savedMembers.isNotEmpty) {
        final count = await ref.read(breedingWorkflowServiceProvider).scheduleForGroup(
              tasks: ref.read(taskRepositoryProvider),
              members: savedMembers,
              defaultMethod: _groupBreedingMethod,
              l10n: l10n,
            );
        if (count > 0) invalidateTaskProviders(ref);
      }

      if (!mounted) return;
      Navigator.pop(context);
      refreshHerdDataProviders(ref);
    } catch (e) {
      if (!mounted) return;
      setState(() => _validationMessage = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final footerLabel = _step == 0
        ? l10n.continueButton
        : _livestockCount == 0
            ? l10n.createGroupAction
            : _livestockCount == 1
                ? l10n.createGroupWithAnimals(_livestockCount)
                : l10n.createGroupWithAnimalsPlural(_livestockCount);

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
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.newGroup,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _busy ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  l10n.wizardStepOf(_step + 1, _totalSteps),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: (_step + 1) / _totalSteps),
              ],
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: _step == 0
                        ? _buildDetailsStep(l10n)
                        : _buildLivestockStep(l10n),
                  ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
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
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _step -= 1;
                                _validationMessage = null;
                              }),
                      child: Text(l10n.backButton),
                    ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy
                          ? null
                          : _step == 0
                              ? _advanceFromDetails
                              : _create,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(footerLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailsStep(AppLocalizations l10n) => [
        GhGroupNameField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.groupName,
            hintText: l10n.groupNameHint,
          ),
          onChanged: (_) => setState(() => _validationMessage = null),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Species>(
                initialValue: _species,
                decoration: InputDecoration(
                  labelText: l10n.species,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: Species.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(localizedSpecies(s, l10n)),
                      ),
                    )
                    .toList(),
                onChanged: _onSpeciesChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GroupPurposeField(
          value: _purpose,
          l10n: l10n,
          onChanged: (p) => setState(() => _purpose = p),
        ),
        if (_purpose == GroupPurpose.breeding) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<BreedingMethod>(
            initialValue: _groupBreedingMethod,
            decoration: InputDecoration(
              labelText: l10n.groupBreedingMethodLabel,
              helperText: l10n.groupBreedingMethodHint,
            ),
            items: [
              for (final method in BreedingMethodCatalog.forSpecies(_species))
                DropdownMenuItem(
                  value: method,
                  child: Text(BreedingMethodCatalog.label(method, l10n)),
                ),
            ],
            onChanged: (method) {
              if (method != null) setState(() => _groupBreedingMethod = method);
            },
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          decoration: InputDecoration(
            labelText: l10n.descriptionOptional,
            hintText: l10n.groupDescriptionHint,
          ),
          maxLines: 2,
        ),
      ];

  List<Widget> _buildLivestockStep(AppLocalizations l10n) => [
        if (_origin != GroupLivestockOrigin.existing) ...[
          AnimalPurposeField(
            value: _defaultAnimalPurpose,
            l10n: l10n,
            onChanged: (p) => setState(() {
              _defaultAnimalPurpose = p;
              for (final d in _newDrafts) {
                d.animalPurpose = p;
              }
            }),
          ),
          const SizedBox(height: 16),
        ],
        BreedDropdownField(
          breeds: _breeds,
          value: _herdBreed.isEmpty ? _defaultBreedName() : _herdBreed,
          l10n: l10n,
          onChanged: (name) {
            setState(() {
              _herdBreed = name;
              for (final d in _newDrafts) {
                d.breed = name;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        _sectionLabel(l10n.groupOfLivestock),
        const SizedBox(height: 8),
        GroupOriginSegmented(
          origin: _origin,
          onChanged: _onOriginChanged,
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        if (_origin == GroupLivestockOrigin.existing)
          GroupExistingAnimalPicker(
            animals: _eligibleExisting,
            selected: _selectedExisting,
            speciesLabel: _speciesLower(l10n),
            l10n: l10n,
            onToggle: (id) {
              setState(() {
                if (_selectedExisting.contains(id)) {
                  _selectedExisting.remove(id);
                } else {
                  _selectedExisting.add(id);
                }
              });
            },
          )
        else
          _NewLivestockList(
            origin: _origin,
            drafts: _newDrafts,
            l10n: l10n,
            species: _species,
            breeds: _breeds,
            onAdd: _addNewDraft,
            onRemove: _removeNewDraft,
            onChanged: () => setState(() {}),
          ),
      ];

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: GhTypography.labelXs.copyWith(color: GhColors.textFaint),
      );
}

class GroupOriginSegmented extends StatelessWidget {
  const GroupOriginSegmented({
    super.key,
    required this.origin,
    required this.onChanged,
    required this.l10n,
  });

  final GroupLivestockOrigin origin;
  final ValueChanged<GroupLivestockOrigin> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GhColors.pageBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tab(l10n.livestockExisting, GroupLivestockOrigin.existing),
          _tab(l10n.livestockNewBorn, GroupLivestockOrigin.born),
          _tab(l10n.livestockNewPurchased, GroupLivestockOrigin.purchased),
        ],
      ),
    );
  }

  Widget _tab(String label, GroupLivestockOrigin value) {
    final selected = origin == value;
    return Expanded(
      child: Material(
        color: selected ? GhColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        elevation: selected ? 1 : 0,
        shadowColor: const Color(0x14000000),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GhTypography.h05.copyWith(
                fontSize: 12,
                color: selected ? GhColors.primary : GhColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupExistingAnimalPicker extends StatelessWidget {
  const GroupExistingAnimalPicker({
    super.key,
    required this.animals,
    required this.selected,
    required this.speciesLabel,
    required this.l10n,
    required this.onToggle,
  });

  final List<Animal> animals;
  final Set<String> selected;
  final String speciesLabel;
  final AppLocalizations l10n;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GhColors.border)),
            ),
            child: Text(
              l10n.animalsAvailable(animals.length, speciesLabel).toUpperCase(),
              style: GhTypography.labelXs,
            ),
          ),
          if (animals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noAnimalsForSpecies(speciesLabel),
                textAlign: TextAlign.center,
                style: GhTypography.body.copyWith(color: GhColors.textSecondary),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: animals.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: GhColors.border),
                itemBuilder: (ctx, i) {
                  final a = animals[i];
                  final on = selected.contains(a.id);
                  final title = a.name.trim().isNotEmpty && a.name != '—'
                      ? '${a.name} #${a.tag}'
                      : '#${a.tag}';
                  return InkWell(
                    onTap: () => onToggle(a.id),
                    child: ColoredBox(
                      color: on ? GhColors.primaryLight : GhColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SpeciesIcon.avatar(a.species, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GhTypography.h05.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${a.breed} · ${a.weightKg.toStringAsFixed(0)} kg',
                                    style: GhTypography.body.copyWith(
                                      fontSize: 11,
                                      color: GhColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _CheckBox(on: on),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: on ? GhColors.primary : GhColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: on ? GhColors.primary : GhColors.border,
          width: 1.5,
        ),
      ),
      child: on
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _NewLivestockList extends StatelessWidget {
  const _NewLivestockList({
    required this.origin,
    required this.drafts,
    required this.l10n,
    required this.species,
    required this.breeds,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final GroupLivestockOrigin origin;
  final List<_NewGroupAnimalDraft> drafts;
  final AppLocalizations l10n;
  final Species species;
  final List<BreedReference> breeds;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final born = origin == GroupLivestockOrigin.born;
    final label =
        born ? l10n.livestockNewBorn.toLowerCase() : l10n.livestockNewPurchased.toLowerCase();

    return Container(
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${drafts.length} $label'.toUpperCase(),
                    style: GhTypography.labelXs,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add, size: 14),
                  label: Text(
                    l10n.addLivestockLabel(label),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (drafts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Text(
                l10n.tapToRegisterLivestock(
                  label,
                  localizedSpecies(species, l10n).toLowerCase(),
                ),
                textAlign: TextAlign.center,
                style: GhTypography.body.copyWith(color: GhColors.textSecondary),
              ),
            )
          else
            ...drafts.asMap().entries.map((e) {
              final idx = e.key;
              final d = e.value;
              return _NewLivestockRow(
                key: ValueKey(d.id),
                index: idx,
                draft: d,
                born: born,
                l10n: l10n,
                breeds: breeds,
                onRemove: () => onRemove(d.id),
                onChanged: onChanged,
              );
            }),
          if (drafts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addingCountToGroupOnSave(drafts.length),
                      style: GhTypography.body.copyWith(
                        fontSize: 12,
                        color: GhColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addAnotherAnimal),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NewLivestockRow extends StatelessWidget {
  const _NewLivestockRow({
    super.key,
    required this.index,
    required this.draft,
    required this.born,
    required this.l10n,
    required this.breeds,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _NewGroupAnimalDraft draft;
  final bool born;
  final AppLocalizations l10n;
  final List<BreedReference> breeds;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final title = born
        ? l10n.newbornAnimalN(index + 1)
        : l10n.purchasedAnimalN(index + 1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GhColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GhTypography.h05.copyWith(fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 14),
                label: Text(l10n.removeAnimal),
                style: TextButton.styleFrom(
                  foregroundColor: GhColors.textFaint,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.tagCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tag',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: draft.sex,
                  decoration: InputDecoration(
                    labelText: l10n.sex,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text(l10n.female),
                    ),
                    DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      draft.sex = v;
                      onChanged();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BreedDropdownField(
                  breeds: breeds,
                  value: draft.breed.isNotEmpty
                      ? draft.breed
                      : (breeds.isNotEmpty ? breeds.first.nameEn : ''),
                  l10n: l10n,
                  onChanged: (name) {
                    draft.breed = name;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: draft.weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.weightKg,
                    suffixText: 'kg',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimalPurposeField(
            value: draft.animalPurpose,
            l10n: l10n,
            onChanged: (p) {
              draft.animalPurpose = p;
              onChanged();
            },
          ),
          if (born) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: draft.damCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.damOptional,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: draft.sireCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.sireOptional,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: draft.supplierCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.supplierSource,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: draft.priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.purchasePrice,
                      suffixText: 'SAR',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
