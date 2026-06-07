import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/catalog_localization.dart';
import '../models/enums.dart';
import '../models/inventory_models.dart';

class MedicineCatalogProduct {
  const MedicineCatalogProduct({
    required this.productNumber,
    required this.nameEn,
    required this.names,
    required this.medicineType,
    this.purpose,
    this.purposeNames = const {},
    this.defaultUnit = 'dose',
    this.withdrawalPeriods = const [],
    this.catalogKind = 'medicine',
    this.activeIngredient,
    this.dosage,
    this.routeOfAdministration,
    this.requiresVetPrescription = false,
  });

  final int productNumber;
  final String nameEn;
  final Map<String, String> names;
  final String medicineType;
  final String? purpose;
  final Map<String, String> purposeNames;
  final String defaultUnit;
  final List<WithdrawalPeriod> withdrawalPeriods;
  final String catalogKind;
  final String? activeIngredient;
  final String? dosage;
  final String? routeOfAdministration;
  final bool requiresVetPrescription;

  String displayName(Locale locale) =>
      resolveCatalogName(names, locale: locale, fallbackEn: nameEn);

  String displayPurpose(Locale locale) {
    if (purposeNames.isNotEmpty) {
      return resolveCatalogName(
        purposeNames,
        locale: locale,
        fallbackEn: purpose ?? '',
      );
    }
    return purpose ?? '';
  }

  WithdrawalPeriod? withdrawalFor(Species species) {
    final key = species.name.toLowerCase();
    for (final w in withdrawalPeriods) {
      if (w.species.toLowerCase() == key) return w;
    }
    return null;
  }
}

/// Catalogue row or an item already in farm inventory.
sealed class MedicinePickerOption {}

class MedicineCatalogOption extends MedicinePickerOption {
  MedicineCatalogOption(this.product);
  final MedicineCatalogProduct product;
}

class MedicineInventoryOption extends MedicinePickerOption {
  MedicineInventoryOption(this.item);
  final MedicalInventoryItem item;
}

abstract final class MedicineCatalogLoader {
  MedicineCatalogLoader._();

  static Future<List<MedicineCatalogProduct>>? _productsCache;

  /// When set (tests only), bypasses asset loading.
  @visibleForTesting
  static Future<List<MedicineCatalogProduct>> Function()? testLoaderOverride;

  static Future<List<MedicineCatalogProduct>> loadProducts() {
    if (testLoaderOverride != null) {
      return testLoaderOverride!();
    }
    return _productsCache ??= _loadProducts();
  }

  @visibleForTesting
  static void clearCacheForTest() {
    _productsCache = null;
    testLoaderOverride = null;
  }

  static Future<List<MedicineCatalogProduct>> _loadProducts() async {
    final raw =
        await rootBundle.loadString('assets/data/medicine_products.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final products = json['products'] as List? ?? [];
    return products.map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      final names = parseCatalogNames(map);
      final nameEn = names[CatalogLocales.en] ?? map['name_en'] as String;
      final purposeNamesRaw = map['purpose_names'];
      Map<String, String> purposeNames = {};
      if (purposeNamesRaw is Map) {
        purposeNames = purposeNamesRaw.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
        purposeNames.removeWhere((_, v) => v.isEmpty);
      }
      final wps = (map['withdrawal_periods'] as List? ?? [])
          .map(
            (e) => WithdrawalPeriod.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      return MedicineCatalogProduct(
        productNumber: (map['product_number'] as num).toInt(),
        nameEn: nameEn,
        names: names,
        medicineType: map['medicine_type'] as String? ?? 'OTHER',
        purpose: map['purpose'] as String?,
        purposeNames: purposeNames,
        defaultUnit: map['default_unit'] as String? ?? 'dose',
        withdrawalPeriods: wps,
        catalogKind: map['catalog_kind'] as String? ?? 'medicine',
        activeIngredient: map['active_ingredient'] as String?,
        dosage: map['dosage'] as String?,
        routeOfAdministration: map['route_of_administration'] as String?,
        requiresVetPrescription:
            map['requires_vet_prescription'] as bool? ?? false,
      );
    }).toList();
  }

  static List<MedicinePickerOption> buildPickerOptions({
    required List<MedicineCatalogProduct> catalogue,
    required List<MedicalInventoryItem> inventory,
  }) {
    final options = <MedicinePickerOption>[
      for (final item in inventory) MedicineInventoryOption(item),
      for (final product in catalogue) MedicineCatalogOption(product),
    ];
    return options;
  }
}
