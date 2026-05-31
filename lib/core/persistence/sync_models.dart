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
