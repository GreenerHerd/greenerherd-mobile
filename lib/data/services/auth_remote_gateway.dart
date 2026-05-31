/// Remote port for `gh-api-auth`.
abstract class AuthRemoteGateway {
  Future<Map<String, dynamic>> login({required String email});

  Future<Map<String, dynamic>> refresh(String refreshToken);
}
