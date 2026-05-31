import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/inventory_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/features/inventory/add_feed_route_args.dart';
import 'package:greenerherd_mobile/features/tasks/task_item_extensions.dart';

void main() {
  test('buy feed task is detected by action kind', () {
    const task = TaskItem(
      id: 't1',
      title: 'Buy Alfalfa',
      subtitle: 'Standard',
      type: TaskType.manual,
      whenLabel: 'Today',
      dueBucket: 'today',
      iconName: 'wallet',
      tone: TaskTone.neutral,
      actionKind: kTaskActionBuyFeed,
    );
    expect(task.isBuyFeedInventoryTask, isTrue);
  });

  test('legacy buy feed task inferred from title', () {
    const task = TaskItem(
      id: 't2',
      title: 'Buy Barley',
      subtitle: 'Marketplace',
      type: TaskType.manual,
      whenLabel: 'Today',
      dueBucket: 'today',
      iconName: 'wallet',
      tone: TaskTone.neutral,
    );
    expect(task.isBuyFeedInventoryTask, isTrue);
    expect(task.inferredFeedProductName, 'Barley');
  });

  test('AddFeedRouteArgs maps standard catalogue product', () {
    const task = TaskItem(
      id: 'task-1',
      title: 'Buy Alfalfa hay',
      subtitle: 'standard',
      type: TaskType.manual,
      whenLabel: 'Today',
      dueBucket: 'today',
      iconName: 'wallet',
      tone: TaskTone.neutral,
      actionKind: kTaskActionBuyFeed,
      feedProductName: 'Alfalfa hay',
      feedPurchaseSource: 'standard',
      feedCatalogProductNumber: 42,
      feedDryMatterPercent: 88,
    );
    final args = AddFeedRouteArgs.fromTask(task);
    expect(args.taskId, 'task-1');
    expect(args.source, InventorySourceType.standard);
    expect(args.catalogProductNumber, 42);
    expect(args.productName, 'Alfalfa hay');
    expect(args.dryMatterPercent, 88);
  });
}
