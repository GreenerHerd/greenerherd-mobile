import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/enums.dart';
import '../models/models.dart';
import 'nutrition_context_builder.dart';

/// Optimizer request profile aligned with `assets/data/group_nutrition_profiles.json`.
class GroupNutritionProfile {
  const GroupNutritionProfile({
    required this.request,
    this.currentIntakeRatio,
    this.currentTotals,
  });

  final Map<String, dynamic> request;
  final double? currentIntakeRatio;
  final Map<String, dynamic>? currentTotals;

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
  }) {
    return GroupNutritionProfile(
      request: request ?? this.request,
      currentIntakeRatio: currentIntakeRatio ?? this.currentIntakeRatio,
      currentTotals: currentTotals ?? this.currentTotals,
    );
  }
}

/// Resolves API bodies for group nutrition / feed-plan endpoints.
abstract final class GroupNutritionProfileResolver {
  static Map<String, GroupNutritionProfile>? _byGroupId;

  static Future<GroupNutritionProfile?> resolve(
    String groupId, {
    AnimalGroup? group,
  }) async {
    await _ensureLoaded();
    final known = _byGroupId![groupId];
    if (known != null) {
      return _mergeGroupHeadCount(known, group);
    }
    if (group != null) {
      return _fromAnimalGroup(group);
    }
    return null;
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

  static GroupNutritionProfile _mergeGroupHeadCount(
    GroupNutritionProfile profile,
    AnimalGroup? group,
  ) {
    if (group == null) return profile;
    final request = Map<String, dynamic>.from(profile.request);
    request['head_count'] = group.headCount;
    return profile.copyWith(request: request);
  }

  static GroupNutritionProfile _fromAnimalGroup(AnimalGroup group) {
    final ctx = NutritionContextBuilder.fromGroup(group);
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
