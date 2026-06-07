import '../../core/config/app_config.dart';
import '../mock/mock_data_store.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../services/auth_api_client.dart';
import '../services/auth_mapper.dart';
import '../services/auth_remote_gateway.dart';
import '../services/farms_api_client.dart';
import '../services/farms_remote_gateway.dart';
import 'repositories.dart';

/// Login via `gh-api-auth`; onboarding status via `gh-api-farms`.
class HybridAuthRepository implements AuthRepository {
  HybridAuthRepository({
    required MockDataStore store,
    AuthRemoteGateway? authGateway,
    FarmsRemoteGateway? farmsGateway,
  })  : _store = store,
        _auth = authGateway ??
            AuthApiClient(baseUrl: AppConfig.authApiBaseUrl),
        _farms = farmsGateway ??
            FarmsApiClient(
              baseUrl: AppConfig.farmsApiBaseUrl,
              bearerToken: bearerFromStore(store),
            );

  final MockDataStore _store;
  final AuthRemoteGateway _auth;
  final FarmsRemoteGateway _farms;

  @override
  AuthProvider? linkedProvider;

  static String bearerFromStore(MockDataStore store) {
    final token = store.session?.accessToken;
    if (token != null && token.isNotEmpty && token != 'mock-jwt-token') {
      return token;
    }
    return AppConfig.inventoryDevBearerToken;
  }

  void _syncFarmsBearer() {
    if (_farms is FarmsApiClient) {
      _farms.updateBearer(bearerFromStore(_store));
    }
  }

  @override
  Future<AuthSession?> currentSession() async => _store.session;

  @override
  Future<AuthSession> signInMock({String email = 'owner@alfalah.test'}) async {
    if (AppConfig.useAuthApi) {
      return _loginEmail(email);
    }
    return _mockSignIn();
  }

  @override
  Future<AuthSession> signInWithProvider(AuthProvider provider) async {
    linkedProvider = provider;
    _store.linkedAuthProvider = provider;
    if (AppConfig.useAuthApi) {
      return _loginEmail(_emailForProvider(provider));
    }
    return _mockSignIn();
  }

  @override
  Future<void> signOut() async {
    _store.session = null;
    linkedProvider = null;
    _store.linkedAuthProvider = null;
    _store.forceOnboarding = false;
  }

  @override
  bool get isOnboardingComplete =>
      !_store.forceOnboarding && _store.onboardingComplete;

  @override
  Future<void> setOnboardingComplete(bool value) async {
    _store.onboardingComplete = value;
    if (value) _store.forceOnboarding = false;
  }

  /// Refreshes [_store.onboardingComplete] from farms API for the active farm.
  Future<void> refreshOnboardingStatus() async {
    if (!AppConfig.useFarmsApi) return;
    final farmId = _store.session?.farmId;
    if (farmId == null) return;
    _syncFarmsBearer();
    try {
      final status = await _farms.getOnboardingStatus(farmId);
      _store.onboardingComplete = status['onboarding_completed'] == true;
    } catch (_) {}
  }

  Future<AuthSession> _loginEmail(String email) async {
    try {
      final data = await _auth.login(email: email);
      final session = AuthMapper.sessionFromLogin(data);
      _store.session = session;
      _syncFarmsBearer();
      if (AppConfig.useFarmsApi) {
        await refreshOnboardingStatus();
      } else {
        _store.onboardingComplete = true;
      }
      return session;
    } catch (_) {
      if (AppConfig.useMockData) {
        return _mockSignIn();
      }
      rethrow;
    }
  }

  Future<AuthSession> _mockSignIn() async {
    final session = AuthSession(
      userId: 'u1',
      farmId: _store.farm.id,
      role: UserRole.owner,
      displayName: 'Yusuf Al-Harbi',
      accessToken: 'mock-jwt-token',
    );
    _store.session = session;
    return session;
  }

  static String _emailForProvider(AuthProvider provider) => switch (provider) {
        AuthProvider.google => 'owner@alfalah.test',
        AuthProvider.apple => 'owner@alfalah.test',
        AuthProvider.facebook => 'owner@alfalah.test',
      };
}
