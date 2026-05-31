import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/catalog_localization.dart';
import '../models/feed_eligibility_models.dart';

class FeedCatalogProduct {
  const FeedCatalogProduct({
    required this.productNumber,
    required this.nameEn,
    required this.names,
    required this.feedType,
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
    this.eligibilityRules = const [],
  });

  final int productNumber;
  final String nameEn;
  final Map<String, String> names;
  final String feedType;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
  final List<FeedEligibilityRule> eligibilityRules;

  String displayName(Locale locale) =>
      resolveCatalogName(names, locale: locale, fallbackEn: nameEn);
}

class MarketplaceFeedProduct {
  const MarketplaceFeedProduct({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.feedType,
    required this.supplierName,
    required this.supplierPhone,
    required this.countryCode,
    required this.currency,
    required this.pricePerKg,
    this.standardProductNumber,
    this.minOrderKg,
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
    this.packSizeKg,
    this.inStock = true,
    this.eligibilityRules = const [],
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String feedType;
  final String supplierName;
  final String supplierPhone;
  final String countryCode;
  final String currency;
  final double pricePerKg;
  final int? standardProductNumber;
  final double? minOrderKg;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
  final double? packSizeKg;
  final bool inStock;
  final List<FeedEligibilityRule> eligibilityRules;

  String displayName(Locale locale) {
    if (locale.languageCode == 'ar' && nameAr.isNotEmpty) return nameAr;
    return nameEn;
  }

  factory MarketplaceFeedProduct.fromJson(Map<String, dynamic> json) {
    final rulesRaw = json['eligibility_rules'] as List? ?? [];
    final rules = rulesRaw
        .map(
          (r) => FeedEligibilityRule.fromJson(
            Map<String, dynamic>.from(r as Map),
          ),
        )
        .toList();
    return MarketplaceFeedProduct(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String? ?? '',
      feedType: json['feed_type'] as String? ?? 'FODDER',
      supplierName: json['supplier_name'] as String,
      supplierPhone: json['supplier_phone'] as String? ?? '',
      countryCode: json['country_code'] as String,
      currency: json['currency'] as String? ?? 'SAR',
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      standardProductNumber: (json['standard_product_number'] as num?)?.toInt(),
      minOrderKg: (json['min_order_kg'] as num?)?.toDouble(),
      dryMatterPercent: (json['dm_percent'] as num?)?.toDouble(),
      crudeProteinPercent: (json['cp_percent'] as num?)?.toDouble(),
      nemMcalPerKg: (json['nem_mcal_kg'] as num?)?.toDouble(),
      ndfPercent: (json['ndf_percent'] as num?)?.toDouble(),
      packSizeKg: (json['pack_size_kg'] as num?)?.toDouble(),
      inStock: json['in_stock'] as bool? ?? true,
      eligibilityRules: rules,
    );
  }
}

class FeedCatalogLoader {
  static Future<List<FeedCatalogProduct>> loadStandardProducts() async {
    final raw = await rootBundle.loadString('assets/data/feed_products.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final products = json['products'] as List? ?? [];
    return products.map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      final names = parseCatalogNames(map);
      final nameEn = names[CatalogLocales.en] ?? map['name_en'] as String;
      final rulesRaw = map['eligibility_rules'] as List? ?? [];
      final rules = rulesRaw
          .map(
            (r) => FeedEligibilityRule.fromJson(
              Map<String, dynamic>.from(r as Map),
            ),
          )
          .toList();
      return FeedCatalogProduct(
        productNumber: (map['product_number'] as num).toInt(),
        nameEn: nameEn,
        names: names,
        feedType: map['feed_type'] as String? ?? 'FODDER',
        dryMatterPercent: (map['dm_percent'] as num?)?.toDouble(),
        crudeProteinPercent: (map['cp_percent'] as num?)?.toDouble(),
        nemMcalPerKg: (map['nem_mcal_kg'] as num?)?.toDouble(),
        ndfPercent: (map['ndf_percent'] as num?)?.toDouble(),
        eligibilityRules: rules,
      );
    }).toList();
  }

  static Future<List<MarketplaceFeedProduct>> loadMarketplaceProducts({
    String countryCode = 'SA',
  }) async {
    final raw = await rootBundle
        .loadString('assets/data/marketplace_feed_products.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final products = json['products'] as List? ?? [];
    final standard = await loadStandardProducts();
    final standardByNumber = {
      for (final p in standard) p.productNumber: p,
    };
    final standardByName = {
      for (final p in standard) _normalizeCatalogName(p.nameEn): p,
    };
    return products
        .map((p) => _enrichMarketplaceProduct(
              MarketplaceFeedProduct.fromJson(
                Map<String, dynamic>.from(p as Map),
              ),
              standardByNumber: standardByNumber,
              standardByName: standardByName,
              standard: standard,
            ))
        .where((p) => p.countryCode == countryCode)
        .toList();
  }

  static String _normalizeCatalogName(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  static const _marketplaceNameAliases = {
    'soyabeanmeal': 'soybeanmeal',
  };

  static const _stripMatchTokens = {
    'premium',
    'organic',
    'good',
    'quality',
    'riyadh',
    'jeddah',
  };

  static FeedCatalogProduct? _matchStandardByName(
    String marketplaceName,
    Map<String, FeedCatalogProduct> standardByName,
    List<FeedCatalogProduct> standard,
  ) {
    var key = _normalizeCatalogName(marketplaceName);
    key = _marketplaceNameAliases[key] ?? key;
    final exact = standardByName[key];
    if (exact != null) return exact;

    FeedCatalogProduct? best;
    var bestLen = 0;
    for (final entry in standardByName.entries) {
      final catKey = entry.key;
      if (catKey.length < 4) continue;
      if (key.contains(catKey) || catKey.contains(key)) {
        if (catKey.length > bestLen) {
          bestLen = catKey.length;
          best = entry.value;
        }
      }
    }
    if (best != null) return best;

    final tokens = marketplaceName
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length > 2 && !_stripMatchTokens.contains(t))
        .take(2)
        .toList();
    if (tokens.isEmpty) return null;

    for (final product in standard) {
      final nameTokens = product.nameEn
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((t) => t.length > 2);
      final allMatch = tokens.every(
        (token) => nameTokens.any(
          (catToken) => catToken.contains(token) || token.contains(catToken),
        ),
      );
      if (allMatch) return product;
    }
    return null;
  }

  static MarketplaceFeedProduct _enrichMarketplaceProduct(
    MarketplaceFeedProduct product, {
    required Map<int, FeedCatalogProduct> standardByNumber,
    required Map<String, FeedCatalogProduct> standardByName,
    required List<FeedCatalogProduct> standard,
  }) {
    FeedCatalogProduct? linked;
    if (product.standardProductNumber != null) {
      linked = standardByNumber[product.standardProductNumber];
    }
    linked ??= _matchStandardByName(
      product.nameEn,
      standardByName,
      standard,
    );
    if (linked == null) return product;

    final rules = product.eligibilityRules.isNotEmpty
        ? product.eligibilityRules
        : linked.eligibilityRules;

    return MarketplaceFeedProduct(
      id: product.id,
      nameEn: product.nameEn,
      nameAr: product.nameAr,
      feedType: product.feedType,
      supplierName: product.supplierName,
      supplierPhone: product.supplierPhone,
      countryCode: product.countryCode,
      currency: product.currency,
      pricePerKg: product.pricePerKg,
      standardProductNumber:
          product.standardProductNumber ?? linked.productNumber,
      minOrderKg: product.minOrderKg,
      dryMatterPercent: product.dryMatterPercent ?? linked.dryMatterPercent,
      crudeProteinPercent:
          product.crudeProteinPercent ?? linked.crudeProteinPercent,
      nemMcalPerKg: product.nemMcalPerKg ?? linked.nemMcalPerKg,
      ndfPercent: product.ndfPercent ?? linked.ndfPercent,
      packSizeKg: product.packSizeKg,
      inStock: product.inStock,
      eligibilityRules: rules,
    );
  }
}
