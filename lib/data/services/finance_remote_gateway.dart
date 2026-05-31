/// Remote port for `gh-api-finance`.
abstract class FinanceRemoteGateway {
  Future<Map<String, dynamic>> getSummary(String farmId);

  Future<Map<String, dynamic>> addEntry(
    String farmId,
    Map<String, dynamic> body,
  );

  Future<List<Map<String, dynamic>>> listPurchases(String farmId);

  Future<Map<String, dynamic>> recordPurchase(
    String farmId,
    Map<String, dynamic> body,
  );

  Future<List<Map<String, dynamic>>> listSales(String farmId);

  Future<Map<String, dynamic>> recordSale(
    String farmId,
    Map<String, dynamic> body,
  );
}
