import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/invite_models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_people_repository.dart';
import 'package:greenerherd_mobile/data/services/people_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakePeopleGateway implements PeopleRemoteGateway {
  FakePeopleGateway({this.members = const []});

  List<Map<String, dynamic>> members;
  Map<String, dynamic>? lastInviteBody;

  @override
  Future<List<Map<String, dynamic>>> listMembers(String farmId) async =>
      members;

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> inviteUser(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    lastInviteBody = body;
    return (
      data: {
        'farm_user': {'farm_role': body['farm_role'], 'user_id': 'u-new'},
        'user': {
          'id': 'u-new',
          'name': body['name'],
          'email': body['email'] ?? 'x@invite.greenerherd.local',
        },
      },
      meta: {
        'invite_link': 'https://greenerherd.app/join?invite=token123',
        'invite_message': 'Join us',
        'email_sent': true,
        'whatsapp_url': 'https://wa.me/966501234567?text=hi',
      },
    );
  }
}

void main() {
  initBddTests();

  group('Feature: People invite with app link', () {
    bddAsyncDomainScenario(
      'Hybrid repository sends email invite with delivery channel',
      tags: ['positive'],
      body: () async {
        final store = BddHarness().store;
        final gateway = FakePeopleGateway();
        final repo = HybridPeopleRepository(
          offlineStore: store,
          farmId: 'farm-1',
          gateway: gateway,
        );
        final result = await repo.inviteUser(
          const InviteUserRequest(
            name: 'Ahmad',
            role: UserRole.farmHand,
            channel: InviteDeliveryChannel.email,
            email: 'ahmad@alfalah.test',
          ),
        );
        expect(gateway.lastInviteBody?['delivery_channel'], 'EMAIL');
        expect(result.inviteLink, contains('invite='));
      },
    );
  });
}
