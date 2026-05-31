import '../../core/config/app_config.dart';
import '../../core/persistence/local_cache_store.dart';
import '../../core/persistence/network_status.dart';
import '../models/enums.dart';
import '../models/models.dart';
import 'repositories.dart';

class OfflineFirstGroupRepository implements GroupRepository {
  OfflineFirstGroupRepository({
    required GroupRepository inner,
    required LocalCacheStore cache,
    required String farmId,
    NetworkStatus? network,
  })  : _inner = inner,
        _cache = cache,
        _farmId = farmId,
        _network = network ?? NetworkStatus();

  final GroupRepository _inner;
  final LocalCacheStore _cache;
  final String _farmId;
  final NetworkStatus _network;

  @override
  Future<List<AnimalGroup>> listGroups({Species? species}) async {
    if (await _network.isOnline) {
      try {
        final fresh = await _inner.listGroups(species: species);
        await _cache.replaceGroups(_farmId, fresh);
        return fresh;
      } catch (_) {
        return _filter(await _cache.loadGroups(_farmId), species);
      }
    }
    return _filter(await _cache.loadGroups(_farmId), species);
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
  Future<({AnimalGroup group, List<Animal> animals})> createGroupBulk({
    required Species species,
    required String breed,
    required String sex,
    required String ageRangeWire,
    required int count,
    required String name,
    required GroupPurpose purpose,
    String? notes,
  }) =>
      _inner.createGroupBulk(
        species: species,
        breed: breed,
        sex: sex,
        ageRangeWire: ageRangeWire,
        count: count,
        name: name,
        purpose: purpose,
        notes: notes,
      );

  @override
  Future<AnimalGroup> createGroup(AnimalGroup group) async {
    final created = await _inner.createGroup(group);
    final all = [...await _cache.loadGroups(_farmId), created];
    await _cache.replaceGroups(_farmId, all);
    if (AppConfig.useOfflineSync) {
      await _cache.enqueuePayload(
        entityType: 'group',
        entityId: created.id,
        operation: 'create',
        payloadJson: '{}',
      );
    }
    return created;
  }

  List<AnimalGroup> _filter(List<AnimalGroup> list, Species? species) {
    if (species == null) return list;
    return list.where((g) => g.species == species).toList();
  }
}
