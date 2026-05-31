/// Remote port for `gh-api-animals`.
abstract class AnimalsRemoteGateway {
  Future<List<Map<String, dynamic>>> listAnimals(
    String farmId, {
    String? species,
    String? groupId,
    String? tag,
  });

  Future<Map<String, dynamic>?> getAnimal(String farmId, String animalId);

  Future<Map<String, dynamic>> createAnimal(
    String farmId,
    Map<String, dynamic> body,
  );

  Future<List<Map<String, dynamic>>> listGroups(String farmId);

  Future<Map<String, dynamic>> flagCull(String farmId, String animalId);

  Future<Map<String, dynamic>> markSold(String farmId, String animalId);

  Future<({Map<String, dynamic> group, List<Map<String, dynamic>> animals})>
      createGroupBulk(String farmId, Map<String, dynamic> body);
}
