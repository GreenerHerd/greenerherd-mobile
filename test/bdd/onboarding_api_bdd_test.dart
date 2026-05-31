import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_onboarding_repository.dart';
import 'package:greenerherd_mobile/data/services/farms_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakeOnboardingFarmsGateway implements FarmsRemoteGateway {
  FakeOnboardingFarmsGateway();

  String? lastSpeciesBody;
  bool completeCalled = false;

  @override
  Future<Map<String, dynamic>?> getFarm(String farmId) async => null;

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> createFarm(
    Map<String, dynamic> body,
  ) async =>
      (
        data: {
          'id': 'farm-new',
          'name': body['name'],
          'country': body['country'],
          'preferred_currency': body['preferred_currency'],
          'housing_type': body['housing_type'],
        },
        meta: {
          'access_token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLW5ldyJdLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NzkxMjU3NDMsImV4cCI6MTgxMDY2MTc0M30.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo',
        },
      );

  @override
  Future<Map<String, dynamic>> addSpecies(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    lastSpeciesBody = body.toString();
    return body;
  }

  @override
  Future<Map<String, dynamic>> getOnboardingStatus(String farmId) async => {
        'onboarding_completed': false,
        'step_2_species': true,
      };

  @override
  Future<Map<String, dynamic>> completeOnboarding(
    String farmId, {
    bool skipAnimals = false,
  }) async {
    completeCalled = true;
    return {'onboarding_completed': true};
  }
}

void main() {
  initBddTests();

  group('Feature: Onboarding API integration', () {
    late MockDataStore store;
    late FakeOnboardingFarmsGateway gateway;

    setUp(() {
      store = MockDataStore(seedDemoHerd: true);
      store.session = const AuthSession(
        userId: 'u1',
        farmId: 'farm-1',
        role: UserRole.owner,
        displayName: 'Owner',
        accessToken: 'token-a',
      );
      store.onboardingComplete = false;
      gateway = FakeOnboardingFarmsGateway();
    });

    bddAsyncDomainScenario(
      'Create farm updates session farm and token',
      tags: ['positive'],
      body: () async {
        final repo = HybridOnboardingRepository(
          store: store,
          farmsGateway: gateway,
        );
        final session = await repo.createFarmProfile(
          name: 'New Farm',
          currency: 'SAR',
        );
        expect(session.farmId, 'farm-new');
        expect(store.session?.farmId, 'farm-new');
      },
    );

    bddAsyncDomainScenario(
      'Add species and complete onboarding',
      tags: ['positive'],
      body: () async {
        final repo = HybridOnboardingRepository(
          store: store,
          farmsGateway: gateway,
        );
        await repo.addSpecies(
          species: Species.cattle,
          purpose: SpeciesPurpose.milk,
        );
        expect(gateway.lastSpeciesBody, contains('CATTLE'));
        await repo.completeOnboarding(skipAnimals: true);
        expect(gateway.completeCalled, isTrue);
        expect(store.onboardingComplete, isTrue);
      },
    );
  });
}
