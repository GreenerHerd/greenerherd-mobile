import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/catalog_localization.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/medicine_catalog_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MedicineCatalogLoader', () {
    test('loads full catalogue from seed SQL export', () async {
      final products = await MedicineCatalogLoader.loadProducts();
      expect(products.length, 302);

      final medicines =
          products.where((p) => p.catalogKind == 'medicine').length;
      final vaccines =
          products.where((p) => p.catalogKind == 'vaccine').length;
      expect(medicines, 202);
      expect(vaccines, 100);
    });

    test('Penicillin G has validated withdrawal from seed data', () async {
      final products = await MedicineCatalogLoader.loadProducts();
      final penicillin = products.firstWhere((p) => p.productNumber == 2001);
      expect(penicillin.nameEn, 'Penicillin G');
      expect(penicillin.names[CatalogLocales.en], 'Penicillin G');
      expect(penicillin.names[CatalogLocales.ar], isNotEmpty);
      expect(penicillin.names[CatalogLocales.fr], isNotEmpty);
      expect(penicillin.names[CatalogLocales.ur], isNotEmpty);
      expect(penicillin.purposeNames[CatalogLocales.en], isNotEmpty);
      expect(penicillin.withdrawalPeriods, isNotEmpty);

      final cattle = penicillin.withdrawalFor(Species.cattle);
      expect(cattle?.meatDays, 9);
      expect(cattle?.milkDays, 0);
    });

    test('FMD vaccine is localized and typed as VACCINE', () async {
      final products = await MedicineCatalogLoader.loadProducts();
      final fmd = products.firstWhere((p) => p.productNumber == 3001);
      expect(fmd.medicineType, 'VACCINE');
      expect(fmd.catalogKind, 'vaccine');
      expect(
        fmd.displayName(const Locale('ar')),
        contains('لقاح'),
      );
    });
  });
}
