import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../data/services/animals_api_client.dart';
import '../../data/services/tasks_api_client.dart';
import '../providers/providers.dart';
import 'database_provider.dart';
import 'network_status.dart';
import 'sync_service.dart';

final networkStatusProvider = Provider<NetworkStatus>((ref) => NetworkStatus());

final syncServiceProvider = Provider<SyncService>((ref) {
  final store = ref.watch(mockDataStoreProvider);
  final session = store.session;
  final bearer = session?.accessToken != null &&
          session!.accessToken.isNotEmpty &&
          session.accessToken != 'mock-jwt-token'
      ? session.accessToken
      : AppConfig.inventoryDevBearerToken;
  return SyncService(
    cache: ref.watch(localCacheStoreProvider),
    network: ref.watch(networkStatusProvider),
    farmId: session?.farmId ?? 'farm-1',
    animalsApi: AppConfig.useAnimalsApi
        ? AnimalsApiClient(
            baseUrl: AppConfig.animalsApiBaseUrl,
            bearerToken: bearer,
          )
        : null,
    tasksApi: AppConfig.useTasksApi
        ? TasksApiClient(
            baseUrl: AppConfig.tasksApiBaseUrl,
            bearerToken: bearer,
          )
        : null,
  );
});

final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final status = ref.watch(networkStatusProvider);
  yield await status.isOnline;
  await for (final _ in Stream.periodic(const Duration(seconds: 8))) {
    yield await status.isOnline;
  }
});
