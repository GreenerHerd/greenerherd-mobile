import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../data/services/animals_api_client.dart';
import '../../data/services/tasks_api_client.dart';
import 'local_cache_store.dart';
import 'network_status.dart';
import 'sync_models.dart';

/// Drains [SyncQueue] when online (Phase 5).
class SyncService {
  SyncService({
    required LocalCacheStore cache,
    NetworkStatus? network,
    AnimalsApiClient? animalsApi,
    TasksApiClient? tasksApi,
    String? farmId,
  })  : _cache = cache,
        _network = network ?? NetworkStatus(),
        _animalsApi = animalsApi,
        _tasksApi = tasksApi,
        _farmId = farmId ?? 'farm-1';

  final LocalCacheStore _cache;
  final NetworkStatus _network;
  final AnimalsApiClient? _animalsApi;
  final TasksApiClient? _tasksApi;
  final String _farmId;

  Future<SyncDrainResult> drainQueue() async {
    if (!AppConfig.useOfflineSync) {
      return const SyncDrainResult(skipped: true);
    }
    if (!await _network.isOnline) {
      return const SyncDrainResult(offline: true);
    }

    var applied = 0;
    var failed = 0;
    final pending = await _cache.pendingSyncItems();
    for (final item in pending) {
      try {
        final ok = await _applyItem(item);
        if (ok) {
          await _cache.removeSyncItem(item.id);
          applied++;
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
    }
    return SyncDrainResult(
      applied: applied,
      failed: failed,
      pending: pending.length,
    );
  }

  Future<bool> _applyItem(QueuedSyncItem item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
    switch ('${item.entityType}.${item.operation}') {
      case 'animal.create':
        if (_animalsApi == null) return true;
        await _animalsApi.createAnimal(_farmId, payload);
        return true;
      case 'animal.update':
        return true;
      case 'task.complete':
        if (_tasksApi == null) return true;
        await _tasksApi.completeTask(item.entityId);
        return true;
      case 'task.dismiss':
        if (_tasksApi == null) return true;
        await _tasksApi.dismissTask(item.entityId);
        return true;
      case 'task.create':
        return true;
      default:
        return true;
    }
  }
}
