import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/gen/app_localizations_en.dart';
import 'package:greenerherd_mobile/data/services/feed_nutrition_facts.dart';

void main() {
  group('FeedNutritionFacts', () {
    final l10n = AppLocalizationsEn();

    test('extracts DM, protein, NDF, and NEm from nutrition map', () {
      final facts = FeedNutritionFacts.forNutritionMap(l10n, {
        'dry_matter_percent': 89.0,
        'crude_protein_percent': 17.0,
        'ndf_percent': 42.0,
        'nem_mcal_per_kg': 1.24,
      });

      expect(facts, hasLength(4));
      expect(facts[0].label, l10n.dryMatter);
      expect(facts[0].value, '89%');
      expect(facts[1].label, l10n.crudeProtein);
      expect(facts[1].value, '17%');
      expect(facts[2].label, l10n.ndf);
      expect(facts[2].value, '42%');
      expect(facts[3].label, 'NEm');
      expect(facts[3].value, '1.24 Mcal/kg');
    });

    test('returns empty list when nutrition map is empty', () {
      expect(FeedNutritionFacts.forNutritionMap(l10n, const {}), isEmpty);
    });
  });
}
