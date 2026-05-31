import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_people_repository.dart';
import 'package:greenerherd_mobile/data/services/people_remote_gateway.dart';

import 'support/bdd_harness.dart';

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
        data: members.isNotEmpty ? members.first : <String, dynamic>{},
        meta: <String, dynamic>{},
      );
}

void main() {
  initBddTests();

  group('Feature: People API integration', () {
    late MockDataStore store;

    setUp(() {
      store = BddHarness().store;
    });

    bddAsyncDomainScenario(
      'Hybrid repository maps API members',
      tags: ['positive'],
      body: () async {
        final repo = HybridPeopleRepository(
          offlineStore: store,
          farmId: 'farm-1',
          gateway: FakePeopleGateway(
            members: [
              {
                'farm_user': {'farm_role': 'OWNER', 'user_id': 'u1'},
                'user': {'id': 'u1', 'name': 'Yusuf Al-Harbi'},
              },
              {
                'farm_user': {'farm_role': 'MANAGER', 'user_id': 'u2'},
                'user': {'id': 'u2', 'name': 'Khaled Saleh'},
              },
            ],
          ),
        );
        final people = await repo.listPeople();
        expect(
          people.any((u) => u.role == UserRole.owner && u.name.contains('Yusuf')),
          isTrue,
        );
        expect(
          people.any((u) => u.role == UserRole.manager),
          isTrue,
        );
      },
    );

    bddAsyncDomainScenario(
      'API failure falls back to mock team',
      tags: ['positive'],
      body: () async {
        final repo = HybridPeopleRepository(
          offlineStore: store,
          farmId: 'farm-1',
          gateway: FakePeopleGateway(throwOnList: true),
        );
        final people = await repo.listPeople();
        expect(people.length, store.users.length);
      },
    );
  });
}
