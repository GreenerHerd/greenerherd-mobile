import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: GhAppBar(
        title: l10n.alertsAndTasks,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<TaskItem>>(
        future: ref.watch(taskRepositoryProvider).listTasks(dueBucket: 'today'),
        builder: (context, snap) {
          final tasks = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Notifications'),
                  subtitle: Text('3 unread alerts (mock)'),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.tasksToday, style: const TextStyle(fontWeight: FontWeight.w700)),
              ...tasks.map(
                (t) => ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.subtitle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
