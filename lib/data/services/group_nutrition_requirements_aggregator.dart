import '../models/enums.dart';
import '../models/models.dart';
import 'nutrition_context_builder.dart';
import 'nutrition_profile_resolver.dart';
import 'nutrition_requirements_catalog.dart';

/// Per-animal requirement row used when summing a mixed group.
class MemberNutritionRequirement {
  const MemberNutritionRequirement({
    required this.animalId,
    required this.profileCode,
    required this.feedCycle,
    required this.matchReason,
    required this.perAnimal,
  });

  final String animalId;
  final String profileCode;
  final String? feedCycle;
  final String matchReason;
  final Map<String, num> perAnimal;
}

/// Group totals derived by summing individual member requirements.
class AggregatedGroupNutritionRequirements {
  const AggregatedGroupNutritionRequirements({
    required this.groupId,
    required this.species,
    required this.optimizer,
    required this.headCount,
    required this.members,
    required this.groupTotals,
  });

  final String groupId;
  final String species;
  final String optimizer;
  final int headCount;
  final List<MemberNutritionRequirement> members;
  final Map<String, num> groupTotals;
}

/// Sums per-animal nutrition targets for heterogeneous groups.
abstract final class GroupNutritionRequirementsAggregator {
  static const _cattleSumKeys = [
    'dry_matter_kg',
    'crude_protein_kg',
    'ndf_kg',
    'fibre_kg',
    'calcium_kg',
    'phosphorus_kg',
    'nem_mcal',
    'neg_mcal',
  ];

  static const _smallRuminantSumKeys = [
    'dry_matter_kg',
    'protein_kg',
    'tdn_kg',
    'calcium_g',
    'phosphorus_g',
  ];

  static AggregatedGroupNutritionRequirements aggregate({
    required NutritionRequirementsCatalog catalog,
    required AnimalGroup group,
    required List<Animal> members,
  }) {
    final active = members
        .where(
          (a) =>
              a.groupId == group.id &&
              a.status == AnimalStatus.active &&
              a.species == group.species,
        )
        .toList();

    if (active.isEmpty) {
      return AggregatedGroupNutritionRequirements(
        groupId: group.id,
        species: _speciesWire(group.species),
        optimizer: 'cattle',
        headCount: 0,
        members: const [],
        groupTotals: const {},
      );
    }

    final memberRows = <MemberNutritionRequirement>[];
    var optimizer = 'cattle';

    for (final animal in active) {
      final ctx = NutritionContextBuilder.fromMemberInGroup(animal, group);
      final resolved = NutritionProfileResolver.resolve(catalog, ctx);
      final requirements = NutritionProfileResolver.buildGroupRequirements(
        resolved.profile,
        1,
        fattening: ctx.fattening,
      );
      optimizer = requirements['optimizer'] as String;
      final perAnimal = Map<String, num>.from(
        (requirements['per_animal'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num)),
        ),
      );
      memberRows.add(
        MemberNutritionRequirement(
          animalId: animal.id,
          profileCode: resolved.profileCode,
          feedCycle: resolved.profile.feedCycle,
          matchReason: resolved.matchReason,
          perAnimal: perAnimal,
        ),
      );
    }

    final sumKeys =
        optimizer == 'small_ruminant' ? _smallRuminantSumKeys : _cattleSumKeys;
    final totals = <String, num>{};
    for (final key in sumKeys) {
      totals[key] = memberRows.fold<num>(
        0,
        (sum, row) => sum + (row.perAnimal[key] ?? 0),
      );
    }
    totals['no_of_animals'] = memberRows.length;

    return AggregatedGroupNutritionRequirements(
      groupId: group.id,
      species: _speciesWire(group.species),
      optimizer: optimizer,
      headCount: memberRows.length,
      members: memberRows,
      groupTotals: totals,
    );
  }

  static String _speciesWire(Species species) => switch (species) {
        Species.cattle => 'CATTLE',
        Species.goat => 'GOAT',
        Species.sheep => 'SHEEP',
      };
}
