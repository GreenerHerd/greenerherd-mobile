import '../models/inventory_models.dart';

class MealStockWarning {
  const MealStockWarning({
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

  factory MealStockWarning.fromJson(Map<String, dynamic> json) {
    return MealStockWarning(
      feedInventoryItemId: json['feed_inventory_item_id'] as String,
      feedItemName: json['feed_item_name'] as String,
      availableKg: (json['available_kg'] as num).toDouble(),
      requestedKg: (json['requested_kg'] as num).toDouble(),
      lowStock: json['low_stock'] == true,
      insufficientForBatch: json['insufficient_for_batch'] == true,
    );
  }
}

double clampFeedQuantityKg(double quantityKg) {
  if (quantityKg.isNaN || quantityKg.isInfinite) return 0;
  return quantityKg < 0 ? 0 : quantityKg;
}

bool isFeedLowStock(double quantityKg, double reorderThresholdKg) {
  if (reorderThresholdKg <= 0) return false;
  return quantityKg <= reorderThresholdKg;
}

List<MealStockWarning> analyzeMealIngredientStock(
  List<FeedInventoryItem> feeds,
  List<MealIngredientInput> ingredients,
) {
  final warnings = <MealStockWarning>[];
  for (final ing in ingredients) {
    final matches = feeds.where((f) => f.id == ing.feedInventoryItemId);
    if (matches.isEmpty) continue;
    final feed = matches.first;
    final available = clampFeedQuantityKg(feed.quantityKg);
    final low = isFeedLowStock(available, feed.reorderThresholdKg);
    final insufficient = ing.amountKg > available;
    if (low || insufficient) {
      warnings.add(
        MealStockWarning(
          feedInventoryItemId: feed.id,
          feedItemName: feed.name,
          availableKg: available,
          requestedKg: ing.amountKg,
          lowStock: low,
          insufficientForBatch: insufficient,
        ),
      );
    }
  }
  return warnings;
}
