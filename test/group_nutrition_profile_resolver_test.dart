import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/group_nutrition_profile_resolver.dart';
import 'package:greenerherd_mobile/data/services/nutrition_requirements_catalog.dart';
import 'package:greenerherd_mobile/data/services/reproduction_status_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads known profile for seed group g1', () async {
    final profile = await GroupNutritionProfileResolver.resolve('g1');
    expect(profile, isNotNull);
    expect(profile!.request['species'], 'CATTLE');
    expect(profile.request['head_count'], 22);
    expect(profile.currentIntakeRatio, closeTo(0.76, 0.001));
  });

  test('builds request body with intake options', () {
    const profile = GroupNutritionProfile(
      request: {'species': 'CATTLE', 'head_count': 5},
      currentIntakeRatio: 0.9,
    );
    final body = profile.toRequestBody();
    expect(body['current_intake_ratio'], 0.9);
    expect(body['head_count'], 5);
  });

  test('merges median months since calving from herd members', () async {
    const group = AnimalGroup(
      id: 'g1',
      name: 'Milking A',
      species: Species.cattle,
      purpose: GroupPurpose.milk,
      headCount: 3,
      managerId: 'u2',
    );
    final members = [
      Animal(
        id: 'a2',
        tag: '0438',
        name: 'Mona',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 398,
        ageLabel: '5y',
        groupId: 'g1',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 5,
      ),
      Animal(
        id: 'a3',
        tag: '0444',
        name: 'Sara',
        species: Species.cattle,
        sex: 'F',
        breed: 'Jersey',
        weightKg: 344,
        ageLabel: '3y',
        groupId: 'g1',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 2,
      ),
      Animal(
        id: 'a4',
        tag: '0451',
        name: 'Hala',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 426,
        ageLabel: '6y',
        groupId: 'g1',
        tags: const [AnimalTagType.lactating],
        monthsSinceCalving: 8,
      ),
    ];

    final profile = await GroupNutritionProfileResolver.resolve(
      'g1',
      group: group,
      members: members,
    );

    expect(profile, isNotNull);
    expect(profile!.request['months_since_calving'], 5);
    expect(profile.request['lactating'], isTrue);
    expect(profile.request['head_count'], 3);
  });

  test('attaches aggregated requirements when catalog and members supplied',
      () async {
    final catalog = await NutritionRequirementsCatalog.load();
    const groupId = 'g-lac-stages';
    final group = AnimalGroup(
      id: groupId,
      name: 'Mixed lactation',
      species: Species.cattle,
      purpose: GroupPurpose.maintenance,
      headCount: 3,
      managerId: 'u2',
    );
    final members = [
      Animal(
        id: 'fresh',
        tag: 'F1',
        name: 'Fresh',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 400,
        ageLabel: '48m',
        groupId: groupId,
        tags: const [AnimalTagType.lactating],
        productionPurpose: SpeciesPurpose.milk,
        monthsSinceCalving: 1,
      ),
      Animal(
        id: 'mid',
        tag: 'M1',
        name: 'Mid',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 400,
        ageLabel: '48m',
        groupId: groupId,
        tags: const [AnimalTagType.lactating],
        productionPurpose: SpeciesPurpose.milk,
        monthsSinceCalving: 5,
      ),
      Animal(
        id: 'late',
        tag: 'L1',
        name: 'Late',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 400,
        ageLabel: '48m',
        groupId: groupId,
        tags: const [AnimalTagType.lactating],
        productionPurpose: SpeciesPurpose.milk,
        monthsSinceCalving: 8,
      ),
    ];

    final profile = await GroupNutritionProfileResolver.resolve(
      groupId,
      group: group,
      members: members,
      catalog: catalog,
    );

    expect(profile, isNotNull);
    expect(profile!.aggregatedRequirements, isNotNull);
    expect(profile.aggregatedRequirements!.headCount, 3);
    expect(
      profile.aggregatedRequirements!.members.map((m) => m.profileCode).toSet(),
      {
        'CATTLE_DAIRY_COW_FRESH',
        'CATTLE_DAIRY_COW_MID',
        'CATTLE_DAIRY_COW_LATE',
      },
    );
  });

  group('GroupBreedingCycleSummary', () {
    test('computes median and stage counts for lactating herd', () {
      final members = [
        Animal(
          id: 'a2',
          tag: '0438',
          name: 'Mona',
          species: Species.cattle,
          sex: 'F',
          breed: 'Holstein',
          weightKg: 398,
          ageLabel: '5y',
          groupId: 'g1',
          tags: const [AnimalTagType.lactating],
          monthsSinceCalving: 5,
        ),
        Animal(
          id: 'a3',
          tag: '0444',
          name: 'Sara',
          species: Species.cattle,
          sex: 'F',
          breed: 'Jersey',
          weightKg: 344,
          ageLabel: '3y',
          groupId: 'g1',
          tags: const [AnimalTagType.lactating],
          monthsSinceCalving: 2,
        ),
        Animal(
          id: 'a4',
          tag: '0451',
          name: 'Hala',
          species: Species.cattle,
          sex: 'F',
          breed: 'Holstein',
          weightKg: 426,
          ageLabel: '6y',
          groupId: 'g1',
          tags: const [AnimalTagType.lactating],
          monthsSinceCalving: 8,
        ),
      ];

      final summary = GroupBreedingCycleSummary.fromMembers(members);
      expect(summary, isNotNull);
      expect(summary!.lactatingCount, 3);
      expect(summary.medianMonthsSinceCalving, 5);
      expect(summary.lactationStageCounts['peak'], 1);
      expect(summary.lactationStageCounts['mid'], 1);
      expect(summary.lactationStageCounts['late'], 1);
      expect(summary.readyForRebreedingCount, 3);
      expect(summary.waitingCount, 0);
    });
  });
}
