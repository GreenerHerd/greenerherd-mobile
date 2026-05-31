import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_cache_store.dart';

final localCacheStoreProvider = Provider<LocalCacheStore>((ref) {
  return LocalCacheStore();
});
