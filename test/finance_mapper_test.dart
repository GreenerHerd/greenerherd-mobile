import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/finance_mapper.dart';

void main() {
  test('FinanceMapper maps summary wire', () {
    final summary = FinanceMapper.summaryFromWire({
      'income_3mo': 1000,
      'expense_3mo': 400,
      'net_3mo': 600,
      'livestock_value': 50000,
      'monthly': [
        {'label': 'May', 'income': 300, 'expense': 100},
      ],
      'recent': [
        {
          'id': 'e1',
          'date_label': 'Today',
          'category': 'Milk',
          'type': 'INCOME',
          'amount': 50,
          'description': 'Sale',
        },
      ],
    });
    expect(summary.income3mo, 1000);
    expect(summary.recent.first.type, FinanceEntryType.income);
  });

  test('FinanceMapper round-trips purchase', () {
    final record = PurchaseRecord(
      id: 'p1',
      purchaseDate: DateTime(2026, 5, 1),
      totalAmount: 9000,
      animalIds: ['a1'],
      supplierName: 'Al-Wafi Genetics',
      totalWeightKg: 2400,
      species: Species.cattle,
      sex: 'Female',
      breed: 'Holstein',
      ageRangeLabel: '1-2yr',
      notes: 'Bulk heifers',
    );
    final wire = FinanceMapper.purchaseToWire(record);
    final back = FinanceMapper.purchaseFromWire({
      ...wire,
      'id': 'p1',
      'species': 'cattle',
    });
    expect(back.totalAmount, 9000);
    expect(back.animalIds, ['a1']);
    expect(back.supplierName, 'Al-Wafi Genetics');
    expect(back.totalWeightKg, 2400);
    expect(back.species, Species.cattle);
    expect(back.sex, 'Female');
    expect(back.breed, 'Holstein');
    expect(back.ageRangeLabel, '1-2yr');
    expect(back.notes, 'Bulk heifers');
  });

  test('FinanceMapper round-trips sale with buyer and purpose', () {
    final record = SaleRecord(
      id: 's1',
      saleDate: DateTime(2026, 5, 2),
      totalAmount: 4500,
      animalIds: ['a2', 'a3'],
      buyerName: 'Riyadh Livestock Co',
      totalWeightKg: 800,
      salePurpose: 'Breeding stock',
      notes: 'Paid in full',
    );
    final wire = FinanceMapper.saleToWire(record);
    final back = FinanceMapper.saleFromWire({
      ...wire,
      'id': 's1',
    });
    expect(back.totalAmount, 4500);
    expect(back.animalIds, ['a2', 'a3']);
    expect(back.buyerName, 'Riyadh Livestock Co');
    expect(back.totalWeightKg, 800);
    expect(back.salePurpose, 'Breeding stock');
    expect(back.notes, 'Paid in full');
  });

  test('FinanceMapper entry wire', () {
    const entry = FinanceEntry(
      id: '1',
      dateLabel: '8 May',
      category: 'Feed',
      type: FinanceEntryType.expense,
      amount: 200,
      description: 'Hay',
    );
    final wire = FinanceMapper.entryToWire(entry);
    expect(wire['type'], 'EXPENSE');
    expect(FinanceMapper.entryFromWire(wire).amount, 200);
  });
}
