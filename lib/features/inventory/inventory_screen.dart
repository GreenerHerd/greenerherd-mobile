import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/feed_nutrition_facts.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_card.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';

final _feedProvider = FutureProvider<List<FeedInventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).listFeed();
});

final _medicalProvider = FutureProvider<List<MedicalInventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).listMedical();
});

final _lowStockProvider = FutureProvider<List<FeedInventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).listLowStock();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _tab = 0;

  void _refresh() {
    ref.invalidate(_feedProvider);
    ref.invalidate(_medicalProvider);
    ref.invalidate(_lowStockProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = ref.watch(_feedProvider);
    final medical = ref.watch(_medicalProvider);
    final lowStock = ref.watch(_lowStockProvider);

    return Scaffold(
      appBar: GhAppBar(title: l10n.inventory),
      floatingActionButton: _tab == 2
          ? null
          : _tab == 0
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final ok =
                        await context.push<bool>('/inventory/add-feed');
                    if (ok == true) _refresh();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addFeedProduct),
                  backgroundColor: GhColors.primary,
                )
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final ok =
                        await context.push<bool>('/inventory/add-medicine');
                    if (ok == true) _refresh();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addMedicine),
                  backgroundColor: GhColors.primary,
                ),
      body: Column(
        children: [
          lowStock.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return MaterialBanner(
                backgroundColor: Colors.orange.shade50,
                leading: Icon(Icons.warning_amber, color: Colors.orange.shade800),
                content: Text(l10n.lowStockFeedBanner(items.length)),
                actions: [
                  TextButton(
                    onPressed: () => context.push('/alerts'),
                    child: Text(l10n.alerts),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text(l10n.feed)),
                      ButtonSegment(value: 1, label: Text(l10n.medicine)),
                      ButtonSegment(value: 2, label: Text(l10n.animals)),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) => setState(() => _tab = s.first),
                  ),
                ),
              ],
            ),
          ),
          if (_tab == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.push('/inventory/meals');
                        _refresh();
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: Text(l10n.viewMealPlans),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await context
                            .push<bool>('/inventory/record-feeding');
                        if (ok == true) _refresh();
                      },
                      icon: const Icon(Icons.scale, size: 18),
                      label: Text(l10n.recordFeeding),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: switch (_tab) {
              0 => feed.when(
                  data: (items) => _feedList(items),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              1 => medical.when(
                  data: (items) => _medicalList(items),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              _ => _animalsTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _feedList(List<FeedInventoryItem> items) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.noFeedInInventory, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final ok =
                      await context.push<bool>('/inventory/add-feed');
                  if (ok == true) _refresh();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addFeedProduct),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final meta = [
          item.sourceLabel,
          if (item.purchasedVolumeKg != null && item.purchasedVolumeKg! > 0)
            l10n.inventoryLastPurchaseKg(
              item.purchasedVolumeKg! == item.purchasedVolumeKg!.roundToDouble()
                  ? '${item.purchasedVolumeKg!.toInt()}'
                  : item.purchasedVolumeKg!.toStringAsFixed(1),
            ),
          if (item.weeksOfSupply != null) '${item.weeksOfSupply} wk supply',
          if (item.supplierName != null) item.supplierName!,
        ].join(' · ');
        final nutritionFacts = FeedNutritionFacts.forNutritionMap(
          l10n,
          item.customNutrition,
        );

        return Card(
          color: item.lowStock ? Colors.orange.shade50 : null,
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final updated =
                  await context.push<bool>('/inventory/restock/${item.id}');
              if (updated == true) _refresh();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.grass, color: GhColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                      if (nutritionFacts.isNotEmpty) ...[
                        const SizedBox(height: 8),
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
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantityKg.toStringAsFixed(0)} ${item.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (item.unitCost != null && item.unitCost! > 0)
                      Text(
                        l10n.inventoryCostPerKg(
                          item.unitCost!.toStringAsFixed(2),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    if (item.lowStock)
                      Text(
                        l10n.lowStock,
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _animalsTab(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GhCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: GhColors.primary),
                title: Text(l10n.buyAnimals),
                subtitle: Text(l10n.buyAnimalsInventorySubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/inventory/buy'),
              ),
              const Divider(height: 1, color: GhColors.border),
              ListTile(
                leading: const GhDesignListIcon(assetPath: GhDesignIcons.sale),
                title: Text(l10n.sellAnimals),
                subtitle: Text(l10n.sellAnimalsInventorySubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/inventory/sell'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _medicalList(List<MedicalInventoryItem> items) {
    if (items.isEmpty) {
      return Center(child: Text(context.l10n.noMedicineInInventory));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(
          child: ListTile(
            leading: const GhDesignListIcon(assetPath: GhDesignIcons.medication),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(item.purpose ?? item.medicineType),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (item.unitCost != null && item.unitCost! > 0)
                  Text(
                    '${item.unitCost!.toStringAsFixed(2)} SAR/${item.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
