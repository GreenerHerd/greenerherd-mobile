import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_input_validation.dart';
import '../../shared/widgets/gh_group_name_field.dart';
import 'breeding_workflow_actions.dart';

/// Applies [normalizeGroupName] to [controller] and returns the normalized value.
String syncGroupNameController(TextEditingController controller) {
  final normalized = normalizeGroupName(controller.text);
  if (controller.text != normalized) {
    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
  return normalized;
}

/// Animal production purpose (milk, meat, or both).
class AnimalPurposeField extends StatelessWidget {
  const AnimalPurposeField({
    super.key,
    required this.value,
    required this.l10n,
    required this.onChanged,
    this.isDense = true,
  });

  final SpeciesPurpose value;
  final AppLocalizations l10n;
  final ValueChanged<SpeciesPurpose> onChanged;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final padding = isDense
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : null;
    return DropdownButtonFormField<SpeciesPurpose>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.animalPurpose,
        isDense: isDense,
        contentPadding: padding,
      ),
      selectedItemBuilder: (context) => [
        for (final p in SpeciesPurpose.values)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              localizedSpeciesPurpose(p, l10n),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      items: SpeciesPurpose.values
          .map(
            (p) => DropdownMenuItem(
              value: p,
              child: Text(
                localizedSpeciesPurpose(p, l10n),
                overflow: TextOverflow.ellipsis,
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

/// Editable animal purpose on the individual animal record (overview).
class AnimalPurposeEditor extends ConsumerWidget {
  const AnimalPurposeEditor({
    super.key,
    required this.animal,
    this.onUpdated,
  });

  final Animal animal;
  final VoidCallback? onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AnimalPurposeField(
      value: animal.productionPurpose,
      l10n: l10n,
      isDense: false,
      onChanged: (purpose) async {
        if (purpose == animal.productionPurpose) return;
        final updated = animal.copyWith(productionPurpose: purpose);
        await ref.read(animalRepositoryProvider).updateAnimal(updated);
        onUpdated?.call();
        refreshAnimalAfterMutation(ref, animalId: animal.id);
      },
    );
  }
}

/// Dropdown sentinel — opens inline group creation.
const createNewGroupOption = '__create_new_group__';

String ageLabelFromDob(DateTime dob, DateTime now, AppLocalizations l10n) {
  var months = (now.year - dob.year) * 12 + now.month - dob.month;
  if (now.day < dob.day) months -= 1;
  if (months < 1) return l10n.ageNew;
  if (months < 24) return '${months}m';
  final years = months ~/ 12;
  final rem = months % 12;
  return rem == 0 ? '${years}y' : '${years}y ${rem}m';
}

Future<AnimalGroup?> promptCreateGroupForAnimal(
  BuildContext context,
  WidgetRef ref, {
  required Species species,
}) {
  return showDialog<AnimalGroup>(
    context: context,
    builder: (dlgCtx) => QuickCreateGroupDialog(species: species),
  );
}

/// Breeding and milking group defaults when an animal is assigned to a group.
Future<Animal> syncAnimalReadyToBreedWithGroup(
  WidgetRef ref,
  Animal animal, {
  BuildContext? context,
  BreedingMethod? groupBreedingMethod,
}) async {
  if (animal.groupId.isEmpty) return animal;
  final group = await ref.read(groupRepositoryProvider).getGroup(animal.groupId);
  if (group == null) return animal;
  var synced = ref.read(lifecycleServiceProvider).syncReadyToBreedForGroupMembership(
        animal,
        group: group,
        method: group.purpose == GroupPurpose.breeding ? groupBreedingMethod : null,
      );
  synced = ref
      .read(lifecycleServiceProvider)
      .syncLactationForGroupMembership(synced, group: group);
  if (context != null &&
      synced.tags.contains(AnimalTagType.readyToBreed) &&
      synced.breedingMethod != null) {
    await scheduleBreedingWorkflowTasks(
      ref,
      synced,
      context: context,
      method: synced.breedingMethod,
    );
  }
  return synced;
}

/// Tags and lactation cycle when the animal is assigned to a milking-purpose group.
Future<Animal> syncAnimalLactationWithGroup(
  WidgetRef ref,
  Animal animal,
) async {
  if (animal.groupId.isEmpty) return animal;
  final group = await ref.read(groupRepositoryProvider).getGroup(animal.groupId);
  if (group == null) return animal;
  return ref
      .read(lifecycleServiceProvider)
      .syncLactationForGroupMembership(animal, group: group);
}

class QuickCreateGroupDialog extends ConsumerStatefulWidget {
  const QuickCreateGroupDialog({super.key, required this.species});

  final Species species;

  @override
  ConsumerState<QuickCreateGroupDialog> createState() =>
      _QuickCreateGroupDialogState();
}

class _QuickCreateGroupDialogState extends ConsumerState<QuickCreateGroupDialog> {
  late final TextEditingController _nameCtrl;
  var _purpose = GroupPurpose.breeding;
  String _errText = '';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final validation = ref.read(animalInputValidationProvider);
    final name = syncGroupNameController(_nameCtrl);
    final issues = validation.validateGroupName(name);
    if (issues.isNotEmpty) {
      setState(() => _errText = issues.first.message);
      return;
    }
    final group = AnimalGroup(
      id: const Uuid().v4(),
      name: name,
      species: widget.species,
      purpose: _purpose,
      headCount: 0,
    );
    final saved = await ref.read(groupRepositoryProvider).createGroup(group);
    if (!mounted) return;
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.newGroup),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GhGroupNameField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l10n.groupName),
            autofocus: true,
          ),
          if (_errText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errText,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<GroupPurpose>(
            initialValue: _purpose,
            decoration: InputDecoration(labelText: l10n.purpose),
            items: GroupPurpose.values
                .map(
                  (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                )
                .toList(),
            onChanged: (v) => setState(() => _purpose = v ?? _purpose),
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
          child: Text(l10n.saveGroup),
        ),
      ],
    );
  }
}
