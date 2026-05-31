import 'package:connectivity_plus/connectivity_plus.dart';

/// Lightweight online check for offline-first sync.
class NetworkStatus {
  NetworkStatus({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
