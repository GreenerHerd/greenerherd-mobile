import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../features/nutrition/nutrition_providers.dart';
import '../../shared/widgets/gh_app_bar.dart';

/// Meal detail for one today's feed row — edit ingredient kg and save.
class TodaysFeedMealScreen extends ConsumerStatefulWidget {
  const TodaysFeedMealScreen({
    super.key,
    required this.groupId,
    required this.entryId,
  });

  final String groupId;
  final String entryId;

  @override
  ConsumerState<TodaysFeedMealScreen> createState() =>
      _TodaysFeedMealScreenState();
}

class _TodaysFeedMealScreenState extends ConsumerState<TodaysFeedMealScreen> {
  final List<_IngredientRow> _rows = [];
  final _headCountCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  TodaysFeedEntry? _entry;
  MealPlan? _meal;
  List<FeedInventoryItem> _feedOptions = [];
  String _screenTitle = '';

  @override
  void dispose() {
    for (final row in _rows) {
      row.amountCtrl.dispose();
    }
    _headCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final inventory = ref.read(inventoryRepositoryProvider);
    final entry = await inventory.getTodaysFeedEntry(widget.entryId);
    final meals = await inventory.listMeals();
    final feed = await inventory.listFeed();
    if (!mounted) return;
    if (entry == null || entry.groupId != widget.groupId) {
      setState(() => _loading = false);
      return;
    }

    _entry = entry;
    _feedOptions = feed;
    _screenTitle = _displayTitle(entry);
    _headCountCtrl.text =
        entry.headCount != null ? '${entry.headCount}' : '';

    MealPlan? meal;
    if (entry.mealTypeId != null) {
      meal = meals.where((m) => m.id == entry.mealTypeId).firstOrNull;
    }
    _meal = meal;

    final lines = entry.fedIngredients.isNotEmpty
        ? entry.fedIngredients
        : meal != null && meal.totalKgPerBatch > 0
            ? _scaledLines(meal, entry.effectiveWeightKg)
            : <MealIngredientLine>[];

    _rows.clear();
    if (lines.isNotEmpty) {
      for (final line in lines) {
        _rows.add(_IngredientRow(
          feedId: line.feedInventoryItemId,
          amountCtrl: TextEditingController(
            text: _formatKg(line.amountKg),
          ),
        ));
      }
    } else if (feed.isNotEmpty) {
      _rows.add(_IngredientRow(
        feedId: feed.first.id,
        amountCtrl: TextEditingController(
          text: _formatKg(entry.effectiveWeightKg),
        ),
      ));
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  static String _displayTitle(TodaysFeedEntry entry) {
    final parts = entry.title.split(' · ');
    return parts.first.trim().isEmpty ? entry.title : parts.first.trim();
  }

  static List<MealIngredientLine> _scaledLines(MealPlan meal, double totalKg) {
    if (meal.totalKgPerBatch <= 0) return const [];
    final scale = totalKg / meal.totalKgPerBatch;
    return [
      for (final ing in meal.ingredients)
        MealIngredientLine(
          feedInventoryItemId: ing.feedInventoryItemId,
          amountKg: ing.amountKg * scale,
          feedItemName: ing.feedItemName,
        ),
    ];
  }

  static String _formatKg(double kg) =>
      kg == kg.roundToDouble() ? '${kg.toInt()}' : kg.toStringAsFixed(1);

  double get _totalKg {
    var sum = 0.0;
    for (final row in _rows) {
      sum += double.tryParse(row.amountCtrl.text.trim()) ?? 0;
    }
    return sum;
  }

  Future<void> _save() async {
    if (_entry == null) return;
    final ingredients = <MealIngredientInput>[];
    for (final row in _rows) {
      if (row.feedId == null) continue;
      final kg = double.tryParse(row.amountCtrl.text.trim()) ?? 0;
      if (kg <= 0) continue;
      ingredients.add(MealIngredientInput(
        feedInventoryItemId: row.feedId!,
        amountKg: kg,
      ));
    }
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one feed amount (kg)')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).updateTodaysFeedMeal(
            entryId: widget.entryId,
            ingredients: ingredients,
            headCount: int.tryParse(_headCountCtrl.text.trim()),
          );
      ref.invalidate(groupTodaysFeedProvider(widget.groupId));
      ref.invalidate(groupNutritionDisplayGapProvider(widget.groupId));
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_entry == null) {
      return Scaffold(
        appBar: GhAppBar(title: l10n.todaysFeed),
        body: const Center(child: Text('Feed entry not found')),
      );
    }

    final entry = _entry!;

    return Scaffold(
      appBar: GhAppBar(title: _screenTitle.isEmpty ? l10n.todaysFeed : _screenTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_meal?.description != null && _meal!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _meal!.description!,
                style: const TextStyle(color: GhColors.textSecondary),
              ),
            ),
          _SummaryCard(
            subtitle: entry.subtitle,
            costSar: entry.costSar,
            totalKg: _totalKg,
          ),
          const SizedBox(height: 16),
          const Text(
            'Feeds in this meal (kg fed today)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._rows.asMap().entries.map((e) {
            final row = e.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: row.feedId,
                      decoration: const InputDecoration(labelText: 'Feed item'),
                      items: _feedOptions
                          .map(
                            (f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(
                                '${f.name} (${f.quantityKg.toInt()} kg)',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => row.feedId = v),
                    ),
                    TextField(
                      controller: row.amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'kg fed'),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_rows.length > 1)
                      TextButton(
                        onPressed: () => setState(() {
                          e.value.amountCtrl.dispose();
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
                        amountCtrl: TextEditingController(text: '10'),
                      ));
                    }),
            icon: const Icon(Icons.add),
            label: const Text('Add feed'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _headCountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Head count (optional)',
            ),
          ),
          if (_meal != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.push('/inventory/meals/${_meal!.id}'),
              icon: const Icon(Icons.restaurant_menu, size: 18),
              label: const Text('Edit meal plan template'),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: GhColors.primary),
            child: Text(_saving ? l10n.updatingFeeding : l10n.updateAction),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtitle,
    required this.costSar,
    required this.totalKg,
  });

  final String subtitle;
  final double costSar;
  final double totalKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalKg > 0
                ? '${_format(totalKg)} kg total'
                : subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (totalKg > 0 && subtitle.contains('kg/head')) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'SAR ${costSar.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static String _format(double kg) =>
      kg == kg.roundToDouble() ? '${kg.toInt()}' : kg.toStringAsFixed(1);
}

class _IngredientRow {
  _IngredientRow({required this.amountCtrl, this.feedId});

  String? feedId;
  final TextEditingController amountCtrl;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
