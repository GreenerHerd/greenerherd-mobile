import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/models.dart';

final animalProvider = FutureProvider.family<Animal?, String>((ref, id) {
  return ref.watch(animalRepositoryProvider).getAnimal(id);
});

/// Full herd list for the animals tab (group filter is applied in the UI only).
final animalsListProvider = FutureProvider<List<Animal>>((ref) async {
  final species = ref.watch(selectedSpeciesFilterProvider);
  final tag = ref.watch(selectedAnimalTagFilterProvider);
  return ref.watch(animalRepositoryProvider).listAnimals(
        species: species,
        statusTag: tag,
      );
});

/// Navigate to animals tab with a group pre-selected.
void openAnimalsForGroup(WidgetRef ref, AnimalGroup group) {
  ref.read(selectedGroupFilterProvider.notifier).state = group.id;
  ref.read(selectedSpeciesFilterProvider.notifier).state = group.species;
  ref.read(selectedAnimalTagFilterProvider.notifier).state = null;
  ref.read(dueSoonFilterProvider.notifier).state = false;
}

final groupsListProvider = FutureProvider<List<AnimalGroup>>((ref) async {
  final species = ref.watch(selectedSpeciesFilterProvider);
  return ref.watch(groupRepositoryProvider).listGroups(species: species);
});
