import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/gen/app_localizations_en.dart';
import 'package:greenerherd_mobile/data/models/breeding_methods.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/breeding_task_scheduler.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Animal sampleAnimal(Species species) => Animal(
        id: 'a1',
        tag: 'T01',
        name: 'Bess',
        species: species,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'g1',
        tags: const [AnimalTagType.readyToBreed],
        breedingMethod: BreedingMethod.ai,
      );

  group('BreedingTaskScheduler', () {
    test('AI schedule has five steps with stable action kinds', () {
      final tasks = BreedingTaskScheduler.buildTasks(
        animal: sampleAnimal(Species.cattle),
        method: BreedingMethod.ai,
        l10n: l10n,
      );
      expect(tasks, hasLength(5));
      expect(tasks.first.type, TaskType.autoBreeding);
      expect(
        tasks.map((t) => t.actionKind),
        [
          BreedingTaskScheduler.actionKindFor('a1', 'ai_d0'),
          BreedingTaskScheduler.actionKindFor('a1', 'ai_d18'),
          BreedingTaskScheduler.actionKindFor('a1', 'ai_d21'),
          BreedingTaskScheduler.actionKindFor('a1', 'ai_d45'),
          BreedingTaskScheduler.actionKindFor('a1', 'ai_d60'),
        ],
      );
    });

    test('sponge schedule for goats has four steps', () {
      final tasks = BreedingTaskScheduler.buildTasks(
        animal: sampleAnimal(Species.goat),
        method: BreedingMethod.sponges,
        l10n: l10n,
      );
      expect(tasks, hasLength(4));
      expect(
        tasks.first.actionKind,
        BreedingTaskScheduler.actionKindFor('a1', 'sponge_d0'),
      );
    });

    test('embryonic schedule for cattle has four steps', () {
      final steps = BreedingTaskScheduler.stepsFor(BreedingMethod.embryonic, l10n);
      expect(steps, hasLength(4));
    });
  });
}
