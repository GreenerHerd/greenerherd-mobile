import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_animal_repository.dart';
import 'package:greenerherd_mobile/data/services/animals_remote_gateway.dart';

class LifecycleFakeGateway implements AnimalsRemoteGateway {
  LifecycleFakeGateway(this.animal);

  Map<String, dynamic> animal;

  @override
  Future<List<Map<String, dynamic>>> listAnimals(
    String farmId, {
    String? species,
    String? groupId,
    String? tag,
  }) async =>
      [animal];

  @override
  Future<Map<String, dynamic>?> getAnimal(String farmId, String animalId) async =>
      animal;

  @override
  Future<Map<String, dynamic>> createAnimal(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      animal;

  @override
  Future<List<Map<String, dynamic>>> listGroups(String farmId) async => [];

  @override
  Future<Map<String, dynamic>> flagCull(String farmId, String animalId) async {
    animal = {...animal, 'cull_flagged': true, 'tags': ['CULL']};
    return animal;
  }

  @override
  Future<Map<String, dynamic>> markSold(String farmId, String animalId) async {
    animal = {...animal, 'status': 'SOLD'};
    return animal;
  }

  @override
  Future<({Map<String, dynamic> group, List<Map<String, dynamic>> animals})>
      createGroupBulk(String farmId, Map<String, dynamic> body) async =>
          (
            group: <String, dynamic>{'id': 'g1'},
            animals: <Map<String, dynamic>>[],
          );
}

void main() {
  test('HybridAnimalRepository flagCull and markSold via API', () async {
    final store = MockDataStore(seedDemoHerd: true);
    final gateway = LifecycleFakeGateway({
      'id': 'a1',
      'species': 'CATTLE',
      'sex': 'FEMALE',
      'breed': 'Holstein',
      'ear_tag': '99',
      'status': 'ACTIVE',
      'cull_flagged': false,
      'tags': <String>[],
    });
    final repo = HybridAnimalRepository(
      offlineStore: store,
      gateway: gateway,
      farmId: 'farm-1',
    );
    final culled = await repo.flagCull('a1');
    expect(culled.tags, contains(AnimalTagType.cull));
    final sold = await repo.markSold('a1');
    expect(sold.status, AnimalStatus.sold);
  });
}
