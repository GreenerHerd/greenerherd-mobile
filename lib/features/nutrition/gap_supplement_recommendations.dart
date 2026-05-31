import 'package:flutter/material.dart';

import '../../data/models/inventory_models.dart';
import '../../data/models/models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/supplement_nutrition.dart';

enum GapSupplementSource { inventory, standard, marketplace }

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

class GapSupplementRecommendations {
  static Future<List<GapSupplementOption>> load({
    required GapSupplementSource source,
    required NutritionGap gap,
    required Locale locale,
    required List<FeedInventoryItem> inventory,
    List<FeedRecommendation> engineRecs = const [],
  }) async {
    return switch (source) {
      GapSupplementSource.inventory => _fromInventory(
          gap: gap,
          inventory: inventory,
          engineRecs: engineRecs,
        ),
      GapSupplementSource.standard => _fromStandard(gap: gap, locale: locale),
      GapSupplementSource.marketplace =>
        _fromMarketplace(gap: gap, locale: locale),
    };
  }

  static Future<List<GapSupplementOption>> _fromInventory({
    required NutritionGap gap,
    required List<FeedInventoryItem> inventory,
    required List<FeedRecommendation> engineRecs,
  }) async {
    final standard = await FeedCatalogLoader.loadStandardProducts();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final options = <GapSupplementOption>[];
    for (final item in inventory) {
      final nutrition = _resolveInventoryNutrition(
        item,
        standard: standard,
        marketplace: marketplace,
      );
      final kg = _suggestedKg(gap, nem: nutrition.nemMcalPerKg);
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
          kg: kg,
          nem: nutrition.nemMcalPerKg,
          cp: nutrition.crudeProteinPercent,
          ndf: nutrition.ndfPercent,
          dm: nutrition.dryMatterPercent,
          inventoryItemId: item.id,
        ),
      );
    }
    for (final rec in engineRecs) {
      if (options.any((o) => o.name == rec.name)) continue;
      final matched = _matchInventoryItem(inventory, rec.name);
      if (matched != null) {
        final nutrition = _resolveInventoryNutrition(
          matched,
          standard: standard,
          marketplace: marketplace,
        );
        final kg =
            rec.kgPerDay > 0 ? rec.kgPerDay : _suggestedKg(gap, nem: nutrition.nemMcalPerKg);
        options.add(
          _option(
            id: 'eng-${rec.id}',
            source: GapSupplementSource.inventory,
            name: rec.name,
            tag: rec.supplier,
            costLabel: '${rec.costPerDay.toStringAsFixed(0)} SAR/day',
            gap: gap,
            kg: kg,
            nem: nutrition.nemMcalPerKg,
            cp: nutrition.crudeProteinPercent,
            ndf: nutrition.ndfPercent,
            dm: nutrition.dryMatterPercent,
            isTopPick: rec.isTopPick,
          ),
        );
        continue;
      }
      final catalogNutrition = _resolveCatalogNutritionByName(
        rec.name,
        standard: standard,
        marketplace: marketplace,
      );
      final kg = rec.kgPerDay > 0
          ? rec.kgPerDay
          : _suggestedKg(gap, nem: catalogNutrition.nemMcalPerKg);
      options.add(
        _option(
          id: 'eng-${rec.id}',
          source: GapSupplementSource.inventory,
          name: rec.name,
          tag: rec.supplier,
          costLabel: '${rec.costPerDay.toStringAsFixed(0)} SAR/day',
          gap: gap,
          kg: kg,
          nem: catalogNutrition.nemMcalPerKg,
          cp: catalogNutrition.crudeProteinPercent,
          ndf: catalogNutrition.ndfPercent,
          dm: catalogNutrition.dryMatterPercent,
          isTopPick: rec.isTopPick,
        ),
      );
    }
    return _rankAndLimit(gap, options);
  }

  static Future<List<GapSupplementOption>> _fromStandard({
    required NutritionGap gap,
    required Locale locale,
  }) async {
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final options = catalog.map((p) {
      final kg = _suggestedKg(gap, nem: p.nemMcalPerKg);
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
        kg: kg,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        ndf: p.ndfPercent,
        dm: p.dryMatterPercent,
        catalogProductNumber: p.productNumber,
      );
    }).toList();
    return _rankAndLimit(gap, options);
  }

  static Future<List<GapSupplementOption>> _fromMarketplace({
    required NutritionGap gap,
    required Locale locale,
  }) async {
    final products = await FeedCatalogLoader.loadMarketplaceProducts();
    final options = products.map((p) {
      final kg = _suggestedKg(gap, nem: p.nemMcalPerKg);
      return _option(
        id: 'mkt-${p.id}',
        source: GapSupplementSource.marketplace,
        name: p.displayName(locale),
        tag: '${p.supplierName} · ${p.countryCode}',
        costLabel: '${p.pricePerKg.toStringAsFixed(2)} ${p.currency}/kg',
        unitCostPerKg: p.pricePerKg,
        gap: gap,
        kg: kg,
        nem: p.nemMcalPerKg,
        cp: p.crudeProteinPercent ?? _defaultCpForFeedType(p.feedType),
        ndf: p.ndfPercent,
        dm: p.dryMatterPercent,
        marketplaceProductId: p.id,
        supplierName: p.supplierName,
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
    required double kg,
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
  }) {
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
    );
    return limited;
  }

  static double _score(NutritionGap gap, GapSupplementOption o) {
    final nem = o.nemMcalPerKg ?? 0;
    final energyShort =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    final proteinShort = gap.proteinTargetKg != null && gap.proteinActualKg != null
        ? (gap.proteinTargetKg! - gap.proteinActualKg!).clamp(0, double.infinity)
        : 0.0;
    return energyShort * nem + proteinShort;
  }

  static double _suggestedKg(NutritionGap gap, {double? nem}) {
    final n = nem ?? 1.5;
    if (n <= 0) return 5;
    final energyShort =
        (gap.energyTargetMj - gap.energyActualMj).clamp(0, double.infinity);
    if (energyShort <= 0) {
      final proteinShort = gap.proteinTargetKg != null &&
              gap.proteinActualKg != null
          ? (gap.proteinTargetKg! - gap.proteinActualKg!).clamp(0, double.infinity)
          : 0.0;
      if (proteinShort > 0) return (proteinShort / 0.15).clamp(2, 15);
      return 5;
    }
    return (energyShort / n).clamp(2, 25);
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
