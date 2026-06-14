import 'package:flutter/material.dart';

import '../../data/models/enums.dart';
import '../../data/models/feed_eligibility_models.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/feed_eligibility_service.dart';
import '../../data/services/supplement_nutrition.dart';
import '../../shared/io/local_image.dart';

enum GapSupplementSource { inventory, standard, marketplace }

class _SuggestedKgWithDosage {
  const _SuggestedKgWithDosage({
    required this.kg,
    this.uncappedKg,
    this.perAnimalDosageCapKg,
    this.groupDosageCapKg,
  });

  final double kg;
  final double? uncappedKg;
  final double? perAnimalDosageCapKg;
  final double? groupDosageCapKg;

  bool get isDosageCapped =>
      uncappedKg != null && uncappedKg! > kg + 0.01;
}

/// A feed option shown on the Fix the gap screen.
class GapSupplementOption {
  const GapSupplementOption({
    required this.id,
    required this.source,
    required this.name,
    required this.tag,
    required this.costLabel,
    required this.energyImpact,
    required this.ndfImpact,
    required this.proteinImpact,
    required this.suggestedKgPerDay,
    this.dryMatterPercent = 88,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
    this.isTopPick = false,
    this.inventoryItemId,
    this.catalogProductNumber,
    this.marketplaceProductId,
    this.supplierName,
    this.unitCostPerKg,
    this.perAnimalDosageCapKg,
    this.groupDosageCapKg,
    this.uncappedSuggestedKg,
    this.photoPath,
    this.catalogImageUrl,
  });

  final String id;
  final GapSupplementSource source;
  final String name;
  final String tag;
  final String costLabel;
  final String energyImpact;
  final String ndfImpact;
  final String proteinImpact;
  final double suggestedKgPerDay;
  final double dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
  final bool isTopPick;
  final String? inventoryItemId;
  final int? catalogProductNumber;
  final String? marketplaceProductId;
  final String? supplierName;
  final double? unitCostPerKg;
  /// Max kg per animal per day from matched eligibility rule, if any.
  final double? perAnimalDosageCapKg;
  /// Max kg for the whole group per day (per-animal cap × eligible head).
  final double? groupDosageCapKg;
  /// Uncapped gap-based suggestion before eligibility dosage limits.
  final double? uncappedSuggestedKg;
  /// User-uploaded inventory photo, when available.
  final String? photoPath;
  /// Catalogue image URL from standard or marketplace product data.
  final String? catalogImageUrl;

  String? get displayImagePath => resolveProductImagePath(
        userPhotoPath: photoPath,
        catalogImageUrl: catalogImageUrl,
      );

  bool get hasDosageCap => groupDosageCapKg != null;

  bool get isDosageCapped =>
      uncappedSuggestedKg != null &&
      uncappedSuggestedKg! > suggestedKgPerDay + 0.01;

  bool get createsBuyTask =>
      source == GapSupplementSource.standard ||
      source == GapSupplementSource.marketplace;

  bool get recordsToTodaysFeed => source == GapSupplementSource.inventory;

  SupplementNutritionInput nutritionInputFor(double kg) =>
      SupplementNutritionInput(
        kgAsFed: kg,
        dryMatterPercent: dryMatterPercent,
        crudeProteinPercent: crudeProteinPercent,
        nemMcalPerKg: nemMcalPerKg,
        ndfPercent: ndfPercent,
      );

  SupplementNutritionContribution contributionAt(double kg) =>
      SupplementNutrition.contribution(nutritionInputFor(kg));

  SupplementNutritionContribution get suggestedContribution =>
      contributionAt(suggestedKgPerDay);
}

class _ResolvedFeedNutrition {
  const _ResolvedFeedNutrition({
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
  });

  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
}

class GapSupplementRecommendations {
  static Future<List<GapSupplementOption>> load({
    required GapSupplementSource source,
    required NutritionGap gap,
    required Locale locale,
    required List<FeedInventoryItem> inventory,
    List<FeedRecommendation> engineRecs = const [],
    List<Animal> groupMembers = const [],
  }) async {
    return switch (source) {
      GapSupplementSource.inventory => _fromInventory(
          gap: gap,
          inventory: inventory,
          engineRecs: engineRecs,
          groupMembers: groupMembers,
        ),
      GapSupplementSource.standard => _fromStandard(
          gap: gap,
          locale: locale,
          groupMembers: groupMembers,
          inventory: inventory,
        ),
      GapSupplementSource.marketplace => _fromMarketplace(
          gap: gap,
          locale: locale,
          groupMembers: groupMembers,
          inventory: inventory,
        ),
    };
  }

  static Future<List<GapSupplementOption>> _fromInventory({
    required NutritionGap gap,
    required List<FeedInventoryItem> inventory,
    required List<FeedRecommendation> engineRecs,
    List<Animal> groupMembers = const [],
  }) async {
    final standard = await FeedCatalogLoader.loadStandardProducts();
    final eligibleStandard =
        FeedEligibilityService.filterProductsForAnimals(standard, groupMembers);
    final eligibleNumbers =
        eligibleStandard.map((p) => p.productNumber).toSet();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final eligibleMarketplace =
        FeedEligibilityService.filterMarketplaceProductsForAnimals(
      marketplace,
      groupMembers,
    );
    final eligibleMarketplaceIds =
        eligibleMarketplace.map((p) => p.id).toSet();
    final options = <GapSupplementOption>[];
    for (final item in inventory) {
      if (item.feedProductNumber != null &&
          groupMembers.isNotEmpty &&
          !eligibleNumbers.contains(item.feedProductNumber)) {
        continue;
      }
      if (item.marketplaceProductId != null &&
          groupMembers.isNotEmpty &&
          !eligibleMarketplaceIds.contains(item.marketplaceProductId)) {
        continue;
      }
      final nutrition = _resolveInventoryNutrition(
        item,
        standard: standard,
        marketplace: marketplace,
      );
      final rules = _rulesForInventoryItem(
        item,
        standard: standard,
        marketplace: marketplace,
      );
      final feedType = _feedTypeForInventoryItem(
        item,
        standard: standard,
        marketplace: marketplace,
      );
      final suggested = _suggestWithDosage(
        gap: gap,
        nem: nutrition.nemMcalPerKg,
        cp: nutrition.crudeProteinPercent,
        rules: rules,
        feedType: feedType,
        groupMembers: groupMembers,
      );
      options.add(
        _option(
          id: 'inv-${item.id}',
          source: GapSupplementSource.inventory,
          name: item.name,
          tag:
              'In inventory · ${item.quantityKg == item.quantityKg.roundToDouble() ? item.quantityKg.toInt() : item.quantityKg.toStringAsFixed(0)} ${item.unit} available',
          costLabel: item.unitCost != null
              ? '${item.unitCost!.toStringAsFixed(2)} SAR/${item.unit}'
              : '—',
          unitCostPerKg: item.unitCost,
          gap: gap,
          suggested: suggested,
          nem: nutrition.nemMcalPerKg,
          cp: nutrition.crudeProteinPercent,
          ndf: nutrition.ndfPercent,
          dm: nutrition.dryMatterPercent,
          inventoryItemId: item.id,
          photoPath: item.photoPath,
          catalogImageUrl: _catalogImageForInventoryItem(
            item,
            standard: standard,
            marketplace: marketplace,
          ),
        ),
      );
    }
    for (final rec in engineRecs) {
      if (options.any((o) => o.name == rec.name)) continue;
      final matched = _matchInventoryItem(inventory, rec.name);
      if (matched != null) {
        if (matched.feedProductNumber != null &&
            groupMembers.isNotEmpty &&
            !eligibleNumbers.contains(matched.feedProductNumber)) {
          continue;
        }
        final nutrition = _resolveInventoryNutrition(
          matched,
          standard: standard,
          marketplace: marketplace,
        );
        final rules = _rulesForInventoryItem(
          matched,
          standard: standard,
          marketplace: marketplace,
        );
        final feedType = _feedTypeForInventoryItem(
          matched,
          standard: standard,
          marketplace: marketplace,
        );
        final suggested = _suggestWithDosage(
          gap: gap,
          nem: nutrition.nemMcalPerKg,
          cp: nutrition.crudeProteinPercent,
          rules: rules,
          feedType: feedType,
          groupMembers: groupMembers,
          overrideKg: rec.kgPerDay > 0 ? rec.kgPerDay : null,
        );
        options.add(
          _option(
            id: 'eng-${rec.id}',
            source: GapSupplementSource.inventory,
            name: rec.name,
            tag: rec.supplier,
            costLabel: '${rec.costPerDay.toStringAsFixed(0)} SAR/day',
            gap: gap,
            suggested: suggested,
            nem: nutrition.nemMcalPerKg,
            cp: nutrition.crudeProteinPercent,
            ndf: nutrition.ndfPercent,
            dm: nutrition.dryMatterPercent,
            isTopPick: rec.isTopPick,
            photoPath: matched.photoPath,
            catalogImageUrl: _catalogImageForInventoryItem(
              matched,
              standard: standard,
              marketplace: marketplace,
            ),
          ),
        );
        continue;
      }
      final product = _findCatalogProduct(rec.name, standard);
      if (product != null &&
          groupMembers.isNotEmpty &&
          !eligibleNumbers.contains(product.productNumber)) {
        continue;
      }
      final catalogNutrition = _resolveCatalogNutritionByName(
        rec.name,
        standard: standard,
        marketplace: marketplace,
      );
      final rules = product?.eligibilityRules ?? const [];
      final feedType = product?.feedType ?? 'CONCENTRATE';
      final suggested = _suggestWithDosage(
        gap: gap,
        nem: catalogNutrition.nemMcalPerKg,
        cp: catalogNutrition.crudeProteinPercent,
        rules: rules,
        feedType: feedType,
        groupMembers: groupMembers,
        overrideKg: rec.kgPerDay > 0 ? rec.kgPerDay : null,
      );
      options.add(
        _option(
          id: 'eng-${rec.id}',
          source: GapSupplementSource.inventory,
          name: rec.name,
          tag: rec.supplier,
          costLabel: '${rec.costPerDay.toStringAsFixed(0)} SAR/day',
          gap: gap,
          suggested: suggested,
          nem: catalogNutrition.nemMcalPerKg,
          cp: catalogNutrition.crudeProteinPercent,
          ndf: catalogNutrition.ndfPercent,
          dm: catalogNutrition.dryMatterPercent,
          isTopPick: rec.isTopPick,
          photoPath: _inventoryPhotoForProduct(inventory, name: rec.name),
          catalogImageUrl: product?.imageUrl,
        ),
      );
    }
    return _rankAndLimit(gap, options);
  }

  static String? _inventoryPhotoForProduct(
    List<FeedInventoryItem> inventory, {
    int? feedProductNumber,
    String? marketplaceProductId,
    String? name,
  }) {
    if (feedProductNumber != null) {
      for (final item in inventory) {
        if (item.feedProductNumber == feedProductNumber) {
          return item.photoPath;
        }
      }
    }
    if (marketplaceProductId != null) {
      for (final item in inventory) {
        if (item.marketplaceProductId == marketplaceProductId) {
          return item.photoPath;
        }
      }
    }
    if (name != null) {
      return _matchInventoryItem(inventory, name)?.photoPath;
    }
    return null;
  }

  static Future<List<GapSupplementOption>> _fromStandard({
    required NutritionGap gap,
    required Locale locale,
    List<Animal> groupMembers = const [],
    List<FeedInventoryItem> inventory = const [],
  }) async {
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final eligible =
        FeedEligibilityService.filterProductsForAnimals(catalog, groupMembers);
    final options = eligible.map((p) {
      final suggested = _suggestWithDosage(
        gap: gap,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        rules: p.eligibilityRules,
        feedType: p.feedType,
        groupMembers: groupMembers,
      );
      return _option(
        id: 'std-${p.productNumber}',
        source: GapSupplementSource.standard,
        name: p.displayName(locale),
        tag: 'Greener Herd standard · ${p.feedType}',
        costLabel: p.nemMcalPerKg != null
            ? '${(p.nemMcalPerKg! * 0.9 + 0.5).toStringAsFixed(2)} SAR/kg est.'
            : 'Catalogue product',
        unitCostPerKg:
            p.nemMcalPerKg != null ? p.nemMcalPerKg! * 0.9 + 0.5 : null,
        gap: gap,
        suggested: suggested,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        ndf: p.ndfPercent,
        dm: p.dryMatterPercent,
        catalogProductNumber: p.productNumber,
        photoPath: _inventoryPhotoForProduct(
          inventory,
          feedProductNumber: p.productNumber,
          name: p.displayName(locale),
        ),
        catalogImageUrl: p.imageUrl,
      );
    }).toList();
    return _rankAndLimit(gap, options);
  }

  static Future<List<GapSupplementOption>> _fromMarketplace({
    required NutritionGap gap,
    required Locale locale,
    List<Animal> groupMembers = const [],
    List<FeedInventoryItem> inventory = const [],
  }) async {
    final products = await FeedCatalogLoader.loadMarketplaceProducts();
    final eligible = FeedEligibilityService.filterMarketplaceProductsForAnimals(
      products,
      groupMembers,
    );
    final options = eligible.map((p) {
      final suggested = _suggestWithDosage(
        gap: gap,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        rules: p.eligibilityRules,
        feedType: p.feedType,
        groupMembers: groupMembers,
      );
      return _option(
        id: 'mkt-${p.id}',
        source: GapSupplementSource.marketplace,
        name: p.displayName(locale),
        tag: '${p.supplierName} · ${p.countryCode}',
        costLabel: '${p.pricePerKg.toStringAsFixed(2)} ${p.currency}/kg',
        unitCostPerKg: p.pricePerKg,
        gap: gap,
        suggested: suggested,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        ndf: p.ndfPercent,
        dm: p.dryMatterPercent,
        marketplaceProductId: p.id,
        supplierName: p.supplierName,
        photoPath: _inventoryPhotoForProduct(
          inventory,
          marketplaceProductId: p.id,
          feedProductNumber: p.standardProductNumber,
          name: p.displayName(locale),
        ),
        catalogImageUrl: p.imageUrl,
      );
    }).toList();
    return _rankAndLimit(gap, options);
  }

  static GapSupplementOption _option({
    required String id,
    required GapSupplementSource source,
    required String name,
    required String tag,
    required String costLabel,
    required NutritionGap gap,
    required _SuggestedKgWithDosage suggested,
    double? nem,
    double? cp,
    double? ndf,
    double? dm,
    double? unitCostPerKg,
    String? inventoryItemId,
    int? catalogProductNumber,
    String? marketplaceProductId,
    String? supplierName,
    bool isTopPick = false,
    String? photoPath,
    String? catalogImageUrl,
  }) {
    final kg = suggested.kg;
    return GapSupplementOption(
      id: id,
      source: source,
      name: name,
      tag: tag,
      costLabel: costLabel,
      energyImpact: _energyImpact(gap, nem, kg),
      ndfImpact: _ndfImpact(gap, ndf, kg),
      proteinImpact: _proteinImpact(gap, cp, kg),
      suggestedKgPerDay: kg,
      dryMatterPercent: dm ?? 88,
      crudeProteinPercent: cp,
      nemMcalPerKg: nem,
      ndfPercent: ndf,
      isTopPick: isTopPick,
      inventoryItemId: inventoryItemId,
      catalogProductNumber: catalogProductNumber,
      marketplaceProductId: marketplaceProductId,
      supplierName: supplierName,
      unitCostPerKg: unitCostPerKg,
      perAnimalDosageCapKg: suggested.perAnimalDosageCapKg,
      groupDosageCapKg: suggested.groupDosageCapKg,
      uncappedSuggestedKg: suggested.uncappedKg,
      photoPath: photoPath,
      catalogImageUrl: catalogImageUrl,
    );
  }

  static List<GapSupplementOption> _rankAndLimit(
    NutritionGap gap,
    List<GapSupplementOption> options,
  ) {
    options.sort((a, b) => _score(gap, b).compareTo(_score(gap, a)));
    final limited = options.take(SupplementNutrition.maxRecommendations).toList();
    if (limited.isEmpty) return limited;
    final first = limited.first;
    limited[0] = GapSupplementOption(
      id: first.id,
      source: first.source,
      name: first.name,
      tag: first.tag,
      costLabel: first.costLabel,
      energyImpact: first.energyImpact,
      ndfImpact: first.ndfImpact,
      proteinImpact: first.proteinImpact,
      suggestedKgPerDay: first.suggestedKgPerDay,
      dryMatterPercent: first.dryMatterPercent,
      crudeProteinPercent: first.crudeProteinPercent,
      nemMcalPerKg: first.nemMcalPerKg,
      ndfPercent: first.ndfPercent,
      isTopPick: true,
      inventoryItemId: first.inventoryItemId,
      catalogProductNumber: first.catalogProductNumber,
      marketplaceProductId: first.marketplaceProductId,
      supplierName: first.supplierName,
      unitCostPerKg: first.unitCostPerKg,
      perAnimalDosageCapKg: first.perAnimalDosageCapKg,
      groupDosageCapKg: first.groupDosageCapKg,
      uncappedSuggestedKg: first.uncappedSuggestedKg,
      photoPath: first.photoPath,
      catalogImageUrl: first.catalogImageUrl,
    );
    return limited;
  }

  static String? _catalogImageForInventoryItem(
    FeedInventoryItem item, {
    required List<FeedCatalogProduct> standard,
    required List<MarketplaceFeedProduct> marketplace,
  }) {
    final feedProductNumber = item.feedProductNumber;
    if (feedProductNumber != null) {
      for (final product in standard) {
        if (product.productNumber == feedProductNumber) {
          return product.imageUrl;
        }
      }
    }
    final marketplaceProductId = item.marketplaceProductId;
    if (marketplaceProductId != null) {
      for (final product in marketplace) {
        if (product.id == marketplaceProductId) {
          return product.imageUrl;
        }
      }
    }
    return null;
  }

  static double _score(NutritionGap gap, GapSupplementOption o) {
    final nem = o.nemMcalPerKg ?? 0;
    final cp = o.crudeProteinPercent ?? 0;
    final energyShort =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    final proteinShort = gap.proteinTargetKg != null && gap.proteinActualKg != null
        ? (gap.proteinTargetKg! - gap.proteinActualKg!).clamp(0, double.infinity)
        : 0.0;
    final cpContributionPerKg = cp / 100;
    return energyShort * nem + proteinShort * cpContributionPerKg;
  }

  static double _suggestedKg(
    NutritionGap gap, {
    double? nem,
    double? cp,
  }) {
    final n = nem ?? 1.5;
    if (n <= 0) return 5;
    final energyShort =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    if (energyShort <= 0) {
      final proteinShort = gap.proteinTargetKg != null &&
              gap.proteinActualKg != null
          ? (gap.proteinTargetKg! - gap.proteinActualKg!)
              .clamp(0, double.infinity)
          : 0.0;
      if (proteinShort > 0) {
        final proteinFraction = (cp ?? 15) / 100;
        if (proteinFraction > 0) {
          return (proteinShort / proteinFraction).clamp(2, 15);
        }
      }
      return 5;
    }
    return (energyShort / n).clamp(2, 25);
  }

  static double _estimatedDailyFeedKgPerAnimal(
    NutritionGap gap,
    List<Animal> groupMembers,
  ) {
    final active =
        groupMembers.where((a) => a.status == AnimalStatus.active).length;
    if (active <= 0 || gap.dryMatterTargetKg <= 0) return 0;
    return gap.dryMatterTargetKg / active;
  }

  static _SuggestedKgWithDosage _suggestWithDosage({
    required NutritionGap gap,
    double? nem,
    double? cp,
    List<FeedEligibilityRule> rules = const [],
    String feedType = 'CONCENTRATE',
    List<Animal> groupMembers = const [],
    double? overrideKg,
  }) {
    final uncapped = overrideKg ?? _suggestedKg(gap, nem: nem, cp: cp);
    final dosageCap = groupMembers.isEmpty || rules.isEmpty
        ? null
        : FeedEligibilityService.groupFeedDosageCap(
            rules: rules,
            feedType: feedType,
            animals: groupMembers,
            estimatedDailyFeedKgPerAnimal:
                _estimatedDailyFeedKgPerAnimal(gap, groupMembers),
          );
    final capped = dosageCap != null
        ? uncapped.clamp(0, dosageCap.groupCapKg)
        : uncapped;
    return _SuggestedKgWithDosage(
      kg: capped.toDouble(),
      uncappedKg: capped < uncapped - 0.01 ? uncapped : null,
      perAnimalDosageCapKg: dosageCap?.perAnimalCapKg,
      groupDosageCapKg: dosageCap?.groupCapKg,
    );
  }

  static List<FeedEligibilityRule> _rulesForInventoryItem(
    FeedInventoryItem item, {
    required List<FeedCatalogProduct> standard,
    required List<MarketplaceFeedProduct> marketplace,
  }) {
    if (item.feedProductNumber != null) {
      for (final product in standard) {
        if (product.productNumber == item.feedProductNumber) {
          return product.eligibilityRules;
        }
      }
    }
    if (item.marketplaceProductId != null) {
      for (final product in marketplace) {
        if (product.id == item.marketplaceProductId) {
          return product.eligibilityRules;
        }
      }
    }
    return const [];
  }

  static String _feedTypeForInventoryItem(
    FeedInventoryItem item, {
    required List<FeedCatalogProduct> standard,
    required List<MarketplaceFeedProduct> marketplace,
  }) {
    if (item.feedProductNumber != null) {
      for (final product in standard) {
        if (product.productNumber == item.feedProductNumber) {
          return product.feedType;
        }
      }
    }
    if (item.marketplaceProductId != null) {
      for (final product in marketplace) {
        if (product.id == item.marketplaceProductId) {
          return product.feedType;
        }
      }
    }
    return item.feedType?.name.toUpperCase() ?? 'CONCENTRATE';
  }

  static String _energyImpact(NutritionGap gap, double? nem, double kg) {
    final shortfall =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    if (shortfall <= 0 || nem == null || nem <= 0) return '—';
    final pct = ((kg * nem) / shortfall * 100).clamp(1, 99);
    return '+${pct.toStringAsFixed(0)}%';
  }

  static String _ndfImpact(NutritionGap gap, double? ndfPercent, double kg) {
    if (gap.ndfTargetKg == null || gap.ndfActualKg == null) return '—';
    final shortfall =
        (gap.ndfTargetKg! - gap.ndfActualKg!).clamp(0, double.infinity);
    if (shortfall <= 0 || ndfPercent == null) return '—';
    final contributed = kg * (ndfPercent / 100);
    final pct = (contributed / shortfall * 100).clamp(1, 99);
    return '+${pct.toStringAsFixed(0)}%';
  }

  static String _proteinImpact(NutritionGap gap, double? cpPercent, double kg) {
    if (gap.proteinTargetKg == null || gap.proteinActualKg == null) {
      return '—';
    }
    final shortfall =
        (gap.proteinTargetKg! - gap.proteinActualKg!).clamp(0, double.infinity);
    if (shortfall <= 0 || cpPercent == null) return '—';
    final contributed = kg * (cpPercent / 100);
    final pct = (contributed / shortfall * 100).clamp(1, 99);
    return '+${pct.toStringAsFixed(0)}%';
  }

  static double? _nemFromMap(Map<String, dynamic> n) =>
      (n['nem_mcal_per_kg'] as num?)?.toDouble();

  static double? _cpFromMap(Map<String, dynamic> n) =>
      (n['crude_protein_percent'] as num?)?.toDouble();

  static double? _ndfFromMap(Map<String, dynamic> n) =>
      (n['ndf_percent'] as num?)?.toDouble();

  static double? _dmFromMap(Map<String, dynamic> n) =>
      (n['dry_matter_percent'] as num?)?.toDouble();

  static _ResolvedFeedNutrition _resolveInventoryNutrition(
    FeedInventoryItem item, {
    required List<FeedCatalogProduct> standard,
    required List<MarketplaceFeedProduct> marketplace,
  }) {
    var dm = _dmFromMap(item.customNutrition);
    var cp = _cpFromMap(item.customNutrition);
    var nem = _nemFromMap(item.customNutrition);
    var ndf = _ndfFromMap(item.customNutrition);

    if (item.feedProductNumber != null) {
      for (final product in standard) {
        if (product.productNumber == item.feedProductNumber) {
          dm ??= product.dryMatterPercent;
          cp ??= product.crudeProteinPercent;
          nem ??= product.nemMcalPerKg;
          ndf ??= product.ndfPercent;
          break;
        }
      }
    }
    if (item.marketplaceProductId != null) {
      for (final product in marketplace) {
        if (product.id == item.marketplaceProductId) {
          dm ??= product.dryMatterPercent;
          cp ??= product.crudeProteinPercent;
          nem ??= product.nemMcalPerKg;
          ndf ??= product.ndfPercent;
          break;
        }
      }
    }

    cp ??= item.feedType != null ? _defaultCpForFeedType(item.feedType!.name) : null;

    return _ResolvedFeedNutrition(
      dryMatterPercent: dm,
      crudeProteinPercent: cp,
      nemMcalPerKg: nem,
      ndfPercent: ndf,
    );
  }

  static _ResolvedFeedNutrition _resolveCatalogNutritionByName(
    String name, {
    required List<FeedCatalogProduct> standard,
    required List<MarketplaceFeedProduct> marketplace,
  }) {
    final needle = name.toLowerCase();
    for (final product in standard) {
      if (_namesMatch(needle, product.nameEn)) {
        return _ResolvedFeedNutrition(
          dryMatterPercent: product.dryMatterPercent,
          crudeProteinPercent:
              product.crudeProteinPercent ?? _defaultCpForFeedType(product.feedType),
          nemMcalPerKg: product.nemMcalPerKg,
          ndfPercent: product.ndfPercent,
        );
      }
    }
    for (final product in marketplace) {
      if (_namesMatch(needle, product.nameEn)) {
        return _ResolvedFeedNutrition(
          dryMatterPercent: product.dryMatterPercent,
          crudeProteinPercent:
              product.crudeProteinPercent ?? _defaultCpForFeedType(product.feedType),
          nemMcalPerKg: product.nemMcalPerKg,
          ndfPercent: product.ndfPercent,
        );
      }
    }
    return const _ResolvedFeedNutrition(nemMcalPerKg: 1.5, crudeProteinPercent: 9);
  }

  static FeedInventoryItem? _matchInventoryItem(
    List<FeedInventoryItem> inventory,
    String name,
  ) {
    final needle = name.toLowerCase();
    for (final item in inventory) {
      if (_namesMatch(needle, item.name)) return item;
    }
    return null;
  }

  static FeedCatalogProduct? _findCatalogProduct(
    String name,
    List<FeedCatalogProduct> catalog,
  ) {
    final needle = name.toLowerCase();
    for (final product in catalog) {
      if (_namesMatch(needle, product.nameEn)) return product;
    }
    return null;
  }

  static bool _namesMatch(String needle, String haystack) {
    final h = haystack.toLowerCase();
    final needleWords =
        needle.split(RegExp(r'[\s(]+')).where((p) => p.length > 2);
    for (final word in needleWords) {
      if (h.contains(word)) return true;
    }
    final hayWords = h.split(RegExp(r'[\s(]+')).where((p) => p.length > 2);
    for (final word in hayWords) {
      if (needle.contains(word)) return true;
    }
    return false;
  }

  static double? _defaultCpForFeedType(String feedType) {
    return switch (feedType.toUpperCase()) {
      'CONCENTRATE' => 14.0,
      'FODDER' => 9.0,
      'ADDITIVE' => 5.0,
      _ => null,
    };
  }
}
