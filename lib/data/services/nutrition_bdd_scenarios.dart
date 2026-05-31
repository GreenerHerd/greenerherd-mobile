import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// One row from `assets/data/nutrition_bdd_scenarios.json` (exported from gh-shared).
class NutritionBddScenario {
  const NutritionBddScenario({
    required this.id,
    required this.name,
    required this.request,
    required this.expectedProfileCode,
    required this.expectSuccess,
  });

  factory NutritionBddScenario.fromJson(Map<String, dynamic> json) {
    return NutritionBddScenario(
      id: json['id'] as String,
      name: json['name'] as String,
      request: Map<String, dynamic>.from(json['request'] as Map),
      expectedProfileCode: json['expected_profile_code'] as String,
      expectSuccess: json['expect_success'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final Map<String, dynamic> request;
  final String expectedProfileCode;
  final bool expectSuccess;
}

abstract final class NutritionBddScenarios {
  static Future<List<NutritionBddScenario>> load() async {
    final raw =
        await rootBundle.loadString('assets/data/nutrition_bdd_scenarios.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['scenarios'] as List)
        .map(
          (e) => NutritionBddScenario.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
