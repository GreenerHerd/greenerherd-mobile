
import '../../core/config/app_config.dart';
import '../../core/persistence/entity_json_codec.dart';
import '../../core/persistence/local_cache_store.dart';
import '../../core/persistence/network_status.dart';
import '../models/models.dart';
import 'repositories.dart';

class OfflineFirstTaskRepository implements TaskRepository {
  OfflineFirstTaskRepository({
    required TaskRepository inner,
    required LocalCacheStore cache,
    required String farmId,
    NetworkStatus? network,
  })  : _inner = inner,
        _cache = cache,
        _farmId = farmId,
        _network = network ?? NetworkStatus();

  final TaskRepository _inner;
  final LocalCacheStore _cache;
  final String _farmId;
  final NetworkStatus _network;

  @override
  Future<List<TaskItem>> listTasks({String? dueBucket}) async {
    if (await _network.isOnline) {
      try {
        final fresh = await _inner.listTasks(dueBucket: dueBucket);
        await _cache.replaceTasks(_farmId, fresh);
        return fresh;
      } catch (_) {
        return _filter(await _cache.loadTasks(_farmId), dueBucket);
      }
    }
    return _filter(await _cache.loadTasks(_farmId), dueBucket);
  }

  @override
  Future<void> addTask(TaskItem task) async {
    await _inner.addTask(task);
    final all = [...await _cache.loadTasks(_farmId), task];
    await _cache.replaceTasks(_farmId, all);
    if (AppConfig.useOfflineSync) {
      await _cache.enqueuePayload(
        entityType: 'task',
        entityId: task.id,
        operation: 'create',
        payloadJson: EntityJsonCodec.encodeTask(task),
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _inner.deleteTask(id);
    await _cache.removeTask(_farmId, id);
    if (AppConfig.useOfflineSync) {
      await _cache.enqueuePayload(
        entityType: 'task',
        entityId: id,
        operation: 'dismiss',
        payloadJson: '{}',
      );
    }
  }

  @override
  Future<void> completeTask(String id) async {
    if (!await _network.isOnline) {
      await _cache.removeTask(_farmId, id);
      await _enqueueTask('complete', id);
      return;
    }
    try {
      await _inner.completeTask(id);
      await _cache.removeTask(_farmId, id);
    } catch (_) {
      await _cache.removeTask(_farmId, id);
      await _enqueueTask('complete', id);
    }
  }

  @override
  Future<void> dismissTask(String id) async {
    if (!await _network.isOnline) {
      await _cache.removeTask(_farmId, id);
      await _enqueueTask('dismiss', id);
      return;
    }
    try {
      await _inner.dismissTask(id);
      await _cache.removeTask(_farmId, id);
    } catch (_) {
      await _cache.removeTask(_farmId, id);
      await _enqueueTask('dismiss', id);
    }
  }

  Future<void> _enqueueTask(String operation, String id) async {
    if (!AppConfig.useOfflineSync) return;
    await _cache.enqueuePayload(
      entityType: 'task',
      entityId: id,
      operation: operation,
      payloadJson: '{}',
    );
  }

  List<TaskItem> _filter(List<TaskItem> list, String? dueBucket) {
    if (dueBucket == null) return list;
    return list.where((t) => t.dueBucket == dueBucket).toList();
  }
}
