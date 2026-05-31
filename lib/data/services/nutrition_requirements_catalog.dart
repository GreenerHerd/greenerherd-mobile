import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Requirement row extracted from Livestock Nutrition Requirements.xlsx.
class NutritionRequirementProfile {
  const NutritionRequirementProfile({
    required this.id,
    required this.profileCode,
    required this.species,
    required this.productionSystem,
    required this.lifeStage,
    this.animalClass,
    this.bodyWeightKg,
    this.monthsSinceCalving,
    required this.dmiKgDay,
    this.cpPercentDm,
    this.nelMcalPerKgDm,
    this.ndfPercentDm,
    this.adfPercentDm,
    this.caPercentDm,
    this.pPercentDm,
    this.milkKgDay,
    this.tdnKgDay,
    this.nemMcalDay,
    this.negMcalDay,
    this.cpKgDay,
    this.caKgDay,
    this.pKgDay,
    this.fodderPercent,
    this.concentratePercent,
    this.sourceSheet,
    this.feedCycle,
  });

  final String id;
  final String profileCode;
  final String species;
  final String productionSystem;
  final String lifeStage;
  final String? animalClass;
  final double? bodyWeightKg;
  final int? monthsSinceCalving;
  final double dmiKgDay;
  final double? cpPercentDm;
  final double? nelMcalPerKgDm;
  final double? ndfPercentDm;
  final double? adfPercentDm;
  final double? caPercentDm;
  final double? pPercentDm;
  final double? milkKgDay;
  final double? tdnKgDay;
  final double? nemMcalDay;
  final double? negMcalDay;
  final double? cpKgDay;
  final double? caKgDay;
  final double? pKgDay;
  final double? fodderPercent;
  final double? concentratePercent;
  final String? sourceSheet;
  final String? feedCycle;

  factory NutritionRequirementProfile.fromJson(Map<String, dynamic> json) {
    double? numVal(dynamic v) {
      if (v == null) return null;
      final n = (v is num) ? v.toDouble() : double.tryParse(v.toString());
      return n;
    }

    int? intVal(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return NutritionRequirementProfile(
      id: json['id'] as String,
      profileCode: json['profile_code'] as String,
      species: json['species'] as String,
      productionSystem: json['production_system'] as String,
      lifeStage: json['life_stage'] as String,
      animalClass: json['animal_class'] as String?,
      bodyWeightKg: numVal(json['body_weight_kg']),
      monthsSinceCalving: intVal(json['months_since_calving']),
      dmiKgDay: numVal(json['dmi_kg_day']) ?? 0,
      cpPercentDm: numVal(json['cp_percent_dm']),
      nelMcalPerKgDm: numVal(json['nel_mcal_per_kg_dm']),
      ndfPercentDm: numVal(json['ndf_percent_dm']),
      adfPercentDm: numVal(json['adf_percent_dm']),
      caPercentDm: numVal(json['ca_percent_dm']),
      pPercentDm: numVal(json['p_percent_dm']),
      milkKgDay: numVal(json['milk_kg_day']),
      tdnKgDay: numVal(json['tdn_kg_day']),
      nemMcalDay: numVal(json['nem_mcal_day']),
      negMcalDay: numVal(json['neg_mcal_day']),
      cpKgDay: numVal(json['cp_kg_day']),
      caKgDay: numVal(json['ca_kg_day']),
      pKgDay: numVal(json['p_kg_day']),
      fodderPercent: numVal(json['fodder_percent']),
      concentratePercent: numVal(json['concentrate_percent']),
      sourceSheet: json['source_sheet'] as String?,
      feedCycle: json['feed_cycle'] as String?,
    );
  }
}

/// In-memory catalog backed by `assets/data/nutrition_requirements.json`.
class NutritionRequirementsCatalog {
  NutritionRequirementsCatalog._(this._all, this._byCode);

  final List<NutritionRequirementProfile> _all;
  final Map<String, NutritionRequirementProfile> _byCode;

  static NutritionRequirementsCatalog? _cache;

  static Future<NutritionRequirementsCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw =
        await rootBundle.loadString('assets/data/nutrition_requirements.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final rows = (json['profiles'] as List)
        .map(
          (e) => NutritionRequirementProfile.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
    if (rows.isEmpty) {
      throw StateError('NutritionRequirementsCatalog requires profiles');
    }
    final byCode = {for (final r in rows) r.profileCode: r};
    return _cache = NutritionRequirementsCatalog._(rows, byCode);
  }

  int get size => _all.length;

  List<NutritionRequirementProfile> list() => List.unmodifiable(_all);

  NutritionRequirementProfile? getByCode(String code) => _byCode[code];

  List<NutritionRequirementProfile> listByFeedCycle(String feedCycle) =>
      _all.where((p) => p.feedCycle == feedCycle).toList();

  List<NutritionRequirementProfile> listForSpecies(String species) =>
      _all.where((p) => p.species == species).toList();

  List<NutritionRequirementProfile> listBeef(
    String animalClass,
    String lifeStage, {
    int? monthsSinceCalving,
  }) {
    final matches = _all
        .where(
          (p) =>
              p.productionSystem == 'BEEF' &&
              p.animalClass == animalClass &&
              p.lifeStage == lifeStage,
        )
        .toList();
    if (matches.isEmpty) return [];
    if (monthsSinceCalving == null) return matches;
    final withMonth =
        matches.where((p) => p.monthsSinceCalving != null).toList();
    withMonth.sort(
      (a, b) =>
          ((a.monthsSinceCalving ?? 0) - monthsSinceCalving)
              .abs()
              .compareTo(
                ((b.monthsSinceCalving ?? 0) - monthsSinceCalving).abs(),
              ),
    );
    return withMonth;
  }

  List<NutritionRequirementProfile> listBeefGrowing(
    String animalClass, {
    double? weightKg,
  }) {
    final matches = _all
        .where(
          (p) =>
              p.productionSystem == 'BEEF' &&
              p.animalClass == animalClass &&
              p.lifeStage == 'Growing',
        )
        .toList();
    if (matches.isEmpty) return [];
    if (weightKg == null) return matches;
    final sorted = [...matches]
      ..sort(
        (a, b) =>
            ((a.bodyWeightKg ?? 0) - weightKg)
                .abs()
                .compareTo(((b.bodyWeightKg ?? 0) - weightKg).abs()),
      );
    return sorted;
  }
}
