import '../../core/config/app_config.dart';
import '../mock/mock_data_store.dart';
import '../models/models.dart';
import '../services/finance_api_client.dart';
import '../services/finance_mapper.dart';
import '../services/finance_remote_gateway.dart';
import '../services/finance_summary_apply.dart';
import 'repositories.dart';

class HybridFinanceRepository implements FinanceRepository {
  HybridFinanceRepository({
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
  Future<FinanceSummary> getSummary() async {
    if (AppConfig.useFinanceApi) {
      try {
        final wire = await _api.getSummary(_farmId);
        final summary = FinanceMapper.summaryFromWire(wire);
        _offline.finance = summary;
        return summary;
      } catch (_) {}
    }
    return _offline.finance;
  }

  @override
  Future<void> addEntry(FinanceEntry entry) async {
    _offline.finance = applyFinanceEntry(_offline.finance, entry);
    if (AppConfig.useFinanceApi) {
      try {
        await _api.addEntry(_farmId, FinanceMapper.entryToWire(entry));
      } catch (_) {}
    }
  }
}
