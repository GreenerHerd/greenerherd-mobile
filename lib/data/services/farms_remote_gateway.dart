/// Remote port for `gh-api-farms`.
abstract class FarmsRemoteGateway {
  Future<Map<String, dynamic>?> getFarm(String farmId);

  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> createFarm(
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> addSpecies(
    String farmId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> getOnboardingStatus(String farmId);

  Future<Map<String, dynamic>> completeOnboarding(
    String farmId, {
    bool skipAnimals = false,
  });
}
