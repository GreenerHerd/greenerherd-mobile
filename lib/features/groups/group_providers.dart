import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/models.dart';

final groupProvider = FutureProvider.family<AnimalGroup?, String>((ref, id) {
  return ref.watch(groupRepositoryProvider).getGroup(id);
});

final groupAnimalsProvider = FutureProvider.family<List<Animal>, String>((ref, id) {
  return ref.watch(animalRepositoryProvider).listAnimals(groupId: id);
});
