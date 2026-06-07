import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_animal_repository.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_group_repository.dart';
import 'package:greenerherd_mobile/data/services/animals_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakeAnimalsGateway implements AnimalsRemoteGateway {
  FakeAnimalsGateway({
    this.animals = const [],
    this.groups = const [],
    this.throwOnList = false,
  });

  List<Map<String, dynamic>> animals;
  List<Map<String, dynamic>> groups;
  bool throwOnList;

  @override
  Future<List<Map<String, dynamic>>> listAnimals(
    String farmId, {
    String? species,
    String? groupId,
    String? tag,
  }) async {
    if (throwOnList) {
      throw Exception('network down');
    }
    return animals;
  }

  @override
  Future<Map<String, dynamic>?> getAnimal(String farmId, String animalId) async {
    try {
      return animals.firstWhere((a) => a['id'] == animalId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> createAnimal(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final id = 'new-${animals.length + 1}';
    final row = {...body, 'id': id, 'status': 'ACTIVE', 'cull_flagged': false};
    animals = [...animals, row];
    return row;
  }

  @override
  Future<List<Map<String, dynamic>>> listGroups(String farmId) async {
    if (throwOnList) throw Exception('network down');
    return groups;
  }

  @override
  Future<Map<String, dynamic>> flagCull(String farmId, String animalId) async {
    final i = animals.indexWhere((a) => a['id'] == animalId);
    final row = Map<String, dynamic>.from(animals[i]);
    row['cull_flagged'] = true;
    row['tags'] = [...(row['tags'] as List? ?? []), 'CULL'];
    animals[i] = row;
    return row;
  }

  @override
  Future<Map<String, dynamic>> markSold(String farmId, String animalId) async {
    final i = animals.indexWhere((a) => a['id'] == animalId);
    final row = Map<String, dynamic>.from(animals[i]);
    row['status'] = 'SOLD';
    animals[i] = row;
    return row;
  }

  @override
  Future<({Map<String, dynamic> group, List<Map<String, dynamic>> animals})>
      createGroupBulk(String farmId, Map<String, dynamic> body) async {
    const groupId = 'g-bulk';
    final group = {
      'id': groupId,
      'name': body['name'],
      'species': body['species'],
      'purpose': body['purpose'],
    };
    groups = [...groups, group];
    final count = body['count'] as int? ?? 1;
    final created = <Map<String, dynamic>>[];
    for (var n = 0; n < count; n++) {
      final row = {
        'id': 'bulk-$n',
        'species': body['species'],
        'sex': body['sex'],
        'breed': body['breed'],
        'ear_tag': 'B$n',
        'group_id': groupId,
        'status': 'ACTIVE',
        'cull_flagged': false,
        'tags': <String>[],
      };
      animals = [...animals, row];
      created.add(row);
    }
    return (group: group, animals: created);
  }
}

void main() {
  initBddTests();

  group('Feature: Animals API integration', () {
    late MockDataStore store;
    late FakeAnimalsGateway gateway;

    setUp(() {
      store = BddHarness().store;
      gateway = FakeAnimalsGateway();
    });

    bddAsyncDomainScenario(
      'Hybrid repository maps API animals',
      tags: ['positive'],
      body: () async {
        gateway.animals = [
          {
            'id': 'a1',
            'species': 'CATTLE',
            'sex': 'FEMALE',
            'breed': 'Holstein',
            'ear_tag': '0421',
            'name': 'Bessie',
            'group_id': 'g1',
            'current_weight_kg': 580,
            'age_range': '1_2Y',
            'status': 'ACTIVE',
            'cull_flagged': false,
            'tags': ['LACTATING'],
          },
        ];
        final repo = HybridAnimalRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        final animals = await repo.listAnimals();
        final bessie = animals.firstWhere((a) => a.tag == '0421');
        expect(bessie.name, 'Bessie');
        expect(bessie.breed, 'Holstein');
      },
    );

    bddAsyncDomainScenario(
      'Hybrid repository maps API groups with head counts',
      tags: ['positive'],
      body: () async {
        gateway.groups = [
          {
            'id': 'g1',
            'name': 'Milking A',
            'species': 'CATTLE',
            'purpose': 'MILK',
            'notes': 'Demo',
          },
        ];
        gateway.animals = List.generate(
          4,
          (i) => {
            'id': 'a$i',
            'species': 'CATTLE',
            'sex': 'FEMALE',
            'breed': 'Holstein',
            'ear_tag': '04$i',
            'name': 'Cow $i',
            'group_id': 'g1',
            'status': 'ACTIVE',
            'cull_flagged': false,
            'tags': <String>[],
          },
        );
        final repo = HybridGroupRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        final groups = await repo.listGroups();
        final milking = groups.firstWhere((g) => g.name == 'Milking A');
        expect(milking.headCount, 4);
      },
    );

    bddAsyncDomainScenario(
      'API failure uses offline animals when cache populated',
      tags: ['positive'],
      body: () async {
        store.addAnimal(
          const Animal(
            id: 'offline-1',
            tag: 'OFF-1',
            name: 'Offline',
            species: Species.cattle,
            sex: 'Female',
            breed: 'Holstein',
            weightKg: 400,
            ageLabel: '2y',
            groupId: 'g-off',
          ),
        );
        gateway.throwOnList = true;
        final repo = HybridAnimalRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        final animals = await repo.listAnimals();
        expect(animals.any((a) => a.tag == 'OFF-1'), isTrue);
      },
    );
  });
}
