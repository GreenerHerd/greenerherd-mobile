import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_commerce_repository.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_finance_repository.dart';
import 'package:greenerherd_mobile/data/services/finance_remote_gateway.dart';

import 'support/bdd_harness.dart';

class FakeFinanceGateway implements FinanceRemoteGateway {
  FakeFinanceGateway();

  final List<Map<String, dynamic>> purchases = [];
  final List<Map<String, dynamic>> sales = [];

  @override
  Future<Map<String, dynamic>> getSummary(String farmId) async => {
        'income_3mo': 10000,
        'expense_3mo': 5000,
        'net_3mo': 5000,
        'livestock_value': 100000,
        'monthly': [
          {'label': 'May', 'income': 3000, 'expense': 1500},
        ],
        'recent': [],
      };

  @override
  Future<Map<String, dynamic>> addEntry(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      {'id': 'e-new', ...body};

  @override
  Future<List<Map<String, dynamic>>> listPurchases(String farmId) async =>
      purchases;

  @override
  Future<Map<String, dynamic>> recordPurchase(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final row = {'id': 'pr-new', ...body};
    purchases.insert(0, row);
    return row;
  }

  @override
  Future<List<Map<String, dynamic>>> listSales(String farmId) async => sales;

  @override
  Future<Map<String, dynamic>> recordSale(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final row = {'id': 'sr-new', ...body};
    sales.insert(0, row);
    return row;
  }
}

void main() {
  initBddTests();

  group('Feature: Finance API integration', () {
    late MockDataStore store;
    late FakeFinanceGateway gateway;

    setUp(() {
      store = MockDataStore(seedDemoHerd: true);
      gateway = FakeFinanceGateway();
    });

    bddAsyncDomainScenario(
      'Hybrid finance loads summary from API',
      tags: ['positive'],
      body: () async {
        final repo = HybridFinanceRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        final summary = await repo.getSummary();
        expect(summary.income3mo, 10000);
        expect(summary.net3mo, 5000);
      },
    );

    bddAsyncDomainScenario(
      'Hybrid finance addEntry updates offline expense before API sync',
      tags: ['positive'],
      body: () async {
        final repo = HybridFinanceRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        final before = store.finance.expense3mo;
        await repo.addEntry(
          const FinanceEntry(
            id: 'e-feed',
            dateLabel: '29 May',
            category: 'Feed purchase',
            type: FinanceEntryType.expense,
            amount: 250,
            description: 'Feed: Alfalfa',
          ),
        );
        expect(store.finance.expense3mo, before + 250);
        expect(store.finance.recent.first.category, 'Feed purchase');
      },
    );

    bddAsyncDomainScenario(
      'Hybrid commerce records purchase via API',
      tags: ['positive'],
      body: () async {
        final repo = HybridCommerceRepository(
          offlineStore: store,
          gateway: gateway,
          farmId: 'farm-1',
        );
        await repo.recordPurchase(
          PurchaseRecord(
            id: 'p1',
            purchaseDate: DateTime(2026, 5, 10),
            totalAmount: 7000,
            animalIds: const [],
          ),
        );
        final list = await repo.listPurchases();
        expect(list.first.totalAmount, 7000);
      },
    );
  });
}
