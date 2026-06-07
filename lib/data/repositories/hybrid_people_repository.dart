import '../../core/config/app_config.dart';
import '../mock/mock_data_store.dart';
import '../models/invite_models.dart';
import '../models/models.dart';
import '../services/people_api_client.dart';
import '../services/people_mapper.dart';
import '../services/people_remote_gateway.dart';
import 'repositories.dart';

/// Loads farm team from `gh-api-people` with mock fallback.
class HybridPeopleRepository implements PeopleRepository {
  HybridPeopleRepository({
    required MockDataStore offlineStore,
    PeopleRemoteGateway? gateway,
    String? farmId,
    String? bearerToken,
  })  : _offline = offlineStore,
        _farmId = farmId ?? 'farm-1',
        _api = gateway ??
            PeopleApiClient(
              baseUrl: AppConfig.peopleApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            );

  final MockDataStore _offline;
  final String _farmId;
  final PeopleRemoteGateway _api;

  @override
  Future<List<FarmUser>> listPeople() async {
    if (AppConfig.usePeopleApi) {
      try {
        final rows = await _api.listMembers(_farmId);
        if (rows.isNotEmpty) {
          return PeopleMapper.fromMemberList(rows);
        }
      } catch (_) {}
    }
    return _offline.users;
  }

  @override
  Future<InviteUserResult> inviteUser(InviteUserRequest request) async {
    if (AppConfig.usePeopleApi) {
      try {
        final body = <String, dynamic>{
          'name': request.name,
          'farm_role': PeopleMapper.roleToWire(request.role),
          'delivery_channel': PeopleMapper.channelToWire(request.channel),
          if (request.email != null && request.email!.isNotEmpty)
            'email': request.email,
          if (request.phone != null && request.phone!.isNotEmpty)
            'phone': request.phone,
          if (request.farmName != null) 'farm_name': request.farmName,
        };
        final response = await _api.inviteUser(_farmId, body);
        final result = PeopleMapper.inviteResultFromResponse(
          response.data,
          response.meta,
        );
        if (!_offline.users.any((u) => u.id == result.member.id)) {
          _offline.users.add(result.member);
        }
        return result;
      } catch (_) {
        // fall through to mock
      }
    }
    return _mockInvite(request);
  }

  InviteUserResult _mockInvite(InviteUserRequest request) {
    final id = 'u-${_offline.users.length + 1}';
    final member = FarmUser(
      id: id,
      name: request.name,
      role: request.role,
      initials: PeopleMapper.fromMemberWire({
        'user': {'id': id, 'name': request.name},
        'farm_user': {'farm_role': PeopleMapper.roleToWire(request.role)},
      }).initials,
    );
    _offline.users.add(member);
    final link =
        '${AppConfig.inviteAppLinkBaseUrl}?invite=mock-$id&farm=$_farmId';
    final farmName = request.farmName ?? _offline.farm.name;
    final message =
        'Hi ${request.name},\n\nYou have been invited to join $farmName on GreenerHerd.\n\n$link';
    return InviteUserResult(
      member: member,
      inviteLink: link,
      message: message,
      emailSent: request.channel != InviteDeliveryChannel.whatsapp,
      whatsappUrl: request.phone != null
          ? 'https://wa.me/${request.phone!.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent(message)}'
          : null,
    );
  }
}
