import 'models.dart';

/// One eligibility rule for a feed product. Products may have **zero or more**
/// rules; each rule defines who may receive the feed and optional dosage caps
/// for that context (species, age range, dairy/meat, lactation, sex, etc.).
///
/// Eligibility passes when **any** rule matches the animal context. Dosage
/// limits apply from the matched rule only.
class FeedEligibilityRule {
  const FeedEligibilityRule({
    required this.ruleNumber,
    required this.speciesScope,
    this.productionFocus,
    this.sexRestriction,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.lactationInclusion,
    this.lactationExclusion,
    this.breedingCycle,
    this.dietaryNeeds,
    this.maxPercFeed,
    this.maxPercConc,
    this.maxPercWeight,
    this.maxFeedWeightKg,
  });

  final int ruleNumber;
  final String speciesScope;
  final String? productionFocus;
  final String? sexRestriction;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final String? lactationInclusion;
  final String? lactationExclusion;
  final String? breedingCycle;
  final String? dietaryNeeds;
  final double? maxPercFeed;
  final double? maxPercConc;
  final double? maxPercWeight;
  final double? maxFeedWeightKg;

  bool get hasDosageLimits =>
      maxPercFeed != null ||
      maxPercConc != null ||
      maxPercWeight != null ||
      maxFeedWeightKg != null;

  factory FeedEligibilityRule.fromJson(Map<String, dynamic> json) {
    return FeedEligibilityRule(
      ruleNumber: (json['rule_number'] as num?)?.toInt() ?? 0,
      speciesScope: json['species_scope'] as String? ?? 'ALL',
      productionFocus: json['production_focus'] as String?,
      sexRestriction: json['sex_restriction'] as String?,
      minAgeMonths: (json['min_age_months'] as num?)?.toInt(),
      maxAgeMonths: (json['max_age_months'] as num?)?.toInt(),
      lactationInclusion: json['lactation_inclusion'] as String?,
      lactationExclusion: json['lactation_exclusion'] as String?,
      breedingCycle: json['breeding_cycle'] as String?,
      dietaryNeeds: json['dietary_needs'] as String?,
      maxPercFeed: (json['max_perc_feed'] as num?)?.toDouble(),
      maxPercConc: (json['max_perc_conc'] as num?)?.toDouble(),
      maxPercWeight: (json['max_perc_weight'] as num?)?.toDouble(),
      maxFeedWeightKg: (json['max_feed_weight_kg'] as num?)?.toDouble(),
    );
  }
}

/// Herd context for feed eligibility (aligned with gh-shared `FeedEligibilityContext`).
class FeedEligibilityContext {
  const FeedEligibilityContext({
    required this.species,
    required this.ageMonths,
    required this.productionFocus,
    required this.lactating,
    this.sex,
    this.pregnant = false,
    this.feedTypes,
  });

  final String species;
  final String? sex;
  final int ageMonths;
  final String productionFocus;
  final bool lactating;
  final bool pregnant;
  final List<String>? feedTypes;
}

class FeedEligibilityResult {
  const FeedEligibilityResult({
    required this.eligible,
    required this.reason,
    this.matchedRuleNumber,
    this.matchedRule,
  });

  final bool eligible;
  final String reason;
  final int? matchedRuleNumber;
  /// The first rule that matched [FeedEligibilityContext], including dosage caps.
  final FeedEligibilityRule? matchedRule;
}

/// One animal that cannot receive a feed product under current rules.
class FeedEligibilityAnimalImpact {
  const FeedEligibilityAnimalImpact({
    required this.animal,
    required this.reason,
  });

  final Animal animal;
  final String reason;
}

class FeedEligibilityProductCheck {
  const FeedEligibilityProductCheck({
    required this.productNumber,
    required this.productName,
    required this.impacts,
  });

  final int? productNumber;
  final String productName;
  final List<FeedEligibilityAnimalImpact> impacts;

  bool get hasImpacts => impacts.isNotEmpty;
}

class FeedEligibilityMealCheck {
  const FeedEligibilityMealCheck({
    required this.mealName,
    required this.productChecks,
  });

  final String mealName;
  final List<FeedEligibilityProductCheck> productChecks;

  bool get hasImpacts => productChecks.any((c) => c.hasImpacts);

  List<FeedEligibilityAnimalImpact> get allImpacts => [
        for (final check in productChecks) ...check.impacts,
      ];
}
