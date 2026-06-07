import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/feed_eligibility_models.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/feed_eligibility_service.dart';
import '../../data/services/meal_mix_nutrition.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'feed_eligibility_ui.dart';

class EditMealScreen extends ConsumerStatefulWidget {
  const EditMealScreen({super.key, required this.mealId});

  final String mealId;

  @override
  ConsumerState<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends ConsumerState<EditMealScreen> {
  final List<_IngredientRow> _rows = [];
  bool _loading = true;
  String _mealName = '';
  List<Animal> _farmAnimals = const [];
  List<FeedCatalogProduct> _catalog = const [];
  List<MarketplaceFeedProduct> _marketplace = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.amountCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final meals = await ref.read(inventoryRepositoryProvider).listMeals();
    final feed = await ref.read(inventoryRepositoryProvider).listFeed();
    final animals = await ref.read(animalRepositoryProvider).listAnimals();
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    MealPlan? meal;
    for (final m in meals) {
      if (m.id == widget.mealId) {
        meal = m;
        break;
      }
    }
    if (meal != null) {
      _mealName = meal.name;
      for (final ing in meal.ingredients) {
        _rows.add(_IngredientRow(
          feedId: ing.feedInventoryItemId,
          amountCtrl: TextEditingController(text: ing.amountKg.toString()),
        ));
      }
    }
    _feedOptions = feed;
    _farmAnimals = animals;
    _catalog = catalog;
    _marketplace = marketplace;
    if (mounted) setState(() => _loading = false);
  }

  List<FeedInventoryItem> _feedOptions = [];

  bool get _hasRestrictedFeedOptions {
    if (_farmAnimals.isEmpty) return false;
    return FeedEligibilityService.restrictedProductCount(_catalog, _farmAnimals) >
            0 ||
        FeedEligibilityService.restrictedMarketplaceProductCount(
          _marketplace,
          _farmAnimals,
        ) >
            0;
  }

  FeedEligibilityProductCheck? _checkForFeedItem(FeedInventoryItem? item) {
    if (item == null || _farmAnimals.isEmpty) return null;
    return FeedEligibilityService.checkInventoryItem(
      item,
      catalog: _catalog,
      animals: _farmAnimals,
      marketplace: _marketplace,
    );
  }

  Future<void> _save() async {
    final ingredients = <MealIngredientInput>[];
    for (final row in _rows) {
      if (row.feedId == null) continue;
      final kg = double.tryParse(row.amountCtrl.text) ?? 0;
      if (kg <= 0) continue;
      ingredients.add(MealIngredientInput(
        feedInventoryItemId: row.feedId!,
        amountKg: kg,
      ));
    }
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient')),
      );
      return;
    }

    final draftMeal = MealPlan(
      id: widget.mealId,
      name: _mealName.isEmpty ? 'Meal' : _mealName,
      totalKgPerBatch: ingredients.fold<double>(0, (sum, i) => sum + i.amountKg),
      ingredients: [
        for (final ing in ingredients)
          MealIngredientLine(
            feedInventoryItemId: ing.feedInventoryItemId,
            feedItemName: () {
              for (final f in _feedOptions) {
                if (f.id == ing.feedInventoryItemId) return f.name;
              }
              return '';
            }(),
            amountKg: ing.amountKg,
          ),
      ],
    );
    final eligibilityCheck = FeedEligibilityService.evaluateMealForAnimals(
      meal: draftMeal,
      feedItems: _feedOptions,
      catalog: _catalog,
      animals: _farmAnimals,
      marketplace: _marketplace,
    );
    if (eligibilityCheck.hasImpacts) {
      final proceed = await confirmMealEligibilityImpacts(context, eligibilityCheck);
      if (!proceed || !mounted) return;
    }

    final result = await ref.read(inventoryRepositoryProvider).setMealIngredients(
          widget.mealId,
          ingredients,
        );
    if (!mounted) return;
    if (result.stockWarnings.isNotEmpty) {
      final lines = result.stockWarnings.map((w) {
        if (w.insufficientForBatch) {
          return '${w.feedItemName}: need ${w.requestedKg.toStringAsFixed(0)} kg, only ${w.availableKg.toStringAsFixed(0)} kg on hand';
        }
        if (w.lowStock) {
          return '${w.feedItemName}: below one week\'s supply';
        }
        return w.feedItemName;
      }).join('\n');
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Stock warning'),
          content: Text(
            'This meal plan has stock issues:\n\n$lines\n\n'
            'Saving anyway — recording a full batch may run items to zero.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    if (mounted) context.pop(true);
  }

  FeedInventoryItem? _feedById(String? id) {
    if (id == null) return null;
    for (final item in _feedOptions) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: GhAppBar(title: _mealName.isEmpty ? 'Edit meal' : _mealName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Combine feed from your inventory — enter kg for each ingredient',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_hasRestrictedFeedOptions) ...[
            const FeedEligibilityRestrictedBanner(),
            const SizedBox(height: 12),
          ],
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No ingredients yet. Tap Add ingredient to build this meal.',
                style: TextStyle(
                  fontSize: 13,
                  color: GhColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ),
          ..._rows.asMap().entries.map((e) {
            final row = e.value;
            final selectedFeed = _feedById(row.feedId);
            final eligibilityCheck = _checkForFeedItem(selectedFeed);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: row.feedId,
                      decoration: const InputDecoration(labelText: 'Feed item'),
                      items: _feedOptions.map((f) {
                        final check = _checkForFeedItem(f);
                        final restricted = check?.hasImpacts ?? false;
                        return DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            restricted
                                ? '${f.name} (${f.quantityKg.toInt()} kg) · restricted'
                                : '${f.name} (${f.quantityKg.toInt()} kg)',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => row.feedId = v),
                    ),
                    if (eligibilityCheck != null)
                      FeedIngredientEligibilityHint(check: eligibilityCheck),
                    TextField(
                      controller: row.amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'kg in mix'),
                      onChanged: (_) => setState(() {}),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        row.amountCtrl.dispose();
                        _rows.removeAt(e.key);
                      }),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _feedOptions.isEmpty
                ? null
                : () => setState(() {
                      _rows.add(_IngredientRow(
                        feedId: _feedOptions.first.id,
                        amountCtrl: TextEditingController(),
                      ));
                    }),
            icon: const Icon(Icons.add),
            label: const Text('Add ingredient'),
          ),
          const SizedBox(height: 16),
          _NutritionSummary(
            rows: _rows,
            feedOptions: _feedOptions,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: GhColors.primary),
            child: const Text('Save meal plan'),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow {
  _IngredientRow({required this.amountCtrl, this.feedId});

  String? feedId;
  final TextEditingController amountCtrl;
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({
    required this.rows,
    required this.feedOptions,
    required this.l10n,
  });

  final List<_IngredientRow> rows;
  final List<FeedInventoryItem> feedOptions;
  final AppLocalizations l10n;

  static String _pct(double value) =>
      value == value.roundToDouble()
          ? '${value.toInt()}%'
          : '${value.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final mix = MealMixNutritionCalculator.calculate(
      ingredients: [
        for (final row in rows)
          (
            feedId: row.feedId,
            kg: double.tryParse(row.amountCtrl.text) ?? 0,
          ),
      ],
      feedItems: feedOptions,
    );
    if (mix == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, size: 16, color: GhColors.primary),
              SizedBox(width: 6),
              Text(
                'Nutrition per kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GhColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Values per 1 kg of mix (${mix.totalMixKg.toStringAsFixed(1)} kg total)',
            style: const TextStyle(fontSize: 11, color: GhColors.textSecondary),
          ),
          const SizedBox(height: 10),
          if (mix.hasNutritionData) ...[
            _NutritionRow(l10n.dryMatter, _pct(mix.dryMatterPercent)),
            _NutritionRow(l10n.crudeProtein, _pct(mix.crudeProteinPercent)),
            _NutritionRow(
              'Energy (NEm)',
              '${mix.nemMcalPerKg.toStringAsFixed(2)} Mcal/kg',
            ),
            _NutritionRow(l10n.ndf, _pct(mix.ndfPercent)),
            if (mix.calciumPercent != null)
              _NutritionRow(l10n.calcium, _pct(mix.calciumPercent!)),
            if (mix.phosphorusPercent != null)
              _NutritionRow(l10n.phosphorus, _pct(mix.phosphorusPercent!)),
          ],
          if (mix.costPerKg != null)
            _NutritionRow(
              'Est. cost',
              '${mix.costPerKg!.toStringAsFixed(2)} SAR/kg',
            ),
          if (!mix.hasNutritionData)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Add nutrition data to feed items for detailed analysis',
                style: TextStyle(fontSize: 11, color: GhColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: GhColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
