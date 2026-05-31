import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_bottom_sheet.dart';
import '../../shared/widgets/gh_chip.dart';
import 'task_completion.dart';
import 'task_item_extensions.dart';

final tasksListProvider = FutureProvider<List<TaskItem>>((ref) async {
  return ref.watch(taskRepositoryProvider).listTasks();
});

enum _TaskFilter { today, week, recurring, all }

void showNewTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  String? animalId,
  String? groupId,
  String? animalTag,
  String? animalName,
}) {
  final l10n = context.l10n;
  final titleCtrl = TextEditingController();
  final defaultTitle = animalName != null && animalName.isNotEmpty
      ? '$animalName · check'
      : animalTag != null
          ? '#$animalTag · check'
          : '';
  if (defaultTitle.isNotEmpty) {
    titleCtrl.text = defaultTitle;
  }

  String subtitle() {
    if (animalTag != null) {
      return 'Animal #$animalTag';
    }
    return l10n.addedManually;
  }

  GhBottomSheet.show(
    context,
    title: l10n.newTask,
    child: TextField(
      controller: titleCtrl,
      decoration: InputDecoration(labelText: l10n.taskTitle),
      autofocus: true,
    ),
    footer: FilledButton(
      onPressed: () async {
        final title = titleCtrl.text.trim();
        if (title.isEmpty) return;
        await ref.read(taskRepositoryProvider).addTask(
              TaskItem(
                id: 't-${DateTime.now().millisecondsSinceEpoch}',
                title: title,
                subtitle: subtitle(),
                whenLabel: l10n.today,
                dueBucket: 'today',
                overdue: false,
                tone: TaskTone.primary,
                iconName: 'task',
                type: TaskType.manual,
                animalId: animalId,
                groupId: groupId,
              ),
            );
        invalidateTaskProviders(ref);
        if (context.mounted) Navigator.pop(context);
      },
      child: Text(l10n.save),
    ),
  ).whenComplete(titleCtrl.dispose);
}

List<TaskItem> _filterTasks(List<TaskItem> list, _TaskFilter filter) {
  return list.where((t) {
    switch (filter) {
      case _TaskFilter.today:
        return t.dueBucket == 'today' || t.overdue;
      case _TaskFilter.week:
        return t.dueBucket == 'today' ||
            t.dueBucket == 'week' ||
            t.overdue;
      case _TaskFilter.recurring:
        return t.dueBucket == 'recurring';
      case _TaskFilter.all:
        return true;
    }
  }).toList();
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tasks = ref.watch(tasksListProvider);

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.tabTasks,
        subtitle: tasks.maybeWhen(
          data: (list) {
            final overdue = list.where((t) => t.overdue).length;
            final due = list.length;
            return l10n.tasksDueSubtitle(due, overdue);
          },
          orElse: () => null,
        ),
        actions: [
          TextButton(
            onPressed: () => showNewTaskSheet(context, ref),
            child: Text(l10n.addNew),
          ),
        ],
      ),
      body: tasks.when(
        data: (list) {
          final filtered = _filterTasks(list, _filter);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GhChip(
                      label: l10n.today,
                      selected: _filter == _TaskFilter.today,
                      onTap: () => setState(() => _filter = _TaskFilter.today),
                    ),
                    GhChip(
                      label: l10n.thisWeek,
                      selected: _filter == _TaskFilter.week,
                      onTap: () => setState(() => _filter = _TaskFilter.week),
                    ),
                    GhChip(
                      label: l10n.recurring,
                      selected: _filter == _TaskFilter.recurring,
                      onTap: () => setState(() => _filter = _TaskFilter.recurring),
                    ),
                    GhChip(
                      label: l10n.allTasks,
                      selected: _filter == _TaskFilter.all,
                      onTap: () => setState(() => _filter = _TaskFilter.all),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: GhColors.primaryLight.withOpacity(0.35),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: GhColors.primaryLight,
                    child: const Icon(Icons.mic, color: GhColors.primary),
                  ),
                  title: Text(
                    l10n.voiceAddTask,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(l10n.voiceLanguages),
                  trailing: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.voiceHoldMock)),
                      );
                    },
                    child: Text(l10n.hold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.nothingForFilter,
                      style: const TextStyle(color: GhColors.textSecondary),
                    ),
                  ),
                )
              else
                ...filtered.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: InkWell(
                        onTap: () => GhBottomSheet.show(
                          context,
                          title: l10n.editTask,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(t.subtitle),
                            ],
                          ),
                          footer: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await ref
                                        .read(taskRepositoryProvider)
                                        .dismissTask(t.id);
                                    invalidateTaskProviders(ref);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                  child: Text(l10n.dismiss),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    await handleTaskComplete(context, ref, t);
                                  },
                                  child: Text(
                                    t.isBuyFeedInventoryTask
                                        ? l10n.addFeed
                                        : l10n.complete,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: _toneBg(t.tone),
                                radius: 18,
                                child: Icon(_toneIcon(t.iconName), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (t.overdue)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: GhColors.errorLight,
                                              borderRadius: BorderRadius.circular(99),
                                            ),
                                            child: Text(
                                              l10n.overdue,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: GhColors.error,
                                              ),
                                            ),
                                          )
                                        else
                                          Text(
                                            t.whenLabel,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: GhColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.subtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: GhColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Color _toneBg(TaskTone tone) {
    switch (tone) {
      case TaskTone.error:
        return GhColors.errorLight;
      case TaskTone.warning:
        return GhColors.warningLight;
      default:
        return GhColors.primaryLight;
    }
  }

  IconData _toneIcon(String name) {
    switch (name) {
      case 'baby':
        return Icons.child_care;
      case 'syringe':
        return Icons.vaccines;
      case 'milk':
        return Icons.water_drop;
      case 'check':
        return Icons.check_circle_outline;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'list':
        return Icons.list_alt;
      default:
        return Icons.task_alt;
    }
  }
}
