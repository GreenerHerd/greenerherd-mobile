import 'enums.dart';

/// How often a treatment is applied.
enum TreatmentFrequency {
  once,
  daily,
  weekly,
  monthly;

  String get wire => name.toUpperCase();

  static TreatmentFrequency? fromWire(String? raw) {
    if (raw == null) return null;
    return TreatmentFrequency.values.cast<TreatmentFrequency?>().firstWhere(
          (e) => e?.wire == raw.toUpperCase(),
          orElse: () => null,
        );
  }
}

/// Active medicine treatment recorded for a sick animal.
class AnimalTreatmentDetails {
  const AnimalTreatmentDetails({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.administeredBy,
    required this.administeredDate,
    this.medicineInventoryId,
    this.catalogProductNumber,
    this.milkWithdrawalDays,
    this.meatWithdrawalDays,
    this.notes,
    this.batchNumber,
    this.expiryDate,
    this.photoPath,
    this.sourceLabel,
  });

  final String medicineName;
  final String? medicineInventoryId;
  final int? catalogProductNumber;
  final String dosage;
  final TreatmentFrequency frequency;
  final String administeredBy;
  final DateTime administeredDate;
  final int? milkWithdrawalDays;
  final int? meatWithdrawalDays;
  final String? notes;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? photoPath;
  /// e.g. "Inventory", "Catalogue", "Marketplace".
  final String? sourceLabel;

  int get maxWithdrawalDays {
    final milk = milkWithdrawalDays ?? 0;
    final meat = meatWithdrawalDays ?? 0;
    return milk > meat ? milk : meat;
  }

  DateTime? milkSafeDate(Species species) {
    final days = milkWithdrawalDays;
    if (days == null || days <= 0) return null;
    final d = administeredDate;
    return DateTime(d.year, d.month, d.day).add(Duration(days: days));
  }

  DateTime? meatSafeDate(Species species) {
    final days = meatWithdrawalDays;
    if (days == null || days <= 0) return null;
    final d = administeredDate;
    return DateTime(d.year, d.month, d.day).add(Duration(days: days));
  }

  String displaySummary() {
    final parts = <String>[
      medicineName,
      if (dosage.isNotEmpty) dosage,
      _frequencyLabel(frequency),
    ];
    if (administeredBy.isNotEmpty) {
      parts.add('by $administeredBy');
    }
    return parts.join(' · ');
  }

  static String _frequencyLabel(TreatmentFrequency f) => switch (f) {
        TreatmentFrequency.once => 'once',
        TreatmentFrequency.daily => 'daily',
        TreatmentFrequency.weekly => 'weekly',
        TreatmentFrequency.monthly => 'monthly',
      };

  Map<String, dynamic> toJson() => {
        'medicine_name': medicineName,
        if (medicineInventoryId != null)
          'medicine_inventory_id': medicineInventoryId,
        if (catalogProductNumber != null)
          'catalog_product_number': catalogProductNumber,
        'dosage': dosage,
        'frequency': frequency.wire,
        'administered_by': administeredBy,
        'administered_date': administeredDate.toIso8601String(),
        if (milkWithdrawalDays != null)
          'milk_withdrawal_days': milkWithdrawalDays,
        if (meatWithdrawalDays != null)
          'meat_withdrawal_days': meatWithdrawalDays,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (batchNumber != null && batchNumber!.isNotEmpty)
          'batch_number': batchNumber,
        if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
        if (photoPath != null) 'photo_path': photoPath,
        if (sourceLabel != null) 'source_label': sourceLabel,
      };

  factory AnimalTreatmentDetails.fromJson(Map<String, dynamic> json) {
    return AnimalTreatmentDetails(
      medicineName: json['medicine_name'] as String? ?? '',
      medicineInventoryId: json['medicine_inventory_id'] as String?,
      catalogProductNumber:
          (json['catalog_product_number'] as num?)?.toInt(),
      dosage: json['dosage'] as String? ?? '',
      frequency: TreatmentFrequency.fromWire(json['frequency'] as String?) ??
          TreatmentFrequency.once,
      administeredBy: json['administered_by'] as String? ?? '',
      administeredDate: DateTime.tryParse(
            json['administered_date'] as String? ?? '',
          ) ??
          DateTime.now(),
      milkWithdrawalDays: (json['milk_withdrawal_days'] as num?)?.toInt(),
      meatWithdrawalDays: (json['meat_withdrawal_days'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      batchNumber: json['batch_number'] as String?,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.tryParse(json['expiry_date'] as String),
      photoPath: json['photo_path'] as String?,
      sourceLabel: json['source_label'] as String?,
    );
  }
}
