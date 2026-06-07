import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/persistence/app_database.dart';
import 'package:greenerherd_mobile/core/persistence/entity_json_codec.dart';
import 'package:greenerherd_mobile/core/persistence/local_cache_store.dart';
import 'package:greenerherd_mobile/core/persistence/network_status.dart';
import 'package:greenerherd_mobile/core/persistence/sync_service.dart';
import 'package:greenerherd_mobile/data/mock/mock_repositories.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_animal_repository.dart';
import 'package:greenerherd_mobile/data/repositories/offline_first_animal_repository.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';

import 'animals_api_bdd_test.dart';
import 'support/bdd_harness.dart';

class AlwaysOfflineNetwork extends NetworkStatus {
  @override
  Future<bool> get isOnline async => false;
}

void main() {
  initBddTests();

  group('Feature: Offline cache and sync queue', () {
    late AppDatabase db;
    late LocalCacheStore cache;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      cache = LocalCacheStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    bddAsyncDomainScenario(
      'Entity JSON codec round-trips an animal',
      tags: ['positive'],
      body: () async {
        const animal = Animal(
          id: 'a-offline',
          tag: '9901',
          name: 'Daisy',
          species: Species.cattle,
          sex: 'Female',
          breed: 'Holstein',
          weightKg: 500,
          ageLabel: '2Y',
          groupId: 'g1',
          tags: [AnimalTagType.lactating],
        );
        final json = EntityJsonCodec.encodeAnimal(animal);
        final decoded = EntityJsonCodec.decodeAnimal(json);
        expect(decoded.tag, '9901');
        expect(decoded.name, 'Daisy');
      },
    );

    bddAsyncDomainScenario(
      'Local cache stores and loads animals',
      tags: ['positive'],
      body: () async {
        const animal = Animal(
          id: 'a-cache',
          tag: '1001',
          name: 'Belle',
          species: Species.cattle,
          sex: 'Female',
          breed: 'Angus',
          weightKg: 420,
          ageLabel: '1Y',
          groupId: 'g1',
        );
        await cache.replaceAnimals('farm-1', [animal]);
        final loaded = await cache.loadAnimals('farm-1');
        expect(loaded.length, 1);
        expect(loaded.first.tag, '1001');
      },
    );

    bddAsyncDomainScenario(
      'Sync queue receives offline task completion',
      tags: ['positive'],
      body: () async {
        await cache.enqueuePayload(
          entityType: 'task',
          entityId: 'task-1',
          operation: 'complete',
          payloadJson: '{}',
        );
        final pending = await cache.pendingSyncItems();
        expect(pending.length, 1);
        expect(pending.first.operation, 'complete');
      },
    );

    bddAsyncDomainScenario(
      'Offline-first repository reads cache when API fails',
      tags: ['positive'],
      body: () async {
        final store = BddHarness().store;
        final gateway = FakeAnimalsGateway(throwOnList: true);
        final hybrid = HybridAnimalRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        await cache.replaceAnimals(
          'farm-1',
          [
            const Animal(
              id: 'cached-1',
              tag: '5555',
              name: 'Cached Cow',
              species: Species.cattle,
              sex: 'Female',
              breed: 'Hereford',
              weightKg: 400,
              ageLabel: '2Y',
              groupId: 'g1',
            ),
          ],
        );
        final repo = OfflineFirstAnimalRepository(
          inner: hybrid,
          cache: cache,
          farmId: 'farm-1',
          network: AlwaysOfflineNetwork(),
        );
        final animals = await repo.listAnimals();
        expect(animals.any((a) => a.tag == '5555'), isTrue);
      },
    );

    bddAsyncDomainScenario(
      'Offline-first repository enqueues animal create when offline',
      tags: ['positive'],
      body: () async {
        final store = BddHarness().store;
        final inner = MockAnimalRepository(store, const AnimalLifecycleService());
        final repo = OfflineFirstAnimalRepository(
          inner: inner,
          cache: cache,
          farmId: 'farm-1',
          network: AlwaysOfflineNetwork(),
        );
        const animal = Animal(
          id: 'pending-create',
          tag: '7777',
          name: 'Pending',
          species: Species.cattle,
          sex: 'Female',
          breed: 'Simmental',
          weightKg: 300,
          ageLabel: '1Y',
          groupId: 'g1',
        );
        await repo.createAnimal(animal);
        final pending = await cache.pendingSyncItems();
        expect(pending.length, 1);
        expect(pending.first.entityType, 'animal');
        expect(pending.first.operation, 'create');
        final payload =
            jsonDecode(pending.first.payloadJson) as Map<String, dynamic>;
        expect(payload['ear_tag'], '7777');
      },
    );

    bddAsyncDomainScenario(
      'SyncService reports offline when network is down',
      tags: ['positive'],
      body: () async {
        final service = SyncService(
          cache: cache,
          network: AlwaysOfflineNetwork(),
        );
        final result = await service.drainQueue();
        expect(result.offline, isTrue);
        expect(result.applied, 0);
      },
    );
  });
}
