import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/feed_eligibility_models.dart';
import 'package:greenerherd_mobile/data/services/feed_catalog_loader.dart';
import 'package:greenerherd_mobile/data/models/models.dart';

/// Reusable livestock pool covering species, sex, production focus, lactation,
/// pregnancy, age bands, and inactive status.
abstract final class EligibilityLivestockPool {
  static const animals = <String, Animal>{
    'cow_dairy_dry_f_48': Animal(
      id: 'a-cow-dry',
      tag: '1001',
      name: 'Dry Holstein',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 520,
      ageLabel: '48m',
      groupId: 'g-dry-dairy',
      productionPurpose: SpeciesPurpose.milk,
    ),
    'cow_dairy_lac_f_48': Animal(
      id: 'a-cow-lac',
      tag: '1044',
      name: 'Lactating Jersey',
      species: Species.cattle,
      sex: 'F',
      breed: 'Jersey',
      weightKg: 380,
      ageLabel: '48m',
      groupId: 'g-lactating',
      tags: [AnimalTagType.lactating],
      productionPurpose: SpeciesPurpose.milk,
      monthsSinceCalving: 4,
    ),
    'cow_dairy_lac_f_8': Animal(
      id: 'a-cow-young-lac',
      tag: '1008',
      name: 'Young lactating heifer',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 280,
      ageLabel: '8m',
      groupId: 'g-young',
      tags: [AnimalTagType.lactating],
      productionPurpose: SpeciesPurpose.milk,
    ),
    'cow_dairy_preg_f_30': Animal(
      id: 'a-cow-preg',
      tag: '1030',
      name: 'Pregnant cow',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 460,
      ageLabel: '30m',
      groupId: 'g-dry-dairy',
      tags: [AnimalTagType.pregnant],
      productionPurpose: SpeciesPurpose.milk,
    ),
    'cow_dairy_senior_f_96': Animal(
      id: 'a-cow-senior',
      tag: '1096',
      name: 'Senior cow',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 500,
      ageLabel: '96m',
      groupId: 'g-senior',
      productionPurpose: SpeciesPurpose.milk,
    ),
    'bull_meat_m_36': Animal(
      id: 'a-bull',
      tag: '2001',
      name: 'Meat bull',
      species: Species.cattle,
      sex: 'M',
      breed: 'Angus',
      weightKg: 680,
      ageLabel: '36m',
      groupId: 'g-meat-cattle',
      productionPurpose: SpeciesPurpose.meat,
    ),
    'steer_meat_m_24': Animal(
      id: 'a-steer',
      tag: '2002',
      name: 'Fattening steer',
      species: Species.cattle,
      sex: 'M',
      breed: 'Angus',
      weightKg: 420,
      ageLabel: '24m',
      groupId: 'g-meat-cattle',
      productionPurpose: SpeciesPurpose.meat,
    ),
    'cow_both_f_36': Animal(
      id: 'a-cow-both',
      tag: '1100',
      name: 'Dual-purpose cow',
      species: Species.cattle,
      sex: 'F',
      breed: 'Simmental',
      weightKg: 440,
      ageLabel: '36m',
      groupId: 'g-dual',
      productionPurpose: SpeciesPurpose.both,
    ),
    'sheep_dairy_lac_f_24': Animal(
      id: 'a-sheep-lac',
      tag: '3001',
      name: 'Lactating ewe',
      species: Species.sheep,
      sex: 'F',
      breed: 'Awassi',
      weightKg: 55,
      ageLabel: '24m',
      groupId: 'g-sr',
      tags: [AnimalTagType.lactating],
      productionPurpose: SpeciesPurpose.milk,
    ),
    'sheep_meat_f_18': Animal(
      id: 'a-sheep-meat',
      tag: '3002',
      name: 'Meat ewe',
      species: Species.sheep,
      sex: 'F',
      breed: 'Najdi',
      weightKg: 48,
      ageLabel: '18m',
      groupId: 'g-sr',
      productionPurpose: SpeciesPurpose.meat,
    ),
    'goat_meat_f_18': Animal(
      id: 'a-goat-f',
      tag: '4001',
      name: 'Meat doe',
      species: Species.goat,
      sex: 'F',
      breed: 'Boer',
      weightKg: 42,
      ageLabel: '18m',
      groupId: 'g-sr',
      productionPurpose: SpeciesPurpose.meat,
    ),
    'goat_meat_m_18': Animal(
      id: 'a-goat-m',
      tag: '4002',
      name: 'Meat buck',
      species: Species.goat,
      sex: 'M',
      breed: 'Boer',
      weightKg: 55,
      ageLabel: '18m',
      groupId: 'g-sr',
      productionPurpose: SpeciesPurpose.meat,
    ),
    'cow_inactive': Animal(
      id: 'a-cow-inactive',
      tag: '1999',
      name: 'Sold cow',
      species: Species.cattle,
      sex: 'F',
      breed: 'Holstein',
      weightKg: 500,
      ageLabel: '48m',
      groupId: 'g-mixed-inactive',
      productionPurpose: SpeciesPurpose.milk,
      status: AnimalStatus.sold,
    ),
  };

  /// Named groups as member key lists (mirrors farm group → animals).
  static const groups = <String, List<String>>{
    'dry_dairy_cows': ['cow_dairy_dry_f_48', 'cow_dairy_preg_f_30'],
    'lactating_dairy': ['cow_dairy_lac_f_48'],
    'mixed_lactation': ['cow_dairy_dry_f_48', 'cow_dairy_lac_f_48'],
    'meat_cattle': ['bull_meat_m_36', 'steer_meat_m_24'],
    'small_ruminants': [
      'sheep_dairy_lac_f_24',
      'sheep_meat_f_18',
      'goat_meat_f_18',
      'goat_meat_m_18',
    ],
    'young_calves': ['cow_dairy_lac_f_8'],
    'senior_cows': ['cow_dairy_senior_f_96'],
    'dual_purpose': ['cow_both_f_36'],
    'with_inactive': ['cow_dairy_dry_f_48', 'cow_inactive'],
  };

  static List<Animal> membersOf(String groupKey) =>
      groups[groupKey]!.map((k) => animals[k]!).toList(growable: false);
}

FeedEligibilityRule _rule({
  required int ruleNumber,
  String speciesScope = 'CATTLE',
  String? productionFocus,
  String? sexRestriction,
  int? minAgeMonths,
  int? maxAgeMonths,
  String? lactationInclusion,
  String? lactationExclusion,
  double? maxPercFeed,
  double? maxPercConc,
  double? maxFeedWeightKg,
}) {
  return FeedEligibilityRule(
    ruleNumber: ruleNumber,
    speciesScope: speciesScope,
    productionFocus: productionFocus,
    sexRestriction: sexRestriction,
    minAgeMonths: minAgeMonths,
    maxAgeMonths: maxAgeMonths,
    lactationInclusion: lactationInclusion,
    lactationExclusion: lactationExclusion,
    maxPercFeed: maxPercFeed,
    maxPercConc: maxPercConc,
    maxFeedWeightKg: maxFeedWeightKg,
  );
}

FeedCatalogProduct _catalogProduct({
  required int number,
  required String name,
  required List<FeedEligibilityRule> rules,
  String feedType = 'CONCENTRATE',
}) {
  return FeedCatalogProduct(
    productNumber: number,
    nameEn: name,
    names: {'en': name},
    feedType: feedType,
    eligibilityRules: rules,
  );
}

/// Feed products with 0–2 rules covering common eligibility patterns.
abstract final class EligibilityProductPool {
  static final catalog = <String, FeedCatalogProduct>{
    'unrestricted_hay': _catalogProduct(
      number: 9001,
      name: 'Unrestricted Hay',
      rules: const [],
      feedType: 'FODDER',
    ),
    'lactation_dairy_cattle': _catalogProduct(
      number: 9002,
      name: 'Lactation Dairy Concentrate',
      rules: [
        _rule(
          ruleNumber: 1,
          speciesScope: 'CATTLE',
          productionFocus: 'DAIRY',
          minAgeMonths: 12,
          lactationInclusion: 'Lactation Period',
          maxPercFeed: 50,
          maxFeedWeightKg: 5,
        ),
      ],
    ),
    'meat_male_cattle': _catalogProduct(
      number: 9003,
      name: 'Bull Finisher',
      rules: [
        _rule(
          ruleNumber: 2,
          speciesScope: 'CATTLE',
          productionFocus: 'MEAT',
          sexRestriction: 'MALE',
          maxFeedWeightKg: 6,
        ),
      ],
    ),
    'cattle_min_12_months': _catalogProduct(
      number: 9004,
      name: 'Cattle Grower 12m+',
      rules: [
        _rule(ruleNumber: 3, speciesScope: 'CATTLE', minAgeMonths: 12),
      ],
    ),
    'cattle_max_72_months': _catalogProduct(
      number: 9005,
      name: 'Cattle Young Stock Max 6y',
      rules: [
        _rule(ruleNumber: 4, speciesScope: 'CATTLE', maxAgeMonths: 72),
      ],
    ),
    'small_ruminant_only': _catalogProduct(
      number: 9006,
      name: 'Small Ruminant Mix',
      rules: [
        _rule(
          ruleNumber: 5,
          speciesScope: 'SMALL_RUMINANT',
          maxFeedWeightKg: 0.4,
        ),
      ],
    ),
    'dual_species_dose': _catalogProduct(
      number: 9007,
      name: 'Dual Species Flakes',
      rules: [
        _rule(
          ruleNumber: 6,
          speciesScope: 'CATTLE',
          maxPercFeed: 40,
          maxFeedWeightKg: 4,
        ),
        _rule(
          ruleNumber: 7,
          speciesScope: 'SMALL_RUMINANT',
          maxPercFeed: 30,
          maxFeedWeightKg: 0.4,
        ),
      ],
    ),
    'dry_period_cattle': _catalogProduct(
      number: 9008,
      name: 'Dry Cow Mineral',
      rules: [
        _rule(
          ruleNumber: 8,
          speciesScope: 'CATTLE',
          productionFocus: 'DAIRY',
          lactationExclusion: 'Lactation Period',
        ),
      ],
    ),
    'female_only_supplement': _catalogProduct(
      number: 9009,
      name: 'Female Repro Supplement',
      rules: [
        _rule(ruleNumber: 9, speciesScope: 'ALL', sexRestriction: 'FEMALE'),
      ],
    ),
    'sheep_only_block': _catalogProduct(
      number: 9010,
      name: 'Sheep Mineral Block',
      rules: [_rule(ruleNumber: 10, speciesScope: 'SHEEP')],
    ),
    'urea_cattle_goat': _catalogProduct(
      number: 9011,
      name: 'Urea Supplement',
      rules: [
        _rule(
          ruleNumber: 11,
          speciesScope: 'CATTLE',
          minAgeMonths: 12,
          maxPercFeed: 1,
          maxPercConc: 3,
          maxFeedWeightKg: 0.1,
        ),
        _rule(
          ruleNumber: 12,
          speciesScope: 'SMALL_RUMINANT',
          minAgeMonths: 12,
          maxPercFeed: 0.5,
          maxPercConc: 2,
          maxFeedWeightKg: 0.15,
        ),
      ],
      feedType: 'ADDITIVE',
    ),
  };

  static MarketplaceFeedProduct marketplaceFrom(FeedCatalogProduct product) {
    return MarketplaceFeedProduct(
      id: 'mp-${product.productNumber}',
      nameEn: product.nameEn,
      nameAr: '',
      feedType: product.feedType,
      supplierName: 'Test Supplier',
      supplierPhone: '',
      countryCode: 'SA',
      currency: 'SAR',
      pricePerKg: 2.5,
      standardProductNumber: product.productNumber,
      dryMatterPercent: product.dryMatterPercent,
      crudeProteinPercent: product.crudeProteinPercent,
      nemMcalPerKg: product.nemMcalPerKg,
      ndfPercent: product.ndfPercent,
      eligibilityRules: product.eligibilityRules,
    );
  }

  static final marketplace = {
    for (final entry in catalog.entries)
      entry.key: marketplaceFrom(entry.value),
  };
}

/// Expected individual eligibility: animalKey → productKey → eligible.
abstract final class EligibilityIndividualMatrix {
  static const expectations = <String, Map<String, bool>>{
    'unrestricted_hay': {
      'cow_dairy_dry_f_48': true,
      'cow_dairy_lac_f_48': true,
      'cow_dairy_lac_f_8': true,
      'bull_meat_m_36': true,
      'sheep_dairy_lac_f_24': true,
      'goat_meat_f_18': true,
      'cow_inactive': true,
    },
    'lactation_dairy_cattle': {
      'cow_dairy_dry_f_48': false,
      'cow_dairy_lac_f_48': true,
      'cow_dairy_lac_f_8': false,
      'cow_dairy_preg_f_30': false,
      'bull_meat_m_36': false,
      'steer_meat_m_24': false,
      'cow_both_f_36': false,
      'sheep_dairy_lac_f_24': false,
      'goat_meat_f_18': false,
      'goat_meat_m_18': false,
    },
    'meat_male_cattle': {
      'cow_dairy_dry_f_48': false,
      'cow_dairy_lac_f_48': false,
      'bull_meat_m_36': true,
      'steer_meat_m_24': true,
      'goat_meat_m_18': false,
      'sheep_meat_f_18': false,
    },
    'cattle_min_12_months': {
      'cow_dairy_dry_f_48': true,
      'cow_dairy_lac_f_8': false,
      'goat_meat_f_18': false,
      'bull_meat_m_36': true,
    },
    'cattle_max_72_months': {
      'cow_dairy_dry_f_48': true,
      'cow_dairy_senior_f_96': false,
      'bull_meat_m_36': true,
    },
    'small_ruminant_only': {
      'cow_dairy_dry_f_48': false,
      'sheep_dairy_lac_f_24': true,
      'sheep_meat_f_18': true,
      'goat_meat_f_18': true,
      'goat_meat_m_18': true,
      'bull_meat_m_36': false,
    },
    'dual_species_dose': {
      'cow_dairy_dry_f_48': true,
      'bull_meat_m_36': true,
      'sheep_meat_f_18': true,
      'goat_meat_f_18': true,
    },
    'dry_period_cattle': {
      'cow_dairy_dry_f_48': true,
      'cow_dairy_lac_f_48': false,
      'cow_dairy_preg_f_30': true,
      'bull_meat_m_36': false,
    },
    'female_only_supplement': {
      'cow_dairy_dry_f_48': true,
      'bull_meat_m_36': false,
      'steer_meat_m_24': false,
      'goat_meat_f_18': true,
      'goat_meat_m_18': false,
    },
    'sheep_only_block': {
      'sheep_dairy_lac_f_24': true,
      'sheep_meat_f_18': true,
      'goat_meat_f_18': false,
      'cow_dairy_dry_f_48': false,
    },
    'urea_cattle_goat': {
      'cow_dairy_dry_f_48': true,
      'cow_dairy_lac_f_8': false,
      'goat_meat_f_18': true,
      'bull_meat_m_36': true,
    },
  };
}

/// Group is eligible for a product when any **active** member can receive it.
abstract final class EligibilityGroupMatrix {
  static const filterVisible = <String, Map<String, bool>>{
    'lactation_dairy_cattle': {
      'dry_dairy_cows': false,
      'lactating_dairy': true,
      'mixed_lactation': true,
      'meat_cattle': false,
      'small_ruminants': false,
      'young_calves': false,
    },
    'meat_male_cattle': {
      'dry_dairy_cows': false,
      'meat_cattle': true,
      'small_ruminants': false,
      'mixed_lactation': false,
    },
    'unrestricted_hay': {
      'dry_dairy_cows': true,
      'lactating_dairy': true,
      'meat_cattle': true,
      'small_ruminants': true,
      'with_inactive': true,
    },
    'dual_species_dose': {
      'dry_dairy_cows': true,
      'small_ruminants': true,
      'meat_cattle': true,
    },
    'dry_period_cattle': {
      'dry_dairy_cows': true,
      'lactating_dairy': false,
      'mixed_lactation': true,
    },
    'small_ruminant_only': {
      'small_ruminants': true,
      'dry_dairy_cows': false,
      'meat_cattle': false,
    },
  };
}

/// Per-animal matched rule dosage expectations for multi-rule products.
abstract final class EligibilityDosageMatrix {
  static const expectations = <String, Map<String, double>>{
    'dual_species_dose': {
      'cow_dairy_dry_f_48': 4,
      'goat_meat_f_18': 0.4,
      'sheep_meat_f_18': 0.4,
    },
    'urea_cattle_goat': {
      'cow_dairy_dry_f_48': 0.1,
      'goat_meat_f_18': 0.15,
    },
  };
}
