import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/models.dart';
import '../../data/services/group_nutrition_profile_resolver.dart';
import '../../data/services/group_nutrition_requirements_aggregator.dart';
import '../../data/services/nutrition_requirements_catalog.dart';
import '../../features/groups/group_mock_extras.dart';
import '../../data/services/todays_feed_nutrition.dart';
import 'gap_supplement_recommendations.dart';

final nutritionGapProvider = FutureProvider.family<NutritionGap, String>((ref, groupId) {
  return ref.watch(nutritionRepositoryProvider).getGap(groupId);
});

/// [NutritionGap] for "Today v Required Nutrition", derived from today's feed when logged.
final groupNutritionDisplayGapProvider =
    FutureProvider.family<NutritionGap, String>((ref, groupId) async {
  final gap = await ref.watch(nutritionGapProvider(groupId).future);
  // Recompute when today's feed list changes (e.g. meal volume saved).
  await ref.watch(groupTodaysFeedProvider(groupId).future);
  final feed = await ref
      .watch(inventoryRepositoryProvider)
      .listTodaysFeedForGroup(groupId);
  if (feed.isEmpty) return gap.withNoLoggedFeedToday();

  final meals = await ref.watch(inventoryRepositoryProvider).listMeals();
  final feedItems = await ref.watch(inventoryRepositoryProvider).listFeed();
  return TodaysFeedNutritionCalculator.applyToGap(
    base: gap,
    entries: feed,
    meals: meals,
    feedItems: feedItems,
  );
});

final groupAnimalsForNutritionProvider =
    FutureProvider.family<List<Animal>, String>((ref, groupId) {
  return ref.watch(animalRepositoryProvider).listAnimals(groupId: groupId);
});

/// Per-animal summed daily requirements for a group (xlsx-aligned profiles).
final groupAggregatedRequirementsProvider =
    FutureProvider.family<AggregatedGroupNutritionRequirements?, String>(
        (ref, groupId) async {
  final group = await ref.watch(groupRepositoryProvider).getGroup(groupId);
  if (group == null) return null;
  final members =
      await ref.watch(groupAnimalsForNutritionProvider(groupId).future);
  if (members.isEmpty) return null;
  final catalog = await NutritionRequirementsCatalog.load();
  final profile = await GroupNutritionProfileResolver.resolve(
    groupId,
    group: group,
    members: members,
    catalog: catalog,
  );
  return profile?.aggregatedRequirements;
});

final groupTodaysFeedProvider =
    FutureProvider.family<List<GroupFeedEntry>, String>((ref, groupId) async {
  final entries =
      await ref.watch(inventoryRepositoryProvider).listTodaysFeedForGroup(groupId);
  return entries
      .map(
        (e) => GroupFeedEntry(
          id: e.id,
          title: e.title,
          subtitle: e.subtitle,
          costSar: e.costSar,
          weightKg: e.effectiveWeightKg,
          headCount: e.headCount,
          mealTypeId: e.mealTypeId,
        ),
      )
      .toList();
});

final feedInventoryForGapProvider =
    FutureProvider<List<FeedInventoryItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).listFeed();
});

/// Supplement options for Fix the gap, keyed as `groupId|source`.
  final gapSupplementsProvider =
    FutureProvider.family<List<GapSupplementOption>, String>((ref, key) async {
  final sep = key.indexOf('|');
  final groupId = key.substring(0, sep);
  final sourceName = key.substring(sep + 1);
  final source = GapSupplementSource.values.byName(sourceName);

  final gap = await ref.watch(groupNutritionDisplayGapProvider(groupId).future);
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final inventory = await ref.watch(feedInventoryForGapProvider.future);
  final engineRecs =
      await ref.watch(nutritionRepositoryProvider).getRecommendations(groupId);
  final groupMembers =
      await ref.watch(groupAnimalsForNutritionProvider(groupId).future);

  return GapSupplementRecommendations.load(
    source: source,
    gap: gap,
    locale: locale,
    inventory: inventory,
    engineRecs: engineRecs,
    groupMembers: groupMembers,
  );
});
