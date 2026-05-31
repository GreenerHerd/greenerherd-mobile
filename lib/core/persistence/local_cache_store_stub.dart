import '../../data/models/models.dart';

/// No-op cache for web (no Drift/sqlite).
class LocalCacheStore {
  LocalCacheStore();
  Future<void> saveFarm(Farm farm) async {}

  Future<Farm?> loadFarm(String farmId) async => null;

  Future<void> replaceAnimals(String farmId, List<Animal> animals) async {}

  Future<List<Animal>> loadAnimals(String farmId) async => [];

  Future<void> upsertAnimal(String farmId, Animal animal) async {}

  Future<void> replaceGroups(String farmId, List<AnimalGroup> groups) async {}

  Future<List<AnimalGroup>> loadGroups(String farmId) async => [];

  Future<void> replaceTasks(String farmId, List<TaskItem> tasks) async {}

  Future<List<TaskItem>> loadTasks(String farmId) async => [];

  Future<void> removeTask(String farmId, String taskId) async {}

  Future<void> enqueuePayload({
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
  }) async {}

  Future<List<StubSyncQueueItem>> pendingSyncItems() async => [];

  Future<void> removeSyncItem(int id) async {}
}

/// Placeholder type so [SyncService] signatures match on web.
class StubSyncQueueItem {
  const StubSyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.payloadJson,
  });

  final int id;
  final String entityType;
  final String operation;
  final String payloadJson;
}
