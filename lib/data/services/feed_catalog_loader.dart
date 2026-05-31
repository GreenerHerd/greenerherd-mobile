import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/catalog_localization.dart';

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
  });

  final int productNumber;
  final String nameEn;
  final Map<String, String> names;
  final String feedType;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;

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
    this.minOrderKg,
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
    this.packSizeKg,
    this.inStock = true,
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
  final double? minOrderKg;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;
  final double? packSizeKg;
  final bool inStock;

  String displayName(Locale locale) {
    if (locale.languageCode == 'ar' && nameAr.isNotEmpty) return nameAr;
    return nameEn;
  }

  factory MarketplaceFeedProduct.fromJson(Map<String, dynamic> json) {
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
      minOrderKg: (json['min_order_kg'] as num?)?.toDouble(),
      dryMatterPercent: (json['dm_percent'] as num?)?.toDouble(),
      crudeProteinPercent: (json['cp_percent'] as num?)?.toDouble(),
      nemMcalPerKg: (json['nem_mcal_kg'] as num?)?.toDouble(),
      ndfPercent: (json['ndf_percent'] as num?)?.toDouble(),
      packSizeKg: (json['pack_size_kg'] as num?)?.toDouble(),
      inStock: json['in_stock'] as bool? ?? true,
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
      return FeedCatalogProduct(
        productNumber: (map['product_number'] as num).toInt(),
        nameEn: nameEn,
        names: names,
        feedType: map['feed_type'] as String? ?? 'FODDER',
        dryMatterPercent: (map['dm_percent'] as num?)?.toDouble(),
        crudeProteinPercent: (map['cp_percent'] as num?)?.toDouble(),
        nemMcalPerKg: (map['nem_mcal_kg'] as num?)?.toDouble(),
        ndfPercent: (map['ndf_percent'] as num?)?.toDouble(),
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
    return products
        .map((p) => MarketplaceFeedProduct.fromJson(
            Map<String, dynamic>.from(p as Map)))
        .where((p) => p.countryCode == countryCode)
        .toList();
  }
}
