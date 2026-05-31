import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/feed_nutrition_facts.dart';
import '../../data/services/meal_mix_nutrition.dart';
import '../../shared/widgets/gh_app_bar.dart';

final _mealPlansProvider =
    FutureProvider<({List<MealPlan> meals, List<FeedInventoryItem> feed})>(
  (ref) async {
    final repo = ref.watch(inventoryRepositoryProvider);
    final meals = await repo.listMeals();
    final feed = await repo.listFeed();
    return (meals: meals, feed: feed);
  },
);

class MealPlansScreen extends ConsumerWidget {
  const MealPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(_mealPlansProvider);
    return Scaffold(
      appBar: GhAppBar(title: l10n.mealPlans),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createMeal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New meal'),
        backgroundColor: GhColors.primary,
      ),
      body: data.when(
        data: (snapshot) {
          final list = snapshot.meals;
          if (list.isEmpty) {
            return const Center(
              child: Text('No meal plans yet. Create one from your feed inventory.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final meal = list[i];
              final mix = MealMixNutritionCalculator.calculate(
                ingredients: [
                  for (final ing in meal.ingredients)
                    (feedId: ing.feedInventoryItemId, kg: ing.amountKg),
                ],
                feedItems: snapshot.feed,
              );
              final nutritionFacts = mix == null
                  ? const <FeedNutritionFact>[]
                  : FeedNutritionFacts.forMealMixPerKg(l10n, mix);
              final subtitle = meal.ingredients.isEmpty
                  ? 'No ingredients yet'
                  : '${meal.ingredients.length} ingredients · ${meal.totalKgPerBatch.toStringAsFixed(0)} kg mix';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await context.push('/inventory/meals/${meal.id}');
                    ref.invalidate(_mealPlansProvider);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: GhColors.textSecondary,
                                ),
                              ),
                              if (nutritionFacts.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Per kg of mix',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: GhColors.primary.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final fact in nutritionFacts)
                                      _NutritionChip(
                                        label: fact.label,
                                        value: fact.value,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: GhColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _createMeal(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New meal plan'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Meal name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    final meal = await ref
        .read(inventoryRepositoryProvider)
        .createMeal(nameCtrl.text.trim());
    if (context.mounted) {
      await context.push('/inventory/meals/${meal.id}');
      ref.invalidate(_mealPlansProvider);
    }
  }
}

class _NutritionChip extends StatelessWidget {
  const _NutritionChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GhColors.primary.withValues(alpha: 0.15)),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 11, color: GhColors.textPrimary),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: GhColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
