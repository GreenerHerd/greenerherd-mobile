import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/services/nutrition_bdd_scenarios.dart';
import 'package:greenerherd_mobile/data/services/nutrition_profile_resolver.dart';
import 'package:greenerherd_mobile/data/services/nutrition_requirements_catalog.dart';

import 'support/bdd_harness.dart';

List<NutritionBddScenario> _loadScenariosFromDisk() {
  final raw = File('assets/data/nutrition_bdd_scenarios.json').readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return (json['scenarios'] as List)
      .map(
        (e) => NutritionBddScenario.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
      .toList();
}

void main() {
  initBddTests();
  final matrixScenarios = _loadScenariosFromDisk();

  group('Feature: Nutrition requirements (Livestock Nutrition Requirements.xlsx)', () {
    late NutritionRequirementsCatalog catalog;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      catalog = await NutritionRequirementsCatalog.load();
    });

    bddAsyncDomainScenario(
      'Masterfile catalog loads from xlsx export',
      tags: ['positive'],
      body: () async {
        expect(catalog.size, greaterThanOrEqualTo(218));
        final dairy = catalog.listForSpecies('CATTLE').where(
              (p) => p.productionSystem == 'DAIRY',
            );
        expect(dairy.length, greaterThanOrEqualTo(10));
        expect(
          catalog.getByCode('CATTLE_DAIRY_DRY_FAR_OFF'),
          isNotNull,
        );
        expect(
          catalog.getByCode('GOAT_SMALL_RUMINANT_LACTATING'),
          isNotNull,
        );
      },
    );

    bddAsyncDomainScenario(
      'Every dairy masterfile stage exists in catalog with DMI',
      tags: ['positive'],
      body: () async {
        const stages = {
          'CATTLE_DAIRY_DRY_FAR_OFF': 14.0,
          'CATTLE_DAIRY_CLOSE_CLOSE_UP': 10.0,
          'CATTLE_DAIRY_COW_FRESH': 15.0,
          'CATTLE_DAIRY_COW_EARLY': 30.0,
          'CATTLE_DAIRY_COW_MID': 24.0,
          'CATTLE_DAIRY_COW_LATE': 20.0,
          'CATTLE_DAIRY_6_MO_HEIFER': 5.0,
          'CATTLE_DAIRY_12_MO_HEIFER': 7.0,
          'CATTLE_DAIRY_18_MO_HEIFER': 11.0,
          'CATTLE_DAIRY_24_MO_HEIFER_CLOSE_UP': 10.0,
        };
        for (final entry in stages.entries) {
          final profile = catalog.getByCode(entry.key);
          expect(profile, isNotNull, reason: 'missing ${entry.key}');
          expect(profile!.dmiKgDay, closeTo(entry.value, 0.01));
          expect(profile.sourceSheet, 'Dairy Cattle');
        }
      },
    );

    bddAsyncDomainScenario(
      'Beef mature cow early lactation month 2 matches spreadsheet row',
      tags: ['positive'],
      body: () async {
        final profile = catalog.getByCode(
          'CATTLE_BEEF_MATURE_COW_EARLY_LACTATION_M2',
        );
        expect(profile, isNotNull);
        expect(profile!.dmiKgDay, closeTo(12.6098576, 0.01));
        expect(profile.cpKgDay, closeTo(1.36984784, 0.01));
        expect(profile.nemMcalDay, closeTo(16.6, 0.01));
      },
    );

    bddAsyncDomainScenario(
      'Small ruminant profiles cover maintenance lactating pregnant fattening',
      tags: ['positive'],
      body: () async {
        for (final species in ['GOAT', 'SHEEP']) {
          for (final suffix in [
            'SMALL_RUMINANT_MAINTENANCE',
            'SMALL_RUMINANT_LACTATING',
            'SMALL_RUMINANT_PREGNANT',
            'SMALL_RUMINANT_FATTENING',
          ]) {
            expect(
              catalog.getByCode('${species}_$suffix'),
              isNotNull,
              reason: '${species}_$suffix',
            );
          }
        }
      },
    );
  });

  group('Feature: Nutrition scenario matrix', () {
    late NutritionRequirementsCatalog catalog;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      catalog = await NutritionRequirementsCatalog.load();
      expect(matrixScenarios.length, greaterThanOrEqualTo(30));
    });

    for (final scenario in matrixScenarios) {
      bddAsyncDomainScenario(
        '${scenario.id}: ${scenario.name}',
        tags: ['positive'],
        body: () async {
          final ctx = NutritionProfileContext.fromRequest(scenario.request);
          final resolved = NutritionProfileResolver.resolve(catalog, ctx);
          expect(
            resolved.profileCode,
            scenario.expectedProfileCode,
            reason: '${scenario.id} profile mismatch (${resolved.matchReason})',
          );

          final requirements = NutritionProfileResolver.buildGroupRequirements(
            resolved.profile,
            ctx.headCount,
            fattening: ctx.fattening,
          );
          final perAnimal =
              requirements['per_animal'] as Map<String, dynamic>;
          expect(perAnimal['dry_matter_kg'], greaterThan(0));

          if (resolved.profile.productionSystem == 'DAIRY') {
            expect(requirements['optimizer'], 'cattle');
            expect(perAnimal['crude_protein_kg'], greaterThan(0));
            expect(perAnimal['nem_mcal'], greaterThan(0));
          } else if (resolved.profile.productionSystem == 'BEEF') {
            expect(perAnimal['crude_protein_kg'], greaterThan(0));
          } else {
            expect(requirements['optimizer'], 'small_ruminant');
            expect(perAnimal['protein_kg'], greaterThan(0));
          }

          final group = requirements['group'] as Map<String, dynamic>;
          expect(group['no_of_animals'], ctx.headCount);
          final dmGroup = group['dry_matter_kg'] as num;
          final dmPer = perAnimal['dry_matter_kg'] as num;
          expect(dmGroup, closeTo(dmPer * ctx.headCount, 0.001));
        },
      );
    }
  });
}
