import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/mock/profile_mock_data.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_kv_list.dart';
import '../tasks/tasks_screen.dart';

class AnimalTasksTab extends ConsumerWidget {
  const AnimalTasksTab({super.key, required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = ProfileMockData.animalTasksKv(animal.id);
    final displayName =
        animal.name.trim().isNotEmpty ? animal.name : '#${animal.tag}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noTasksForAnimal,
                style: const TextStyle(color: GhColors.textSecondary),
              ),
            ),
          )
        else
          GhKvListCard(rows: rows),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => showNewTaskSheet(
            context,
            ref,
            animalId: animal.id,
            animalTag: animal.tag,
            animalName: animal.name,
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.addTaskForAnimal(displayName)),
        ),
      ],
    );
  }
}
