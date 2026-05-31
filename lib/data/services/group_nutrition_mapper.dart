import 'dart:convert';

import '../models/models.dart';

/// Maps optimizer JSON (`assets/data/group_nutrition/{groupId}.json`) to UI models.
abstract final class GroupNutritionMapper {
  static NutritionGap gapFromPayload(Map<String, dynamic> payload) {
    final groupId = payload['group_id'] as String;
    final current = _map(payload['current']);
    final required = _map(payload['required']);
    final plan = _map(payload['plan']);
    final headCount = (payload['head_count'] as num?)?.toInt() ?? 1;
    final costPerDay =
        (payload['recommendation']?['cost_per_day'] as num?)?.toDouble() ?? 0;
    final costPerHead = headCount > 0 ? costPerDay / headCount : costPerDay;

    return NutritionGap(
      groupId: groupId,
      dryMatterActualKg: _num(current['dry_matter_kg']),
      dryMatterTargetKg: _num(required['dry_matter_kg']),
      energyActualMj: _num(current['energy_mj']),
      energyTargetMj: _num(required['energy_mj']),
      proteinActualKg: _optional(current['protein_kg']),
      proteinTargetKg: _optional(required['protein_kg']),
      ndfActualKg: _optional(current['ndf_kg']),
      ndfTargetKg: _optional(required['ndf_kg']),
      calciumActualKg: _mineralKg(
        payload,
        current,
        nutrient: 'calcium',
        kgKey: 'calcium_kg',
        gKey: 'calciumKg',
        totalsKey: 'calciumKg',
      ),
      calciumTargetKg: _mineralTargetKg(
        payload,
        required,
        nutrient: 'calcium',
        kgKey: 'calcium_kg',
      ),
      phosphorusActualKg: _mineralKg(
        payload,
        current,
        nutrient: 'phosphorus',
        kgKey: 'phosphorus_kg',
        gKey: 'phosphorusKg',
        totalsKey: 'phosphorusKg',
      ),
      phosphorusTargetKg: _mineralTargetKg(
        payload,
        required,
        nutrient: 'phosphorus',
        kgKey: 'phosphorus_kg',
      ),
      fixGapMessage: _fixGapMessage(payload, current, required),
      dailyCostPerHeadSar: costPerHead,
      dailyCostChangePct: null,
      optimizerPass: payload['optimizer_pass'] as String?,
      profileCode: payload['profile_code'] as String?,
      planDryMatterKg: _optional(plan['dry_matter_kg']),
      needsMarketSupplement:
          payload['catalog_achievement']?['needs_market_supplement'] == true,
    );
  }

  static List<FeedRecommendation> recommendationsFromPayload(
    Map<String, dynamic> payload,
  ) {
    final lines = payload['feed_lines'] as List<dynamic>? ?? [];
    final recs = <FeedRecommendation>[];
    for (var i = 0; i < lines.length; i++) {
      final line = Map<String, dynamic>.from(lines[i] as Map);
      final name = line['name'] as String? ?? 'Feed';
      recs.add(
        FeedRecommendation(
          id: line['product_number']?.toString() ?? 'line-$i',
          name: name,
          supplier: line['feed_type'] as String? ?? 'Catalogue',
          costPerDay: _num(line['cost_per_day']),
          kgPerDay: _num(line['kg_per_day']),
          isTopPick: i == 0,
          feedType: line['feed_type'] as String?,
        ),
      );
    }
    return recs;
  }

  static List<NutrientBridgeGap> bridgeGapsFromPayload(
    Map<String, dynamic> payload,
  ) {
    final gaps = payload['nutrient_gaps'] as List<dynamic>? ?? [];
    return gaps.map((raw) {
      final g = Map<String, dynamic>.from(raw as Map);
      return NutrientBridgeGap(
        nutrient: g['nutrient'] as String? ?? '',
        target: _num(g['target']),
        actual: _num(g['actual']),
        unit: g['unit'] as String? ?? '',
        percentOfTarget: _num(g['percent_of_target']),
        bridgeNote: g['bridge_note'] as String?,
      );
    }).toList();
  }

  static Map<String, dynamic> decodeJson(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;

  static Map<String, double> _map(dynamic value) {
    if (value is! Map) return {};
    return value.map((k, v) => MapEntry(k.toString(), _num(v)));
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static double? _optional(dynamic value) {
    if (value == null) return null;
    return _num(value);
  }

  static double? _mineralKg(
    Map<String, dynamic> payload,
    Map<String, double> current, {
    required String nutrient,
    required String kgKey,
    required String gKey,
    required String totalsKey,
  }) {
    final fromCurrent = _optional(current[kgKey]);
    if (fromCurrent != null) return fromCurrent;

    final totals = payload['recommendation']?['totals'];
    if (totals is Map) {
      final fromTotals = _optional(totals[totalsKey]);
      if (fromTotals != null) return fromTotals;
    }

    final fromGaps = _nutrientFromGaps(payload, nutrient, actual: true);
    if (fromGaps != null) return fromGaps;

    return _optional(current[gKey]);
  }

  static double? _mineralTargetKg(
    Map<String, dynamic> payload,
    Map<String, double> required, {
    required String nutrient,
    required String kgKey,
  }) {
    final fromRequired = _optional(required[kgKey]);
    if (fromRequired != null) return fromRequired;
    return _nutrientFromGaps(payload, nutrient, actual: false);
  }

  static double? _nutrientFromGaps(
    Map<String, dynamic> payload,
    String nutrient, {
    required bool actual,
  }) {
    final gaps = payload['nutrient_gaps'] as List<dynamic>? ?? [];
    for (final raw in gaps) {
      if (raw is! Map) continue;
      final g = Map<String, dynamic>.from(raw);
      final name = (g['nutrient'] as String?)?.toLowerCase();
      if (name != nutrient.toLowerCase()) continue;
      final value = _num(g[actual ? 'actual' : 'target']);
      final unit = (g['unit'] as String?)?.toLowerCase() ?? 'kg/day';
      if (unit.startsWith('g')) return value / 1000;
      return value;
    }
    return null;
  }

  static String? _fixGapMessage(
    Map<String, dynamic> payload,
    Map<String, double> current,
    Map<String, double> required,
  ) {
    final needsSupplement =
        payload['catalog_achievement']?['needs_market_supplement'] == true;
    final energyTarget = required['energy_mj'] ?? 0;
    final energyActual = current['energy_mj'] ?? 0;
    if (energyTarget <= 0) return null;

    final energyPct = ((energyActual - energyTarget) / energyTarget) * 100;
    if (energyPct >= -10 && !needsSupplement) return null;

    final pass = payload['optimizer_pass'] as String?;
    if (pass == 'partial' || needsSupplement) {
      return 'Catalog feeds reach about ${(energyActual / energyTarget * 100).toStringAsFixed(0)}% of energy target. Use market supplements to close remaining gaps.';
    }
    if (energyPct < -10) {
      return 'Group is ${energyPct.abs().toStringAsFixed(0)}% below energy target. Review today\'s mix or apply the recommended plan below.';
    }
    return null;
  }
}

/// Remaining nutrient shortfall after catalogue optimization.
class NutrientBridgeGap {
  const NutrientBridgeGap({
    required this.nutrient,
    required this.target,
    required this.actual,
    required this.unit,
    required this.percentOfTarget,
    this.bridgeNote,
  });

  final String nutrient;
  final double target;
  final double actual;
  final String unit;
  final double percentOfTarget;
  final String? bridgeNote;
}
