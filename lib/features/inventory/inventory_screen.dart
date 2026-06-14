import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/feed_nutrition_facts.dart';
import '../../shared/io/local_image.dart';
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

typedef FeedImageIndex = ({
  Map<int, String> standardByNumber,
  Map<String, String> marketplaceById,
});

final _feedImageIndexProvider = FutureProvider<FeedImageIndex>((ref) async {
  final standardByNumber = await FeedCatalogLoader.loadStandardImageUrlsByNumber();
  final marketplaceById = await FeedCatalogLoader.loadMarketplaceImageUrlsById();
  return (
    standardByNumber: standardByNumber,
    marketplaceById: marketplaceById,
  );
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
      backgroundColor: context.ghPageBackground,
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
                  backgroundColor: context.ghPrimary,
                )
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final ok =
                        await context.push<bool>('/inventory/add-medicine');
                    if (ok == true) _refresh();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addMedicine),
                  backgroundColor: context.ghPrimary,
                ),
      body: Column(
        children: [
          lowStock.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return MaterialBanner(
                backgroundColor: context.ghWarningLight,
                leading: Icon(Icons.warning_amber, color: context.ghWarning),
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
                  data: (items) => ref.watch(_feedImageIndexProvider).when(
                        data: (imageIndex) =>
                            _feedList(items, imageIndex: imageIndex),
                        loading: () => _feedList(items),
                        error: (_, __) => _feedList(items),
                      ),
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

  Widget _feedList(List<FeedInventoryItem> items, {FeedImageIndex? imageIndex}) {
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
          color: item.lowStock ? context.ghWarningLight : null,
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
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _FeedListThumbnail(
                    item: item,
                    catalogImageUrl: _catalogImageUrlForItem(item, imageIndex),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: context.textH04,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: context.textMuted.copyWith(fontSize: 12),
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
                      style: context.textH04,
                    ),
                    if (item.unitCost != null && item.unitCost! > 0)
                      Text(
                        l10n.inventoryCostPerKg(
                          item.unitCost!.toStringAsFixed(2),
                        ),
                        style: context.textMuted.copyWith(fontSize: 12),
                      ),
                    if (item.lowStock)
                      Text(
                        l10n.lowStock,
                        style: TextStyle(
                          color: context.ghWarning,
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

  String? _catalogImageUrlForItem(
    FeedInventoryItem item,
    FeedImageIndex? imageIndex,
  ) {
    if (imageIndex == null) return null;
    final feedProductNumber = item.feedProductNumber;
    if (feedProductNumber != null) {
      return imageIndex.standardByNumber[feedProductNumber];
    }
    final marketplaceProductId = item.marketplaceProductId;
    if (marketplaceProductId != null) {
      return imageIndex.marketplaceById[marketplaceProductId];
    }
    return null;
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
                leading: Icon(Icons.add_circle_outline, color: context.ghPrimary),
                title: Text(l10n.buyAnimals, style: context.textBody),
                subtitle: Text(
                  l10n.buyAnimalsInventorySubtitle,
                  style: context.textMuted.copyWith(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: context.ghTextFaint),
                onTap: () => context.push('/inventory/buy'),
              ),
              Divider(height: 1, color: context.ghBorder),
              ListTile(
                leading: const GhDesignListIcon(assetPath: GhDesignIcons.sale),
                title: Text(l10n.sellAnimals, style: context.textBody),
                subtitle: Text(
                  l10n.sellAnimalsInventorySubtitle,
                  style: context.textMuted.copyWith(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: context.ghTextFaint),
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
            title: Text(item.name, style: context.textH04),
            subtitle: Text(
              item.purpose ?? item.medicineType,
              style: context.textMuted.copyWith(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                  style: context.textH04,
                ),
                if (item.unitCost != null && item.unitCost! > 0)
                  Text(
                    '${item.unitCost!.toStringAsFixed(2)} SAR/${item.unit}',
                    style: context.textMuted.copyWith(fontSize: 12),
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
        color: context.ghAccentSurfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.ghPrimary.withValues(alpha: 0.15)),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 11, color: context.ghTextPrimary),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.ghTextSecondary,
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

class _FeedListThumbnail extends StatelessWidget {
  const _FeedListThumbnail({
    required this.item,
    this.catalogImageUrl,
  });

  final FeedInventoryItem item;
  final String? catalogImageUrl;

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    final displayPath = resolveProductImagePath(
      userPhotoPath: item.photoPath,
      catalogImageUrl: catalogImageUrl,
    );
    if (productImageResolvable(displayPath)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: buildProductImage(
          path: displayPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context),
        ),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.ghAccentSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.grass, color: context.ghPrimary),
    );
  }
}
