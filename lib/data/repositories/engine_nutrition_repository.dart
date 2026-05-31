import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';
import '../services/group_nutrition_mapper.dart';
import '../services/supplement_nutrition.dart';
import 'hybrid_nutrition_repository.dart';
import 'repositories.dart';

/// Loads precomputed optimizer output from `assets/data/group_nutrition/`.
class EngineNutritionRepository implements NutritionRepository {
  // Legacy offline-only implementation; prefer [HybridNutritionRepository].
  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Set<String>> _addedIds = {};
  String? _lastGroupId;

  @override
  Future<NutritionGap> getGap(String groupId) async {
    final payload = await _load(groupId);
    return GroupNutritionMapper.gapFromPayload(payload);
  }

  @override
  Future<List<FeedRecommendation>> getRecommendations(String groupId) async {
    _lastGroupId = groupId;
    final payload = await _load(groupId);
    final recs = GroupNutritionMapper.recommendationsFromPayload(payload);
    final added = _addedIds[groupId] ?? {};
    return recs
        .map((r) => r.copyWith(added: added.contains(r.id)))
        .toList();
  }

  @override
  Future<List<NutrientBridgeGap>> getBridgeGaps(String groupId) async {
    final payload = await _load(groupId);
    return GroupNutritionMapper.bridgeGapsFromPayload(payload);
  }

  @override
  Future<void> updateRecommendation(FeedRecommendation item) async {
    final groupId = _lastGroupId;
    if (groupId == null) return;
    _addedIds.putIfAbsent(groupId, () => {});
    if (item.added) {
      _addedIds[groupId]!.add(item.id);
    } else {
      _addedIds[groupId]!.remove(item.id);
    }
  }

  @override
  Future<void> applySupplement({
    required String groupId,
    required SupplementNutritionInput input,
    bool subtract = false,
  }) async {
    final payload = await _load(groupId);
    final delta = SupplementNutrition.contribution(input);
    SupplementNutrition.applyToPayload(payload, delta, subtract: subtract);
    _cache[groupId] = payload;
  }

  @override
  Future<ApplyFeedPlanResult> applyFeedPlan(String groupId) async {
    final payload = await _load(groupId);
    final plan = payload['plan'];
    if (plan is Map) {
      payload['current'] = Map<String, dynamic>.from(plan);
      _cache[groupId] = payload;
    }
    return const ApplyFeedPlanResult(
      applied: true,
      source: 'offline',
      message: 'Plan applied from bundled optimizer data',
    );
  }

  Future<Map<String, dynamic>> loadPayload(String groupId) => _load(groupId);

  Future<Map<String, dynamic>> _load(String groupId) async {
    if (_cache.containsKey(groupId)) return _cache[groupId]!;
    final path = 'assets/data/group_nutrition/$groupId.json';
    try {
      final raw = await rootBundle.loadString(path);
      final payload = GroupNutritionMapper.decodeJson(raw);
      _cache[groupId] = payload;
      return payload;
    } catch (_) {
      final fallback = GroupNutritionMapper.decodeJson(
        await rootBundle.loadString('assets/data/group_nutrition/g1.json'),
      );
      fallback['group_id'] = groupId;
      _cache[groupId] = fallback;
      return fallback;
    }
  }

}
