import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_cache_store.dart';

/// Declared for API parity with IO; functional only on native (see [database_provider_io.dart]).
final appDatabaseProvider = Provider<Object?>(
  (ref) => throw UnsupportedError(
    'AppDatabase is only available on native platforms',
  ),
);

final localCacheStoreProvider = Provider<LocalCacheStore>((ref) {
  return LocalCacheStore();
});
