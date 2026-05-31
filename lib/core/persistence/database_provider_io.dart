import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'local_cache_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localCacheStoreProvider = Provider<LocalCacheStore>((ref) {
  return LocalCacheStore(ref.watch(appDatabaseProvider));
});
