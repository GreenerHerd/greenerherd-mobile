import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/group_nutrition_requirements_aggregator.dart';
import 'package:greenerherd_mobile/data/services/nutrition_feed_cycle.dart';
import 'package:greenerherd_mobile/data/services/nutrition_context_builder.dart';
import 'package:greenerherd_mobile/data/services/nutrition_profile_resolver.dart';
import 'package:greenerherd_mobile/data/services/nutrition_requirements_catalog.dart';

import 'support/bdd_harness.dart';

void main() {
  initBddTests();

  group('Feature: Group nutrition requirements aggregation', () {
    late NutritionRequirementsCatalog catalog;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      catalog = await NutritionRequirementsCatalog.load();
    });

    bddAsyncDomainScenario(
      'Homogeneous lactating dairy cows sum per-animal needs to group total',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-dairy-lactating';
        final group = _group(
          id: groupId,
          species: Species.cattle,
          purpose: GroupPurpose.maintenance,
          headCount: 3,
        );
        final members = List.generate(
          3,
          (i) => _animal(
            id: 'cow-$i',
            groupId: groupId,
            species: Species.cattle,
            ageLabel: '48m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
          ),
        );

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(agg.headCount, 3);
        expect(agg.members.every((m) => m.profileCode == 'CATTLE_DAIRY_COW_EARLY'), isTrue);
        _expectGroupEqualsSumOfMembers(agg, 'crude_protein_kg');
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
        _expectGroupEqualsSumOfMembers(agg, 'nem_mcal');

        final single = NutritionProfileResolver.buildGroupRequirements(
          catalog.getByCode('CATTLE_DAIRY_COW_EARLY')!,
          1,
        );
        final perDm = (single['per_animal'] as Map)['dry_matter_kg'] as num;
        expect(agg.groupTotals['dry_matter_kg'], closeTo(perDm * 3, 0.001));
      },
    );

    bddAsyncDomainScenario(
      'Lactating cows with different months since calving use distinct stages',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-lac-stages';
        final group = _group(
          id: groupId,
          species: Species.cattle,
          purpose: GroupPurpose.maintenance,
          headCount: 3,
        );
        final members = [
          _animal(
            id: 'fresh',
            groupId: groupId,
            ageLabel: '48m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
            monthsSinceCalving: 1,
          ),
          _animal(
            id: 'mid',
            groupId: groupId,
            ageLabel: '48m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
            monthsSinceCalving: 5,
          ),
          _animal(
            id: 'late',
            groupId: groupId,
            ageLabel: '48m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
            monthsSinceCalving: 8,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        final codes = agg.members.map((m) => m.profileCode).toSet();
        expect(codes, {
          'CATTLE_DAIRY_COW_FRESH',
          'CATTLE_DAIRY_COW_MID',
          'CATTLE_DAIRY_COW_LATE',
        });
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Mixed beef herd resolves distinct profiles and sums nutrients',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-beef-mixed';
        final group = _group(
          id: groupId,
          species: Species.cattle,
          purpose: GroupPurpose.maintenance,
          headCount: 3,
        );
        final members = [
          _animal(
            id: 'cow-mature',
            groupId: groupId,
            ageLabel: '60m',
            tags: const [],
            production: SpeciesPurpose.meat,
          ),
          _animal(
            id: 'heifer',
            groupId: groupId,
            ageLabel: '26m',
            tags: const [],
            production: SpeciesPurpose.meat,
          ),
          _animal(
            id: 'bull',
            groupId: groupId,
            sex: 'M',
            ageLabel: '48m',
            tags: const [],
            production: SpeciesPurpose.meat,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(agg.headCount, 3);
        expect(
          agg.members.map((m) => m.profileCode).toSet(),
          {
            'CATTLE_BEEF_MATURE_COW_MAINTENANCE',
            'CATTLE_BEEF_FIRST_CALF_HEIFER_MAINTENANCE',
            'CATTLE_BEEF_MATURE_BULL_MAINTENANCE',
          },
        );
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
        _expectGroupEqualsSumOfMembers(agg, 'crude_protein_kg');
        _expectGroupEqualsSumOfMembers(agg, 'nem_mcal');
      },
    );

    bddAsyncDomainScenario(
      'Mixed sheep maintenance group keeps individual feed cycles',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-sheep-mixed';
        final group = _group(
          id: groupId,
          species: Species.sheep,
          purpose: GroupPurpose.maintenance,
          headCount: 3,
        );
        final members = [
          _animal(
            id: 'ewe-lact',
            groupId: groupId,
            species: Species.sheep,
            ageLabel: '24m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
          ),
          _animal(
            id: 'ewe-preg',
            groupId: groupId,
            species: Species.sheep,
            ageLabel: '30m',
            tags: const [AnimalTagType.pregnant],
            production: SpeciesPurpose.both,
          ),
          _animal(
            id: 'ram',
            groupId: groupId,
            species: Species.sheep,
            sex: 'M',
            ageLabel: '30m',
            tags: const [],
            production: SpeciesPurpose.meat,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        final byId = {for (final m in agg.members) m.animalId: m};
        expect(byId['ewe-lact']!.profileCode, 'SHEEP_SMALL_RUMINANT_LACTATING');
        expect(byId['ewe-preg']!.profileCode, 'SHEEP_SMALL_RUMINANT_PREGNANT');
        expect(byId['ram']!.profileCode, 'SHEEP_SMALL_RUMINANT_MAINTENANCE');
        expect(byId['ewe-lact']!.feedCycle, NutritionFeedCycle.lactating);
        expect(byId['ewe-preg']!.feedCycle, NutritionFeedCycle.pregnant);
        expect(byId['ram']!.feedCycle, NutritionFeedCycle.maintenance);
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
        _expectGroupEqualsSumOfMembers(agg, 'protein_kg');
        _expectGroupEqualsSumOfMembers(agg, 'tdn_kg');
      },
    );

    bddAsyncDomainScenario(
      'Fattening group applies fattening feed cycle to all members including young',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-goat-fatten';
        final group = _group(
          id: groupId,
          species: Species.goat,
          purpose: GroupPurpose.fattening,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'goat-adult',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '18m',
            production: SpeciesPurpose.meat,
          ),
          _animal(
            id: 'goat-young',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '8m',
            production: SpeciesPurpose.meat,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(agg.members.length, 2);
        for (final row in agg.members) {
          expect(row.profileCode, contains('FATTENING'));
          expect(row.feedCycle, contains('FATTENING'));
        }
        expect(
          agg.members.singleWhere((m) => m.animalId == 'goat-adult').profileCode,
          'GOAT_SMALL_RUMINANT_FATTENING',
        );
        expect(
          agg.members.singleWhere((m) => m.animalId == 'goat-young').profileCode,
          'GOAT_SMALL_RUMINANT_FATTENING_YOUNG',
        );

        final adultOnly = agg.members.singleWhere((m) => m.animalId == 'goat-adult');
        final youngOnly = agg.members.singleWhere((m) => m.animalId == 'goat-young');
        expect(
          youngOnly.perAnimal['dry_matter_kg']!,
          lessThan(adultOnly.perAnimal['dry_matter_kg']!),
        );
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Individual lactating tag overrides fattening group purpose',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-fatten-mixed';
        final group = _group(
          id: groupId,
          species: Species.sheep,
          purpose: GroupPurpose.fattening,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'fatten-only',
            groupId: groupId,
            species: Species.sheep,
            ageLabel: '18m',
          ),
          _animal(
            id: 'lactating-ewe',
            groupId: groupId,
            species: Species.sheep,
            ageLabel: '24m',
            tags: const [AnimalTagType.lactating],
            production: SpeciesPurpose.milk,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        final byId = {for (final m in agg.members) m.animalId: m};
        expect(byId['fatten-only']!.profileCode, 'SHEEP_SMALL_RUMINANT_FATTENING');
        expect(byId['lactating-ewe']!.profileCode, 'SHEEP_SMALL_RUMINANT_LACTATING');
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Breeding group applies breeding profile to untagged members',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-breed';
        final group = _group(
          id: groupId,
          species: Species.goat,
          purpose: GroupPurpose.breeding,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'doe',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '18m',
          ),
          _animal(
            id: 'buck',
            groupId: groupId,
            species: Species.goat,
            sex: 'M',
            ageLabel: '24m',
            tags: const [AnimalTagType.readyToBreed],
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(
          agg.members.every((m) => m.profileCode == 'GOAT_SMALL_RUMINANT_BREEDING'),
          isTrue,
        );
        expect(
          agg.members.every((m) => m.feedCycle == NutritionFeedCycle.breeding),
          isTrue,
        );
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Sick tag routes member to sick profile regardless of group purpose',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-sick';
        final group = _group(
          id: groupId,
          species: Species.goat,
          purpose: GroupPurpose.maintenance,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'goat-a',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '18m',
            tags: const [AnimalTagType.sick],
          ),
          _animal(
            id: 'goat-b',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '24m',
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        final byId = {for (final m in agg.members) m.animalId: m};
        expect(byId['goat-a']!.profileCode, 'GOAT_SICK');
        expect(byId['goat-b']!.profileCode, 'GOAT_SMALL_RUMINANT_MAINTENANCE');
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Weaning tag uses weaning profile not group purpose alone',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-weaning';
        final group = _group(
          id: groupId,
          species: Species.cattle,
          purpose: GroupPurpose.maintenance,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'calf-a',
            groupId: groupId,
            ageLabel: '6m',
            tags: const [AnimalTagType.weaning],
            production: SpeciesPurpose.meat,
          ),
          _animal(
            id: 'calf-b',
            groupId: groupId,
            ageLabel: '8m',
            tags: const [AnimalTagType.weaning],
            production: SpeciesPurpose.meat,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(agg.members.every((m) => m.profileCode == 'CATTLE_WEANING'), isTrue);
        expect(agg.members.every((m) => m.feedCycle == NutritionFeedCycle.weaning), isTrue);
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
        _expectGroupEqualsSumOfMembers(agg, 'crude_protein_kg');
      },
    );

    bddAsyncDomainScenario(
      'Group total differs from single-profile times headcount for mixed ages',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-goat-ages';
        final group = _group(
          id: groupId,
          species: Species.goat,
          purpose: GroupPurpose.maintenance,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'young',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '8m',
          ),
          _animal(
            id: 'adult',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '24m',
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        final young = agg.members.singleWhere((m) => m.animalId == 'young');
        final adult = agg.members.singleWhere((m) => m.animalId == 'adult');
        expect(young.profileCode, 'GOAT_SMALL_RUMINANT_MAINTENANCE_YOUNG');
        expect(adult.profileCode, 'GOAT_SMALL_RUMINANT_MAINTENANCE');

        final groupCtx = NutritionContextBuilder.fromGroup(group, members: members);
        final representative = NutritionProfileResolver.resolve(catalog, groupCtx);
        final shortcut = NutritionProfileResolver.buildGroupRequirements(
          representative.profile,
          members.length,
        );
        final shortcutDm =
            (shortcut['group'] as Map)['dry_matter_kg'] as num;
        expect(
          agg.groupTotals['dry_matter_kg'],
          isNot(closeTo(shortcutDm, 0.001)),
          reason:
              'per-animal sum ${agg.groupTotals['dry_matter_kg']} must differ '
              'from one profile (${representative.profileCode}) × head count '
              '($shortcutDm)',
        );
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );

    bddAsyncDomainScenario(
      'Inactive or sold animals are excluded from group requirement sum',
      tags: ['positive'],
      body: () async {
        const groupId = 'g-active-only';
        final group = _group(
          id: groupId,
          species: Species.goat,
          purpose: GroupPurpose.maintenance,
          headCount: 2,
        );
        final members = [
          _animal(
            id: 'active',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '18m',
          ),
          _animal(
            id: 'sold',
            groupId: groupId,
            species: Species.goat,
            ageLabel: '18m',
            status: AnimalStatus.sold,
          ),
        ];

        final agg = GroupNutritionRequirementsAggregator.aggregate(
          catalog: catalog,
          group: group,
          members: members,
        );

        expect(agg.headCount, 1);
        expect(agg.members.single.animalId, 'active');
        _expectGroupEqualsSumOfMembers(agg, 'dry_matter_kg');
      },
    );
  });
}

void _expectGroupEqualsSumOfMembers(
  AggregatedGroupNutritionRequirements agg,
  String nutrientKey,
) {
  final summed = agg.members.fold<num>(
    0,
    (total, row) => total + (row.perAnimal[nutrientKey] ?? 0),
  );
  expect(
    agg.groupTotals[nutrientKey],
    closeTo(summed, 0.001),
    reason: 'group $nutrientKey should equal sum of per-animal $nutrientKey',
  );
}

AnimalGroup _group({
  required String id,
  required Species species,
  required GroupPurpose purpose,
  required int headCount,
}) {
  return AnimalGroup(
    id: id,
    name: 'Test $id',
    species: species,
    purpose: purpose,
    headCount: headCount,
  );
}

Animal _animal({
  required String id,
  required String groupId,
  Species species = Species.cattle,
  String sex = 'F',
  String ageLabel = '24m',
  List<AnimalTagType> tags = const [],
  SpeciesPurpose production = SpeciesPurpose.meat,
  AnimalStatus status = AnimalStatus.active,
  int? monthsSinceCalving,
}) {
  return Animal(
    id: id,
    tag: 'T-$id',
    name: id,
    species: species,
    sex: sex,
    breed: 'Test',
    weightKg: 400,
    ageLabel: ageLabel,
    groupId: groupId,
    tags: tags,
    productionPurpose: production,
    status: status,
    monthsSinceCalving: monthsSinceCalving,
  );
}
