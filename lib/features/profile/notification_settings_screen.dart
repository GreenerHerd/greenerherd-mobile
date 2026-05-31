import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/notification_preference.dart';
import '../../shared/widgets/gh_app_bar.dart';

final _notificationPrefsProvider =
    FutureProvider<NotificationPreferencesBundle>((ref) async {
  return ref.watch(notificationPreferenceRepositoryProvider).getPreferences();
});

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _saving = false;

  Future<void> _toggleItem(
    NotificationPreferencesBundle bundle,
    NotificationPreferenceItem item,
    bool enabled,
  ) async {
    setState(() => _saving = true);
    try {
      final updated = bundle.items
          .map((i) => i.taskDefinitionId == item.taskDefinitionId
              ? i.copyWith(
                  enabled: enabled,
                  pushEnabled: enabled ? i.pushEnabled : false,
                  inAppEnabled: enabled ? i.inAppEnabled : false,
                )
              : i)
          .toList();
      await ref
          .read(notificationPreferenceRepositoryProvider)
          .updatePreferences(updated);
      ref.invalidate(_notificationPrefsProvider);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleCategory(
    NotificationPreferencesBundle bundle,
    String category,
    bool enabled,
  ) async {
    setState(() => _saving = true);
    try {
      final updated = bundle.items
          .map(
            (i) => i.category == category
                ? i.copyWith(
                    enabled: enabled,
                    pushEnabled: enabled && i.pushEnabled,
                    inAppEnabled: enabled && i.inAppEnabled,
                  )
                : i,
          )
          .toList();
      await ref
          .read(notificationPreferenceRepositoryProvider)
          .updatePreferences(updated);
      ref.invalidate(_notificationPrefsProvider);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(_notificationPrefsProvider);
    return Scaffold(
      appBar: GhAppBar(
        title: 'Notifications & tasks',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: prefs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load settings: $e')),
        data: (bundle) {
          final byCategory = <String, List<NotificationPreferenceItem>>{};
          for (final item in bundle.items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Choose which recommended tasks and reminders you receive. '
                'GreenerHerd can update these rules centrally; your choices '
                'control what appears on this farm.',
                style: TextStyle(height: 1.4),
              ),
              if (_saving) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 16),
              ...bundle.categories.map((summary) {
                final items = byCategory[summary.category] ?? [];
                final allOn = summary.enabledCount == summary.totalCount;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    initiallyExpanded: summary.category == 'Nutrition' ||
                        summary.category == 'Breeding',
                    title: Text(summary.category),
                    subtitle: Text(
                      '${summary.enabledCount} of ${summary.totalCount} enabled',
                    ),
                    trailing: Switch(
                      value: allOn,
                      onChanged: _saving
                          ? null
                          : (v) => _toggleCategory(bundle, summary.category, v),
                    ),
                    children: items
                        .map(
                          (item) => SwitchListTile(
                            title: Text(item.taskName),
                            subtitle: Text(
                              [
                                if (item.triggerEvent != null)
                                  item.triggerEvent!,
                                if (item.expandedDetail != null)
                                  item.expandedDetail!,
                              ].join('\n'),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: item.enabled,
                            onChanged: _saving
                                ? null
                                : (v) => _toggleItem(bundle, item, v),
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
