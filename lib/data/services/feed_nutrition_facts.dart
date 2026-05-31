import '../../core/l10n/gen/app_localizations.dart';
import 'meal_mix_nutrition.dart';

/// One nutrient row/chip for feed inventory display.
class FeedNutritionFact {
  const FeedNutritionFact({required this.label, required this.value});

  final String label;
  final String value;
}

/// Reads [FeedInventoryItem.customNutrition] for product listing labels.
abstract final class FeedNutritionFacts {
  FeedNutritionFacts._();

  static double? _num(Map<String, dynamic> nutrition, String key) =>
      (nutrition[key] as num?)?.toDouble();

  static String _percent(double value) =>
      value == value.roundToDouble()
          ? '${value.toInt()}%'
          : '${value.toStringAsFixed(1)}%';

  static List<FeedNutritionFact> forNutritionMap(
    AppLocalizations l10n,
    Map<String, dynamic> nutrition,
  ) {
    if (nutrition.isEmpty) return const [];

    final facts = <FeedNutritionFact>[];
    final dm = _num(nutrition, 'dry_matter_percent');
    final cp = _num(nutrition, 'crude_protein_percent');
    final ndf = _num(nutrition, 'ndf_percent');
    final nem = _num(nutrition, 'nem_mcal_per_kg');

    if (dm != null && dm > 0) {
      facts.add(FeedNutritionFact(label: l10n.dryMatter, value: _percent(dm)));
    }
    if (cp != null && cp > 0) {
      facts.add(FeedNutritionFact(label: l10n.crudeProtein, value: _percent(cp)));
    }
    if (ndf != null && ndf > 0) {
      facts.add(FeedNutritionFact(label: l10n.ndf, value: _percent(ndf)));
    }
    if (nem != null && nem > 0) {
      facts.add(
        FeedNutritionFact(
          label: 'NEm',
          value: '${nem.toStringAsFixed(2)} Mcal/kg',
        ),
      );
    }
    return facts;
  }

  /// Per-kg mix nutrients for meal plan list cards.
  static List<FeedNutritionFact> forMealMixPerKg(
    AppLocalizations l10n,
    MealMixNutritionPerKg mix,
  ) {
    if (!mix.hasNutritionData) return const [];

    final facts = <FeedNutritionFact>[];
    if (mix.dryMatterPercent > 0) {
      facts.add(
        FeedNutritionFact(label: l10n.dryMatter, value: _percent(mix.dryMatterPercent)),
      );
    }
    if (mix.crudeProteinPercent > 0) {
      facts.add(
        FeedNutritionFact(
          label: l10n.crudeProtein,
          value: _percent(mix.crudeProteinPercent),
        ),
      );
    }
    if (mix.ndfPercent > 0) {
      facts.add(FeedNutritionFact(label: l10n.ndf, value: _percent(mix.ndfPercent)));
    }
    if (mix.nemMcalPerKg > 0) {
      facts.add(
        FeedNutritionFact(
          label: 'NEm',
          value: '${mix.nemMcalPerKg.toStringAsFixed(2)} Mcal/kg',
        ),
      );
    }
    if (mix.calciumPercent != null && mix.calciumPercent! > 0) {
      facts.add(
        FeedNutritionFact(label: l10n.calcium, value: _percent(mix.calciumPercent!)),
      );
    }
    if (mix.phosphorusPercent != null && mix.phosphorusPercent! > 0) {
      facts.add(
        FeedNutritionFact(
          label: l10n.phosphorus,
          value: _percent(mix.phosphorusPercent!),
        ),
      );
    }
    return facts;
  }
}
