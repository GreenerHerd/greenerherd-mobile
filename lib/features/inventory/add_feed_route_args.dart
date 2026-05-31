import '../../data/models/inventory_models.dart';
import '../../data/models/models.dart';
import '../tasks/task_item_extensions.dart';

/// Route extra for [AddFeedScreen] when opened from a buy-feed task.
class AddFeedRouteArgs {
  const AddFeedRouteArgs({
    this.taskId,
    this.productName,
    this.source = InventorySourceType.standard,
    this.catalogProductNumber,
    this.marketplaceProductId,
    this.supplierName,
    this.dryMatterPercent,
    this.crudeProteinPercent,
    this.nemMcalPerKg,
  });

  final String? taskId;
  final String? productName;
  final InventorySourceType source;
  final int? catalogProductNumber;
  final String? marketplaceProductId;
  final String? supplierName;
  final double? dryMatterPercent;
  final double? crudeProteinPercent;
  final double? nemMcalPerKg;

  factory AddFeedRouteArgs.fromTask(TaskItem task) {
    final name = task.feedProductName ?? task.inferredFeedProductName;
    final source = switch (task.feedPurchaseSource) {
      'marketplace' => InventorySourceType.marketplace,
      'standard' => InventorySourceType.standard,
      _ => InventorySourceType.standard,
    };
    return AddFeedRouteArgs(
      taskId: task.id,
      productName: name,
      source: source,
      catalogProductNumber: task.feedCatalogProductNumber,
      marketplaceProductId: task.feedMarketplaceProductId,
      supplierName: task.feedSupplierName,
      dryMatterPercent: task.feedDryMatterPercent,
      crudeProteinPercent: task.feedCrudeProteinPercent,
      nemMcalPerKg: task.feedNemMcalPerKg,
    );
  }
}
