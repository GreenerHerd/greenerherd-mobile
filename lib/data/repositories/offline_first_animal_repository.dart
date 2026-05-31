import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../core/persistence/local_cache_store.dart';
import '../../core/persistence/network_status.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../services/animal_mapper.dart';
import 'repositories.dart';

/// Drift-backed cache + sync queue around [AnimalRepository] (Phase 5).
class OfflineFirstAnimalRepository implements AnimalRepository {
  OfflineFirstAnimalRepository({
    required AnimalRepository inner,
    required LocalCacheStore cache,
    required String farmId,
    NetworkStatus? network,
  })  : _inner = inner,
        _cache = cache,
        _farmId = farmId,
        _network = network ?? NetworkStatus();

  final AnimalRepository _inner;
  final LocalCacheStore _cache;
  final String _farmId;
  final NetworkStatus _network;

  @override
  Future<List<Animal>> listAnimals({
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  }) async {
    if (await _network.isOnline) {
      try {
        final fresh = await _inner.listAnimals(
          species: species,
          statusTag: statusTag,
          groupId: groupId,
          search: search,
        );
        final cached = await _cache.loadAnimals(_farmId);
        final merged = _mergeWithCached(fresh, cached);
        await _cache.replaceAnimals(_farmId, merged);
        return _filterCached(
          merged,
          species: species,
          statusTag: statusTag,
          groupId: groupId,
          search: search,
        );
      } catch (_) {
        return _filterCached(
          await _cache.loadAnimals(_farmId),
          species: species,
          statusTag: statusTag,
          groupId: groupId,
          search: search,
        );
      }
    }
    return _filterCached(
      await _cache.loadAnimals(_farmId),
      species: species,
      statusTag: statusTag,
      groupId: groupId,
      search: search,
    );
  }

  @override
  Future<Animal?> getAnimal(String id) async {
    final cached = await _cache.loadAnimals(_farmId);
    Animal? local;
    try {
      local = cached.firstWhere((a) => a.id == id);
    } catch (_) {
      local = null;
    }
    if (local != null) return local;
    if (await _network.isOnline) {
      try {
        final animal = await _inner.getAnimal(id);
        if (animal != null) await _cache.upsertAnimal(_farmId, animal);
        return animal;
      } catch (_) {}
    }
    try {
      return cached.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Animal> createAnimal(Animal animal, {bool purchased = false}) async {
    if (!await _network.isOnline) {
      await _cache.upsertAnimal(_farmId, animal);
      await _enqueueAnimal('create', animal, purchased: purchased);
      return animal;
    }
    try {
      final created = await _inner.createAnimal(animal, purchased: purchased);
      await _cache.upsertAnimal(_farmId, created);
      return created;
    } catch (_) {
      await _cache.upsertAnimal(_farmId, animal);
      await _enqueueAnimal('create', animal, purchased: purchased);
      return animal;
    }
  }

  @override
  Future<Animal> flagCull(String id) => _inner.flagCull(id);

  @override
  Future<Animal> markSold(String id, {double? saleAmount}) =>
      _inner.markSold(id, saleAmount: saleAmount);

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    if (!await _network.isOnline) {
      await _cache.upsertAnimal(_farmId, animal);
      await _enqueueAnimal('update', animal);
      return animal;
    }
    try {
      final updated = await _inner.updateAnimal(animal);
      await _cache.upsertAnimal(_farmId, updated);
      return updated;
    } catch (_) {
      await _cache.upsertAnimal(_farmId, animal);
      await _enqueueAnimal('update', animal);
      return animal;
    }
  }

  Future<void> _enqueueAnimal(
    String operation,
    Animal animal, {
    bool purchased = false,
  }) async {
    if (!AppConfig.useOfflineSync) return;
    await _cache.enqueuePayload(
      entityType: 'animal',
      entityId: animal.id,
      operation: operation,
      payloadJson: jsonEncode(
        AnimalMapper.toCreateBody(animal, purchased: purchased),
      ),
    );
  }

  List<Animal> _filterCached(
    List<Animal> list, {
    Species? species,
    AnimalTagType? statusTag,
    String? groupId,
    String? search,
  }) {
    var out = list.where((a) => a.status == AnimalStatus.active);
    if (species != null) out = out.where((a) => a.species == species);
    if (statusTag != null) out = out.where((a) => a.tags.contains(statusTag));
    if (groupId != null) out = out.where((a) => a.groupId == groupId);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      out = out.where(
        (a) =>
            a.name.toLowerCase().contains(q) ||
            a.tag.toLowerCase().contains(q) ||
            a.breed.toLowerCase().contains(q),
      );
    }
    return out.toList();
  }

  List<Animal> _mergeWithCached(List<Animal> fresh, List<Animal> cached) {
    if (cached.isEmpty) return fresh;
    final cachedById = {for (final a in cached) a.id: a};
    final freshIds = fresh.map((a) => a.id).toSet();
    return [
      for (final animal in fresh) cachedById[animal.id] ?? animal,
      for (final animal in cached)
        if (!freshIds.contains(animal.id)) animal,
    ];
  }
}
