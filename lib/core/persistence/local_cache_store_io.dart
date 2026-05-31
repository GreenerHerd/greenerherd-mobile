import 'package:drift/drift.dart';

import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'app_database.dart' hide Farm;
import 'entity_json_codec.dart';

/// Read/write Drift cache for core harness entities.
class LocalCacheStore {
  LocalCacheStore(this._db);

  final AppDatabase _db;

  Future<void> saveFarm(Farm farm) async {
    await _db.into(_db.farms).insertOnConflictUpdate(
          FarmsCompanion.insert(
            id: farm.id,
            name: farm.name,
            currency: farm.currency,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<Farm?> loadFarm(String farmId) async {
    final row = await (_db.select(_db.farms)..where((t) => t.id.equals(farmId)))
        .getSingleOrNull();
    if (row == null) return null;
    return Farm(
      id: row.id,
      name: row.name,
      location: '',
      currency: row.currency,
      housing: HousingType.indoorFans,
      ownerName: '',
    );
  }

  Future<void> replaceAnimals(String farmId, List<Animal> animals) async {
    await _db.transaction(() async {
      await (_db.delete(_db.animalsLocal)
            ..where((t) => t.farmId.equals(farmId)))
          .go();
      final now = DateTime.now();
      for (final a in animals) {
        await _db.into(_db.animalsLocal).insert(
              AnimalsLocalCompanion.insert(
                id: a.id,
                farmId: farmId,
                payloadJson: EntityJsonCodec.encodeAnimal(a),
                updatedAt: now,
              ),
            );
      }
    });
  }

  Future<List<Animal>> loadAnimals(String farmId) async {
    final rows = await (_db.select(_db.animalsLocal)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return rows.map((r) => EntityJsonCodec.decodeAnimal(r.payloadJson)).toList();
  }

  Future<void> upsertAnimal(String farmId, Animal animal) async {
    await _db.into(_db.animalsLocal).insertOnConflictUpdate(
          AnimalsLocalCompanion.insert(
            id: animal.id,
            farmId: farmId,
            payloadJson: EntityJsonCodec.encodeAnimal(animal),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> replaceGroups(String farmId, List<AnimalGroup> groups) async {
    await _db.transaction(() async {
      await (_db.delete(_db.groupsLocal)..where((t) => t.farmId.equals(farmId)))
          .go();
      final now = DateTime.now();
      for (final g in groups) {
        await _db.into(_db.groupsLocal).insert(
              GroupsLocalCompanion.insert(
                id: g.id,
                farmId: farmId,
                payloadJson: EntityJsonCodec.encodeGroup(g),
                updatedAt: now,
              ),
            );
      }
    });
  }

  Future<List<AnimalGroup>> loadGroups(String farmId) async {
    final rows = await (_db.select(_db.groupsLocal)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return rows.map((r) => EntityJsonCodec.decodeGroup(r.payloadJson)).toList();
  }

  Future<void> replaceTasks(String farmId, List<TaskItem> tasks) async {
    await _db.transaction(() async {
      await (_db.delete(_db.tasksLocal)..where((t) => t.farmId.equals(farmId)))
          .go();
      final now = DateTime.now();
      for (final t in tasks) {
        await _db.into(_db.tasksLocal).insert(
              TasksLocalCompanion.insert(
                id: t.id,
                farmId: farmId,
                payloadJson: EntityJsonCodec.encodeTask(t),
                updatedAt: now,
              ),
            );
      }
    });
  }

  Future<List<TaskItem>> loadTasks(String farmId) async {
    final rows = await (_db.select(_db.tasksLocal)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    return rows.map((r) => EntityJsonCodec.decodeTask(r.payloadJson)).toList();
  }

  Future<void> removeTask(String farmId, String taskId) async {
    await (_db.delete(_db.tasksLocal)
          ..where((t) => t.farmId.equals(farmId) & t.id.equals(taskId)))
        .go();
  }

  Future<void> enqueuePayload({
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
  }) async {
    await _db.enqueueSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payloadJson: payloadJson,
    );
  }

  Future<List<SyncQueueData>> pendingSyncItems() =>
      _db.select(_db.syncQueue).get();

  Future<void> removeSyncItem(int id) async {
    await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(id))).go();
  }
}
