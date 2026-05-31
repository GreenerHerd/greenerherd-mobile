import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/feed_eligibility_models.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/feed_catalog_loader.dart';
import 'package:greenerherd_mobile/data/services/feed_eligibility_service.dart';

FeedEligibilityRule _rule({
  String speciesScope = 'CATTLE',
  String? productionFocus,
  int? minAgeMonths,
  int? maxAgeMonths,
  String? lactationInclusion,
  String? lactationExclusion,
  String? sexRestriction,
}) {
  return FeedEligibilityRule(
    ruleNumber: 1,
    speciesScope: speciesScope,
    productionFocus: productionFocus,
    minAgeMonths: minAgeMonths,
    maxAgeMonths: maxAgeMonths,
    lactationInclusion: lactationInclusion,
    lactationExclusion: lactationExclusion,
    sexRestriction: sexRestriction,
  );
}

FeedCatalogProduct _product({
  required int number,
  required String name,
  required List<FeedEligibilityRule> rules,
  String feedType = 'CONCENTRATE',
}) {
  return FeedCatalogProduct(
    productNumber: number,
    nameEn: name,
    names: {'en': name},
    feedType: feedType,
    eligibilityRules: rules,
  );
}

Animal _cow({
  required String id,
  required String tag,
  List<AnimalTagType> tags = const [],
  int? monthsSinceCalving,
  int ageMonths = 48,
  SpeciesPurpose production = SpeciesPurpose.milk,
}) {
  return Animal(
    id: id,
    tag: tag,
    name: tag,
    species: Species.cattle,
    sex: 'F',
    breed: 'Holstein',
    weightKg: 400,
    ageLabel: '${ageMonths}m',
    groupId: 'g1',
    tags: tags,
    productionPurpose: production,
    monthsSinceCalving: monthsSinceCalving,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedEligibilityService rule evaluation', () {
    late FeedCatalogProduct steamedCorn;
    late FeedCatalogProduct barleyAll;

    setUp(() {
      steamedCorn = _product(
        number: 1014,
        name: 'Steamed Corn Flake',
        rules: [
          _rule(
            productionFocus: 'DAIRY',
            minAgeMonths: 12,
            lactationInclusion: 'Lactation Period',
          ),
        ],
      );
      barleyAll = _product(
        number: 1001,
        name: 'Barley',
        rules: [_rule(speciesScope: 'ALL')],
      );
    });

    test('excludes dairy lactation feed for dry cows', () {
      final ctx = FeedEligibilityContext(
        species: 'CATTLE',
        ageMonths: 36,
        productionFocus: 'MILK',
        lactating: false,
      );
      expect(
        FeedEligibilityService.isProductEligible(steamedCorn, ctx).eligible,
        isFalse,
      );
    });

    test('includes dairy lactation feed for lactating dairy cows', () {
      final ctx = FeedEligibilityContext(
        species: 'CATTLE',
        ageMonths: 36,
        productionFocus: 'MILK',
        lactating: true,
      );
      expect(
        FeedEligibilityService.isProductEligible(steamedCorn, ctx).eligible,
        isTrue,
      );
    });

    test('excludes cattle-only feed for sheep', () {
      final ctx = FeedEligibilityContext(
        species: 'SHEEP',
        ageMonths: 24,
        productionFocus: 'MILK',
        lactating: true,
      );
      expect(
        FeedEligibilityService.isProductEligible(steamedCorn, ctx).eligible,
        isFalse,
      );
    });

    test('includes barley for cattle and sheep via ALL scope', () {
      final cattle = FeedEligibilityContext(
        species: 'CATTLE',
        ageMonths: 24,
        productionFocus: 'MEAT',
        lactating: false,
      );
      final sheep = FeedEligibilityContext(
        species: 'SHEEP',
        ageMonths: 24,
        productionFocus: 'MEAT',
        lactating: false,
      );
      expect(
        FeedEligibilityService.isProductEligible(barleyAll, cattle).eligible,
        isTrue,
      );
      expect(
        FeedEligibilityService.isProductEligible(barleyAll, sheep).eligible,
        isTrue,
      );
    });

    test('enforces minimum age on rules', () {
      final young = FeedEligibilityContext(
        species: 'CATTLE',
        ageMonths: 6,
        productionFocus: 'MILK',
        lactating: true,
      );
      expect(
        FeedEligibilityService.isProductEligible(steamedCorn, young).eligible,
        isFalse,
      );
    });

    test('SMALL_RUMINANT scope matches goats and sheep', () {
      final goatProduct = _product(
        number: 2001,
        name: 'Goat mix',
        rules: [_rule(speciesScope: 'SMALL_RUMINANT')],
      );
      expect(
        FeedEligibilityService.isProductEligible(
          goatProduct,
          const FeedEligibilityContext(
            species: 'GOAT',
            ageMonths: 12,
            productionFocus: 'MEAT',
            lactating: false,
          ),
        ).eligible,
        isTrue,
      );
      expect(
        FeedEligibilityService.isProductEligible(
          goatProduct,
          const FeedEligibilityContext(
            species: 'CATTLE',
            ageMonths: 12,
            productionFocus: 'MEAT',
            lactating: false,
          ),
        ).eligible,
        isFalse,
      );
    });
  });

  group('FeedEligibilityService herd filtering', () {
    test('filters products when no animal in herd is eligible', () {
      final lactationOnly = _product(
        number: 1014,
        name: 'Steamed Corn Flake',
        rules: [
          _rule(
            productionFocus: 'DAIRY',
            minAgeMonths: 12,
            lactationInclusion: 'Lactation Period',
          ),
        ],
      );
      final barley = _product(
        number: 1001,
        name: 'Barley',
        rules: [_rule(speciesScope: 'ALL')],
      );
      final dryCow = _cow(id: 'd1', tag: '1001', tags: const []);
      final filtered = FeedEligibilityService.filterProductsForAnimals(
        [lactationOnly, barley],
        [dryCow],
      );
      expect(filtered.map((p) => p.productNumber), [1001]);
      expect(
        FeedEligibilityService.restrictedProductCount(
          [lactationOnly, barley],
          [dryCow],
        ),
        1,
      );
    });

    test('includes lactation product when lactating cow in herd', () {
      final lactationOnly = _product(
        number: 1014,
        name: 'Steamed Corn Flake',
        rules: [
          _rule(
            productionFocus: 'DAIRY',
            minAgeMonths: 12,
            lactationInclusion: 'Lactation Period',
          ),
        ],
      );
      final lactating = _cow(
        id: 'l1',
        tag: '0444',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      );
      final filtered = FeedEligibilityService.filterProductsForAnimals(
        [lactationOnly],
        [lactating],
      );
      expect(filtered, hasLength(1));
    });

    test('reports impacted animal tags for ineligible product', () {
      final lactationOnly = _product(
        number: 1014,
        name: 'Steamed Corn Flake',
        rules: [
          _rule(
            productionFocus: 'DAIRY',
            minAgeMonths: 12,
            lactationInclusion: 'Lactation Period',
          ),
        ],
      );
      final dry = _cow(id: 'd1', tag: '0999');
      final lactating = _cow(
        id: 'l1',
        tag: '0444',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      );
      final impacts = FeedEligibilityService.impactedAnimals(
        lactationOnly,
        [dry, lactating],
      );
      expect(impacts, hasLength(1));
      expect(impacts.first.animal.tag, '0999');
      expect(impacts.first.reason, contains('lactating'));
    });
  });

  group('FeedEligibilityService meal plans', () {
    test('flags meal with ineligible ingredient for group', () {
      final lactationOnly = _product(
        number: 1014,
        name: 'Steamed Corn Flake',
        rules: [
          _rule(
            productionFocus: 'DAIRY',
            minAgeMonths: 12,
            lactationInclusion: 'Lactation Period',
          ),
        ],
      );
      final feedItem = FeedInventoryItem(
        id: 'f1',
        name: 'Steamed Corn Flake',
        sourceType: InventorySourceType.standard,
        quantityKg: 100,
        unit: 'kg',
        feedProductNumber: 1014,
      );
      final meal = MealPlan(
        id: 'm1',
        name: 'Morning mix',
        totalKgPerBatch: 2,
        ingredients: const [
          MealIngredientLine(
            feedInventoryItemId: 'f1',
            feedItemName: 'Steamed Corn Flake',
            amountKg: 2,
          ),
        ],
      );
      final dryCow = _cow(id: 'd1', tag: '1001');
      final check = FeedEligibilityService.evaluateMealForAnimals(
        meal: meal,
        feedItems: [feedItem],
        catalog: [lactationOnly],
        animals: [dryCow],
      );
      expect(check.hasImpacts, isTrue);
      expect(check.productChecks.first.productName, 'Steamed Corn Flake');
      expect(check.allImpacts.first.animal.tag, '1001');
    });
  });

  group('FeedEligibilityService multi-rule products', () {
    test('zero rules means unrestricted eligibility', () {
      final open = _product(number: 1, name: 'Hay', rules: const []);
      final dry = _cow(id: 'd1', tag: '1001');
      final result = FeedEligibilityService.isProductEligible(
        open,
        FeedEligibilityService.contextFromAnimal(dry),
      );
      expect(result.eligible, isTrue);
      expect(result.matchedRule, isNull);
    });

    test('picks species-specific rule and dosage for cattle vs goat', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      FeedCatalogProduct? barley;
      for (final p in catalog) {
        if (p.nameEn == 'Barley- Flakes') {
          barley = p;
          break;
        }
      }
      expect(barley, isNotNull);
      expect(barley!.eligibilityRules.length, 2);

      final cow = _cow(id: 'c1', tag: '2001', ageMonths: 36);
      final goat = Animal(
        id: 'g1',
        tag: '3001',
        name: '3001',
        species: Species.goat,
        sex: 'F',
        breed: 'Boer',
        weightKg: 45,
        ageLabel: '24m',
        groupId: 'g1',
        productionPurpose: SpeciesPurpose.meat,
      );

      final cowRule = FeedEligibilityService.matchingRuleForAnimal(
        barley.eligibilityRules,
        barley.feedType,
        cow,
      );
      final goatRule = FeedEligibilityService.matchingRuleForAnimal(
        barley.eligibilityRules,
        barley.feedType,
        goat,
      );

      expect(cowRule?.speciesScope, 'CATTLE');
      expect(cowRule?.maxFeedWeightKg, 4);
      expect(goatRule?.speciesScope, 'SMALL_RUMINANT');
      expect(goatRule?.maxFeedWeightKg, 0.4);
    });

    test('Steamed Corn Flake applies dairy lactation rule with dosage', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      FeedCatalogProduct? steamed;
      for (final p in catalog) {
        if (p.nameEn == 'Steamed Corn Flake') {
          steamed = p;
          break;
        }
      }
      expect(steamed, isNotNull);
      expect(steamed!.eligibilityRules.length, 2);

      final lactating = _cow(
        id: 'l1',
        tag: '0444',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
        ageMonths: 48,
      );
      final result = FeedEligibilityService.isProductEligible(
        steamed,
        FeedEligibilityService.contextFromAnimal(lactating),
      );
      expect(result.eligible, isTrue);
      expect(result.matchedRule, isNotNull);
      expect(result.matchedRule!.productionFocus, 'DAIRY');
      expect(result.matchedRule!.lactationInclusion, contains('Lactation'));
      expect(result.matchedRule!.maxFeedWeightKg, 5);
      expect(result.matchedRule!.maxPercFeed, 50);
    });
  });

  group('Dosage caps', () {
    test('conservativePerAnimalDosageCapKg uses minimum across members', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      FeedCatalogProduct? barley;
      for (final p in catalog) {
        if (p.nameEn == 'Barley- Flakes') {
          barley = p;
          break;
        }
      }
      expect(barley, isNotNull);

      final cow = _cow(id: 'c1', tag: '2001', ageMonths: 36);
      final goat = Animal(
        id: 'g1',
        tag: '3001',
        name: '3001',
        species: Species.goat,
        sex: 'F',
        breed: 'Boer',
        weightKg: 45,
        ageLabel: '24m',
        groupId: 'g1',
        productionPurpose: SpeciesPurpose.meat,
      );

      final cap = FeedEligibilityService.conservativePerAnimalDosageCapKg(
        rules: barley!.eligibilityRules,
        feedType: barley.feedType,
        animals: [cow, goat],
      );

      expect(cap, 0.4);
    });

    test('applyDosageCapToSuggestedKg limits group total by per-animal cap',
        () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      FeedCatalogProduct? steamed;
      for (final p in catalog) {
        if (p.nameEn == 'Steamed Corn Flake') {
          steamed = p;
          break;
        }
      }
      expect(steamed, isNotNull);

      final members = [
        _cow(
          id: 'l1',
          tag: '0444',
          tags: const [AnimalTagType.lactating],
          monthsSinceCalving: 5,
          ageMonths: 48,
        ),
        _cow(
          id: 'l2',
          tag: '0445',
          tags: const [AnimalTagType.lactating],
          monthsSinceCalving: 4,
          ageMonths: 48,
        ),
      ];

      final capped = FeedEligibilityService.applyDosageCapToSuggestedKg(
        suggestedKg: 25,
        rules: steamed!.eligibilityRules,
        feedType: steamed.feedType,
        animals: members,
        estimatedDailyFeedKgPerAnimal: 20,
      );

      expect(capped, 10);
    });
  });

  group('Feed catalogue asset integration', () {
    test('Steamed Corn Flake in asset catalogue excludes dry dairy cows', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      FeedCatalogProduct? steamed;
      for (final p in catalog) {
        if (p.nameEn == 'Steamed Corn Flake') {
          steamed = p;
          break;
        }
      }
      expect(steamed, isNotNull);
      expect(steamed!.eligibilityRules, isNotEmpty);

      final dry = _cow(id: 'd1', tag: '1001');
      expect(
        FeedEligibilityService.isProductEligibleForAnimal(steamed, dry),
        isFalse,
      );

      final lactating = _cow(
        id: 'l1',
        tag: '0444',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      );
      expect(
        FeedEligibilityService.isProductEligibleForAnimal(steamed, lactating),
        isTrue,
      );
    });

    test('marketplace listings inherit eligibility from standard catalogue', () async {
      final catalog = await FeedCatalogLoader.loadStandardProducts();
      final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
      MarketplaceFeedProduct? steamedListing;
      for (final p in marketplace) {
        if (p.nameEn == 'Steamed Corn Flake') {
          steamedListing = p;
          break;
        }
      }
      expect(steamedListing, isNotNull);
      expect(steamedListing!.eligibilityRules, isNotEmpty);
      expect(steamedListing.standardProductNumber, isNotNull);

      final dry = _cow(id: 'd1', tag: '1001');
      expect(
        FeedEligibilityService.isMarketplaceProductEligibleForAnimal(
          steamedListing,
          dry,
        ),
        isFalse,
      );

      final filtered = FeedEligibilityService.filterMarketplaceProductsForAnimals(
        marketplace,
        [dry],
      );
      expect(filtered.any((p) => p.id == steamedListing!.id), isFalse);

      final feedItem = FeedInventoryItem(
        id: 'f-mp',
        name: 'Steamed Corn Flake (marketplace)',
        sourceType: InventorySourceType.marketplace,
        quantityKg: 50,
        unit: 'kg',
        marketplaceProductId: steamedListing.id,
      );
      final check = FeedEligibilityService.checkInventoryItem(
        feedItem,
        catalog: catalog,
        animals: [dry],
        marketplace: marketplace,
      );
      expect(check, isNotNull);
      expect(check!.hasImpacts, isTrue);
    });

    test('Soya Bean Meal marketplace listing links to standard Soybean meal', () async {
      final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
      MarketplaceFeedProduct? soya;
      for (final p in marketplace) {
        if (p.nameEn == 'Soya Bean Meal') {
          soya = p;
          break;
        }
      }
      expect(soya, isNotNull);
      expect(soya!.standardProductNumber, 1023);
      expect(soya.eligibilityRules, isNotEmpty);
    });
  });
}
