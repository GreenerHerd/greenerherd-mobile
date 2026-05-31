import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_farm_repository.dart';
import 'package:greenerherd_mobile/data/services/farms_remote_gateway.dart';
import 'package:greenerherd_mobile/data/services/people_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakeFarmsGateway implements FarmsRemoteGateway {
  FakeFarmsGateway({this.farm, this.throwOnGet = false});

  Map<String, dynamic>? farm;
  bool throwOnGet;

  @override
  Future<Map<String, dynamic>?> getFarm(String farmId) async {
    if (throwOnGet) throw Exception('network down');
    return farm;
  }

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> createFarm(
    Map<String, dynamic> body,
  ) async =>
      (data: farm ?? {}, meta: null);

  @override
  Future<Map<String, dynamic>> addSpecies(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      body;

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

class FakePeopleGateway implements PeopleRemoteGateway {
  FakePeopleGateway({this.members = const [], this.throwOnList = false});

  List<Map<String, dynamic>> members;
  bool throwOnList;

  @override
  Future<List<Map<String, dynamic>>> listMembers(String farmId) async {
    if (throwOnList) throw Exception('network down');
    return members;
  }

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> inviteUser(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      (
        data: Map<String, dynamic>.from(
          members.isNotEmpty ? members.first : <String, dynamic>{},
        ),
        meta: null,
      );
}

void main() {
  initBddTests();

  group('Feature: Farms API integration', () {
    late MockDataStore store;

    setUp(() {
      store = BddHarness().store;
    });

    bddAsyncDomainScenario(
      'Hybrid repository maps API farm profile',
      tags: ['positive'],
      body: () async {
        final repo = HybridFarmRepository(
          offlineStore: store,
          farmId: 'farm-1',
          farmsGateway: FakeFarmsGateway(
            farm: {
              'id': 'farm-1',
              'name': 'Al-Falah Farm',
              'country': 'SA',
              'preferred_currency': 'SAR',
              'housing_type': 'INDOOR_FANS',
            },
          ),
          peopleGateway: FakePeopleGateway(
            members: [
              {
                'farm_user': {'farm_role': 'OWNER', 'user_id': 'u1'},
                'user': {'id': 'u1', 'name': 'Yusuf Al-Harbi'},
              },
            ],
          ),
        );
        final farm = await repo.getCurrentFarm();
        expect(farm.name, 'Al-Falah Farm');
        expect(farm.ownerName, 'Yusuf Al-Harbi');
      },
    );

    bddAsyncDomainScenario(
      'API failure falls back to mock farm',
      tags: ['positive'],
      body: () async {
        final repo = HybridFarmRepository(
          offlineStore: store,
          farmId: 'farm-1',
          farmsGateway: FakeFarmsGateway(throwOnGet: true),
        );
        final farm = await repo.getCurrentFarm();
        expect(farm.name, store.farm.name);
      },
    );
  });
}
