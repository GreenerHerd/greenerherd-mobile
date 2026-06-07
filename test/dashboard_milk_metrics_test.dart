import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/animal_lactation_cycle.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/lactation_models.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/dashboard_milk_metrics.dart';
import 'package:greenerherd_mobile/data/services/dashboard_stats_builder.dart';
import 'package:greenerherd_mobile/data/services/reproduction_status_rules.dart';

void main() {
  test('herdAvgLactatingDailyMilk uses prior records not today', () {
    final now = DateTime(2026, 5, 29);
    const cow = Animal(
      id: 'c1',
      tag: '1',
      name: 'Cow',
      species: Species.cattle,
      sex: 'F',
      breed: 'H',
      weightKg: 400,
      ageLabel: '3y',
      groupId: 'g1',
      tags: [AnimalTagType.lactating],
      lactationCycle: AnimalLactationCycle.cattleMid,
      milkTodayLitres: 99,
    );
    final history = [
      MilkYieldRecord(
        date: now.subtract(const Duration(days: 3)),
        litres: 20,
        lactationDay: 100,
      ),
      MilkYieldRecord(
        date: now.subtract(const Duration(days: 10)),
        litres: 30,
        lactationDay: 93,
      ),
    ];

    final avg = DashboardMilkMetrics.herdAvgLactatingDailyMilk(
      animals: [cow],
      historyFor: (_) => history,
      onDate: now,
    );

    expect(avg, closeTo(25, 0.01));
  });

  test('DashboardStatsBuilder counts weaning tag and 0-3 month age', () {
    final animals = [
      Animal(
        id: 'w1',
        tag: 'W1',
        name: 'Tagged',
        species: Species.cattle,
        sex: 'F',
        breed: 'H',
        weightKg: 80,
        ageLabel: '8m',
        groupId: 'g1',
        tags: const [AnimalTagType.weaning],
        dob: DateTime.now().subtract(const Duration(days: 240)),
      ),
      Animal(
        id: 'w2',
        tag: 'W2',
        name: 'Young',
        species: Species.cattle,
        sex: 'F',
        breed: 'H',
        weightKg: 40,
        ageLabel: '2m',
        groupId: 'g1',
        dob: DateTime.now().subtract(const Duration(days: 60)),
      ),
      const Animal(
        id: 'a1',
        tag: 'A1',
        name: 'Adult',
        species: Species.cattle,
        sex: 'F',
        breed: 'H',
        weightKg: 400,
        ageLabel: '3y',
        groupId: 'g1',
      ),
    ];

    expect(ReproductionStatusRules.isWeaningForDashboard(animals[0]), isTrue);
    expect(ReproductionStatusRules.isWeaningForDashboard(animals[1]), isTrue);
    expect(ReproductionStatusRules.isWeaningForDashboard(animals[2]), isFalse);

    final stats = DashboardStatsBuilder.fromLists(
      animals: animals,
      tasks: const [],
    );
    expect(stats.weaning, 2);
  });
}
