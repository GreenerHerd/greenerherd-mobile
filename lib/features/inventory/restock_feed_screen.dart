import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/feed_nutrition_facts.dart';
import '../../data/services/meal_stock_analyzer.dart';
import '../../shared/widgets/gh_app_bar.dart';

/// Record a new purchase against an existing feed inventory item.
class RestockFeedScreen extends ConsumerStatefulWidget {
  const RestockFeedScreen({super.key, required this.feedId});

  final String feedId;

  @override
  ConsumerState<RestockFeedScreen> createState() => _RestockFeedScreenState();
}

class _RestockFeedScreenState extends ConsumerState<RestockFeedScreen> {
  final _volumeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _supplierPhoneCtrl = TextEditingController();

  FeedInventoryItem? _item;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _priceCtrl.dispose();
    _supplierCtrl.dispose();
    _supplierPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final item =
        await ref.read(inventoryRepositoryProvider).getFeed(widget.feedId);
    if (!mounted) return;
    if (item != null) {
      _item = item;
      _priceCtrl.text = item.unitCost != null && item.unitCost! > 0
          ? item.unitCost!.toStringAsFixed(2)
          : '';
      _supplierCtrl.text = item.supplierName ?? '';
      _supplierPhoneCtrl.text = item.supplierPhone ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final item = _item;
    if (item == null) return;

    final volRaw = double.tryParse(_volumeCtrl.text.trim());
    if (volRaw == null || volRaw <= 0) {
      _snack(l10n.purchasedVolumeRequired);
      return;
    }
    final unitCost = double.tryParse(_priceCtrl.text.trim());
    if (unitCost == null || unitCost <= 0) {
      _snack(l10n.unitCostRequired);
      return;
    }

    final supplierName = _supplierCtrl.text.trim();
    if (item.sourceType != InventorySourceType.marketplace &&
        supplierName.isEmpty) {
      _snack(l10n.supplierNameRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      final vol = clampFeedQuantityKg(volRaw);
      final updated = await ref.read(inventoryRepositoryProvider).restockFeed(
            feedId: item.id,
            purchasedVolumeKg: vol,
            unitCost: unitCost,
            supplierName: supplierName.isEmpty ? null : supplierName,
            supplierPhone: _supplierPhoneCtrl.text.trim().isEmpty
                ? null
                : _supplierPhoneCtrl.text.trim(),
          );
      await ref.read(financeLedgerProvider).recordFeedPurchase(
            productName: updated.name,
            quantityKg: vol,
            unitCostPerKg: unitCost,
            supplierName: supplierName.isEmpty ? null : supplierName,
          );
      refreshFinanceProviders(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.stockUpdated)),
      );
      context.pop(true);
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: GhAppBar(title: l10n.recordPurchase),
        body: const Center(child: Text('Feed product not found')),
      );
    }

    final nutritionFacts = FeedNutritionFacts.forNutritionMap(
      l10n,
      item.customNutrition,
    );
    final previousCost = item.unitCost;

    return Scaffold(
      appBar: GhAppBar(title: l10n.recordPurchase),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.inventoryCurrentStockKg(
              item.quantityKg.toStringAsFixed(0),
            ),
            style: const TextStyle(color: GhColors.textSecondary),
          ),
          if (nutritionFacts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final fact in nutritionFacts)
                  Chip(
                    label: Text(
                      '${fact.label} ${fact.value}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        GhColors.primaryLight.withValues(alpha: 0.35),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          TextField(
            controller: _volumeCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.purchasedVolumeKg} *',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.unitCostSar} *',
              helperText: previousCost != null && previousCost > 0
                  ? l10n.inventoryPreviousUnitCost(
                      previousCost.toStringAsFixed(2),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _supplierCtrl,
            decoration: InputDecoration(
              labelText: item.sourceType == InventorySourceType.marketplace
                  ? l10n.supplierName
                  : '${l10n.supplierName} *',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _supplierPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.supplierPhone),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: GhColors.primary),
            child: Text(_saving ? l10n.saving : l10n.recordPurchase),
          ),
        ],
      ),
    );
  }
}
