import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/gen/app_localizations.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/core/theme/theme_mode_controller.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/mock/mock_repositories.dart';
import 'package:greenerherd_mobile/data/models/animal_lactation_cycle.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/feed_eligibility_models.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/models/invite_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/core/theme/gh_colors.dart';
import 'package:greenerherd_mobile/core/theme/gh_theme.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_inventory_repository.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_nutrition_repository.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_people_repository.dart';
import 'package:greenerherd_mobile/data/repositories/repositories.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';
import 'package:greenerherd_mobile/data/services/group_nutrition_mapper.dart';
import 'package:greenerherd_mobile/data/services/reproduction_status_rules.dart';
import 'package:greenerherd_mobile/data/services/feed_catalog_loader.dart';
import 'package:greenerherd_mobile/data/services/nutrition_profile_resolver.dart';
import 'package:greenerherd_mobile/data/services/nutrition_requirements_catalog.dart';
import 'package:greenerherd_mobile/data/services/people_remote_gateway.dart';
import 'package:greenerherd_mobile/data/services/supplement_nutrition.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeController', () {
    test('restores persisted mode and saves changes', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      final controller = ThemeModeController();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, ThemeMode.dark);

      await controller.setMode(ThemeMode.light);
      expect(controller.state, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('provider exposes controller', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });

  group('Model helpers', () {
    const group = AnimalGroup(
      id: 'g1',
      name: 'Herd',
      species: Species.cattle,
      purpose: GroupPurpose.milk,
      headCount: 5,
    );

    const sickCow = Animal(
      id: 'a1',
      tag: '100',
      name: 'Bess',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 500,
      ageLabel: '4y',
      groupId: 'g1',
      tags: [AnimalTagType.sick],
      illnessNote: 'Mastitis',
      treatmentNote: 'Penicillin 5ml',
    );

    test('AnimalGroup.needsAttention detects sick member', () {
      expect(group.needsAttention([sickCow]), isTrue);
      expect(
        group.needsAttention([
          sickCow.copyWith(tags: const [], status: AnimalStatus.active),
        ]),
        isFalse,
      );
    });

    test('Animal activeTreatmentSummary and cullReasonLabel', () {
      expect(sickCow.activeTreatmentSummary, contains('Mastitis'));
      expect(sickCow.activeTreatmentSummary, contains('Penicillin'));

      final culled = sickCow.copyWith(
        cullType: 'Health',
        cullReason: 'Chronic mastitis',
      );
      expect(culled.cullReasonLabel, 'Health · Chronic mastitis');
      expect(
        sickCow.copyWith(deathReason: 'Sold at market').cullReasonLabel,
        'Sold at market',
      );
    });

    test('Animal copyWith clears optional fields', () {
      final cleared = sickCow.copyWith(
        clearIllnessNote: true,
        clearTreatmentNote: true,
        clearProlificacy: true,
        prolificacy: 3,
      );
      expect(cleared.illnessNote, isNull);
      expect(cleared.prolificacy, isNull);
    });

    test('Animal missingFields and Equatable props', () {
      const incomplete = Animal(
        id: 'x',
        tag: 'NEW-1',
        name: 'X',
        species: Species.sheep,
        sex: 'F',
        breed: '—',
        weightKg: 0,
        ageLabel: '?',
        groupId: 'g1',
      );
      expect(incomplete.hasIncompleteData, isTrue);
      expect(incomplete.missingFields, contains('tag'));
      expect(incomplete.props, contains('g1'));
    });

    test('FeedRecommendation copyWith and props', () {
      const rec = FeedRecommendation(
        id: 'r1',
        name: 'Alfalfa',
        supplier: 'Co',
        costPerDay: 12,
        kgPerDay: 2,
      );
      final updated = rec.copyWith(added: true, kgPerDay: 3);
      expect(updated.added, isTrue);
      expect(updated.kgPerDay, 3);
      expect(updated.props, [rec.id, true, 3.0]);
    });

    test('NutritionGap and PurchaseRecord props', () {
      const gap = NutritionGap(
        groupId: 'g1',
        dryMatterActualKg: 1,
        dryMatterTargetKg: 2,
        energyActualMj: 1,
        energyTargetMj: 2,
        proteinActualKg: 1,
        proteinTargetKg: 2,
        ndfActualKg: 1,
        ndfTargetKg: 2,
      );
      expect(gap.props, ['g1']);

      final purchase = PurchaseRecord(
        id: 'p1',
        purchaseDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        animalIds: const ['a1'],
      );
      expect(purchase.props, contains('p1'));
    });

    test('FinanceSummary and FinanceMonth props', () {
      const summary = FinanceSummary(
        income3mo: 1,
        expense3mo: 2,
        net3mo: -1,
        livestockValue: 100,
        monthly: [FinanceMonth(label: 'May', income: 1, expense: 1)],
        recent: [],
      );
      expect(summary.props, [1.0, 2.0]);
      expect(const FinanceMonth(label: 'May', income: 1, expense: 1).props,
          ['May']);
    });
  });

  group('Inventory models JSON', () {
    test('model props and nutrition input serialize all fields', () {
      const custom = CustomNutritionInput(
        feedType: InventoryFeedType.fodder,
        dryMatterPercent: 90,
        crudeProteinPercent: 12,
        nemMcalPerKg: 1.5,
        ndfPercent: 35,
      );
      expect(custom.toJson().keys, hasLength(5));

      const feed = FeedInventoryItem(
        id: 'f1',
        name: 'Hay',
        sourceType: InventorySourceType.standard,
        quantityKg: 1,
        unit: 'kg',
      );
      expect(feed.props, ['f1']);
      expect(feed.sourceLabel, 'Standard catalogue');

      const med = MedicalInventoryItem(
        id: 'm1',
        name: 'Med',
        medicineType: 'VACCINE',
        quantity: 1,
        unit: 'dose',
      );
      expect(med.props, ['m1']);

      const line = MealIngredientLine(
        feedInventoryItemId: 'f1',
        amountKg: 2,
        feedItemName: 'Hay',
      );
      expect(line.props, ['f1']);

      const warning = MealStockWarningLine(
        feedInventoryItemId: 'f1',
        feedItemName: 'Hay',
        availableKg: 1,
        requestedKg: 2,
        lowStock: true,
        insufficientForBatch: true,
      );
      expect(warning.props, ['f1']);
    });

    test('parses feed, medical, meal, and withdrawal models', () {
      final feed = FeedInventoryItem.fromJson({
        'id': 'f1',
        'name': 'Hay',
        'source_type': 'MARKETPLACE',
        'feed_type': 'CONCENTRATE',
        'quantity_kg': 10,
      });
      expect(feed.sourceType, InventorySourceType.marketplace);
      expect(feed.feedType, InventoryFeedType.concentrate);

      final med = MedicalInventoryItem.fromJson({
        'id': 'm1',
        'name': 'Med',
        'medicine_type': 'VACCINE',
        'quantity': 2,
        'unit': 'dose',
        'withdrawal_periods': [
          {'species': 'goat', 'meat_days': 7, 'milk_days': 3},
        ],
      });
      expect(med.withdrawalFor('goat')?.meatDays, 7);

      final meal = MealPlan.fromJson({
        'id': 'meal-1',
        'name': 'Mix',
        'ingredients': [
          {
            'feed_inventory_item_id': 'f1',
            'amount_kg': 5,
          },
        ],
        'stock_warnings': [
          {
            'feed_inventory_item_id': 'f1',
            'feed_item_name': 'Hay',
            'available_kg': 1,
            'requested_kg': 5,
            'low_stock': true,
            'insufficient_for_batch': true,
          },
        ],
      });
      expect(meal.totalKgPerBatch, 5);
      expect(meal.stockWarnings.single.lowStock, isTrue);

      final input = CreateFeedInventoryInput(
        name: 'Custom',
        sourceType: InventorySourceType.custom,
        quantityKg: 1,
        purchasedVolumeKg: 1,
        feedType: InventoryFeedType.additive,
        customNutrition: const CustomNutritionInput(ndfPercent: 40),
        supplierPhone: '+966',
        notes: 'note',
        photoPath: '/tmp.jpg',
      );
      expect(input.toJson()['feed_type'], 'ADDITIVE');
    });

    test('TodaysFeedEntry parses subtitle weight', () {
      expect(
        TodaysFeedEntry.weightKgFromSubtitle('148 kg · 6.7 kg/head'),
        148,
      );
      final entry = TodaysFeedEntry(
        id: 'e1',
        groupId: 'g1',
        recordedAt: DateTime(2026, 3, 1),
        title: 'Feed',
        subtitle: '10 kg',
        costSar: 5,
        weightKg: 0,
      );
      expect(entry.effectiveWeightKg, 10);
    });
  });

  group('FeedCatalogLoader enrichment', () {
    test('MarketplaceFeedProduct fromJson and Arabic displayName', () {
      final product = MarketplaceFeedProduct.fromJson({
        'id': 'mp-1',
        'name_en': 'Premium Soyabean Meal',
        'name_ar': 'فول الصويا',
        'supplier_name': 'Supplier',
        'country_code': 'SA',
        'price_per_kg': 3.5,
        'eligibility_rules': [
          {
            'species': ['CATTLE'],
            'allowed_tags': ['LACTATING'],
          },
        ],
      });
      expect(product.displayName(const Locale('ar')), 'فول الصويا');
      expect(product.eligibilityRules, hasLength(1));
      expect(product.eligibilityRules.first, isA<FeedEligibilityRule>());
    });

    test('standard product displayName resolves localized names', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      expect(catalog, isNotEmpty);
      final product = catalog.first;
      expect(product.displayName(const Locale('en')), isNotEmpty);
    });
  });

  group('LactationCycleCatalog', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('covers goat and sheep options and wire round-trip', () {
      final goatOptions = LactationCycleCatalog.forSpecies(Species.goat);
      expect(goatOptions, contains(AnimalLactationCycle.lactatingTwin));

      for (final cycle in [
        AnimalLactationCycle.cattleClose,
        AnimalLactationCycle.cattlePreCalvingCloseToDryOff,
        AnimalLactationCycle.lactatingSingle,
      ]) {
        final wire = LactationCycleCatalog.wire(cycle);
        expect(LactationCycleCatalog.fromWire(wire), cycle);
        expect(LactationCycleCatalog.label(cycle, l10n), isNotEmpty);
      }

      expect(
        LactationCycleCatalog.isLactating(AnimalLactationCycle.cattleDry),
        isFalse,
      );
      expect(
        LactationCycleCatalog.isPreCalvingDry(
          AnimalLactationCycle.cattlePreCalvingCloseToDryOff,
        ),
        isTrue,
      );
      expect(
        LactationCycleCatalog.isTwinLactation(
          AnimalLactationCycle.lactatingTwin,
        ),
        isTrue,
      );
    });
  });

  group('NutritionProfileResolver edge paths', () {
    late NutritionRequirementsCatalog catalog;

    setUpAll(() async {
      catalog = await NutritionRequirementsCatalog.load();
    });

    test('resolves beef growing yearling and maintenance', () {
      final young = NutritionProfileResolver.resolve(
        catalog,
        const NutritionProfileContext(
          species: 'CATTLE',
          sex: 'MALE',
          ageMonths: 8,
          productionFocus: 'MEAT',
          lactating: false,
        ),
      );
      expect(young.matchReason, contains('beef'));

      final mature = NutritionProfileResolver.resolve(
        catalog,
        const NutritionProfileContext(
          species: 'CATTLE',
          sex: 'FEMALE',
          ageMonths: 48,
          productionFocus: 'MEAT',
          lactating: false,
          pregnant: false,
        ),
      );
      expect(mature.profileCode, isNotEmpty);
    });

    test('buildGroupRequirements scales small ruminant twins', () {
      final profile = catalog.getByCode('GOAT_SMALL_RUMINANT_LACTATING')!;
      final reqs = NutritionProfileResolver.buildGroupRequirements(
        profile,
        10,
        lactatingTwin: true,
      );
      expect(reqs['group']['no_of_animals'], 10);
      expect(
        reqs['per_animal']['dry_matter_kg'],
        greaterThan(profile.dmiKgDay),
      );
    });

    test('fromRequest maps wire payload', () {
      final ctx = NutritionProfileContext.fromRequest({
        'species': 'SHEEP',
        'age_months': 6,
        'production_focus': 'MILK',
        'lactating': true,
        'months_since_calving': 2,
      });
      expect(ctx.species, 'SHEEP');
      expect(ctx.lactating, isTrue);
      expect(ctx.monthsSinceCalving, 2);
    });
  });

  group('Mock repositories', () {
    const lifecycle = AnimalLifecycleService();

    test('MockFarmRepository returns users', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final users = await MockFarmRepository(store).getUsers();
      expect(users, isNotEmpty);
    });

    test('MockTaskRepository filters by due bucket', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final repo = MockTaskRepository(store);
      final all = await repo.listTasks();
      if (all.isEmpty) return;
      final bucket = all.first.dueBucket;
      final filtered = await repo.listTasks(dueBucket: bucket);
      expect(filtered.every((t) => t.dueBucket == bucket), isTrue);
    });

    test('MockAnimalRepository flagCull throws for missing animal', () async {
      final store = MockDataStore();
      final repo = MockAnimalRepository(store, lifecycle);
      expect(() => repo.flagCull('missing'), throwsStateError);
    });

    test('MockInventoryRepository delegates getFeed', () async {
      final store = MockDataStore();
      final repo = MockInventoryRepository(store);
      final feed = await repo.getFeed('feed-alfalfa');
      expect(feed?.name, contains('Alfalfa'));
      await repo.removeTodaysFeedEntry('feed-demo-1');
      await repo.restoreSupplementInventory(
        feedInventoryItemId: 'feed-alfalfa',
        weightKg: 1,
      );
    });

    test('MockNutritionRepository applySupplement adjusts gap', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final repo = MockNutritionRepository(store);
      await repo.applySupplement(
        groupId: 'g1',
        input: const SupplementNutritionInput(
          kgAsFed: 2,
          crudeProteinPercent: 16,
        ),
      );
      final gap = await repo.getGap('g1');
      expect(gap.groupId, 'g1');
    });

    test('MockPeopleRepository invite builds whatsapp link', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final result = await MockPeopleRepository(store).inviteUser(
        const InviteUserRequest(
          name: 'Sam',
          role: UserRole.manager,
          channel: InviteDeliveryChannel.whatsapp,
          phone: '+966 50 123 4567',
        ),
      );
      expect(result.whatsappUrl, contains('wa.me/966501234567'));
    });
  });

  group('HybridPeopleRepository mock invite fallback', () {
    test('uses offline invite when API throws', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final repo = HybridPeopleRepository(
        offlineStore: store,
        farmId: 'farm-1',
        gateway: _ThrowingPeopleGateway(),
      );
      final result = await repo.inviteUser(
        const InviteUserRequest(
          name: 'Fatima',
          role: UserRole.farmHand,
          channel: InviteDeliveryChannel.email,
          email: 'fatima@test.com',
          farmName: 'Al Falah',
        ),
      );
      expect(result.member.name, 'Fatima');
      expect(result.inviteLink, contains('invite=mock-'));
      expect(result.emailSent, isTrue);
    });
  });

  group('Riverpod providers', () {
    test('core providers resolve with demo store', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(mockDataStoreProvider), isA<MockDataStore>());
      expect(
        container.read(inventoryRepositoryProvider),
        isA<HybridInventoryRepository>(),
      );
      expect(container.read(lifecycleServiceProvider), isA<AnimalLifecycleService>());
      expect(container.read(financeLedgerProvider), isNotNull);

      final events = container.read(vaccinationEventsProvider);
      expect(events, isA<List<VaccinationEvent>>());

      container.read(selectedSpeciesFilterProvider.notifier).state =
          Species.cattle;
      expect(container.read(selectedSpeciesFilterProvider), Species.cattle);

      container.read(dueSoonFilterProvider.notifier).state = true;
      expect(container.read(dueSoonFilterProvider), isTrue);
    });

    test('breed reference provider loads breeds', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final breeds =
          await container.read(breedsForSpeciesProvider(Species.cattle).future);
      expect(breeds, isNotEmpty);
    });

    test('bridgeGapsProvider returns gaps for hybrid nutrition', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final container = ProviderContainer(
        overrides: [
          mockDataStoreProvider.overrideWithValue(store),
          nutritionRepositoryProvider.overrideWithValue(
            HybridNutritionRepository(
              animalRepository: MockAnimalRepository(
                store,
                const AnimalLifecycleService(),
              ),
              groupRepository: MockGroupRepository(store),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final gaps = await container.read(bridgeGapsProvider('g1').future);
      expect(gaps, isA<List<NutrientBridgeGap>>());
    });
  });

  group('ReproductionStatusRules extended', () {
    test('tooltips explain minimum age for pregnancy and lactation', () {
      expect(
        ReproductionStatusRules.disabledPregnancyTooltip(
          species: Species.cattle,
          sex: 'Female',
          ageMonths: 10,
        ),
        contains('Minimum'),
      );
      expect(
        ReproductionStatusRules.disabledLactatingTooltip(
          species: Species.goat,
          sex: 'Female',
          ageMonths: 4,
        ),
        contains('goats'),
      );
    });

    test('GroupBreedingCycleSummary aggregates lactating herd', () {
      final summary = GroupBreedingCycleSummary.fromMembers([
        const Animal(
          id: 'a1',
          tag: '1',
          name: 'Cow',
          species: Species.cattle,
          sex: 'F',
          breed: 'H',
          weightKg: 400,
          ageLabel: '4y',
          groupId: 'g1',
          tags: [AnimalTagType.lactating],
          monthsSinceCalving: 5,
        ),
        const Animal(
          id: 'a2',
          tag: '2',
          name: 'Cow2',
          species: Species.cattle,
          sex: 'F',
          breed: 'H',
          weightKg: 400,
          ageLabel: '4y',
          groupId: 'g1',
          tags: [AnimalTagType.lactating, AnimalTagType.readyToBreed],
          monthsSinceCalving: 3,
        ),
      ]);
      expect(summary, isNotNull);
      expect(summary!.lactatingCount, 2);
      expect(summary.readyForRebreedingCount, greaterThan(0));
      expect(summary.lactationStageCounts['mid'], greaterThan(0));
    });
  });

  group('AnimalMapper age helpers', () {
    test('dashboardAgeBucketIndex maps all buckets', () {
      expect(AnimalMapper.dashboardAgeBucketIndex('0-3m'), 0);
      expect(AnimalMapper.dashboardAgeBucketIndex('7-11m'), 1);
      expect(AnimalMapper.dashboardAgeBucketIndex('2-3yr'), 3);
      expect(AnimalMapper.dashboardAgeBucketIndex('5+yr'), 4);
      expect(AnimalMapper.dashboardAgeBucketIndex('—'), isNull);
    });

    test('maps age range wires and verbose dob parsing', () {
      expect(AnimalMapper.ageRangeWireFromLabel('2-3yr'), '2_3Y');
      expect(AnimalMapper.ageRangeWireFromLabel('unknown'), '1_2Y');
      final dob = AnimalMapper.dobFromAgeLabel('4y 2m', DateTime(2026, 5, 29));
      expect(dob.isBefore(DateTime(2026, 5, 29)), isTrue);
      expect(AnimalMapper.ageMidpointMonths('5+yr'), 72);
    });

    test('ageMonthsForAnimal prefers label bucket then dob', () {
      const fromLabel = Animal(
        id: 'a',
        tag: '1',
        name: 'X',
        species: Species.cattle,
        sex: 'F',
        breed: 'H',
        weightKg: 1,
        ageLabel: '7-11m',
        groupId: 'g',
      );
      expect(AnimalMapper.ageMonthsForAnimal(fromLabel), 9);

      final fromDob = fromLabel.copyWith(
        ageLabel: 'verbose',
        dob: DateTime.now().subtract(const Duration(days: 400)),
      );
      expect(AnimalMapper.ageMonthsForAnimal(fromDob), greaterThan(10));
    });
  });

  group('GhColors theme extension', () {
    testWidgets('resolves light semantic colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: GhTheme.light(),
          home: Builder(
            builder: (context) {
              expect(context.ghPrimary, GhColors.primary);
              expect(context.ghPageBackground, GhColors.pageBackground);
              expect(context.ghSuccessLight, GhColors.successLight);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('resolves dark semantic colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: GhTheme.dark(),
          home: Builder(
            builder: (context) {
              expect(context.ghPrimary, GhColors.darkPrimary);
              expect(context.ghErrorLight, GhColors.darkErrorLight);
              expect(context.ghTextFaint, GhColors.darkTextFaint);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('HybridNutritionRepository with members', () {
    test('loads bridge gaps using group and animal repositories', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final repo = HybridNutritionRepository(
        animalRepository: MockAnimalRepository(
          store,
          const AnimalLifecycleService(),
        ),
        groupRepository: _LookupGroupRepository(store),
      );
      final gaps = await repo.getBridgeGaps('g1');
      expect(gaps, isA<List<NutrientBridgeGap>>());
      final recs = await repo.getRecommendations('g1');
      expect(recs, isNotEmpty);
      await repo.updateRecommendation(recs.first.copyWith(added: true));
    });
  });
}

class _LookupGroupRepository implements GroupRepository {
  _LookupGroupRepository(this._store);
  final MockDataStore _store;

  @override
  Future<AnimalGroup?> getGroup(String id) async => null;

  @override
  Future<List<AnimalGroup>> listGroups({Species? species}) async =>
      _store.groups;

  @override
  Future<AnimalGroup> createGroup(AnimalGroup group) async {
    _store.groups.add(group);
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
    final group = AnimalGroup(
      id: 'bulk-$name',
      name: name,
      species: species,
      purpose: purpose,
      headCount: count,
    );
    _store.groups.add(group);
    return (group: group, animals: const <Animal>[]);
  }
}

class _ThrowingPeopleGateway implements PeopleRemoteGateway {
  @override
  Future<List<Map<String, dynamic>>> listMembers(String farmId) async =>
      throw StateError('offline');

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> inviteUser(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      throw StateError('offline');
}
