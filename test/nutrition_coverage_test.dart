import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/nutrition_context_builder.dart';
import 'package:greenerherd_mobile/data/services/nutrition_feed_cycle.dart';
import 'package:greenerherd_mobile/data/services/nutrition_profile_resolver.dart';
import 'package:greenerherd_mobile/data/services/nutrition_requirements_catalog.dart';

/// Documents which app livestock combinations resolve to a masterfile profile.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrition coverage vs app livestock options', () {
    late NutritionRequirementsCatalog catalog;

    setUpAll(() async {
      catalog = await NutritionRequirementsCatalog.load();
    });

    test('every profile has a feed_cycle code', () {
      for (final p in catalog.list()) {
        expect(
          p.feedCycle,
          isNotNull,
          reason: 'missing feed_cycle on ${p.profileCode}',
        );
        expect(p.feedCycle, isNotEmpty);
      }
    });

    test('all group purposes resolve for cattle dairy and meat herds', () {
      final failures = <String>[];
      for (final purpose in GroupPurpose.values) {
        for (final prod in SpeciesPurpose.values) {
          final group = _mockGroup(
            species: Species.cattle,
            purpose: purpose,
            production: prod,
          );
          try {
            final ctx = NutritionContextBuilder.fromGroup(group);
            NutritionProfileResolver.resolve(catalog, ctx);
          } catch (e) {
            failures.add('cattle/${purpose.name}/${prod.name}: $e');
          }
        }
      }
      expect(
        failures,
        isEmpty,
        reason: 'Unresolved cattle groups:\n${failures.join('\n')}',
      );
    });

    test('goat and sheep group purposes resolve', () {
      final failures = <String>[];
      for (final species in [Species.goat, Species.sheep]) {
        for (final purpose in GroupPurpose.values) {
          final group = _mockGroup(species: species, purpose: purpose);
          try {
            final ctx = NutritionContextBuilder.fromGroup(group);
            NutritionProfileResolver.resolve(catalog, ctx);
          } catch (e) {
            failures.add('${species.name}/${purpose.name}: $e');
          }
        }
      }
      expect(failures, isEmpty);
    });

    test('dedicated feed_cycle profiles exist for sick weaning breeding', () {
      for (final cycle in [
        NutritionFeedCycle.sick,
        NutritionFeedCycle.weaning,
        NutritionFeedCycle.breeding,
      ]) {
        expect(
          catalog.listByFeedCycle(cycle),
          isNotEmpty,
          reason: 'expected dedicated profiles for $cycle',
        );
      }
    });

    test('sick weaning and breeding groups resolve to dedicated profiles', () {
      const dedicated = {
        GroupPurpose.sick: NutritionFeedCycle.sick,
        GroupPurpose.weaning: NutritionFeedCycle.weaning,
        GroupPurpose.breeding: NutritionFeedCycle.breeding,
      };
      for (final entry in dedicated.entries) {
        final group = _mockGroup(
          species: Species.goat,
          purpose: entry.key,
        );
        final ctx = NutritionContextBuilder.fromGroup(group);
        expect(ctx.feedCycleHint, entry.value);
        final resolved = NutritionProfileResolver.resolve(catalog, ctx);
        expect(resolved.profile.feedCycle, entry.value);
        expect(resolved.profile.dmiKgDay, greaterThan(0));
      }
    });

    test('male dairy cattle uses breeding bull profile', () {
      final ctx = NutritionProfileContext(
        species: 'CATTLE',
        sex: 'MALE',
        ageMonths: 48,
        productionFocus: 'MILK',
        lactating: false,
        feedCycleHint: NutritionFeedCycle.bullMaintenance,
      );
      final resolved = NutritionProfileResolver.resolve(catalog, ctx);
      expect(resolved.profileCode, 'CATTLE_DAIRY_BREEDING_BULL');
    });
  });
}

AnimalGroup _mockGroup({
  required Species species,
  required GroupPurpose purpose,
  SpeciesPurpose production = SpeciesPurpose.both,
}) {
  return AnimalGroup(
    id: 'g-test',
    name: 'Test',
    species: species,
    purpose: purpose,
    headCount: 5,
  );
}
