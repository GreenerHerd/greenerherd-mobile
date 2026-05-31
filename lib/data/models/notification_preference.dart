import 'package:equatable/equatable.dart';

class NotificationPreferenceItem extends Equatable {
  const NotificationPreferenceItem({
    required this.taskDefinitionId,
    required this.taskId,
    required this.category,
    required this.taskName,
    this.expandedDetail,
    this.triggerEvent,
    this.enabled = true,
    this.pushEnabled = true,
    this.inAppEnabled = true,
    this.defaultEnabled = true,
  });

  final String taskDefinitionId;
  final int taskId;
  final String category;
  final String taskName;
  final String? expandedDetail;
  final String? triggerEvent;
  final bool enabled;
  final bool pushEnabled;
  final bool inAppEnabled;
  final bool defaultEnabled;

  NotificationPreferenceItem copyWith({
    bool? enabled,
    bool? pushEnabled,
    bool? inAppEnabled,
  }) {
    return NotificationPreferenceItem(
      taskDefinitionId: taskDefinitionId,
      taskId: taskId,
      category: category,
      taskName: taskName,
      expandedDetail: expandedDetail,
      triggerEvent: triggerEvent,
      enabled: enabled ?? this.enabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      defaultEnabled: defaultEnabled,
    );
  }

  @override
  List<Object?> get props => [
        taskDefinitionId,
        taskId,
        category,
        taskName,
        enabled,
        pushEnabled,
        inAppEnabled,
      ];
}

class NotificationCategorySummary extends Equatable {
  const NotificationCategorySummary({
    required this.category,
    required this.enabledCount,
    required this.totalCount,
  });

  final String category;
  final int enabledCount;
  final int totalCount;

  @override
  List<Object?> get props => [category, enabledCount, totalCount];
}

class NotificationPreferencesBundle extends Equatable {
  const NotificationPreferencesBundle({
    required this.items,
    required this.categories,
  });

  final List<NotificationPreferenceItem> items;
  final List<NotificationCategorySummary> categories;

  @override
  List<Object?> get props => [items, categories];
}
