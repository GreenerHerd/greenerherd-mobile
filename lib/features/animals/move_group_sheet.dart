import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/group_purpose_badge.dart';
import 'animal_form_helpers.dart';
import 'animal_providers.dart';
import '../groups/group_providers.dart';

/// Bottom sheet to move an animal to another group or create one.
Future<void> showMoveGroupSheet(
  BuildContext context,
  WidgetRef ref, {
  required Animal animal,
  required VoidCallback onMoved,
}) async {
  final l10n = context.l10n;
  final groups = await ref.read(groupRepositoryProvider).listGroups();
  if (!context.mounted) return;

  final candidates = groups
      .where((g) => g.species == animal.species)
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  AnimalGroup? currentGroup;
  if (animal.groupId.isNotEmpty) {
    for (final g in candidates) {
      if (g.id == animal.groupId) {
        currentGroup = g;
        break;
      }
    }
    currentGroup ??=
        await ref.read(groupRepositoryProvider).getGroup(animal.groupId);
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final maxHeight = MediaQuery.sizeOf(sheetCtx).height * 0.65;
      return Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.moveGroupTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${animal.tag}${animal.name.isNotEmpty ? ' · ${animal.name}' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: GhColors.textSecondary,
                  ),
                ),
                if (currentGroup != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.moveGroupCurrent(currentGroup.name),
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(l10n.moveToNewGroup),
                  subtitle: Text(l10n.moveToNewGroupSubtitle),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    final created = await promptCreateGroupForAnimal(
                      context,
                      ref,
                      species: animal.species,
                    );
                    if (created == null || !context.mounted) return;
                    await assignAnimalToGroup(
                      context,
                      ref,
                      animal: animal,
                      groupId: created.id,
                      groupName: created.name,
                    );
                    onMoved();
                  },
                ),
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.link_off_outlined),
                        title: Text(l10n.removeFromGroup),
                        onTap: () async {
                          Navigator.pop(sheetCtx);
                          if (animal.groupId.isEmpty) return;
                          await assignAnimalToGroup(
                            context,
                            ref,
                            animal: animal,
                            groupId: '',
                            groupName: l10n.removeFromGroup,
                          );
                          onMoved();
                        },
                      ),
                      if (candidates.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.moveGroupNoGroups,
                            style: const TextStyle(
                              color: GhColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        for (final group in candidates)
                          ListTile(
                            leading: Icon(
                              group.id == animal.groupId
                                  ? Icons.check_circle
                                  : Icons.group_outlined,
                              color: group.id == animal.groupId
                                  ? GhColors.primary
                                  : GhColors.textSecondary,
                            ),
                            title: Text(group.name),
                            subtitle: GroupPurposeBadge(purpose: group.purpose),
                            enabled: group.id != animal.groupId,
                            onTap: group.id == animal.groupId
                                ? null
                                : () async {
                                    Navigator.pop(sheetCtx);
                                    await assignAnimalToGroup(
                                      context,
                                      ref,
                                      animal: animal,
                                      groupId: group.id,
                                      groupName: group.name,
                                    );
                                    onMoved();
                                  },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> assignAnimalToGroup(
  BuildContext context,
  WidgetRef ref, {
  required Animal animal,
  required String groupId,
  required String groupName,
}) async {
  final l10n = context.l10n;
  final previousGroupId = animal.groupId;
  var updated = animal.copyWith(groupId: groupId);
  updated = await syncAnimalReadyToBreedWithGroup(
    ref,
    updated,
    context: context,
  );
  await ref.read(animalRepositoryProvider).updateAnimal(updated);
  if (!context.mounted) return;

  refreshAnimalAfterMutation(
    ref,
    animalId: animal.id,
    groupId: groupId.isNotEmpty ? groupId : null,
  );
  if (previousGroupId.isNotEmpty && previousGroupId != groupId) {
    ref.invalidate(groupAnimalsProvider(previousGroupId));
  }
  ref.invalidate(groupsListProvider);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        groupId.isEmpty
            ? l10n.animalRemovedFromGroup(animal.tag)
            : l10n.animalMovedToGroup(animal.tag, groupName),
      ),
    ),
  );
}
