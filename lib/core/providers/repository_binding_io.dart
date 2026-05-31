import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/offline_first_animal_repository.dart';
import '../../data/repositories/offline_first_group_repository.dart';
import '../../data/repositories/offline_first_task_repository.dart';
import '../../data/repositories/repositories.dart';
import '../persistence/database_provider.dart';

AnimalRepository wrapAnimalRepository(
  Ref ref,
  AnimalRepository inner,
  String farmId,
) {
  return OfflineFirstAnimalRepository(
    inner: inner,
    cache: ref.watch(localCacheStoreProvider),
    farmId: farmId,
  );
}

GroupRepository wrapGroupRepository(
  Ref ref,
  GroupRepository inner,
  String farmId,
) {
  return OfflineFirstGroupRepository(
    inner: inner,
    cache: ref.watch(localCacheStoreProvider),
    farmId: farmId,
  );
}

TaskRepository wrapTaskRepository(
  Ref ref,
  TaskRepository inner,
  String farmId,
) {
  return OfflineFirstTaskRepository(
    inner: inner,
    cache: ref.watch(localCacheStoreProvider),
    farmId: farmId,
  );
}
