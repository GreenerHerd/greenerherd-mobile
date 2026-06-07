import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/services/medicine_catalog_loader.dart';

/// User's medicine choice from inventory or product catalogue.
class SelectedMedicine {
  const SelectedMedicine({
    required this.name,
    required this.sourceLabel,
    this.inventoryId,
    this.catalogProductNumber,
    this.suggestedDosage,
    this.milkWithdrawalDays,
    this.meatWithdrawalDays,
    this.inInventory = true,
  });

  final String name;
  final String sourceLabel;
  final String? inventoryId;
  final int? catalogProductNumber;
  final String? suggestedDosage;
  final int? milkWithdrawalDays;
  final int? meatWithdrawalDays;
  final bool inInventory;
}

/// Searchable bottom sheet: farm inventory first, then catalogue / marketplace list.
Future<SelectedMedicine?> showMedicinePickerSheet(
  BuildContext context, {
  required Species species,
}) {
  return showModalBottomSheet<SelectedMedicine>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _MedicinePickerSheet(species: species),
  );
}

class _MedicinePickerSheet extends ConsumerStatefulWidget {
  const _MedicinePickerSheet({required this.species});

  final Species species;

  @override
  ConsumerState<_MedicinePickerSheet> createState() =>
      _MedicinePickerSheetState();
}

class _MedicinePickerSheetState extends ConsumerState<_MedicinePickerSheet> {
  final _query = TextEditingController();
  List<MedicinePickerOption> _options = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _query.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    final catalogue = await MedicineCatalogLoader.loadProducts();
    final inventory =
        await ref.read(inventoryRepositoryProvider).listMedical();
    if (!mounted) return;
    setState(() {
      _options = MedicineCatalogLoader.buildPickerOptions(
        catalogue: catalogue,
        inventory: inventory,
      );
      _loading = false;
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<MedicinePickerOption> get _filtered {
    final q = _query.text.trim().toLowerCase();
    final locale = Localizations.localeOf(context);
    if (q.isEmpty) return _options;
    return _options.where((option) {
      return switch (option) {
        MedicineInventoryOption(:final item) =>
          item.name.toLowerCase().contains(q),
        MedicineCatalogOption(:final product) =>
          product.productNumber.toString().contains(q) ||
              product.displayName(locale).toLowerCase().contains(q),
      };
    }).toList();
  }

  Set<String> get _inventoryNames => _options
      .whereType<MedicineInventoryOption>()
      .map((o) => o.item.name.toLowerCase())
      .toSet();

  void _select(MedicinePickerOption option) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    final w = switch (option) {
      MedicineInventoryOption(:final item) => item.withdrawalFor(
            widget.species.name,
          ),
      MedicineCatalogOption(:final product) =>
        product.withdrawalFor(widget.species),
    };

    final selected = switch (option) {
      MedicineInventoryOption(:final item) => SelectedMedicine(
          name: item.name,
          sourceLabel: l10n.inStockLabel,
          inventoryId: item.id,
          suggestedDosage: null,
          milkWithdrawalDays: w?.milkDays,
          meatWithdrawalDays: w?.meatDays,
          inInventory: true,
        ),
      MedicineCatalogOption(:final product) => SelectedMedicine(
          name: product.displayName(locale),
          sourceLabel: l10n.fromProductList,
          catalogProductNumber: product.productNumber,
          suggestedDosage: product.dosage,
          milkWithdrawalDays: w?.milkDays,
          meatWithdrawalDays: w?.meatDays,
          inInventory:
              _inventoryNames.contains(product.displayName(locale).toLowerCase()),
        ),
    };
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final filtered = _filtered;
    final inventoryItems =
        filtered.whereType<MedicineInventoryOption>().toList();
    final catalogueItems =
        filtered.whereType<MedicineCatalogOption>().toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectMedicineProduct,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: l10n.searchCatalogue,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.addMedicine),
              subtitle: Text(l10n.addMedicineToInventoryHint),
              onTap: () async {
                final added = await context.push<bool>('/inventory/add-medicine');
                if (added == true) {
                  await _load();
                }
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: scrollController,
                      children: [
                        if (inventoryItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              l10n.medicine,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: GhColors.textSecondary,
                              ),
                            ),
                          ),
                          for (final o in inventoryItems)
                            ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(o.item.name),
                              subtitle: Text(o.item.medicineType),
                              onTap: () => _select(o),
                            ),
                        ],
                        if (catalogueItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              l10n.fromProductList,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: GhColors.textSecondary,
                              ),
                            ),
                          ),
                          for (final o in catalogueItems)
                            ListTile(
                              leading: const Icon(Icons.medical_information_outlined),
                              title: Text(
                                o.product.displayName(locale),
                              ),
                              subtitle: Text(
                                '#${o.product.productNumber} · ${o.product.medicineType}',
                              ),
                              onTap: () => _select(o),
                            ),
                        ],
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.noMedicineInInventory,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: GhColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
