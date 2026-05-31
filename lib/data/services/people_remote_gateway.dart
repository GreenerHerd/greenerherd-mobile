/// Remote port for `gh-api-people`.
abstract class PeopleRemoteGateway {
  Future<List<Map<String, dynamic>>> listMembers(String farmId);

  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> inviteUser(
    String farmId,
    Map<String, dynamic> body,
  );
}
