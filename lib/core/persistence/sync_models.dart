/// Platform-neutral sync queue row (Drift [SyncQueueData] on IO).
class QueuedSyncItem {
  const QueuedSyncItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
  });

  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
}

class SyncDrainResult {
  const SyncDrainResult({
    this.applied = 0,
    this.failed = 0,
    this.pending = 0,
    this.offline = false,
    this.skipped = false,
  });

  final int applied;
  final int failed;
  final int pending;
  final bool offline;
  final bool skipped;
}
