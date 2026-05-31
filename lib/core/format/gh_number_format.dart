import 'package:intl/intl.dart';

/// SAR and herd number formatting (comma thousands separators).
abstract final class GhNumberFormat {
  static final _int = NumberFormat('#,###', 'en');
  static final _decimal = NumberFormat('#,##0.##', 'en');
  static final _currency = NumberFormat.currency(
    locale: 'en',
    symbol: 'SAR ',
    decimalDigits: 0,
  );
  static final _currency2 = NumberFormat.currency(
    locale: 'en',
    symbol: 'SAR ',
    decimalDigits: 2,
  );

  static String formatInt(num value) => _int.format(value.round());

  static String formatAmount(num value, {int decimals = 0}) {
    if (decimals > 0) return _currency2.format(value);
    return _currency.format(value);
  }

  static String formatSignedAmount(
    num value, {
    bool income = true,
    int decimals = 0,
  }) {
    final prefix = income ? '+ ' : '− ';
    final body = decimals > 0
        ? _decimal.format(value.abs())
        : _int.format(value.abs().round());
    return '$prefix$body';
  }

  static String formatTrend(num delta) {
    final sign = delta >= 0 ? '+' : '−';
    return '$sign${delta.abs().toStringAsFixed(2)}';
  }

  /// Parses amount fields that may include commas.
  static double? parseAmount(String raw) {
    final cleaned = raw.trim().replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
