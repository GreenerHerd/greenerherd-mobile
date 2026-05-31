import '../../core/config/app_config.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../mock/mock_data_store.dart';
import '../services/animal_mapper.dart';
import '../services/animals_api_client.dart';
import '../services/animals_remote_gateway.dart';
import 'repositories.dart';

/// Loads groups from `gh-api-animals` with mock fallback.
class HybridGroupRepository implements GroupRepository {
  HybridGroupRepository({
    required MockDataStore offlineStore,
    AnimalsRemoteGateway? gateway,
    String? farmId,
    String? bearerToken,
  })  : _offline = offlineStore,
        _farmId = farmId ?? 'farm-1',
        _api = gateway ??
            AnimalsApiClient(
              baseUrl: AppConfig.animalsApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            );

  final MockDataStore _offline;
  final String _farmId;
  final AnimalsRemoteGateway _api;

  @override
  Future<List<AnimalGroup>> listGroups({Species? species}) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final groupRows = await _api.listGroups(_farmId);
        final animalRows = await _api.listAnimals(_farmId);
        final counts = <String, int>{};
        for (final a in animalRows) {
          final gid = a['group_id'] as String?;
          if (gid != null) counts[gid] = (counts[gid] ?? 0) + 1;
        }
        var groups = groupRows
            .map(
              (g) => AnimalMapper.groupFromWire(
                g,
                headCount: counts[g['id'] as String] ?? 0,
              ),
            )
            .toList();
        if (species != null) {
          groups = groups.where((g) => g.species == species).toList();
        }
        _offline.replaceGroups(groups);
        return groups;
      } catch (e) {
        if (AppConfig.useAnimalsApi) {
          return _offline.groups;
        }
      }
    }
    var list = _offline.groups;
    if (species != null) {
      list = list.where((g) => g.species == species).toList();
    }
    return list;
  }

  @override
  Future<AnimalGroup?> getGroup(String id) async {
    final groups = await listGroups();
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AnimalGroup> createGroup(AnimalGroup group) async {
    _offline.addGroup(group);
    return group;
  }

  @override
  Future<({AnimalGroup group, List<Animal> animals})> createGroupBulk({
    required Species species,
    required String breed,
    required String sex,
    required String ageRangeWire,
    required int count,
    required String name,
    required GroupPurpose purpose,
    String? notes,
  }) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final result = await _api.createGroupBulk(_farmId, {
          'species': AnimalMapper.speciesWire(species),
          'breed': breed,
          'sex': sex.toLowerCase() == 'male' ? 'MALE' : 'FEMALE',
          'age_range': ageRangeWire,
          'count': count,
          'name': name,
          'purpose': AnimalMapper.groupPurposeWire(purpose),
          if (notes != null) 'notes': notes,
        });
        final group = AnimalMapper.groupFromWire(
          result.group,
          headCount: count,
        );
        final animals =
            result.animals.map(AnimalMapper.fromWire).toList();
        _offline.addGroup(group);
        for (final a in animals) {
          _offline.addAnimal(a);
        }
        return (group: group, animals: animals);
      } catch (_) {}
    }
    final group = AnimalGroup(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      species: species,
      purpose: purpose,
      headCount: count,
      description: notes,
    );
    _offline.addGroup(group);
    return (group: group, animals: <Animal>[]);
  }
}
