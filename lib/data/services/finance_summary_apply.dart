import '../models/enums.dart';
import '../models/models.dart';

/// Applies a ledger entry to an in-memory [FinanceSummary] (recent list + 3mo totals).
FinanceSummary applyFinanceEntry(FinanceSummary current, FinanceEntry entry) {
  final recent = [entry, ...current.recent];
  var income = current.income3mo;
  var expense = current.expense3mo;
  if (entry.type == FinanceEntryType.income) {
    income += entry.amount;
  } else {
    expense += entry.amount;
  }
  return FinanceSummary(
    income3mo: income,
    expense3mo: expense,
    net3mo: income - expense,
    livestockValue: current.livestockValue,
    monthly: current.monthly,
    recent: recent,
  );
}
