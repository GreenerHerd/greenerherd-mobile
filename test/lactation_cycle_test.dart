import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/animal_lactation_cycle.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/lactation_cycle_service.dart';
import 'package:greenerherd_mobile/data/services/nutrition_context_builder.dart';

void main() {
  const service = LactationCycleService();

  Animal femaleGoat() => const Animal(
        id: 'g1',
        tag: 'G1',
        name: 'Daisy',
        species: Species.goat,
        sex: 'F',
        breed: 'Boer',
        weightKg: 40,
        ageLabel: '2y',
        groupId: 'grp',
      );

  test('twin lactation sets tag and isTwin', () {
    final updated = service.applyCycle(
      femaleGoat(),
      AnimalLactationCycle.lactatingTwin,
    );
    expect(updated.tags, contains(AnimalTagType.lactating));
    expect(updated.isTwin, isTrue);
    expect(updated.lactationCycle, AnimalLactationCycle.lactatingTwin);
  });

  Animal femaleCattle() => const Animal(
        id: 'c1',
        tag: 'C1',
        name: 'Bess',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'grp',
      );

  test('cattle dry clears lactating tag', () {
    final cow = femaleCattle().copyWith(
      tags: [AnimalTagType.lactating],
    );
    final updated = service.applyCycle(cow, AnimalLactationCycle.cattleDry);
    expect(updated.tags, isNot(contains(AnimalTagType.lactating)));
    expect(updated.lactationCycle, AnimalLactationCycle.cattleDry);
  });

  test('nutrition context uses cattle mid lactation feed cycle', () {
    final cow = service.applyCycle(
      femaleCattle(),
      AnimalLactationCycle.cattleMid,
    );
    final ctx = NutritionContextBuilder.fromAnimal(cow);
    expect(ctx.lactating, isTrue);
    expect(ctx.feedCycleHint, 'MID_LACTATION');
    expect(ctx.monthsSinceCalving, 4);
  });

  test('defaultForMilkingGroup returns mid for cattle and single for goats', () {
    expect(
      LactationCycleCatalog.defaultForMilkingGroup(Species.cattle),
      AnimalLactationCycle.cattleMid,
    );
    expect(
      LactationCycleCatalog.defaultForMilkingGroup(Species.goat),
      AnimalLactationCycle.lactatingSingle,
    );
  });

  test('applyMilkingGroupPurpose sets mid lactation for eligible cattle', () {
    const lifecycle = AnimalLifecycleService();
    final updated = lifecycle.applyMilkingGroupPurpose(
      femaleCattle(),
      GroupPurpose.milk,
    );
    expect(updated.lactationCycle, AnimalLactationCycle.cattleMid);
    expect(updated.tags, contains(AnimalTagType.lactating));
  });

  test('applyMilkingGroupPurpose skips when cycle already set', () {
    const lifecycle = AnimalLifecycleService();
    final cow = const LactationCycleService().applyCycle(
      femaleCattle(),
      AnimalLactationCycle.cattleEarly,
    );
    final updated = lifecycle.applyMilkingGroupPurpose(cow, GroupPurpose.milk);
    expect(updated.lactationCycle, AnimalLactationCycle.cattleEarly);
  });

  test('pre-calving close to dry-off uses close-up nutrition', () {
    final cow = service.applyCycle(
      femaleCattle(),
      AnimalLactationCycle.cattlePreCalvingCloseToDryOff,
    );
    expect(cow.tags, isNot(contains(AnimalTagType.lactating)));
    final ctx = NutritionContextBuilder.fromAnimal(cow);
    expect(ctx.lactating, isFalse);
    expect(ctx.feedCycleHint, 'CLOSE_UP');
  });

  test('nutrition context twin flag for goats', () {
    final goat = service.applyCycle(
      femaleGoat(),
      AnimalLactationCycle.lactatingTwin,
    );
    final ctx = NutritionContextBuilder.fromAnimal(goat);
    expect(ctx.lactatingTwin, isTrue);
    expect(ctx.feedCycleHint, 'LACTATING');
  });
}
