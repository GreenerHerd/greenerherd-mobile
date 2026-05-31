import '../models/enums.dart';
import '../models/models.dart';

/// Maps `gh-api-tasks` wire records to UI [TaskItem]s.
abstract final class TaskMapper {
  static TaskItem fromWire(Map<String, dynamic> wire) {
    final status = (wire['status'] as String? ?? 'PENDING').toUpperCase();
    final dueDate = DateTime.tryParse(wire['due_date'] as String? ?? '') ??
        DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    final dueBucket = diff <= 0
        ? 'today'
        : diff == 1
            ? 'tomorrow'
            : 'week';
    final overdue = status == 'PENDING' && diff < 0;

    final taskTypeWire = (wire['task_type'] as String? ?? 'MANUAL').toUpperCase();
    final type = switch (taskTypeWire) {
      'AUTO_BREEDING' => TaskType.autoBreeding,
      'AUTO_VACCINATION' => TaskType.autoVaccination,
      'AUTO_HEALTH' => TaskType.autoHealth,
      _ => TaskType.manual,
    };

    final priority = (wire['priority'] as String? ?? '').toUpperCase();
    final tone = overdue
        ? TaskTone.error
        : priority == 'HIGH'
            ? TaskTone.warning
            : TaskTone.primary;

    final metadata = wire['metadata'];
    final meta = metadata is Map ? metadata : null;
    final iconName = meta != null
        ? (meta['icon'] as String? ?? _iconForType(taskTypeWire))
        : _iconForType(taskTypeWire);

    return TaskItem(
      id: wire['id'] as String,
      title: wire['title'] as String? ?? 'Task',
      subtitle: wire['description'] as String? ?? '',
      type: type,
      whenLabel: _whenLabel(diff, overdue),
      dueBucket: dueBucket,
      overdue: overdue,
      iconName: iconName,
      tone: tone,
      animalId: wire['animal_id'] as String?,
      groupId: wire['group_id'] as String?,
      assigneeId: wire['assigned_to'] as String?,
      actionKind: meta?['action_kind'] as String?,
      feedProductName: meta?['feed_product_name'] as String?,
      feedPurchaseSource: meta?['feed_purchase_source'] as String?,
      feedCatalogProductNumber:
          (meta?['feed_catalog_product_number'] as num?)?.toInt(),
      feedMarketplaceProductId:
          meta?['feed_marketplace_product_id'] as String?,
      feedSupplierName: meta?['feed_supplier_name'] as String?,
      feedDryMatterPercent:
          (meta?['feed_dry_matter_percent'] as num?)?.toDouble(),
      feedCrudeProteinPercent:
          (meta?['feed_crude_protein_percent'] as num?)?.toDouble(),
      feedNemMcalPerKg: (meta?['feed_nem_mcal_per_kg'] as num?)?.toDouble(),
    );
  }

  static String _whenLabel(int dayDiff, bool overdue) {
    if (overdue) return 'Overdue';
    if (dayDiff == 0) return 'Today';
    if (dayDiff == 1) return 'Tomorrow';
    if (dayDiff < 7) return 'This week';
    return 'Later';
  }

  static String _iconForType(String taskType) {
    return switch (taskType) {
      'AUTO_BREEDING' => 'baby',
      'AUTO_VACCINATION' => 'syringe',
      'AUTO_NUTRITION' => 'milk',
      _ => 'task',
    };
  }
}
