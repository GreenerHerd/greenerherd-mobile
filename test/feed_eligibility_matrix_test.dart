import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/services/feed_eligibility_service.dart';

import 'support/feed_eligibility_fixtures.dart';

void main() {
  group('Feed eligibility fixture pools', () {
    test('livestock pool covers species, sex, production, lactation, and age', () {
      final animals = EligibilityLivestockPool.animals.values.toList();
      expect(animals.map((a) => a.species).toSet(), {
        Species.cattle,
        Species.goat,
        Species.sheep,
      });
      expect(animals.where((a) => a.sex == 'M').length, greaterThanOrEqualTo(3));
      expect(animals.where((a) => a.sex == 'F').length, greaterThanOrEqualTo(6));
      expect(
        animals.map((a) => a.productionPurpose).toSet(),
        containsAll([SpeciesPurpose.milk, SpeciesPurpose.meat, SpeciesPurpose.both]),
      );
      expect(
        animals.any((a) => a.tags.contains(AnimalTagType.lactating)),
        isTrue,
      );
      expect(
        animals.any((a) => a.tags.contains(AnimalTagType.pregnant)),
        isTrue,
      );
      expect(
        animals.any((a) => a.status != AnimalStatus.active),
        isTrue,
      );
    });

    test('product pool covers zero, single, and multi-rule products', () {
      final products = EligibilityProductPool.catalog.values.toList();
      expect(products.any((p) => p.eligibilityRules.isEmpty), isTrue);
      expect(
        products.where((p) => p.eligibilityRules.length == 1).length,
        greaterThanOrEqualTo(6,
      ));
      expect(
        products.where((p) => p.eligibilityRules.length >= 2).length,
        greaterThanOrEqualTo(2),
      );
    });
  });

  group('Individual eligibility matrix', () {
    for (final productEntry in EligibilityIndividualMatrix.expectations.entries) {
      final productKey = productEntry.key;
      final product = EligibilityProductPool.catalog[productKey]!;

      for (final caseEntry in productEntry.value.entries) {
        final animalKey = caseEntry.key;
        final expectedEligible = caseEntry.value;
        final animal = EligibilityLivestockPool.animals[animalKey]!;

        test('$productKey × $animalKey → eligible=$expectedEligible', () {
          final result = FeedEligibilityService.isProductEligibleForAnimal(
            product,
            animal,
          );
          expect(
            result,
            expectedEligible,
            reason: '$productKey for $animalKey',
          );
        });
      }
    }
  });

  group('Marketplace individual eligibility matrix', () {
    for (final productEntry in EligibilityIndividualMatrix.expectations.entries) {
      final productKey = productEntry.key;
      final product = EligibilityProductPool.marketplace[productKey]!;

      for (final caseEntry in productEntry.value.entries) {
        final animalKey = caseEntry.key;
        final expectedEligible = caseEntry.value;
        final animal = EligibilityLivestockPool.animals[animalKey]!;

        test('marketplace $productKey × $animalKey → eligible=$expectedEligible',
            () {
          final result =
              FeedEligibilityService.isMarketplaceProductEligibleForAnimal(
            product,
            animal,
          );
          expect(
            result,
            expectedEligible,
            reason: 'marketplace $productKey for $animalKey',
          );
        });
      }
    }
  });

  group('Group herd filtering matrix', () {
    for (final productEntry in EligibilityGroupMatrix.filterVisible.entries) {
      final productKey = productEntry.key;
      final product = EligibilityProductPool.catalog[productKey]!;

      for (final groupEntry in productEntry.value.entries) {
        final groupKey = groupEntry.key;
        final expectVisible = groupEntry.value;
        final members = EligibilityLivestockPool.membersOf(groupKey);

        test(
          '$productKey visible for group $groupKey → $expectVisible',
          () {
            final filtered = FeedEligibilityService.filterProductsForAnimals(
              [product],
              members,
            );
            final visible = filtered.any((p) => p.productNumber == product.productNumber);
            expect(visible, expectVisible);
          },
        );
      }
    }
  });

  group('Group marketplace filtering matrix', () {
    test('mixed lactation group keeps lactation marketplace listing', () {
      final product = EligibilityProductPool.marketplace['lactation_dairy_cattle']!;
      final members =
          EligibilityLivestockPool.membersOf('mixed_lactation');
      final filtered =
          FeedEligibilityService.filterMarketplaceProductsForAnimals(
        [product],
        members,
      );
      expect(filtered, hasLength(1));
    });

    test('dry dairy group excludes lactation marketplace listing', () {
      final product = EligibilityProductPool.marketplace['lactation_dairy_cattle']!;
      final members = EligibilityLivestockPool.membersOf('dry_dairy_cows');
      final filtered =
          FeedEligibilityService.filterMarketplaceProductsForAnimals(
        [product],
        members,
      );
      expect(filtered, isEmpty);
    });
  });

  group('Matched rule dosage matrix', () {
    for (final productEntry in EligibilityDosageMatrix.expectations.entries) {
      final productKey = productEntry.key;
      final product = EligibilityProductPool.catalog[productKey]!;

      for (final doseEntry in productEntry.value.entries) {
        final animalKey = doseEntry.key;
        final expectedMaxKg = doseEntry.value;
        final animal = EligibilityLivestockPool.animals[animalKey]!;

        test('$productKey dosage for $animalKey → ${expectedMaxKg}kg max', () {
          final rule = FeedEligibilityService.matchingRuleForAnimal(
            product.eligibilityRules,
            product.feedType,
            animal,
          );
          expect(rule, isNotNull);
          expect(rule!.maxFeedWeightKg, expectedMaxKg);
        });
      }
    }
  });

  group('Impacted animals and inactive herd members', () {
    test('lactation product impacts dry cow tag in mixed group', () {
      final product = EligibilityProductPool.catalog['lactation_dairy_cattle']!;
      final members = EligibilityLivestockPool.membersOf('mixed_lactation');
      final impacts = FeedEligibilityService.impactedAnimals(product, members);
      expect(impacts.map((i) => i.animal.tag), ['1001']);
      expect(impacts.first.reason.toLowerCase(), contains('lactating'));
    });

    test('inactive animals are ignored in herd filtering', () {
      final product = EligibilityProductPool.catalog['lactation_dairy_cattle']!;
      final members = EligibilityLivestockPool.membersOf('with_inactive');
      final filtered = FeedEligibilityService.filterProductsForAnimals(
        [product],
        members,
      );
      expect(filtered, isEmpty);
    });

    test('inactive animals are ignored in impacted animals list', () {
      final product = EligibilityProductPool.catalog['unrestricted_hay']!;
      final members = EligibilityLivestockPool.membersOf('with_inactive');
      final impacts = FeedEligibilityService.impactedAnimals(product, members);
      expect(impacts, isEmpty);
    });
  });

  group('Inventory and meal checks with fixture pools', () {
    test('standard inventory item check uses product pool rules', () {
      final product = EligibilityProductPool.catalog['dry_period_cattle']!;
      final members = EligibilityLivestockPool.membersOf('mixed_lactation');
      final item = FeedInventoryItem(
        id: 'inv-dry-min',
        name: product.nameEn,
        sourceType: InventorySourceType.standard,
        quantityKg: 25,
        unit: 'kg',
        feedProductNumber: product.productNumber,
      );
      final check = FeedEligibilityService.checkInventoryItem(
        item,
        catalog: EligibilityProductPool.catalog.values.toList(),
        animals: members,
      );
      expect(check, isNotNull);
      expect(check!.impacts.map((i) => i.animal.tag), ['1044']);
    });

    test('marketplace inventory item check uses inherited rules', () {
      final mp = EligibilityProductPool.marketplace['dry_period_cattle']!;
      final members = EligibilityLivestockPool.membersOf('mixed_lactation');
      final item = FeedInventoryItem(
        id: 'inv-mp-dry',
        name: mp.nameEn,
        sourceType: InventorySourceType.marketplace,
        quantityKg: 10,
        unit: 'kg',
        marketplaceProductId: mp.id,
      );
      final check = FeedEligibilityService.checkInventoryItem(
        item,
        catalog: EligibilityProductPool.catalog.values.toList(),
        animals: members,
        marketplace: EligibilityProductPool.marketplace.values.toList(),
      );
      expect(check, isNotNull);
      expect(check!.hasImpacts, isTrue);
    });

    test('meal plan flags ineligible ingredient for small ruminant group', () {
      final product = EligibilityProductPool.catalog['cattle_min_12_months']!;
      final members = EligibilityLivestockPool.membersOf('small_ruminants');
      final feedItem = FeedInventoryItem(
        id: 'inv-grower',
        name: product.nameEn,
        sourceType: InventorySourceType.standard,
        quantityKg: 100,
        unit: 'kg',
        feedProductNumber: product.productNumber,
      );
      final meal = MealPlan(
        id: 'meal-sr',
        name: 'Grower mix',
        totalKgPerBatch: 3,
        ingredients: [
          MealIngredientLine(
            feedInventoryItemId: feedItem.id,
            feedItemName: feedItem.name,
            amountKg: 3,
          ),
        ],
      );
      final check = FeedEligibilityService.evaluateMealForAnimals(
        meal: meal,
        feedItems: [feedItem],
        catalog: EligibilityProductPool.catalog.values.toList(),
        animals: members,
      );
      expect(check.hasImpacts, isTrue);
      expect(check.allImpacts.length, 4);
    });
  });

  group('Full catalogue cross-check', () {
    test('every individual matrix case is exercised', () {
      var caseCount = 0;
      for (final productCases in EligibilityIndividualMatrix.expectations.values) {
        caseCount += productCases.length;
      }
      expect(caseCount, greaterThanOrEqualTo(50));
    });

    test('restricted count matches pool expectations for dry dairy group', () {
      final members = EligibilityLivestockPool.membersOf('dry_dairy_cows');
      final allProducts = EligibilityProductPool.catalog.values.toList();
      final restricted =
          FeedEligibilityService.restrictedProductCount(allProducts, members);
      final visible =
          FeedEligibilityService.filterProductsForAnimals(allProducts, members);
      expect(restricted + visible.length, allProducts.length);
      expect(visible.map((p) => p.nameEn), contains('Unrestricted Hay'));
      expect(visible.map((p) => p.nameEn), isNot(contains('Lactation Dairy Concentrate')));
    });
  });
}
