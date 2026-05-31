import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

/// Standard finance categories linked to farm operations.
abstract final class FinanceCategories {
  static const livestockPurchase = 'Livestock purchase';
  static const feedPurchase = 'Feed purchase';
  static const medicinePurchase = 'Medicine purchase';
  static const milkSale = 'Milk sale';
  static const livestockSale = 'Livestock sale';
  static const otherIncome = 'Other income';
  static const otherExpense = 'Other expense';
}

/// Posts income/expense entries when inventory, commerce, or milk flows complete.
class FinanceLedgerService {
  FinanceLedgerService(this._finance);

  final FinanceRepository _finance;
  static const _uuid = Uuid();

  Future<void> recordExpense({
    required String category,
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) return;
    await _finance.addEntry(
      FinanceEntry(
        id: _uuid.v4(),
        dateLabel: _todayLabel(),
        category: category,
        type: FinanceEntryType.expense,
        amount: amount,
        description: description,
      ),
    );
  }

  Future<void> recordIncome({
    required String category,
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) return;
    await _finance.addEntry(
      FinanceEntry(
        id: _uuid.v4(),
        dateLabel: _todayLabel(),
        category: category,
        type: FinanceEntryType.income,
        amount: amount,
        description: description,
      ),
    );
  }

  Future<void> recordFeedPurchase({
    required String productName,
    required double quantityKg,
    double? unitCostPerKg,
    String? supplierName,
  }) async {
    final total = (unitCostPerKg ?? 0) * quantityKg;
    if (total <= 0) return;
    await recordExpense(
      category: FinanceCategories.feedPurchase,
      amount: total,
      description: supplierName == null || supplierName.isEmpty
          ? 'Feed: $productName (${quantityKg.toStringAsFixed(0)} kg)'
          : 'Feed: $productName · $supplierName',
    );
  }

  Future<void> recordMedicinePurchase({
    required String productName,
    required double quantity,
    required String unit,
    double? unitCost,
    String? supplierName,
  }) async {
    final total = (unitCost ?? 0) * quantity;
    if (total <= 0) return;
    await recordExpense(
      category: FinanceCategories.medicinePurchase,
      amount: total,
      description: supplierName == null || supplierName.isEmpty
          ? 'Medicine: $productName ($quantity $unit)'
          : 'Medicine: $productName · $supplierName',
    );
  }

  Future<void> recordLivestockPurchase({
    required double totalAmount,
    required int animalCount,
    String? note,
  }) async {
    await recordExpense(
      category: FinanceCategories.livestockPurchase,
      amount: totalAmount,
      description: note ??
          'Purchased $animalCount animal${animalCount == 1 ? '' : 's'}',
    );
  }

  Future<void> recordLivestockSale({
    required double totalAmount,
    required List<String> animalTags,
    String? buyer,
    DateTime? saleDate,
    String? purpose,
  }) async {
    final tagLabel = animalTags.length == 1
        ? '#${animalTags.first}'
        : '${animalTags.length} animals';
    final parts = <String>['Sale: $tagLabel'];
    if (buyer != null && buyer.isNotEmpty) parts.add(buyer);
    if (purpose != null && purpose.isNotEmpty) parts.add(purpose);
    if (saleDate != null) {
      final d = saleDate;
      parts.add('${d.day}/${d.month}/${d.year}');
    }
    await recordIncome(
      category: FinanceCategories.livestockSale,
      amount: totalAmount,
      description: parts.join(' · '),
    );
  }

  Future<void> recordMilkSale({
    required double totalAmount,
    String? note,
  }) async {
    await recordIncome(
      category: FinanceCategories.milkSale,
      amount: totalAmount,
      description: note ?? 'Milk sale',
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }
}
