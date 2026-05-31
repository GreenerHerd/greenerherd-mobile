import 'local_cache_store.dart';
import 'network_status.dart';
import 'sync_models.dart';

/// Web stub: offline sync queue is not available.
class SyncService {
  SyncService({
    LocalCacheStore? cache,
    NetworkStatus? network,
    Object? animalsApi,
    Object? tasksApi,
    String? farmId,
  });

  Future<SyncDrainResult> drainQueue() async {
    return const SyncDrainResult(skipped: true);
  }
}
