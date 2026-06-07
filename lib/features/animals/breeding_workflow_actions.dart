import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../tasks/task_completion.dart';

/// Schedules auto-breeding tasks for a ready-to-breed animal.
Future<void> scheduleBreedingWorkflowTasks(
  WidgetRef ref,
  Animal animal, {
  required BuildContext context,
  BreedingMethod? method,
}) async {
  if (!animal.tags.contains(AnimalTagType.readyToBreed)) return;

  final resolved = BreedingMethodCatalog.resolveMethod(
    species: animal.species,
    explicit: method ?? animal.breedingMethod,
  );

  await ref.read(breedingWorkflowServiceProvider).scheduleForAnimal(
        tasks: ref.read(taskRepositoryProvider),
        animal: animal.copyWith(breedingMethod: resolved),
        method: resolved,
        l10n: context.l10n,
      );
  invalidateTaskProviders(ref);
}

/// Removes scheduled breeding workflow tasks for an animal.
Future<void> clearBreedingWorkflowTasks(WidgetRef ref, String animalId) async {
  await ref.read(breedingWorkflowServiceProvider).clearForAnimal(
        tasks: ref.read(taskRepositoryProvider),
        animalId: animalId,
      );
  invalidateTaskProviders(ref);
}
