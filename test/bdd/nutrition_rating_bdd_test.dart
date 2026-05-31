import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_seed_data.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/services/nutrition_traffic_light.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();
  group('Feature: Nutrition rating display', () {
    const lifecycle = AnimalLifecycleService();

    bddScenario(
      'Milking group gap shows energy gap badge',
      tags: ['positive'],
      body: (tester) async {
        final gap = MockSeedData.nutritionGapFor('g1');
        expect(gap.gapBadgeLabel, 'Energy gap');
        expect(gap.dryMatterActualKg, 194);
        expect(gap.dryMatterTargetKg, 202);
        expect(nutritionTrafficLight(gap.energyDeviationPct),
            NutritionTrafficLight.red);
      },
    );

    bddScenario(
      'Breeding group gap is not energy gap',
      tags: ['negative'],
      body: (tester) async {
        final gap = MockSeedData.nutritionGapFor('g2');
        expect(gap.gapBadgeLabel, isNot('Energy gap'));
      },
    );

    bddScenario(
      'Animal birth does not duplicate lactating tag',
      tags: ['positive'],
      body: (tester) async {
        const animal = Animal(
          id: 'x',
          tag: 'T1',
          name: 'Bessie',
          species: Species.cattle,
          sex: 'F',
          breed: 'Holstein',
          weightKg: 400,
          ageLabel: '3y',
          groupId: 'g1',
          tags: [AnimalTagType.pregnant, AnimalTagType.lactating],
        );
        final updated = lifecycle.recordCalvingOutcome(
          animal,
          CalvingOutcome.bornLive,
        );
        expect(
          updated.tags.where((t) => t == AnimalTagType.lactating).length,
          1,
        );
        expect(updated.tags, isNot(contains(AnimalTagType.pregnant)));
      },
    );
  });
}
