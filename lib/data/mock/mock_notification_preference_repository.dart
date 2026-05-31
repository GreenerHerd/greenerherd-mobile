import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/notification_preference.dart';
import '../repositories/notification_preference_repository.dart';
import 'mock_data_store.dart';

class MockNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  MockNotificationPreferenceRepository(this._store);

  final MockDataStore _store;
  static NotificationPreferencesBundle? _catalog;

  static Future<NotificationPreferencesBundle> loadCatalog() async {
    if (_catalog != null) return _catalog!;
    final raw = await rootBundle.loadString(
      'assets/data/notification_task_definitions.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final defs = (json['definitions'] as List<dynamic>)
        .where((d) => d['go_live'] == true && d['is_active'] != false)
        .cast<Map<String, dynamic>>();

    final items = defs
        .map(
          (d) => NotificationPreferenceItem(
            taskDefinitionId: d['id'] as String,
            taskId: (d['task_id'] as num).toInt(),
            category: (d['category'] as String?) ?? 'General',
            taskName: d['task_name'] as String,
            expandedDetail: d['expanded_detail'] as String?,
            triggerEvent: d['trigger_event'] as String?,
            enabled: d['default_enabled'] as bool? ?? true,
            pushEnabled: (d['channels'] as List<dynamic>? ?? [])
                .contains('PUSH'),
            inAppEnabled: (d['channels'] as List<dynamic>? ?? [])
                .contains('IN_APP'),
            defaultEnabled: d['default_enabled'] as bool? ?? true,
          ),
        )
        .toList()
      ..sort((a, b) => a.taskId.compareTo(b.taskId));

    final categoryMap = <String, NotificationCategorySummary>{};
    for (final item in items) {
      final existing = categoryMap[item.category];
      if (existing == null) {
        categoryMap[item.category] = NotificationCategorySummary(
          category: item.category,
          enabledCount: item.enabled ? 1 : 0,
          totalCount: 1,
        );
      } else {
        categoryMap[item.category] = NotificationCategorySummary(
          category: item.category,
          enabledCount: existing.enabledCount + (item.enabled ? 1 : 0),
          totalCount: existing.totalCount + 1,
        );
      }
    }

    _catalog = NotificationPreferencesBundle(
      items: items,
      categories: categoryMap.values.toList()
        ..sort((a, b) => a.category.compareTo(b.category)),
    );
    return _catalog!;
  }

  @override
  Future<NotificationPreferencesBundle> getPreferences() async {
    final catalog = await loadCatalog();
    final overrides = _store.notificationPreferenceOverrides;
    if (overrides.isEmpty) return catalog;

    final merged = catalog.items
        .map((item) => overrides[item.taskDefinitionId] ?? item)
        .toList();
    return _bundleFromItems(merged);
  }

  @override
  Future<NotificationPreferencesBundle> updatePreferences(
    List<NotificationPreferenceItem> items,
  ) async {
    _store.notificationPreferenceOverrides = {
      for (final i in items) i.taskDefinitionId: i,
    };
    return getPreferences();
  }

  NotificationPreferencesBundle _bundleFromItems(
    List<NotificationPreferenceItem> items,
  ) {
    final categoryMap = <String, NotificationCategorySummary>{};
    for (final item in items) {
      final existing = categoryMap[item.category];
      if (existing == null) {
        categoryMap[item.category] = NotificationCategorySummary(
          category: item.category,
          enabledCount: item.enabled ? 1 : 0,
          totalCount: 1,
        );
      } else {
        categoryMap[item.category] = NotificationCategorySummary(
          category: item.category,
          enabledCount: existing.enabledCount + (item.enabled ? 1 : 0),
          totalCount: existing.totalCount + 1,
        );
      }
    }
    return NotificationPreferencesBundle(
      items: items,
      categories: categoryMap.values.toList()
        ..sort((a, b) => a.category.compareTo(b.category)),
    );
  }
}
