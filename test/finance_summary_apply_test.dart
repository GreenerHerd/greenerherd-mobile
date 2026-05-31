import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_finance_repository.dart';
import 'package:greenerherd_mobile/data/services/finance_remote_gateway.dart';
import 'package:greenerherd_mobile/data/services/finance_summary_apply.dart';

class _FakeFinanceGateway implements FinanceRemoteGateway {
  @override
  Future<Map<String, dynamic>> getSummary(String farmId) async => {
        'income_3mo': 0,
        'expense_3mo': 0,
        'net_3mo': 0,
        'livestock_value': 0,
        'monthly': [],
        'recent': [],
      };

  @override
  Future<Map<String, dynamic>> addEntry(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      {'id': 'e-new', ...body};

  @override
  Future<List<Map<String, dynamic>>> listPurchases(String farmId) async => [];

  @override
  Future<Map<String, dynamic>> recordPurchase(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      body;

  @override
  Future<List<Map<String, dynamic>>> listSales(String farmId) async => [];

  @override
  Future<Map<String, dynamic>> recordSale(
    String farmId,
    Map<String, dynamic> body,
  ) async =>
      body;
}

void main() {
  test('applyFinanceEntry updates expense and recent list', () {
    const summary = FinanceSummary(
      income3mo: 1000,
      expense3mo: 200,
      net3mo: 800,
      livestockValue: 50000,
      monthly: [],
      recent: [],
    );
    const entry = FinanceEntry(
      id: 'e1',
      dateLabel: '29 May',
      category: 'Feed purchase',
      type: FinanceEntryType.expense,
      amount: 150,
      description: 'Feed: Alfalfa',
    );
    final updated = applyFinanceEntry(summary, entry);
    expect(updated.expense3mo, 350);
    expect(updated.net3mo, 650);
    expect(updated.recent, [entry]);
  });

  test('HybridFinanceRepository.addEntry updates offline store immediately', () async {
    final store = MockDataStore(seedDemoHerd: true);
    final gateway = _FakeFinanceGateway();
    final repo = HybridFinanceRepository(
      offlineStore: store,
      gateway: gateway,
      farmId: 'farm-1',
    );
    const entry = FinanceEntry(
      id: 'e-feed',
      dateLabel: '29 May',
      category: 'Feed purchase',
      type: FinanceEntryType.expense,
      amount: 500,
      description: 'Feed: Barley (100 kg)',
    );
    final before = store.finance.expense3mo;
    await repo.addEntry(entry);
    expect(store.finance.expense3mo, before + 500);
    expect(store.finance.recent.first.id, 'e-feed');
  });
}
