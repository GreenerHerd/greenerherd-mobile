import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/gen/app_localizations.dart';
import 'package:greenerherd_mobile/core/theme/gh_theme.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/services/medicine_catalog_loader.dart';
import 'package:greenerherd_mobile/data/repositories/local_inventory_repository.dart';
import 'package:greenerherd_mobile/features/inventory/add_feed_screen.dart';
import 'package:greenerherd_mobile/features/inventory/add_medicine_screen.dart';
import 'package:greenerherd_mobile/features/inventory/inventory_screen.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Inventory management', () {
    late BddHarness harness;
    late LocalInventoryRepository inventory;
    late List<MedicineCatalogProduct> penicillinCatalogue;

    setUpAll(() async {
      final catalogue = await MedicineCatalogLoader.loadProducts();
      penicillinCatalogue = catalogue
          .where((product) => product.productNumber == 2001)
          .toList();
    });

    setUp(() {
      harness = BddHarness();
      inventory = LocalInventoryRepository();
      MedicineCatalogLoader.clearCacheForTest();
    });

    List<Override> inventoryOverrides() => [
          inventoryRepositoryProvider.overrideWithValue(inventory),
        ];

    Future<void> openInventoryScreen(WidgetTester tester) async {
      await harness.pumpScreen(
        tester,
        const InventoryScreen(),
        overrides: inventoryOverrides(),
      );
    }

    Future<void> openAddFeedScreen(WidgetTester tester) async {
      await harness.pumpScreen(
        tester,
        const AddFeedScreen(),
        overrides: inventoryOverrides(),
      );
    }

    bddAsyncDomainScenario(
      'Feed inventory lists seeded products with low-stock state',
      tags: ['positive'],
      body: () async {
        final feed = await inventory.listFeed();
        final alfalfa = feed.firstWhere(
          (f) => f.name == 'Alfalfa hay (mid-bloom)',
        );
        final barley = feed.firstWhere((f) => f.name == 'Barley concentrate');
        expect(alfalfa.lowStock, isTrue);
        expect(barley.lowStock, isTrue);
      },
    );

    bddDomainScenario(
      'Medical inventory lists seeded medicines',
      tags: ['positive'],
      body: () async {
        final medical = await inventory.listMedical();
        expect(
          medical.any((m) => m.name == 'Penicillin'),
          isTrue,
        );
      },
    );

    bddAsyncDomainScenario(
      'Recording feeding deducts stock and flags low items',
      tags: ['positive'],
      body: () async {
        final meals = await inventory.listMeals();
        final morning = meals.firstWhere((m) => m.name == 'Morning mix');
        final before = (await inventory.listFeed())
            .firstWhere((f) => f.name == 'Alfalfa hay (mid-bloom)')
            .quantityKg;
        final result = await inventory.recordFeeding(
          groupId: 'g1',
          mealTypeId: morning.id,
          totalWeightKg: 85,
        );
        final after = (await inventory.listFeed())
            .firstWhere((f) => f.name == 'Alfalfa hay (mid-bloom)')
            .quantityKg;
        expect(after, lessThan(before));
        expect(result.lowStockItems, isNotEmpty);
        final low = await inventory.listLowStock();
        expect(low.length, greaterThanOrEqualTo(1));
      },
    );

    bddScenario(
      'Custom feed without nutrition is rejected in the add feed form',
      tags: ['negative'],
      body: (tester) async {
        await openAddFeedScreen(tester);
        await tester.tap(
          find.descendant(
            of: find.byType(SegmentedButton<InventorySourceType>),
            matching: find.text('Custom'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Product name'),
          'Mystery mix',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Supplier name'),
          'Local mill',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Purchased volume (kg) *'),
          '100',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Unit cost (SAR/kg) *'),
          '1.50',
        );
        final saveButton = find.text('Add to inventory');
        await tester.scrollUntilVisible(
          saveButton,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        expect(
          find.text('Add at least one nutritional value (DM%, CP%, or NEm)'),
          findsOneWidget,
        );
      },
    );

    bddScenario(
      'Inventory screen shows feed tab and low-stock banner',
      tags: ['positive'],
      body: (tester) async {
        await openInventoryScreen(tester);
        expect(find.text('Alfalfa hay (mid-bloom)'), findsOneWidget);
        expect(
          find.textContaining("below one week's supply"),
          findsOneWidget,
        );
        expect(find.textContaining('SAR/kg'), findsWidgets);
      },
    );

    bddAsyncDomainScenario(
      'addFeed sets stock from purchased volume and unit cost',
      tags: ['positive'],
      body: () async {
        final added = await inventory.addFeed(
          const CreateFeedInventoryInput(
            name: 'BDD test hay',
            sourceType: InventorySourceType.custom,
            quantityKg: 250,
            purchasedVolumeKg: 250,
            unitCost: 2.5,
            supplierName: 'Test supplier',
          ),
        );
        expect(added.quantityKg, 250);
        expect(added.unitCost, 2.5);
        expect(added.purchasedVolumeKg, 250);

        final restock = await inventory.addFeed(
          const CreateFeedInventoryInput(
            name: 'BDD test hay',
            sourceType: InventorySourceType.custom,
            quantityKg: 50,
            purchasedVolumeKg: 50,
            unitCost: 2.5,
            supplierName: 'Test supplier',
          ),
        );
        expect(restock.quantityKg, 300);
      },
    );

    Future<void> openAddMedicineScreen(WidgetTester tester) async {
      MedicineCatalogLoader.testLoaderOverride = () async => penicillinCatalogue;
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...inventoryOverrides(),
          ],
          child: MaterialApp(
            theme: GhTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AddMedicineScreen(),
          ),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
            find.byType(TextField).evaluate().isNotEmpty) {
          break;
        }
      }
    }

    bddScenario(
      'Add medicine from list prefills withdrawal periods',
      tags: ['positive'],
      body: (tester) async {
        await openAddMedicineScreen(tester);
        final dropdown = find.byWidgetPredicate(
          (w) =>
              w is DropdownButtonFormField &&
              w.decoration.labelText == 'Select medicine',
        );
        expect(find.byType(TextField), findsWidgets);
        await tester.enterText(find.byType(TextField).first, 'Penicillin');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(dropdown);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.textContaining('2001 —').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.scrollUntilVisible(
          find.text('Meat (days)').first,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('9'), findsWidgets);
        final milkField = find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.labelText == 'Milk (days)',
        );
        expect(milkField, findsWidgets);
        expect(
          tester.widget<TextField>(milkField.first).controller?.text,
          isEmpty,
        );
      },
    );

    bddScenario(
      'Add feed form requires purchased volume before save',
      tags: ['positive'],
      body: (tester) async {
        await openAddFeedScreen(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Unit cost (SAR/kg) *'),
          '2.00',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Supplier name'),
          'Test supplier',
        );
        final saveButton = find.text('Add to inventory');
        await tester.scrollUntilVisible(
          saveButton,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        expect(find.text('Enter purchased volume (kg)'), findsOneWidget);
        expect(find.byType(InventoryScreen), findsNothing);
      },
    );

  });
}
