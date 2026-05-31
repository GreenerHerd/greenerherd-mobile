import '../models/enums.dart';
import '../models/feed_eligibility_models.dart';
import '../models/inventory_models.dart';
import '../models/models.dart';
import '../services/feed_catalog_loader.dart';
import 'reproduction_status_rules.dart';

/// Feed product eligibility — Dart port of `services/gh-shared/db/feed-eligibility.ts`.
abstract final class FeedEligibilityService {
  FeedEligibilityService._();

  static bool matchesSpeciesScope(String scope, String species) {
    if (scope == 'ALL') return true;
    if (scope == 'CATTLE') return species == 'CATTLE';
    if (scope == 'GOAT') return species == 'GOAT';
    if (scope == 'SHEEP') return species == 'SHEEP';
    if (scope == 'SMALL_RUMINANT') {
      return species == 'GOAT' || species == 'SHEEP';
    }
    return false;
  }

  static FeedEligibilityContext contextFromAnimal(Animal animal) {
    final species = switch (animal.species) {
      Species.cattle => 'CATTLE',
      Species.goat => 'GOAT',
      Species.sheep => 'SHEEP',
    };
    final production = switch (animal.productionPurpose) {
      SpeciesPurpose.milk => 'MILK',
      SpeciesPurpose.meat => 'MEAT',
      SpeciesPurpose.both => 'BOTH',
    };
    return FeedEligibilityContext(
      species: species,
      sex: ReproductionStatusRules.isFemaleSex(animal.sex) ? 'FEMALE' : 'MALE',
      ageMonths: ReproductionStatusRules.ageMonthsFromAnimal(animal) ?? 24,
      productionFocus: production,
      lactating: animal.tags.contains(AnimalTagType.lactating),
      pregnant: animal.tags.contains(AnimalTagType.pregnant),
    );
  }

  static FeedEligibilityResult isRuleEligible(
    FeedEligibilityRule rule,
    String feedType,
    FeedEligibilityContext ctx,
  ) {
    if (!matchesSpeciesScope(rule.speciesScope, ctx.species)) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Rule scope ${rule.speciesScope} does not include ${ctx.species}',
      );
    }

    if (ctx.feedTypes != null &&
        ctx.feedTypes!.isNotEmpty &&
        !ctx.feedTypes!.contains(feedType)) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Feed type $feedType not requested',
      );
    }

    if (rule.productionFocus == 'DAIRY') {
      if (ctx.productionFocus != 'MILK' && ctx.productionFocus != 'BOTH') {
        return const FeedEligibilityResult(
          eligible: false,
          reason: 'Rule is for dairy production only',
        );
      }
    }
    if (rule.productionFocus == 'MEAT') {
      if (ctx.productionFocus != 'MEAT' && ctx.productionFocus != 'BOTH') {
        return const FeedEligibilityResult(
          eligible: false,
          reason: 'Rule is for meat production only',
        );
      }
    }

    if (rule.sexRestriction != null &&
        ctx.sex != null &&
        rule.sexRestriction != ctx.sex) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Rule restricted to ${rule.sexRestriction} animals',
      );
    }

    if (rule.minAgeMonths != null && ctx.ageMonths < rule.minAgeMonths!) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Minimum age is ${rule.minAgeMonths} months',
      );
    }
    if (rule.maxAgeMonths != null && ctx.ageMonths > rule.maxAgeMonths!) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Maximum age is ${rule.maxAgeMonths} months',
      );
    }

    if (rule.lactationInclusion != null) {
      final needsLactation =
          RegExp(r'lactat', caseSensitive: false).hasMatch(rule.lactationInclusion!);
      if (needsLactation && !ctx.lactating) {
        return const FeedEligibilityResult(
          eligible: false,
          reason: 'Rule requires lactating animals',
        );
      }
    }

    if (rule.lactationExclusion != null && ctx.lactating) {
      return FeedEligibilityResult(
        eligible: false,
        reason: 'Excluded during: ${rule.lactationExclusion}',
      );
    }

    return FeedEligibilityResult(
      eligible: true,
      reason: 'Eligible for this herd context',
      matchedRuleNumber: rule.ruleNumber,
      matchedRule: rule,
    );
  }

  /// First rule that passes all constraints for this context, if any.
  static FeedEligibilityRule? findMatchingRule(
    List<FeedEligibilityRule> rules,
    String feedType,
    FeedEligibilityContext ctx,
  ) {
    for (final rule in rules) {
      if (isRuleEligible(rule, feedType, ctx).eligible) return rule;
    }
    return null;
  }

  static FeedEligibilityResult isProductEligible(
    FeedCatalogProduct product,
    FeedEligibilityContext ctx,
  ) =>
      isEligibleWithRules(
        product.feedType,
        product.eligibilityRules,
        ctx,
      );

  static FeedEligibilityResult isMarketplaceProductEligible(
    MarketplaceFeedProduct product,
    FeedEligibilityContext ctx,
  ) =>
      isEligibleWithRules(
        product.feedType,
        product.eligibilityRules,
        ctx,
      );

  static FeedEligibilityResult isEligibleWithRules(
    String feedType,
    List<FeedEligibilityRule> rules,
    FeedEligibilityContext ctx,
  ) {
    if (rules.isEmpty) {
      return const FeedEligibilityResult(
        eligible: true,
        reason: 'No eligibility restrictions',
      );
    }

    FeedEligibilityResult? lastFailure;
    for (final rule in rules) {
      final result = isRuleEligible(rule, feedType, ctx);
      if (result.eligible) return result;
      lastFailure = result;
    }

    return lastFailure ??
        const FeedEligibilityResult(
          eligible: false,
          reason: 'No matching eligibility rule for this herd context',
        );
  }

  static FeedEligibilityRule? matchingRuleForAnimal(
    List<FeedEligibilityRule> rules,
    String feedType,
    Animal animal,
  ) =>
      findMatchingRule(rules, feedType, contextFromAnimal(animal));

  static bool isMarketplaceProductEligibleForAnimal(
    MarketplaceFeedProduct product,
    Animal animal,
  ) =>
      isMarketplaceProductEligible(product, contextFromAnimal(animal)).eligible;

  static bool isProductEligibleForAnimal(
    FeedCatalogProduct product,
    Animal animal,
  ) =>
      isProductEligible(product, contextFromAnimal(animal)).eligible;

  /// Product is selectable when at least one animal in scope can receive it.
  static List<FeedCatalogProduct> filterProductsForAnimals(
    List<FeedCatalogProduct> products,
    List<Animal> animals,
  ) {
    if (animals.isEmpty) return products;
    final active = animals.where((a) => a.status == AnimalStatus.active);
    return products
        .where(
          (p) => active.any((a) => isProductEligibleForAnimal(p, a)),
        )
        .toList();
  }

  static List<MarketplaceFeedProduct> filterMarketplaceProductsForAnimals(
    List<MarketplaceFeedProduct> products,
    List<Animal> animals,
  ) {
    if (animals.isEmpty) return products;
    final active = animals.where((a) => a.status == AnimalStatus.active);
    return products
        .where(
          (p) => active.any((a) => isMarketplaceProductEligibleForAnimal(p, a)),
        )
        .toList();
  }

  static int restrictedMarketplaceProductCount(
    List<MarketplaceFeedProduct> products,
    List<Animal> animals,
  ) {
    if (animals.isEmpty) return 0;
    return products.length -
        filterMarketplaceProductsForAnimals(products, animals).length;
  }

  static List<FeedEligibilityAnimalImpact> impactedAnimalsForMarketplace(
    MarketplaceFeedProduct product,
    List<Animal> animals,
  ) {
    return animals
        .where((a) => a.status == AnimalStatus.active)
        .map((animal) {
          final result =
              isMarketplaceProductEligible(product, contextFromAnimal(animal));
          if (result.eligible) return null;
          return FeedEligibilityAnimalImpact(
            animal: animal,
            reason: result.reason,
          );
        })
        .whereType<FeedEligibilityAnimalImpact>()
        .toList();
  }

  static MarketplaceFeedProduct? marketplaceProductById(
    List<MarketplaceFeedProduct> marketplace,
    String productId,
  ) {
    for (final p in marketplace) {
      if (p.id == productId) return p;
    }
    return null;
  }

  static FeedEligibilityProductCheck? checkMarketplaceProduct(
    MarketplaceFeedProduct product,
    List<Animal> animals, {
    String? displayName,
  }) {
    final impacts = impactedAnimalsForMarketplace(product, animals);
    if (impacts.isEmpty) return null;
    return FeedEligibilityProductCheck(
      productNumber: product.standardProductNumber,
      productName: displayName ?? product.nameEn,
      impacts: impacts,
    );
  }

  static int restrictedProductCount(
    List<FeedCatalogProduct> products,
    List<Animal> animals,
  ) {
    if (animals.isEmpty) return 0;
    return products.length - filterProductsForAnimals(products, animals).length;
  }

  static List<FeedEligibilityAnimalImpact> impactedAnimals(
    FeedCatalogProduct product,
    List<Animal> animals,
  ) {
    return animals
        .where((a) => a.status == AnimalStatus.active)
        .map((animal) {
          final result = isProductEligible(product, contextFromAnimal(animal));
          if (result.eligible) return null;
          return FeedEligibilityAnimalImpact(
            animal: animal,
            reason: result.reason,
          );
        })
        .whereType<FeedEligibilityAnimalImpact>()
        .toList();
  }

  static FeedEligibilityProductCheck? checkInventoryItem(
    FeedInventoryItem item, {
    required List<FeedCatalogProduct> catalog,
    required List<Animal> animals,
    List<MarketplaceFeedProduct> marketplace = const [],
  }) {
    if (item.feedProductNumber != null) {
      FeedCatalogProduct? product;
      for (final p in catalog) {
        if (p.productNumber == item.feedProductNumber) {
          product = p;
          break;
        }
      }
      if (product == null) return null;
      final impacts = impactedAnimals(product, animals);
      if (impacts.isEmpty) return null;
      return FeedEligibilityProductCheck(
        productNumber: product.productNumber,
        productName: item.name,
        impacts: impacts,
      );
    }
    if (item.marketplaceProductId != null && marketplace.isNotEmpty) {
      final product =
          marketplaceProductById(marketplace, item.marketplaceProductId!);
      if (product == null) return null;
      return checkMarketplaceProduct(
        product,
        animals,
        displayName: item.name,
      );
    }
    return null;
  }

  static FeedEligibilityMealCheck evaluateMealForAnimals({
    required MealPlan meal,
    required List<FeedInventoryItem> feedItems,
    required List<FeedCatalogProduct> catalog,
    required List<Animal> animals,
    List<MarketplaceFeedProduct> marketplace = const [],
  }) {
    final checks = <FeedEligibilityProductCheck>[];
    for (final ingredient in meal.ingredients) {
      FeedInventoryItem? item;
      for (final f in feedItems) {
        if (f.id == ingredient.feedInventoryItemId) {
          item = f;
          break;
        }
      }
      if (item == null) continue;
      final check = checkInventoryItem(
        item,
        catalog: catalog,
        animals: animals,
        marketplace: marketplace,
      );
      if (check != null) checks.add(check);
    }
    return FeedEligibilityMealCheck(mealName: meal.name, productChecks: checks);
  }

  static FeedCatalogProduct? catalogProductByNumber(
    List<FeedCatalogProduct> catalog,
    int productNumber,
  ) {
    for (final p in catalog) {
      if (p.productNumber == productNumber) return p;
    }
    return null;
  }

  static String formatImpactedTags(List<FeedEligibilityAnimalImpact> impacts) {
    return impacts.map((i) => '#${i.animal.tag}').join(', ');
  }
}
