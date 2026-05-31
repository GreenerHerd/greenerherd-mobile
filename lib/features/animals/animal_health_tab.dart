import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/mock/profile_mock_data.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_kv_list.dart';
import 'animal_lifecycle_ui.dart';

Future<void> persistTreatmentUpdate(
  WidgetRef ref,
  BuildContext context, {
  required Animal animal,
  required Animal updated,
  required VoidCallback onUpdated,
  String? snackMessage,
}) async {
  await ref.read(animalRepositoryProvider).updateAnimal(updated);
  if (!context.mounted) return;
  FocusManager.instance.primaryFocus?.unfocus();
  onUpdated();
  refreshAnimalAfterMutation(
    ref,
    animalId: animal.id,
    groupId: animal.groupId.isNotEmpty ? animal.groupId : null,
  );
  if (snackMessage != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snackMessage)),
    );
  }
}

class AnimalHealthTab extends ConsumerWidget {
  const AnimalHealthTab({
    super.key,
    required this.animal,
    required this.onCured,
  });

  final Animal animal;
  final VoidCallback onCured;

  String _animalLabel() {
    if (animal.name.trim().isNotEmpty) {
      return '#${animal.tag} · ${animal.name}';
    }
    return '#${animal.tag}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lifecycle = ref.watch(lifecycleServiceProvider);
    final isDeceased = animal.status == AnimalStatus.deceased;
    final isActive = animal.status == AnimalStatus.active;
    final isSick = animal.isSick;
    final withdrawal = animal.withdrawalDays ?? 0;
    final treatmentSummary =
        animal.activeTreatmentSummary ?? l10n.underTreatmentDefault;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isDeceased) ...[
          Card(
            color: GhColors.textSecondary.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.dangerous_outlined, color: GhColors.textSecondary, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.deceased,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (animal.cullReasonLabel != null &&
                            animal.cullReasonLabel!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            animal.cullReasonLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: GhColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          l10n.removedFromGroupNote,
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
          const SizedBox(height: 12),
        ],
        if (isActive && withdrawal > 0) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GhColors.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GhColors.warning.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.withdrawalPeriodActive,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: GhColors.warning,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.withdrawalMilkSafe('11 May'),
                  style: const TextStyle(fontSize: 13, color: GhColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (isActive && isSick) ...[
          Card(
            color: GhColors.errorLight.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medical_services, color: GhColors.error, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sick,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: GhColors.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          treatmentSummary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: GhColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => showTreatmentSheet(
                            context,
                            isSick: true,
                            illnessNote: animal.illnessNote,
                            treatmentNote: animal.treatmentNote,
                            onRecordTreatment: (details) async {
                              final updated = lifecycle.recordTreatment(
                                animal,
                                illnessNote: details.illnessNote,
                                treatmentNote: details.treatmentNote,
                              );
                              await persistTreatmentUpdate(
                                ref,
                                context,
                                animal: animal,
                                updated: updated,
                                onUpdated: onCured,
                                snackMessage: l10n.treatmentUpdated,
                              );
                            },
                            onMarkCured: () async {
                              final updated = lifecycle.markCured(animal);
                              await persistTreatmentUpdate(
                                ref,
                                context,
                                animal: animal,
                                updated: updated,
                                onUpdated: onCured,
                                snackMessage: l10n.markedCured,
                              );
                            },
                          ),
                          child: Text(l10n.updateTreatment),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        GhKvListCard(
          title: l10n.healthcareHistory,
          rows: ProfileMockData.healthHistoryKv(animal.id),
        ),
        const SizedBox(height: 12),
        GhKvListCard(
          title: l10n.vaccinationsSection,
          rows: ProfileMockData.vaccinationKv(animal.id),
        ),
        if (isActive) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showTreatmentSheet(
              context,
              isSick: isSick,
              illnessNote: animal.illnessNote,
              treatmentNote: animal.treatmentNote,
              onRecordTreatment: (details) async {
                final updated = lifecycle.recordTreatment(
                  animal,
                  illnessNote: details.illnessNote,
                  treatmentNote: details.treatmentNote,
                );
                await persistTreatmentUpdate(
                  ref,
                  context,
                  animal: animal,
                  updated: updated,
                  onUpdated: onCured,
                  snackMessage: l10n.treatmentRecorded,
                );
              },
              onMarkCured: () async {
                final updated = lifecycle.markCured(animal);
                await persistTreatmentUpdate(
                  ref,
                  context,
                  animal: animal,
                  updated: updated,
                  onUpdated: onCured,
                  snackMessage: l10n.markedCured,
                );
              },
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.recordTreatment),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final selection = await showRecordDeathFlow(
                context,
                animalLabel: _animalLabel(),
              );
              if (selection == null || !context.mounted) return;
              try {
                final updated =
                    lifecycle.markDeceased(animal, selection: selection);
                final previousGroupId =
                    animal.groupId.isNotEmpty ? animal.groupId : null;
                await ref.read(animalRepositoryProvider).updateAnimal(updated);
                if (!context.mounted) return;
                FocusManager.instance.primaryFocus?.unfocus();
                onCured();
                refreshAnimalAfterMutation(
                  ref,
                  animalId: animal.id,
                  groupId: previousGroupId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.animalRecordedDeceased)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
            icon: const Icon(Icons.dangerous_outlined),
            label: Text(l10n.recordDeath),
            style: OutlinedButton.styleFrom(
              foregroundColor: GhColors.error,
              side: const BorderSide(color: GhColors.error),
            ),
          ),
        ],
      ],
    );
  }
}
