import '../../core/config/app_config.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../services/group_nutrition_mapper.dart';
import '../services/group_nutrition_profile_resolver.dart';
import '../services/nutrition_api_client.dart';
import '../services/nutrition_requirements_catalog.dart';
import '../services/supplement_nutrition.dart';
import 'engine_nutrition_repository.dart';
import 'repositories.dart';

/// Result of applying a feed plan to a group (morning mix).
class ApplyFeedPlanResult {
  const ApplyFeedPlanResult({
    required this.applied,
    required this.source,
    this.message,
  });

  final bool applied;
  /// `api` when persisted via gh-api-nutrition; `offline` when cached locally only.
  final String source;
  final String? message;
}

/// Loads nutrition from the API when available, with bundled optimizer JSON as fallback.
class HybridNutritionRepository implements NutritionRepository {
  HybridNutritionRepository({
    NutritionApiClient? apiClient,
    EngineNutritionRepository? offline,
    AnimalRepository? animalRepository,
    GroupRepository? groupRepository,
  })  : _api = apiClient ??
            NutritionApiClient(baseUrl: AppConfig.nutritionApiBaseUrl),
        _offline = offline ?? EngineNutritionRepository(),
        _animals = animalRepository,
        _groups = groupRepository;

  final NutritionApiClient _api;
  final EngineNutritionRepository _offline;
  final AnimalRepository? _animals;
  final GroupRepository? _groups;

  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Set<String>> _addedIds = {};
  String? _lastGroupId;

  @override
  Future<NutritionGap> getGap(String groupId) async {
    final payload = await _loadPayload(groupId);
    return GroupNutritionMapper.gapFromPayload(payload);
  }

  @override
  Future<List<FeedRecommendation>> getRecommendations(String groupId) async {
    _lastGroupId = groupId;
    final payload = await _loadPayload(groupId);
    final recs = GroupNutritionMapper.recommendationsFromPayload(payload);
    final added = _addedIds[groupId] ?? {};
    return recs
        .map((r) => r.copyWith(added: added.contains(r.id)))
        .toList();
  }

  @override
  Future<List<NutrientBridgeGap>> getBridgeGaps(String groupId) async {
    final payload = await _loadPayload(groupId);
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

    // "Product-suggestions agent" behavior: when the user accepts/rejects
    // recommended feeds, re-run the optimizer using the selected products.
    if (!AppConfig.useNutritionApi) return;

    final profile = await _resolveProfile(groupId);
    if (profile == null) return;

    final selectedProductNumbers = _addedIds[groupId]!
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toList(growable: false);

    final request = Map<String, dynamic>.from(profile.request);
    if (selectedProductNumbers.isNotEmpty) {
      request['included_product_numbers'] = selectedProductNumbers;
    } else {
      request.remove('included_product_numbers');
    }

    final updatedProfile = profile.copyWith(
      request: request,
    );

    try {
      final refreshed = await _api.fetchGroupNutrition(groupId, updatedProfile);
      _cache[groupId] = refreshed;
    } on NutritionApiException {
      // If recompute fails, keep existing cached plan but still update the
      // local "added" markers for UX continuity.
    }
  }

  @override
  Future<void> applySupplement({
    required String groupId,
    required SupplementNutritionInput input,
    bool subtract = false,
  }) async {
    final payload = await _loadPayload(groupId);
    final delta = SupplementNutrition.contribution(input);
    SupplementNutrition.applyToPayload(payload, delta, subtract: subtract);
    _cache[groupId] = payload;
  }

  @override
  Future<ApplyFeedPlanResult> applyFeedPlan(String groupId) async {
    final profile = await _resolveProfile(groupId);
    if (profile == null) {
      return const ApplyFeedPlanResult(
        applied: false,
        source: 'offline',
        message: 'No nutrition profile for this group',
      );
    }

    if (AppConfig.useNutritionApi) {
      final selectedProductNumbers = _addedIds[groupId]
              ?.map((id) => int.tryParse(id))
              .whereType<int>()
              .toList(growable: false) ??
          const <int>[];
      final request = Map<String, dynamic>.from(profile.request);
      if (selectedProductNumbers.isNotEmpty) {
        request['included_product_numbers'] = selectedProductNumbers;
      } else {
        request.remove('included_product_numbers');
      }
      final updatedProfile = profile.copyWith(request: request);
      try {
        final saved = await _api.saveActiveFeedPlan(
          groupId,
          updatedProfile,
        );
        final planNutrients = _planNutrientsFromSaveResponse(saved);
        final refreshed = await _api.fetchGroupNutrition(
          groupId,
          updatedProfile.copyWith(
            currentIntakeRatio: 1,
            currentTotals: planNutrients,
          ),
        );
        _cache[groupId] = refreshed;
        return const ApplyFeedPlanResult(
          applied: true,
          source: 'api',
          message: 'Feed plan saved and applied to morning mix',
        );
      } on NutritionApiException {
        // Fall through to offline apply.
      }
    }

    final payload = await _offline.loadPayload(groupId);
    final plan = payload['plan'];
    if (plan is Map) {
      payload['current'] = Map<String, dynamic>.from(plan);
    }
    _cache[groupId] = payload;
    return const ApplyFeedPlanResult(
      applied: true,
      source: 'offline',
      message: 'Plan applied locally (nutrition API unavailable)',
    );
  }

  Future<GroupNutritionProfile?> _resolveProfile(String groupId) async {
    AnimalGroup? group;
    List<Animal>? members;

    if (_groups != null) {
      final groups = _groups;
      group = await groups.getGroup(groupId);
      if (group == null) {
        for (final g in await groups.listGroups()) {
          if (g.id == groupId) {
            group = g;
            break;
          }
        }
      }
    }
    if (_animals != null) {
      final all = await _animals.listAnimals(groupId: groupId);
      members = all
          .where((a) => a.status == AnimalStatus.active)
          .toList(growable: false);
    }

    final catalog = await NutritionRequirementsCatalog.load();
    return GroupNutritionProfileResolver.resolve(
      groupId,
      group: group,
      members: members,
      catalog: catalog,
    );
  }

  Future<Map<String, dynamic>> _loadPayload(String groupId) async {
    if (_cache.containsKey(groupId)) {
      return _cache[groupId]!;
    }

    final profile = await _resolveProfile(groupId);
    if (AppConfig.useNutritionApi && profile != null) {
      try {
        final payload = await _api.fetchGroupNutrition(groupId, profile);
        _cache[groupId] = payload;
        return payload;
      } on NutritionApiException {
        // Use bundled JSON below.
      }
    }

    final payload = await _offline.loadPayload(groupId);
    _cache[groupId] = payload;
    return payload;
  }

  Map<String, dynamic>? _planNutrientsFromSaveResponse(Map<String, dynamic> saved) {
    final context = saved['plan']?['context'];
    if (context is Map && context['plan'] is Map) {
      return Map<String, dynamic>.from(context['plan'] as Map);
    }
    final plan = saved['plan'];
    if (plan is Map && plan['totals'] is Map) {
      final totals = Map<String, dynamic>.from(plan['totals'] as Map);
      return {
        'dry_matter_kg': totals['dryMatterKg'] ?? totals['dry_matter_kg'],
        'protein_kg': totals['crudeProteinKg'] ?? totals['protein_kg'],
        'energy_mj': _energyMjFromTotals(totals),
        'ndf_kg': totals['ndfKg'] ?? totals['ndf_kg'],
      };
    }
    return null;
  }

  double? _energyMjFromTotals(Map<String, dynamic> totals) {
    final nem = totals['nemMcal'];
    if (nem is num) return nem.toDouble() * 4.184;
    final energy = totals['energy_mj'];
    if (energy is num) return energy.toDouble();
    return null;
  }
}
