import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/mock/mock_repositories.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/finance_ledger_service.dart';

void main() {
  const lifecycle = AnimalLifecycleService();

  Animal sampleCow({String groupId = 'g1'}) => Animal(
        id: 'cow-1',
        tag: '1001',
        name: 'Daisy',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 420,
        ageLabel: '3y',
        groupId: groupId,
      );

  group('Livestock sale lifecycle', () {
    test('markSold removes animal from group without cull', () {
      final sold = lifecycle.markSold(sampleCow());
      expect(sold.status, AnimalStatus.sold);
      expect(sold.groupId, isEmpty);
    });

    test('MockAnimalRepository batch sell clears group membership', () async {
      final store = MockDataStore(seedDemoHerd: true);
      final animals = MockAnimalRepository(store, lifecycle);
      final active = await animals.listAnimals();
      expect(active, isNotEmpty);
      final target = active.firstWhere((a) => a.groupId.isNotEmpty);
      final groupId = target.groupId;

      await animals.markSold(target.id);
      final inGroup = await animals.listAnimals(groupId: groupId);
      expect(inGroup.any((a) => a.id == target.id), isFalse);

      final stored = await animals.getAnimal(target.id);
      expect(stored?.status, AnimalStatus.sold);
      expect(stored?.groupId, isEmpty);
    });
  });

  group('Commerce records', () {
    test('MockCommerceRepository stores extended purchase metadata', () async {
      final store = MockDataStore();
      final commerce = MockCommerceRepository(store);
      await commerce.recordPurchase(
        PurchaseRecord(
          id: 'pur-1',
          purchaseDate: DateTime(2026, 1, 10),
          totalAmount: 25000,
          animalIds: ['x1', 'x2'],
          supplierName: 'Neighbour farm',
          totalWeightKg: 1100,
          species: Species.sheep,
          sex: 'Male',
          breed: 'Najdi',
          ageRangeLabel: '2-3yr',
        ),
      );
      final list = await commerce.listPurchases();
      final p = list.singleWhere((r) => r.id == 'pur-1');
      expect(p.supplierName, 'Neighbour farm');
      expect(p.totalWeightKg, 1100);
      expect(p.species, Species.sheep);
      expect(p.breed, 'Najdi');
    });

    test('MockCommerceRepository stores extended sale metadata', () async {
      final store = MockDataStore();
      final commerce = MockCommerceRepository(store);
      await commerce.recordSale(
        SaleRecord(
          id: 'sale-1',
          saleDate: DateTime(2026, 2, 5),
          totalAmount: 9000,
          animalIds: ['y1'],
          buyerName: 'Abu Dhabi buyer',
          totalWeightKg: 380,
          salePurpose: 'Export',
        ),
      );
      final list = await commerce.listSales();
      final s = list.singleWhere((r) => r.id == 'sale-1');
      expect(s.buyerName, 'Abu Dhabi buyer');
      expect(s.salePurpose, 'Export');
    });
  });

  group('FinanceLedgerService livestock entries', () {
    test('recordLivestockSale posts income for multiple tags', () async {
      final store = MockDataStore();
      final finance = MockFinanceRepository(store);
      final ledger = FinanceLedgerService(finance);
      await ledger.recordLivestockSale(
        totalAmount: 15000,
        animalTags: ['1001', '1002'],
        buyer: 'Market buyer',
        saleDate: DateTime(2026, 5, 1),
        purpose: 'Breeding',
      );
      final summary = await finance.getSummary();
      final entry = summary.recent.firstWhere(
        (e) => e.category == 'Livestock sale',
      );
      expect(entry.type, FinanceEntryType.income);
      expect(entry.amount, 15000);
      expect(entry.description, contains('2 animals'));
      expect(entry.description, contains('Market buyer'));
      expect(entry.description, contains('Breeding'));
    });

    test('recordLivestockPurchase posts expense', () async {
      final store = MockDataStore();
      final finance = MockFinanceRepository(store);
      final ledger = FinanceLedgerService(finance);
      await ledger.recordLivestockPurchase(
        totalAmount: 20000,
        animalCount: 5,
        note: 'Purchased from Al-Wafi Genetics',
      );
      final summary = await finance.getSummary();
      final entry = summary.recent.firstWhere(
        (e) => e.category == 'Livestock purchase',
      );
      expect(entry.type, FinanceEntryType.expense);
      expect(entry.amount, 20000);
      expect(entry.description, contains('Al-Wafi Genetics'));
    });

    test('recordLivestockPurchase default description includes count', () async {
      final store = MockDataStore();
      final finance = MockFinanceRepository(store);
      final ledger = FinanceLedgerService(finance);
      await ledger.recordLivestockPurchase(
        totalAmount: 5000,
        animalCount: 3,
      );
      final summary = await finance.getSummary();
      final entry = summary.recent.firstWhere(
        (e) => e.category == 'Livestock purchase',
      );
      expect(entry.description, contains('3 animals'));
    });
  });

  group('Purchase animal creation', () {
    test('createAnimal purchased adds active animal to herd', () async {
      final store = MockDataStore();
      final animals = MockAnimalRepository(store, lifecycle);
      final created = await animals.createAnimal(
        Animal(
          id: 'new-pur-1',
          tag: 'PUR-001',
          name: '',
          species: Species.goat,
          sex: 'Female',
          breed: 'Damascus',
          weightKg: 45,
          ageLabel: '7-11m',
          groupId: '',
        ),
        purchased: true,
      );
      expect(created.status, AnimalStatus.active);
      expect(created.tag, 'PUR-001');
      final listed = await animals.listAnimals(search: 'PUR-001');
      expect(listed.any((a) => a.id == created.id), isTrue);
    });
  });
}
