import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../inventory/add_feed_route_args.dart';
import 'task_item_extensions.dart';
import 'tasks_screen.dart';

/// Completes a task, or opens add-feed first for buy-inventory tasks.
Future<void> handleTaskComplete(
  BuildContext context,
  WidgetRef ref,
  TaskItem task, {
  bool popSheet = true,
}) async {
  if (task.isBuyFeedInventoryTask) {
    if (popSheet && context.mounted) Navigator.pop(context);
    final ok = await context.push<bool>(
      '/inventory/add-feed',
      extra: AddFeedRouteArgs.fromTask(task),
    );
    if (ok == true) {
      invalidateTaskProviders(ref);
    }
    return;
  }

  await ref.read(taskRepositoryProvider).completeTask(task.id);
  invalidateTaskProviders(ref);
  if (popSheet && context.mounted) Navigator.pop(context);
}

void invalidateTaskProviders(WidgetRef ref) {
  ref.invalidate(tasksListProvider);
  ref.invalidate(dashboardStatsProvider);
}
