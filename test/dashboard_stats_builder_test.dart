import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/dashboard_stats_builder.dart';

void main() {
  test('bySpecies counts stay full herd when speciesFilter is set', () {
    final animals = [
      const Animal(
        id: 'c1',
        tag: 'C1',
        name: 'Cow',
        species: Species.cattle,
        sex: 'Female',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '3y',
        groupId: 'g1',
      ),
      const Animal(
        id: 'g1',
        tag: 'G1',
        name: 'Goat',
        species: Species.goat,
        sex: 'Female',
        breed: 'Boer',
        weightKg: 50,
        ageLabel: '2y',
        groupId: 'g2',
        tags: [AnimalTagType.pregnant],
      ),
      const Animal(
        id: 's1',
        tag: 'S1',
        name: 'Sheep',
        species: Species.sheep,
        sex: 'Female',
        breed: 'Awassi',
        weightKg: 60,
        ageLabel: '2y',
        groupId: 'g3',
      ),
    ];

    final allStats = DashboardStatsBuilder.fromLists(
      animals: animals,
      tasks: const [],
    );
    final cattleStats = DashboardStatsBuilder.fromLists(
      animals: animals,
      tasks: const [],
      speciesFilter: Species.cattle,
    );

    expect(allStats.bySpecies[null], 3);
    expect(cattleStats.bySpecies[null], 3);
    expect(cattleStats.bySpecies[Species.cattle], 1);
    expect(cattleStats.bySpecies[Species.goat], 1);
    expect(cattleStats.bySpecies[Species.sheep], 1);

    expect(allStats.pregnant, 1);
    expect(cattleStats.pregnant, 0);
  });
}
