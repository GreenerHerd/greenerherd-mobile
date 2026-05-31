import '../../core/config/app_config.dart';
import '../mock/mock_data_store.dart';
import '../models/models.dart';
import '../services/finance_api_client.dart';
import '../services/finance_mapper.dart';
import '../services/finance_remote_gateway.dart';
import 'repositories.dart';

class HybridCommerceRepository implements CommerceRepository {
  HybridCommerceRepository({
    required MockDataStore offlineStore,
    FinanceRemoteGateway? gateway,
    String? farmId,
    String? bearerToken,
  })  : _offline = offlineStore,
        _farmId = farmId ?? 'farm-1',
        _api = gateway ??
            FinanceApiClient(
              baseUrl: AppConfig.financeApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            );

  final MockDataStore _offline;
  final String _farmId;
  final FinanceRemoteGateway _api;

  @override
  Future<List<PurchaseRecord>> listPurchases() async {
    if (AppConfig.useFinanceApi) {
      try {
        final rows = await _api.listPurchases(_farmId);
        final list = rows.map(FinanceMapper.purchaseFromWire).toList();
        if (list.isNotEmpty) {
          _offline.purchases
            ..clear()
            ..addAll(list);
          return list;
        }
      } catch (_) {}
    }
    return List.from(_offline.purchases);
  }

  @override
  Future<List<SaleRecord>> listSales() async {
    if (AppConfig.useFinanceApi) {
      try {
        final rows = await _api.listSales(_farmId);
        final list = rows.map(FinanceMapper.saleFromWire).toList();
        if (list.isNotEmpty) {
          _offline.sales
            ..clear()
            ..addAll(list);
          return list;
        }
      } catch (_) {}
    }
    return List.from(_offline.sales);
  }

  @override
  Future<PurchaseRecord> recordPurchase(PurchaseRecord record) async {
    if (AppConfig.useFinanceApi) {
      try {
        final wire = await _api.recordPurchase(
          _farmId,
          FinanceMapper.purchaseToWire(record),
        );
        final mapped = FinanceMapper.purchaseFromWire(wire);
        _offline.purchases.insert(0, mapped);
        return mapped;
      } catch (_) {}
    }
    _offline.purchases.add(record);
    return record;
  }

  @override
  Future<SaleRecord> recordSale(SaleRecord record) async {
    if (AppConfig.useFinanceApi) {
      try {
        final wire = await _api.recordSale(
          _farmId,
          FinanceMapper.saleToWire(record),
        );
        final mapped = FinanceMapper.saleFromWire(wire);
        _offline.sales.insert(0, mapped);
        return mapped;
      } catch (_) {}
    }
    _offline.sales.add(record);
    return record;
  }
}
