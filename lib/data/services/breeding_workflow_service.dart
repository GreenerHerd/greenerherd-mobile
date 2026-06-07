import '../../core/l10n/gen/app_localizations.dart';
import '../models/breeding_methods.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'breeding_task_scheduler.dart';

/// Schedules breeding workflow tasks when animals are activated for breeding.
class BreedingWorkflowService {
  const BreedingWorkflowService();

  Future<int> scheduleForAnimal({
    required TaskRepository tasks,
    required Animal animal,
    required BreedingMethod method,
    required AppLocalizations l10n,
    DateTime? activatedOn,
    bool replaceExisting = true,
  }) async {
    if (!animal.tags.contains(AnimalTagType.readyToBreed)) return 0;

    if (replaceExisting) {
      await _removeExistingSchedule(tasks, animal.id);
    }

    final generated = BreedingTaskScheduler.buildTasks(
      animal: animal,
      method: method,
      l10n: l10n,
      activatedOn: activatedOn,
    );

    for (final task in generated) {
      await tasks.addTask(task);
    }
    return generated.length;
  }

  Future<void> clearForAnimal({
    required TaskRepository tasks,
    required String animalId,
  }) async {
    await _removeExistingSchedule(tasks, animalId);
  }

  Future<int> scheduleForGroup({
    required TaskRepository tasks,
    required List<Animal> members,
    required BreedingMethod defaultMethod,
    required AppLocalizations l10n,
    DateTime? activatedOn,
  }) async {
    var count = 0;
    for (final animal in members) {
      if (!animal.tags.contains(AnimalTagType.readyToBreed)) continue;
      final method = animal.breedingMethod ?? defaultMethod;
      count += await scheduleForAnimal(
        tasks: tasks,
        animal: animal,
        method: method,
        l10n: l10n,
        activatedOn: activatedOn,
        replaceExisting: true,
      );
    }
    return count;
  }

  Future<void> _removeExistingSchedule(
    TaskRepository tasks,
    String animalId,
  ) async {
    final existing = await tasks.listTasks();
    for (final task in existing) {
      if (task.animalId == animalId &&
          (task.type == TaskType.autoBreeding ||
              BreedingTaskScheduler.isBreedingScheduleAction(task.actionKind))) {
        await tasks.deleteTask(task.id);
      }
    }
  }
}
