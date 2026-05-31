import '../../core/config/app_config.dart';
import '../models/cull_reasons.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../mock/mock_data_store.dart';
import '../services/animal_lifecycle_service.dart';
import '../services/animal_mapper.dart';
import '../services/animals_api_client.dart';
import '../services/animals_remote_gateway.dart';
import 'repositories.dart';

/// Loads animals from `gh-api-animals` with mock fallback.
class HybridAnimalRepository implements AnimalRepository {
  HybridAnimalRepository({
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
  Future<List<Animal>> listAnimals({
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  }) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final rows = await _api.listAnimals(
          _farmId,
          species: species?.name.toUpperCase(),
          groupId: groupId,
          tag: statusTag != null ? _tagWire(statusTag) : null,
        );
        var list = rows.map(AnimalMapper.fromWire).toList();
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          list = list
              .where(
                (a) =>
                    a.name.toLowerCase().contains(q) ||
                    a.tag.toLowerCase().contains(q) ||
                    a.breed.toLowerCase().contains(q),
              )
              .toList();
        }
        return _overlayLocalAnimals(list);
      } catch (e) {
        // fall through to offline cache
      }
    }
    return _mockList(
      species: species,
      statusTag: statusTag,
      groupId: groupId,
      search: search,
    );
  }

  @override
  Future<Animal?> getAnimal(String id) async {
    final local = _offline.animalById(id);
    if (local != null) return local;
    if (AppConfig.useAnimalsApi) {
      try {
        final row = await _api.getAnimal(_farmId, id);
        if (row != null) return AnimalMapper.fromWire(row);
      } catch (_) {
        // fall through
      }
    }
    try {
      return _offline.animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Animal> createAnimal(Animal animal, {bool purchased = false}) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final created = await _api.createAnimal(
          _farmId,
          AnimalMapper.toCreateBody(animal, purchased: purchased),
        );
        final mapped = AnimalMapper.fromWire(created);
        _offline.addAnimal(mapped);
        return mapped;
      } catch (_) {
        // fall through
      }
    }
    _offline.addAnimal(animal);
    return animal;
  }

  @override
  Future<Animal> flagCull(String id) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final wire = await _api.flagCull(_farmId, id);
        final mapped = AnimalMapper.fromWire(wire);
        _offline.updateAnimal(mapped);
        return mapped;
      } catch (_) {}
    }
    final animal = await getAnimal(id);
    if (animal == null) throw StateError('Animal not found');
    final updated = const AnimalLifecycleService().flagForCull(
      animal,
      selection: CullReasonCatalog.defaultSelection,
    );
    _offline.updateAnimal(updated);
    return updated;
  }

  @override
  Future<Animal> markSold(String id, {double? saleAmount}) async {
    if (AppConfig.useAnimalsApi) {
      try {
        final wire = await _api.markSold(_farmId, id);
        final mapped = AnimalMapper.fromWire(wire);
        _offline.updateAnimal(mapped);
        return mapped;
      } catch (_) {}
    }
    final animal = await getAnimal(id);
    if (animal == null) throw StateError('Animal not found');
    final updated = const AnimalLifecycleService().markSold(animal);
    _offline.updateAnimal(updated);
    return updated;
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    _offline.updateAnimal(animal);
    return animal;
  }

  Future<List<Animal>> _mockList({
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  }) async {
    var list = _offline.animals.where((a) => a.status == AnimalStatus.active);
    if (species != null) list = list.where((a) => a.species == species);
    if (statusTag != null) {
      list = list.where((a) => a.tags.contains(statusTag));
    }
    if (groupId != null) list = list.where((a) => a.groupId == groupId);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where(
        (a) =>
            a.name.toLowerCase().contains(q) ||
            a.tag.toLowerCase().contains(q) ||
            a.breed.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  List<Animal> _overlayLocalAnimals(List<Animal> remote) {
    final localById = {for (final a in _offline.animals) a.id: a};
    if (localById.isEmpty) return remote;
    final remoteIds = remote.map((a) => a.id).toSet();
    final merged = [
      for (final animal in remote) localById[animal.id] ?? animal,
      for (final local in _offline.animals)
        if (!remoteIds.contains(local.id)) local,
    ];
    return merged;
  }

  static String _tagWire(AnimalTagType tag) {
    return switch (tag) {
      AnimalTagType.readyToBreed => 'READY_TO_BREED',
      AnimalTagType.pregnant => 'PREGNANT',
      AnimalTagType.lactating => 'LACTATING',
      AnimalTagType.weaning => 'WEANING',
      AnimalTagType.cull => 'CULL',
      AnimalTagType.miscarriage => 'MISCARRIAGE',
      AnimalTagType.stillborn => 'STILLBORN',
      AnimalTagType.sick => 'SICK',
      _ => tag.name.toUpperCase(),
    };
  }
}
