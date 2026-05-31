import '../models/enums.dart';
import '../models/models.dart';

abstract final class FinanceMapper {
  static FinanceSummary summaryFromWire(Map<String, dynamic> wire) {
    final monthly = (wire['monthly'] as List? ?? [])
        .map(
          (m) => FinanceMonth(
            label: m['label'] as String? ?? '',
            income: (m['income'] as num?)?.toDouble() ?? 0,
            expense: (m['expense'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
    final recent = (wire['recent'] as List? ?? [])
        .map((e) => entryFromWire(Map<String, dynamic>.from(e as Map)))
        .toList();
    return FinanceSummary(
      income3mo: (wire['income_3mo'] as num?)?.toDouble() ?? 0,
      expense3mo: (wire['expense_3mo'] as num?)?.toDouble() ?? 0,
      net3mo: (wire['net_3mo'] as num?)?.toDouble() ?? 0,
      livestockValue: (wire['livestock_value'] as num?)?.toDouble() ?? 0,
      monthly: monthly,
      recent: recent,
    );
  }

  static FinanceEntry entryFromWire(Map<String, dynamic> wire) {
    final typeWire = (wire['type'] as String? ?? 'EXPENSE').toUpperCase();
    return FinanceEntry(
      id: wire['id'] as String? ?? '',
      dateLabel: wire['date_label'] as String? ?? '',
      category: wire['category'] as String? ?? '',
      type: typeWire == 'INCOME'
          ? FinanceEntryType.income
          : FinanceEntryType.expense,
      amount: (wire['amount'] as num?)?.toDouble() ?? 0,
      description: wire['description'] as String? ?? '',
    );
  }

  static Map<String, dynamic> entryToWire(FinanceEntry entry) => {
        'date_label': entry.dateLabel,
        'category': entry.category,
        'type': entry.type == FinanceEntryType.income ? 'INCOME' : 'EXPENSE',
        'amount': entry.amount,
        'description': entry.description,
      };

  static PurchaseRecord purchaseFromWire(Map<String, dynamic> wire) {
    final speciesRaw = wire['species'] as String?;
    return PurchaseRecord(
      id: wire['id'] as String? ?? '',
      purchaseDate: DateTime.tryParse(wire['purchase_date'] as String? ?? '') ??
          DateTime.now(),
      totalAmount: (wire['total_amount'] as num?)?.toDouble() ?? 0,
      animalIds: (wire['animal_ids'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      supplierName: wire['supplier_name'] as String?,
      totalWeightKg: (wire['total_weight_kg'] as num?)?.toDouble(),
      species:
          speciesRaw == null ? null : _speciesFromWire(speciesRaw),
      sex: wire['sex'] as String?,
      breed: wire['breed'] as String?,
      ageRangeLabel: wire['age_range_label'] as String?,
      notes: wire['notes'] as String?,
    );
  }

  static Species? _speciesFromWire(String raw) {
    final u = raw.toUpperCase();
    for (final s in Species.values) {
      if (s.name.toUpperCase() == u) return s;
    }
    return null;
  }

  static Map<String, dynamic> purchaseToWire(PurchaseRecord record) => {
        'purchase_date': record.purchaseDate.toIso8601String().split('T').first,
        'total_amount': record.totalAmount,
        'animal_ids': record.animalIds,
        if (record.supplierName != null && record.supplierName!.isNotEmpty)
          'supplier_name': record.supplierName,
        if (record.totalWeightKg != null) 'total_weight_kg': record.totalWeightKg,
        if (record.species != null) 'species': record.species!.name,
        if (record.sex != null && record.sex!.isNotEmpty) 'sex': record.sex,
        if (record.breed != null && record.breed!.isNotEmpty) 'breed': record.breed,
        if (record.ageRangeLabel != null && record.ageRangeLabel!.isNotEmpty)
          'age_range_label': record.ageRangeLabel,
        if (record.notes != null && record.notes!.isNotEmpty) 'notes': record.notes,
      };

  static SaleRecord saleFromWire(Map<String, dynamic> wire) {
    return SaleRecord(
      id: wire['id'] as String? ?? '',
      saleDate:
          DateTime.tryParse(wire['sale_date'] as String? ?? '') ?? DateTime.now(),
      totalAmount: (wire['total_amount'] as num?)?.toDouble() ?? 0,
      animalIds: (wire['animal_ids'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      buyerName: wire['buyer_name'] as String?,
      totalWeightKg: (wire['total_weight_kg'] as num?)?.toDouble(),
      salePurpose: wire['sale_purpose'] as String?,
      notes: wire['notes'] as String?,
    );
  }

  static Map<String, dynamic> saleToWire(SaleRecord record) => {
        'sale_date': record.saleDate.toIso8601String().split('T').first,
        'total_amount': record.totalAmount,
        'animal_ids': record.animalIds,
        if (record.buyerName != null && record.buyerName!.isNotEmpty)
          'buyer_name': record.buyerName,
        if (record.totalWeightKg != null) 'total_weight_kg': record.totalWeightKg,
        if (record.salePurpose != null && record.salePurpose!.isNotEmpty)
          'sale_purpose': record.salePurpose,
        if (record.notes != null && record.notes!.isNotEmpty) 'notes': record.notes,
      };
}
