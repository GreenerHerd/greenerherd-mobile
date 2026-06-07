import 'package:uuid/uuid.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../models/breeding_methods.dart';
import '../models/enums.dart';
import '../models/models.dart';

/// Template for a breeding workflow task offset from activation date.
class BreedingTaskStep {
  const BreedingTaskStep({
    required this.id,
    required this.dayOffset,
    required this.title,
    required this.subtitle,
    this.iconName = 'check',
    this.tone = TaskTone.primary,
  });

  final String id;
  final int dayOffset;
  final String title;
  final String subtitle;
  final String iconName;
  final TaskTone tone;
}

const kBreedingTaskActionPrefix = 'breeding_schedule';

/// Builds [TaskType.autoBreeding] items from method-specific timelines (harness 06).
abstract final class BreedingTaskScheduler {
  static List<BreedingTaskStep> stepsFor(
    BreedingMethod method,
    AppLocalizations l10n,
  ) {
    return switch (method) {
      BreedingMethod.natural => _naturalSteps(l10n),
      BreedingMethod.ai => _aiSteps(l10n),
      BreedingMethod.embryonic => _embryonicSteps(l10n),
      BreedingMethod.sponges => _spongeSteps(l10n),
    };
  }

  static List<TaskItem> buildTasks({
    required Animal animal,
    required BreedingMethod method,
    required AppLocalizations l10n,
    DateTime? activatedOn,
  }) {
    final start = DateTime(
      (activatedOn ?? DateTime.now()).year,
      (activatedOn ?? DateTime.now()).month,
      (activatedOn ?? DateTime.now()).day,
    );
    final methodLabel = BreedingMethodCatalog.label(method, l10n);
    final tag = animal.tag.isNotEmpty ? '#${animal.tag}' : animal.name;

    return [
      for (final step in stepsFor(method, l10n))
        _toTaskItem(
          animal: animal,
          step: step,
          methodLabel: methodLabel,
          tag: tag,
          start: start,
        ),
    ];
  }

  static String actionKindFor(String animalId, String stepId) =>
      '$kBreedingTaskActionPrefix|$animalId|$stepId';

  static bool isBreedingScheduleAction(String? actionKind) =>
      actionKind != null && actionKind.startsWith('$kBreedingTaskActionPrefix|');

  static List<BreedingTaskStep> _naturalSteps(AppLocalizations l10n) => [
        BreedingTaskStep(
          id: 'natural_d0',
          dayOffset: 0,
          title: l10n.breedingTaskNaturalObserveTitle,
          subtitle: l10n.breedingTaskNaturalObserveSubtitle,
          iconName: 'check',
        ),
        BreedingTaskStep(
          id: 'natural_d21',
          dayOffset: 21,
          title: l10n.breedingTaskCycleCheckTitle,
          subtitle: l10n.breedingTaskCycleCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'natural_d45',
          dayOffset: 45,
          title: l10n.breedingTaskPregnancyConfirmTitle,
          subtitle: l10n.breedingTaskPregnancyConfirmSubtitle,
        ),
      ];

  static List<BreedingTaskStep> _aiSteps(AppLocalizations l10n) => [
        BreedingTaskStep(
          id: 'ai_d0',
          dayOffset: 0,
          title: l10n.breedingTaskAiRecordTitle,
          subtitle: l10n.breedingTaskAiRecordSubtitle,
          iconName: 'syringe',
        ),
        BreedingTaskStep(
          id: 'ai_d18',
          dayOffset: 18,
          title: l10n.breedingTaskAiConceptionCheckTitle,
          subtitle: l10n.breedingTaskAiConceptionCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'ai_d21',
          dayOffset: 21,
          title: l10n.breedingTaskCycleCheckTitle,
          subtitle: l10n.breedingTaskCycleCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'ai_d45',
          dayOffset: 45,
          title: l10n.breedingTaskPregnancyScanTitle,
          subtitle: l10n.breedingTaskPregnancyScanSubtitle,
        ),
        BreedingTaskStep(
          id: 'ai_d60',
          dayOffset: 60,
          title: l10n.breedingTaskPregnancyNutritionTitle,
          subtitle: l10n.breedingTaskPregnancyNutritionSubtitle,
        ),
      ];

  static List<BreedingTaskStep> _embryonicSteps(AppLocalizations l10n) => [
        BreedingTaskStep(
          id: 'et_d0',
          dayOffset: 0,
          title: l10n.breedingTaskEmbryoTransferTitle,
          subtitle: l10n.breedingTaskEmbryoTransferSubtitle,
        ),
        BreedingTaskStep(
          id: 'et_d7',
          dayOffset: 7,
          title: l10n.breedingTaskPostTransferCheckTitle,
          subtitle: l10n.breedingTaskPostTransferCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'et_d30',
          dayOffset: 30,
          title: l10n.breedingTaskEarlyPregnancyCheckTitle,
          subtitle: l10n.breedingTaskEarlyPregnancyCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'et_d45',
          dayOffset: 45,
          title: l10n.breedingTaskPregnancyConfirmTitle,
          subtitle: l10n.breedingTaskPregnancyConfirmSubtitle,
        ),
      ];

  static List<BreedingTaskStep> _spongeSteps(AppLocalizations l10n) => [
        BreedingTaskStep(
          id: 'sponge_d0',
          dayOffset: 0,
          title: l10n.breedingTaskSpongeInsertTitle,
          subtitle: l10n.breedingTaskSpongeInsertSubtitle,
        ),
        BreedingTaskStep(
          id: 'sponge_d12',
          dayOffset: 12,
          title: l10n.breedingTaskSpongeRemoveTitle,
          subtitle: l10n.breedingTaskSpongeRemoveSubtitle,
        ),
        BreedingTaskStep(
          id: 'sponge_d21',
          dayOffset: 21,
          title: l10n.breedingTaskCycleCheckTitle,
          subtitle: l10n.breedingTaskCycleCheckSubtitle,
        ),
        BreedingTaskStep(
          id: 'sponge_d45',
          dayOffset: 45,
          title: l10n.breedingTaskPregnancyConfirmTitle,
          subtitle: l10n.breedingTaskPregnancyConfirmSubtitle,
        ),
      ];

  static TaskItem _toTaskItem({
    required Animal animal,
    required BreedingTaskStep step,
    required String methodLabel,
    required String tag,
    required DateTime start,
  }) {
    final due = start.add(Duration(days: step.dayOffset));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final overdue = due.isBefore(today);
    final daysUntil = due.difference(today).inDays;

    final whenLabel = step.dayOffset == 0
        ? 'Today'
        : daysUntil <= 0
            ? 'Overdue'
            : daysUntil == 1
                ? 'Tomorrow'
                : 'Day +${step.dayOffset}';

    final dueBucket = step.dayOffset == 0 || overdue
        ? 'today'
        : daysUntil <= 7
            ? 'week'
            : 'week';

    return TaskItem(
      id: const Uuid().v4(),
      title: '$tag · ${step.title}',
      subtitle: 'Auto · $methodLabel · ${step.subtitle}',
      type: TaskType.autoBreeding,
      whenLabel: whenLabel,
      dueBucket: dueBucket,
      overdue: overdue,
      iconName: step.iconName,
      tone: overdue ? TaskTone.error : step.tone,
      animalId: animal.id,
      groupId: animal.groupId.isEmpty ? null : animal.groupId,
      actionKind: actionKindFor(animal.id, step.id),
    );
  }
}
