import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_auth_repository.dart';
import 'package:greenerherd_mobile/data/services/auth_remote_gateway.dart';
import 'package:greenerherd_mobile/data/services/farms_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakeAuthGateway implements AuthRemoteGateway {
  @override
  Future<Map<String, dynamic>> login({required String email}) async => {
        'accessToken':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLTEiXSwicm9sZSI6Ik9XTkVSIiwiaWF0IjoxNzc5MTI1NzQzLCJleHAiOjE4MTA2NjE3NDN9.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo',
        'user': {'id': 'u1', 'name': 'Yusuf', 'role': 'OWNER'},
      };

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async =>
      login(email: 'x');
}

class FakeFarmsOnboardingGateway implements FarmsRemoteGateway {
  @override
  Future<Map<String, dynamic>?> getFarm(String farmId) async => null;

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> createFarm(
    Map<String, dynamic> body,
  ) async =>
      (data: {'id': 'farm-1'}, meta: null);

  @override
  Future<Map<String, dynamic>> addSpecies(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      {};

  @override
  Future<Map<String, dynamic>> getOnboardingStatus(String farmId) async => {
        'onboarding_completed': true,
      };

  @override
  Future<Map<String, dynamic>> completeOnboarding(
    String farmId, {
    bool skipAnimals = false,
  }) async =>
      {};
}

void main() {
  initBddTests();

  group('Feature: Auth API integration', () {
    late MockDataStore store;

    setUp(() {
      store = MockDataStore(seedDemoHerd: true);
      store.session = null;
    });

    bddAsyncDomainScenario(
      'Hybrid auth maps login token to session',
      tags: ['positive'],
      body: () async {
        final repo = HybridAuthRepository(
          store: store,
          authGateway: FakeAuthGateway(),
          farmsGateway: FakeFarmsOnboardingGateway(),
        );
        final session = await repo.signInMock(email: 'owner@alfalah.test');
        expect(session.userId, 'u1');
        expect(session.farmId, 'farm-1');
        expect(session.accessToken, isNotEmpty);
        expect(store.session, isNotNull);
        expect(store.onboardingComplete, isTrue);
      },
    );
  });
}
