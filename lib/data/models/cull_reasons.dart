/// Structured cull / death reason: main category (type) and subcategory.
class CullReasonSelection {
  const CullReasonSelection({
    required this.type,
    required this.reason,
  });

  final String type;
  final String reason;

  String get label => '$type · $reason';
}

/// Farm cull taxonomy — type (column 1) and reason (column 2).
abstract final class CullReasonCatalog {
  static const Map<String, List<String>> entries = {
    'Health': [
      'Mastitis',
      'Lameness',
      'Downer Cow',
      'Injury',
      'Metabolic',
      'Other',
    ],
    'Fertility': [
      'Aborted',
      'Not in Calf',
      'Repeat breeder',
      'Other',
    ],
    'Performance': [
      'Age',
      'Condition',
      'Cell count',
      'Milk yield',
    ],
    'Management': [
      'Udder',
      'Surplus',
      'Meat price',
      'Other',
    ],
  };

  static List<String> get types => entries.keys.toList();

  static List<String> reasonsFor(String type) =>
      List.unmodifiable(entries[type] ?? const []);

  static const defaultSelection = CullReasonSelection(
    type: 'Management',
    reason: 'Other',
  );
}
