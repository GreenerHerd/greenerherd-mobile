import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/enums.dart';
import '../models/models.dart';
import 'group_nutrition_requirements_aggregator.dart';
import 'nutrition_context_builder.dart';
import 'nutrition_requirements_catalog.dart';

/// Optimizer request profile aligned with `assets/data/group_nutrition_profiles.json`.
class GroupNutritionProfile {
  const GroupNutritionProfile({
    required this.request,
    this.currentIntakeRatio,
    this.currentTotals,
    this.aggregatedRequirements,
  });

  final Map<String, dynamic> request;
  final double? currentIntakeRatio;
  final Map<String, dynamic>? currentTotals;

  /// Per-animal summed requirements when resolved with [GroupNutritionRequirementsAggregator].
  /// Not sent to the API yet — nutrition UI wiring is a follow-up.
  final AggregatedGroupNutritionRequirements? aggregatedRequirements;

  Map<String, dynamic> toRequestBody() {
    return {
      ...request,
      if (currentIntakeRatio != null) 'current_intake_ratio': currentIntakeRatio,
      if (currentTotals != null) 'current_totals': currentTotals,
    };
  }

  GroupNutritionProfile copyWith({
    Map<String, dynamic>? request,
    double? currentIntakeRatio,
    Map<String, dynamic>? currentTotals,
    AggregatedGroupNutritionRequirements? aggregatedRequirements,
  }) {
    return GroupNutritionProfile(
      request: request ?? this.request,
      currentIntakeRatio: currentIntakeRatio ?? this.currentIntakeRatio,
      currentTotals: currentTotals ?? this.currentTotals,
      aggregatedRequirements:
          aggregatedRequirements ?? this.aggregatedRequirements,
    );
  }
}

/// Resolves API bodies for group nutrition / feed-plan endpoints.
abstract final class GroupNutritionProfileResolver {
  static Map<String, GroupNutritionProfile>? _byGroupId;

  /// Resolves a group nutrition profile. When [members] are supplied, herd-derived
  /// fields (including median [months_since_calving]) override static seed values.
  static Future<GroupNutritionProfile?> resolve(
    String groupId, {
    AnimalGroup? group,
    List<Animal>? members,
    NutritionRequirementsCatalog? catalog,
  }) async {
    await _ensureLoaded();
    final known = _byGroupId![groupId];
    GroupNutritionProfile? profile;
    if (known != null) {
      profile = _mergeHerdContext(known, group, members);
    } else if (group != null) {
      profile = _fromAnimalGroup(group, members: members);
    }
    if (profile == null || group == null || members == null || catalog == null) {
      return profile;
    }
    final aggregated = GroupNutritionRequirementsAggregator.aggregate(
      catalog: catalog,
      group: group,
      members: members,
    );
    return profile.copyWith(aggregatedRequirements: aggregated);
  }

  static Future<void> _ensureLoaded() async {
    if (_byGroupId != null) return;
    final raw = await rootBundle.loadString(
      'assets/data/group_nutrition_profiles.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _byGroupId = decoded.map((groupId, value) {
      final entry = Map<String, dynamic>.from(value as Map);
      final request = Map<String, dynamic>.from(entry['request'] as Map);
      return MapEntry(
        groupId,
        GroupNutritionProfile(
          request: request,
          currentIntakeRatio: (entry['current_intake_ratio'] as num?)?.toDouble(),
        ),
      );
    });
  }

  static GroupNutritionProfile _mergeHerdContext(
    GroupNutritionProfile profile,
    AnimalGroup? group,
    List<Animal>? members,
  ) {
    if (group == null) return profile;
    final request = Map<String, dynamic>.from(profile.request);
    request['head_count'] = group.headCount;
    if (members == null || members.isEmpty) return profile.copyWith(request: request);

    final ctx = NutritionContextBuilder.fromGroup(group, members: members);
    request['species'] = ctx.species;
    if (ctx.sex != null) {
      request['sex'] = ctx.sex;
    } else {
      request.remove('sex');
    }
    request['age_months'] = ctx.ageMonths;
    request['production_focus'] = ctx.productionFocus;
    request['lactating'] = ctx.lactating;
    if (ctx.pregnant) {
      request['pregnant'] = true;
    } else {
      request.remove('pregnant');
    }
    if (ctx.fattening) {
      request['fattening'] = true;
    } else {
      request.remove('fattening');
    }
    if (ctx.monthsSinceCalving != null) {
      request['months_since_calving'] = ctx.monthsSinceCalving;
    } else {
      request.remove('months_since_calving');
    }
    return profile.copyWith(request: request);
  }

  static GroupNutritionProfile _fromAnimalGroup(
    AnimalGroup group, {
    List<Animal>? members,
  }) {
    final ctx = NutritionContextBuilder.fromGroup(group, members: members);
    return GroupNutritionProfile(
      request: {
        'species': ctx.species,
        if (ctx.sex != null) 'sex': ctx.sex,
        'age_months': ctx.ageMonths,
        'production_focus': ctx.productionFocus,
        'lactating': ctx.lactating,
        if (ctx.pregnant) 'pregnant': true,
        if (ctx.fattening) 'fattening': true,
        if (ctx.monthsSinceCalving != null)
          'months_since_calving': ctx.monthsSinceCalving,
        if (ctx.feedCycleHint != null) 'feed_cycle_hint': ctx.feedCycleHint,
        'head_count': group.headCount,
        'country_code': ctx.countryCode,
      },
      currentIntakeRatio: 0.85,
    );
  }
}
