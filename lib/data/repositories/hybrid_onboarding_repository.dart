import '../../core/config/app_config.dart';
import 'hybrid_auth_repository.dart';
import '../mock/mock_data_store.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../services/auth_mapper.dart';
import '../services/farm_mapper.dart';
import '../services/farms_api_client.dart';
import '../services/farms_remote_gateway.dart';
import '../services/onboarding_mapper.dart';
import 'repositories.dart';

/// Farm create, species, and onboarding completion via `gh-api-farms`.
class HybridOnboardingRepository implements OnboardingRepository {
  HybridOnboardingRepository({
    required MockDataStore store,
    FarmsRemoteGateway? farmsGateway,
  })  : _store = store,
        _farms = farmsGateway ??
            FarmsApiClient(
              baseUrl: AppConfig.farmsApiBaseUrl,
              bearerToken: HybridAuthRepository.bearerFromStore(store),
            );

  final MockDataStore _store;
  final FarmsRemoteGateway _farms;

  void _syncBearer() {
    if (_farms is FarmsApiClient) {
      _farms.updateBearer(HybridAuthRepository.bearerFromStore(_store));
    }
  }

  @override
  Future<AuthSession> createFarmProfile({
    required String name,
    required String currency,
    String country = 'SA',
    HousingType housing = HousingType.indoorFans,
  }) async {
    if (!AppConfig.useFarmsApi) {
      return _store.session!;
    }
    _syncBearer();
    final result = await _farms.createFarm({
      'name': name,
      'country': country,
      'housing_type': OnboardingMapper.housingWire(housing),
      'preferred_currency': currency,
      'preferred_lang': 'EN',
    });
    final farm = FarmMapper.fromWire(result.data);
    final token = result.meta?['access_token'] as String?;
    final base = _store.session;
    if (base == null) {
      throw StateError('No session before createFarm');
    }
    final session = AuthMapper.sessionWithFarm(
      base: base,
      farmId: farm.id,
      accessToken: token ?? base.accessToken,
    );
    _store.session = session;
    _store.onboardingComplete = false;
    _syncBearer();
    return session;
  }

  @override
  Future<void> addSpecies({
    required Species species,
    required SpeciesPurpose purpose,
  }) async {
    if (!AppConfig.useFarmsApi) return;
    _syncBearer();
    final farmId = _store.session?.farmId;
    if (farmId == null) return;
    await _farms.addSpecies(
      farmId,
      {
        'species': OnboardingMapper.speciesWire(species),
        'purpose': OnboardingMapper.purposeWire(purpose),
      },
    );
  }

  @override
  Future<void> completeOnboarding({bool skipAnimals = false}) async {
    if (AppConfig.useFarmsApi) {
      _syncBearer();
      final farmId = _store.session?.farmId;
      if (farmId == null) return;
      await _farms.completeOnboarding(farmId, skipAnimals: skipAnimals);
      _store.onboardingComplete = true;
      _store.forceOnboarding = false;
      return;
    }
    _store.onboardingComplete = true;
    _store.forceOnboarding = false;
  }

  @override
  Future<bool> fetchOnboardingComplete() async {
    if (!AppConfig.useFarmsApi) return _store.onboardingComplete;
    _syncBearer();
    final farmId = _store.session?.farmId;
    if (farmId == null) return false;
    try {
      final status = await _farms.getOnboardingStatus(farmId);
      final done = status['onboarding_completed'] == true;
      _store.onboardingComplete = done;
      return done;
    } catch (_) {
      return _store.onboardingComplete;
    }
  }
}
