import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/feed_eligibility_service.dart';
import 'package:greenerherd_mobile/features/nutrition/gap_supplement_recommendations.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Feed eligibility in recommendations', () {
    bddAsyncDomainScenario(
      'Fix the gap standard tab excludes lactation-only feeds for dry groups',
      tags: ['positive'],
      body: () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final gap = NutritionGap(
          groupId: 'g-dry',
          dryMatterActualKg: 10,
          dryMatterTargetKg: 20,
          energyActualMj: 50,
          energyTargetMj: 100,
        );
        final dryCow = Animal(
          id: 'd1',
          tag: '1001',
          name: 'Dry',
          species: Species.cattle,
          sex: 'F',
          breed: 'Holstein',
          weightKg: 400,
          ageLabel: '48m',
          groupId: 'g-dry',
          productionPurpose: SpeciesPurpose.milk,
        );
        final options = await GapSupplementRecommendations.load(
          source: GapSupplementSource.standard,
          gap: gap,
          locale: const Locale('en'),
          inventory: const [],
          groupMembers: [dryCow],
        );
        expect(options.any((o) => o.name == 'Steamed Corn Flake'), isFalse);
        expect(options, isNotEmpty);
      },
    );

    bddAsyncDomainScenario(
      'Fix the gap includes lactation feed for lactating dairy group',
      tags: ['positive'],
      body: () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final gap = NutritionGap(
          groupId: 'g-lac',
          dryMatterActualKg: 10,
          dryMatterTargetKg: 20,
          energyActualMj: 50,
          energyTargetMj: 100,
        );
        final lactating = Animal(
          id: 'l1',
          tag: '0444',
          name: 'Sara',
          species: Species.cattle,
          sex: 'F',
          breed: 'Jersey',
          weightKg: 344,
          ageLabel: '42m',
          groupId: 'g-lac',
          tags: const [AnimalTagType.lactating],
          productionPurpose: SpeciesPurpose.milk,
          monthsSinceCalving: 5,
        );
        final options = await GapSupplementRecommendations.load(
          source: GapSupplementSource.standard,
          gap: gap,
          locale: const Locale('en'),
          inventory: const [],
          groupMembers: [lactating],
        );
        expect(options.any((o) => o.name == 'Steamed Corn Flake'), isTrue);
      },
    );
  });
}
