import 'package:equatable/equatable.dart';

enum InventorySourceType { standard, marketplace, custom }

enum InventoryFeedType { fodder, concentrate, additive, custom }

class CustomNutritionInput {
  const CustomNutritionInput({
    this.feedType,
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
    this.ndfPercent,
  });

  final InventoryFeedType? feedType;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;
  final double? ndfPercent;

  Map<String, dynamic> toJson() => {
        if (feedType != null) 'feed_type': feedType!.name.toUpperCase(),
        if (dryMatterPercent != null) 'dry_matter_percent': dryMatterPercent,
        if (crudeProteinPercent != null)
          'crude_protein_percent': crudeProteinPercent,
        if (nemMcalPerKg != null) 'nem_mcal_per_kg': nemMcalPerKg,
        if (ndfPercent != null) 'ndf_percent': ndfPercent,
      };
}

class FeedInventoryItem extends Equatable {
  const FeedInventoryItem({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.quantityKg,
    required this.unit,
    this.feedProductNumber,
    this.marketplaceProductId,
    this.feedType,
    this.purchasedVolumeKg,
    this.unitCost,
    this.currency = 'SAR',
    this.supplierName,
    this.supplierPhone,
    this.supplierNotes,
    this.weeklyUsageKg = 0,
    this.reorderThresholdKg = 0,
    this.lowStock = false,
    this.weeksOfSupply,
    this.expiryDate,
    this.notes,
    this.customNutrition = const {},
    this.photoPath,
  });

  final String id;
  final String name;
  final InventorySourceType sourceType;
  final int? feedProductNumber;
  final String? marketplaceProductId;
  final InventoryFeedType? feedType;
  final double quantityKg;
  final double? purchasedVolumeKg;
  final double? unitCost;
  final String currency;
  final String? supplierName;
  final String? supplierPhone;
  final String? supplierNotes;
  final double weeklyUsageKg;
  final double reorderThresholdKg;
  final bool lowStock;
  final double? weeksOfSupply;
  final String unit;
  final String? expiryDate;
  final String? notes;
  final Map<String, dynamic> customNutrition;
  final String? photoPath;

  String get sourceLabel => switch (sourceType) {
        InventorySourceType.standard => 'Standard catalogue',
        InventorySourceType.marketplace => 'Marketplace',
        InventorySourceType.custom => 'Custom product',
      };

  factory FeedInventoryItem.fromJson(Map<String, dynamic> json) {
    return FeedInventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceType: _parseSource(json['source_type'] as String?),
      feedProductNumber: (json['feed_product_number'] as num?)?.toInt(),
      marketplaceProductId: json['marketplace_product_id'] as String?,
      feedType: _parseFeedType(json['feed_type'] as String?),
      quantityKg: (json['quantity_kg'] as num).toDouble(),
      purchasedVolumeKg: (json['purchased_volume_kg'] as num?)?.toDouble(),
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'SAR',
      supplierName: json['supplier_name'] as String?,
      supplierPhone: json['supplier_phone'] as String?,
      supplierNotes: json['supplier_notes'] as String?,
      weeklyUsageKg: (json['weekly_usage_kg'] as num?)?.toDouble() ?? 0,
      reorderThresholdKg:
          (json['reorder_threshold_kg'] as num?)?.toDouble() ?? 0,
      lowStock: json['low_stock'] == true,
      weeksOfSupply: (json['weeks_of_supply'] as num?)?.toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      expiryDate: json['expiry_date'] as String?,
      notes: json['notes'] as String?,
      customNutrition: Map<String, dynamic>.from(
        json['custom_nutrition'] as Map? ?? {},
      ),
      photoPath: json['photo_path'] as String?,
    );
  }

  static InventorySourceType _parseSource(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'STANDARD':
        return InventorySourceType.standard;
      case 'MARKETPLACE':
        return InventorySourceType.marketplace;
      default:
        return InventorySourceType.custom;
    }
  }

  static InventoryFeedType? _parseFeedType(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'FODDER':
        return InventoryFeedType.fodder;
      case 'CONCENTRATE':
        return InventoryFeedType.concentrate;
      case 'ADDITIVE':
        return InventoryFeedType.additive;
      case 'CUSTOM':
        return InventoryFeedType.custom;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id];
}

class WithdrawalPeriod {
  const WithdrawalPeriod({
    required this.species,
    required this.meatDays,
    required this.milkDays,
  });

  final String species;
  final int meatDays;
  final int milkDays;

  factory WithdrawalPeriod.fromJson(Map<String, dynamic> json) {
    return WithdrawalPeriod(
      species: json['species'] as String,
      meatDays: (json['meat_days'] as num?)?.toInt() ?? 0,
      milkDays: (json['milk_days'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'species': species,
        'meat_days': meatDays,
        'milk_days': milkDays,
      };
}

class MedicalInventoryItem extends Equatable {
  const MedicalInventoryItem({
    required this.id,
    required this.name,
    required this.medicineType,
    required this.quantity,
    required this.unit,
    this.lowStock = false,
    this.unitCost,
    this.supplierName,
    this.purpose,
    this.withdrawalPeriods = const [],
  });

  final String id;
  final String name;
  final String medicineType;
  final double quantity;
  final String unit;
  final bool lowStock;
  final double? unitCost;
  final String? supplierName;
  final String? purpose;
  final List<WithdrawalPeriod> withdrawalPeriods;

  WithdrawalPeriod? withdrawalFor(String species) {
    for (final w in withdrawalPeriods) {
      if (w.species.toLowerCase() == species.toLowerCase()) return w;
    }
    return null;
  }

  factory MedicalInventoryItem.fromJson(Map<String, dynamic> json) {
    final wps = (json['withdrawal_periods'] as List? ?? [])
        .map((e) =>
            WithdrawalPeriod.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return MedicalInventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      medicineType: json['medicine_type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      lowStock: json['low_stock'] == true,
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      supplierName: json['supplier_name'] as String?,
      purpose: json['purpose'] as String?,
      withdrawalPeriods: wps,
    );
  }

  @override
  List<Object?> get props => [id];
}

class MealIngredientLine extends Equatable {
  const MealIngredientLine({
    required this.feedInventoryItemId,
    required this.amountKg,
    required this.feedItemName,
  });

  final String feedInventoryItemId;
  final double amountKg;
  final String feedItemName;

  factory MealIngredientLine.fromJson(Map<String, dynamic> json) {
    return MealIngredientLine(
      feedInventoryItemId: json['feed_inventory_item_id'] as String,
      amountKg: (json['amount_kg'] as num).toDouble(),
      feedItemName:
          json['feed_item_name'] as String? ?? 'Feed',
    );
  }

  @override
  List<Object?> get props => [feedInventoryItemId];
}

class MealPlan extends Equatable {
  const MealPlan({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.totalKgPerBatch,
    this.description,
    this.stockWarnings = const [],
  });

  final String id;
  final String name;
  final String? description;
  final List<MealIngredientLine> ingredients;
  final double totalKgPerBatch;
  final List<MealStockWarningLine> stockWarnings;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final ings = (json['ingredients'] as List? ?? [])
        .map((e) => MealIngredientLine.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final warnings = (json['stock_warnings'] as List? ?? [])
        .map(
          (e) => MealStockWarningLine.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
    return MealPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ingredients: ings,
      totalKgPerBatch: (json['total_kg_per_batch'] as num?)?.toDouble() ??
          ings.fold(0.0, (s, i) => s + i.amountKg),
      stockWarnings: warnings,
    );
  }

  @override
  List<Object?> get props => [id];
}

class MealStockWarningLine extends Equatable {
  const MealStockWarningLine({
    required this.feedInventoryItemId,
    required this.feedItemName,
    required this.availableKg,
    required this.requestedKg,
    required this.lowStock,
    required this.insufficientForBatch,
  });

  final String feedInventoryItemId;
  final String feedItemName;
  final double availableKg;
  final double requestedKg;
  final bool lowStock;
  final bool insufficientForBatch;

  factory MealStockWarningLine.fromJson(Map<String, dynamic> json) {
    return MealStockWarningLine(
      feedInventoryItemId: json['feed_inventory_item_id'] as String,
      feedItemName: json['feed_item_name'] as String,
      availableKg: (json['available_kg'] as num).toDouble(),
      requestedKg: (json['requested_kg'] as num).toDouble(),
      lowStock: json['low_stock'] == true,
      insufficientForBatch: json['insufficient_for_batch'] == true,
    );
  }

  @override
  List<Object?> get props => [feedInventoryItemId];
}

class SetMealIngredientsResult {
  const SetMealIngredientsResult({
    required this.meal,
    required this.stockWarnings,
  });

  final MealPlan meal;
  final List<MealStockWarningLine> stockWarnings;
}

class MealIngredientInput {
  const MealIngredientInput({
    required this.feedInventoryItemId,
    required this.amountKg,
  });

  final String feedInventoryItemId;
  final double amountKg;
}

class CreateFeedInventoryInput {
  const CreateFeedInventoryInput({
    required this.name,
    required this.sourceType,
    required this.quantityKg,
    required this.purchasedVolumeKg,
    this.feedProductNumber,
    this.marketplaceProductId,
    this.feedType,
    this.unitCost,
    this.currency = 'SAR',
    this.supplierName,
    this.supplierPhone,
    this.supplierNotes,
    this.customNutrition,
    this.estimatedDailyUsageKg,
    this.notes,
    this.photoPath,
  });

  final String name;
  final InventorySourceType sourceType;
  final double quantityKg;
  final double purchasedVolumeKg;
  final int? feedProductNumber;
  final String? marketplaceProductId;
  final InventoryFeedType? feedType;
  final double? unitCost;
  final String currency;
  final String? supplierName;
  final String? supplierPhone;
  final String? supplierNotes;
  final CustomNutritionInput? customNutrition;
  final double? estimatedDailyUsageKg;
  final String? notes;
  final String? photoPath;

  Map<String, dynamic> toJson() => {
        'name': name,
        'source_type': switch (sourceType) {
          InventorySourceType.standard => 'STANDARD',
          InventorySourceType.marketplace => 'MARKETPLACE',
          InventorySourceType.custom => 'CUSTOM',
        },
        'quantity_kg': quantityKg,
        'purchased_volume_kg': purchasedVolumeKg,
        if (feedProductNumber != null) 'feed_product_number': feedProductNumber,
        if (marketplaceProductId != null)
          'marketplace_product_id': marketplaceProductId,
        if (feedType != null)
          'feed_type': switch (feedType!) {
            InventoryFeedType.fodder => 'FODDER',
            InventoryFeedType.concentrate => 'CONCENTRATE',
            InventoryFeedType.additive => 'ADDITIVE',
            InventoryFeedType.custom => 'CUSTOM',
          },
        if (unitCost != null) 'unit_cost': unitCost,
        'currency': currency,
        if (supplierName != null) 'supplier_name': supplierName,
        if (supplierPhone != null) 'supplier_phone': supplierPhone,
        if (supplierNotes != null) 'supplier_notes': supplierNotes,
        if (customNutrition != null)
          'custom_nutrition': customNutrition!.toJson(),
        if (estimatedDailyUsageKg != null)
          'estimated_daily_usage_kg': estimatedDailyUsageKg,
        if (notes != null) 'notes': notes,
        if (photoPath != null) 'photo_path': photoPath,
      };
}

/// One feeding event shown on the group nutrition "Today's feed" panel.
class TodaysFeedEntry extends Equatable {
  const TodaysFeedEntry({
    required this.id,
    required this.groupId,
    required this.recordedAt,
    required this.title,
    required this.subtitle,
    required this.costSar,
    required this.weightKg,
    this.headCount,
    this.mealTypeId,
    this.unitCostPerKg,
    this.fedIngredients = const [],
  });

  final String id;
  final String groupId;
  final DateTime recordedAt;
  final String title;
  final String subtitle;
  final double costSar;
  final double weightKg;
  final int? headCount;
  final String? mealTypeId;
  final double? unitCostPerKg;
  /// Actual kg fed per inventory item when edited on the meal detail screen.
  final List<MealIngredientLine> fedIngredients;

  /// Parses legacy subtitles like `148 kg · 6.7 kg/head`.
  static double? weightKgFromSubtitle(String subtitle) {
    final m = RegExp(r'^(\d+(?:\.\d+)?)\s*kg').firstMatch(subtitle.trim());
    return m != null ? double.tryParse(m.group(1)!) : null;
  }

  double get effectiveWeightKg =>
      weightKg > 0 ? weightKg : (weightKgFromSubtitle(subtitle) ?? 0);

  @override
  List<Object?> get props => [id, weightKg, costSar];
}
