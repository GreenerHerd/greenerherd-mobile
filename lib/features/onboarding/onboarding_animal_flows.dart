import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/providers.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_mapper.dart';

/// Single-animal onboarding (step 3A).
Future<bool> runOnboardingAddAnimal(
  BuildContext context,
  WidgetRef ref, {
  required Species species,
}) async {
  final tagCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final breedCtrl = TextEditingController(text: 'Holstein');
  var sex = 'Female';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add first animal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagCtrl,
              decoration: const InputDecoration(labelText: 'Ear tag'),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            TextField(
              controller: breedCtrl,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              initialSelection: sex,
              label: const Text('Sex'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Female', label: 'Female'),
                DropdownMenuEntry(value: 'Male', label: 'Male'),
              ],
              onSelected: (v) {
                if (v != null) sex = v;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;
  final animal = Animal(
    id: const Uuid().v4(),
    tag: tagCtrl.text.trim().isEmpty ? 'NEW-1' : tagCtrl.text.trim(),
    name: nameCtrl.text.trim(),
    species: species,
    sex: sex,
    breed: breedCtrl.text.trim().isEmpty ? 'Holstein' : breedCtrl.text.trim(),
    weightKg: 0,
    ageLabel: '1-2yr',
    dob: AnimalMapper.dobFromAgeLabel('1-2yr'),
    groupId: '',
  );
  await ref.read(animalRepositoryProvider).createAnimal(animal);
  return true;
}

/// Bulk group onboarding (step 3B).
Future<bool> runOnboardingBulkGroup(
  BuildContext context,
  WidgetRef ref, {
  required Species species,
}) async {
  final nameCtrl = TextEditingController(text: 'Starter herd');
  final breedCtrl = TextEditingController(text: 'Holstein');
  final countCtrl = TextEditingController(text: '10');
  var sex = 'Female';
  var purpose = GroupPurpose.maintenance;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add animals as a group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Group name'),
            ),
            TextField(
              controller: breedCtrl,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            TextField(
              controller: countCtrl,
              decoration: const InputDecoration(labelText: 'Head count'),
              keyboardType: TextInputType.number,
            ),
            DropdownMenu<String>(
              initialSelection: sex,
              label: const Text('Sex'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Female', label: 'Female'),
                DropdownMenuEntry(value: 'Male', label: 'Male'),
              ],
              onSelected: (v) {
                if (v != null) sex = v;
              },
            ),
            DropdownMenu<GroupPurpose>(
              initialSelection: purpose,
              label: const Text('Purpose'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: GroupPurpose.maintenance,
                  label: 'Maintenance',
                ),
                DropdownMenuEntry(value: GroupPurpose.milk, label: 'Milk'),
                DropdownMenuEntry(
                  value: GroupPurpose.breeding,
                  label: 'Breeding',
                ),
              ],
              onSelected: (v) {
                if (v != null) purpose = v;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Create group'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;
  final count = int.tryParse(countCtrl.text.trim()) ?? 1;
  final result = await ref.read(groupRepositoryProvider).createGroupBulk(
        species: species,
        breed: breedCtrl.text.trim(),
        sex: sex,
        ageRangeWire: '1_2Y',
        count: count,
        name: nameCtrl.text.trim(),
        purpose: purpose,
      );
  final lifecycle = ref.read(lifecycleServiceProvider);
  final animalRepo = ref.read(animalRepositoryProvider);
  for (final animal in result.animals) {
    var updated = animal;
    if (purpose == GroupPurpose.breeding) {
      updated = lifecycle.applyBreedingGroupPurpose(updated, purpose);
    }
    if (purpose == GroupPurpose.milk) {
      updated = lifecycle.applyMilkingGroupPurpose(updated, purpose);
      updated = lifecycle.syncLactationForGroupMembership(
        updated,
        group: result.group,
      );
    }
    if (updated != animal) {
      await animalRepo.updateAnimal(updated);
    }
  }
  return true;
}
