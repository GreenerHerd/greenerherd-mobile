import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';

void main() {
  test('1-2yr label maps to 1-2y dashboard bucket without dob', () {
    const animal = Animal(
      id: 's1',
      tag: '001',
      name: 'Lamb',
      species: Species.sheep,
      sex: 'Female',
      breed: 'Najdi',
      weightKg: 40,
      ageLabel: '1-2yr',
      groupId: 'g1',
    );
    expect(AnimalMapper.dashboardAgeBucketIndex(animal.ageLabel), 2);
    expect(AnimalMapper.ageMonthsForAnimal(animal), 18);
  });

  test('missing dob does not default to 2-5y bucket', () {
    final animals = List.generate(
      20,
      (i) => Animal(
        id: 's$i',
        tag: '$i',
        name: '—',
        species: Species.sheep,
        sex: i.isEven ? 'Female' : 'Male',
        breed: 'Najdi',
        weightKg: 40,
        ageLabel: '1-2yr',
        groupId: 'g1',
      ),
    );

    final buckets = List<int>.filled(5, 0);
    for (final a in animals) {
      final idx = AnimalMapper.dashboardAgeBucketIndex(a.ageLabel);
      expect(idx, isNotNull);
      buckets[idx!]++;
    }
    expect(buckets[2], 20);
    expect(buckets[3], 0);
  });

  test('verbose age label buckets by months when no range label', () {
    final animal = Animal(
      id: 's2',
      tag: '002',
      name: '—',
      species: Species.sheep,
      sex: 'Male',
      breed: 'Najdi',
      weightKg: 48,
      ageLabel: '2y 8m',
      dob: DateTime.now().subtract(const Duration(days: 913)),
      groupId: 'g1',
    );
    expect(AnimalMapper.dashboardAgeBucketIndex(animal.ageLabel), isNull);
    final months = AnimalMapper.ageMonthsForAnimal(animal);
    expect(months, greaterThanOrEqualTo(24));
    expect(months, lessThan(60));
  });
}
