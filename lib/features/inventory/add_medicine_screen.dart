import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/medicine_catalog_loader.dart';
import '../../shared/widgets/gh_app_bar.dart';

enum _MedicineEntryMode { catalogue, custom }

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  _MedicineEntryMode _mode = _MedicineEntryMode.catalogue;
  List<MedicinePickerOption> _pickerOptions = [];
  MedicinePickerOption? _selectedOption;

  final _name = TextEditingController();
  final _type = TextEditingController(text: 'ANTIBIOTIC');
  final _purpose = TextEditingController();
  final _quantity = TextEditingController();
  final _weeklyUsage = TextEditingController();
  final _price = TextEditingController();
  final _supplier = TextEditingController();
  String _unit = 'dose';
  bool _saving = false;
  String? _catalogQuery;
  bool _loading = true;

  final Map<Species, TextEditingController> _meatWithdrawal = {};
  final Map<Species, TextEditingController> _milkWithdrawal = {};

  @override
  void initState() {
    super.initState();
    for (final sp in Species.values) {
      _meatWithdrawal[sp] = TextEditingController();
      _milkWithdrawal[sp] = TextEditingController();
    }
    _loadPicker();
  }

  Future<void> _loadPicker() async {
    final catalogue = await MedicineCatalogLoader.loadProducts();
    final inventory =
        await ref.read(inventoryRepositoryProvider).listMedical();
    if (!mounted) return;
    setState(() {
      _pickerOptions = MedicineCatalogLoader.buildPickerOptions(
        catalogue: catalogue,
        inventory: inventory,
      );
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _purpose.dispose();
    _quantity.dispose();
    _weeklyUsage.dispose();
    _price.dispose();
    _supplier.dispose();
    for (final c in _meatWithdrawal.values) {
      c.dispose();
    }
    for (final c in _milkWithdrawal.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearWithdrawals() {
    for (final sp in Species.values) {
      _meatWithdrawal[sp]!.text = '';
      _milkWithdrawal[sp]!.text = '';
    }
  }

  void _applyWithdrawals(List<WithdrawalPeriod> periods) {
    _clearWithdrawals();
    for (final sp in Species.values) {
      WithdrawalPeriod? match;
      for (final w in periods) {
        if (w.species.toLowerCase() == sp.name.toLowerCase()) {
          match = w;
          break;
        }
      }
      if (match == null) continue;
      if (match.meatDays > 0) {
        _meatWithdrawal[sp]!.text = '${match.meatDays}';
      }
      if (match.milkDays > 0) {
        _milkWithdrawal[sp]!.text = '${match.milkDays}';
      }
    }
  }

  void _applyCatalogProduct(MedicineCatalogProduct product, Locale locale) {
    _name.text = product.displayName(locale);
    _type.text = product.medicineType;
    _purpose.text = product.displayPurpose(locale);
    _unit = product.defaultUnit;
    _applyWithdrawals(product.withdrawalPeriods);
  }

  void _applyInventoryItem(MedicalInventoryItem item) {
    _name.text = item.name;
    _type.text = item.medicineType;
    _purpose.text = item.purpose ?? '';
    _unit = item.unit;
    if (item.unitCost != null) {
      _price.text = item.unitCost!.toStringAsFixed(2);
    }
    if (item.supplierName != null && item.supplierName!.isNotEmpty) {
      _supplier.text = item.supplierName!;
    }
    _applyWithdrawals(item.withdrawalPeriods);
  }

  void _onPickerChanged(MedicinePickerOption? option, Locale locale) {
    setState(() {
      _selectedOption = option;
      if (option == null) return;
      switch (option) {
        case MedicineCatalogOption(:final product):
          _applyCatalogProduct(product, locale);
        case MedicineInventoryOption(:final item):
          _applyInventoryItem(item);
      }
    });
  }

  List<MedicinePickerOption> _filteredPickerOptions(Locale locale) {
    final q = _catalogQuery?.trim().toLowerCase() ?? '';
    final inStock = _pickerOptions.whereType<MedicineInventoryOption>().toList();
    if (q.isEmpty) {
      return inStock;
    }
    return _pickerOptions.where((option) {
      return switch (option) {
        MedicineCatalogOption(:final product) =>
          product.productNumber.toString().contains(q) ||
              product.displayName(locale).toLowerCase().contains(q) ||
              product.displayPurpose(locale).toLowerCase().contains(q),
        MedicineInventoryOption(:final item) =>
          item.name.toLowerCase().contains(q),
      };
    }).toList();
  }

  int get _catalogueMatchCount => _pickerOptions
      .whereType<MedicineCatalogOption>()
      .length;

  void _switchMode(_MedicineEntryMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _selectedOption = null;
      _name.clear();
      _type.text = 'ANTIBIOTIC';
      _purpose.clear();
      _clearWithdrawals();
      if (mode == _MedicineEntryMode.custom) {
        _name.clear();
      }
    });
  }

  List<WithdrawalPeriod> _buildWithdrawals() {
    final list = <WithdrawalPeriod>[];
    for (final sp in Species.values) {
      final meat = int.tryParse(_meatWithdrawal[sp]?.text ?? '') ?? 0;
      final milk = int.tryParse(_milkWithdrawal[sp]?.text ?? '') ?? 0;
      if (meat > 0 || milk > 0) {
        list.add(WithdrawalPeriod(
          species: sp.name,
          meatDays: meat,
          milkDays: milk,
        ));
      }
    }
    return list;
  }

  String _resolveName() {
    if (_mode == _MedicineEntryMode.custom) {
      return _name.text.trim();
    }
    return _name.text.trim().isNotEmpty
        ? _name.text.trim()
        : switch (_selectedOption) {
            MedicineCatalogOption(:final product) => product.nameEn,
            MedicineInventoryOption(:final item) => item.name,
            null => '',
          };
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _resolveName();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medicineNameRequired)),
      );
      return;
    }
    if (_supplier.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supplierNameRequired)),
      );
      return;
    }
    final qty = double.tryParse(_quantity.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchasedVolumeRequired)),
      );
      return;
    }
    final unitCost = double.tryParse(_price.text.trim());
    if (unitCost == null || unitCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unitCostRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).addMedical(
            name: name,
            medicineType: _type.text.trim(),
            quantity: qty,
            unit: _unit,
            supplierName: _supplier.text.trim(),
            unitCost: unitCost,
            purpose:
                _purpose.text.trim().isEmpty ? null : _purpose.text.trim(),
            estimatedWeeklyUsage: double.tryParse(_weeklyUsage.text),
            withdrawalPeriods: _buildWithdrawals(),
          );
      await ref.read(financeLedgerProvider).recordMedicinePurchase(
            productName: name,
            quantity: qty,
            unit: _unit,
            unitCost: unitCost,
            supplierName: _supplier.text.trim(),
          );
      refreshFinanceProviders(ref);
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _speciesLabel(Species sp) => switch (sp) {
        Species.cattle => 'Cattle',
        Species.goat => 'Goat',
        Species.sheep => 'Sheep',
      };

  String _pickerLabel(MedicinePickerOption option, Locale locale) {
    return switch (option) {
      MedicineInventoryOption(:final item) =>
        '${context.l10n.inStockLabel}: ${item.name}',
      MedicineCatalogOption(:final product) =>
        '${product.productNumber} — ${product.displayName(locale)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    if (_loading) {
      return Scaffold(
        appBar: GhAppBar(title: l10n.addMedicine),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: GhAppBar(title: l10n.addMedicine),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.medicineProductSource,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SegmentedButton<_MedicineEntryMode>(
            segments: [
              ButtonSegment(
                value: _MedicineEntryMode.catalogue,
                label: Text(l10n.fromProductList),
              ),
              ButtonSegment(
                value: _MedicineEntryMode.custom,
                label: Text(l10n.customMedicineName),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => _switchMode(s.first),
          ),
          const SizedBox(height: 16),
          if (_mode == _MedicineEntryMode.catalogue) ...[
            TextField(
              decoration: InputDecoration(
                labelText: l10n.searchCatalogue,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
              onChanged: (v) => setState(() => _catalogQuery = v),
            ),
            const SizedBox(height: 12),
            Text(
              (_catalogQuery?.trim().isEmpty ?? true)
                  ? l10n.medicineCatalogueSearchHint(_catalogueMatchCount)
                  : '${_filteredPickerOptions(locale).length} ${l10n.medicineProductsAvailable}',
              style: const TextStyle(
                fontSize: 12,
                color: GhColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MedicinePickerOption>(
              initialValue: _selectedOption,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.selectMedicineProduct,
                hintText: l10n.selectMedicineProduct,
              ),
              items: _filteredPickerOptions(locale)
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        _pickerLabel(o, locale),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (o) => _onPickerChanged(o, locale),
            ),
            if (_selectedOption case MedicineCatalogOption(:final product)) ...[
              const SizedBox(height: 8),
              if (product.activeIngredient != null &&
                  product.activeIngredient!.isNotEmpty)
                Text(
                  '${l10n.activeIngredient}: ${product.activeIngredient}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                ),
              if (product.dosage != null && product.dosage!.isNotEmpty)
                Text(
                  '${l10n.dosage}: ${product.dosage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                ),
              if (product.routeOfAdministration != null &&
                  product.routeOfAdministration!.isNotEmpty)
                Text(
                  '${l10n.routeOfAdministration}: ${product.routeOfAdministration}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                ),
            ],
            if (_selectedOption case MedicineInventoryOption(:final item)) ...[
              const SizedBox(height: 8),
              Text(
                l10n.inventoryCurrentStockKg(
                  item.quantity.toStringAsFixed(0),
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: GhColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              readOnly: _selectedOption != null,
              decoration: InputDecoration(
                labelText: l10n.medicineName,
                helperText: _selectedOption == null
                    ? l10n.selectMedicineOrEnterName
                    : null,
              ),
            ),
          ] else ...[
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.medicineName),
            ),
          ],
          TextField(
            controller: _type,
            decoration: InputDecoration(labelText: l10n.medicineTypeLabel),
          ),
          TextField(
            controller: _purpose,
            decoration: InputDecoration(labelText: l10n.purpose),
          ),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.purchasedVolumeKg} *',
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: _unit,
            decoration: InputDecoration(labelText: l10n.unit),
            items: const ['kg', 'litre', 'unit', 'dose', 'ml']
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) => setState(() => _unit = v!),
          ),
          TextField(
            controller: _weeklyUsage,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.estimatedWeeklyUsage,
            ),
          ),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.unitCostSar} *',
            ),
          ),
          TextField(
            controller: _supplier,
            decoration: InputDecoration(
              labelText: '${l10n.supplierName} *',
            ),
          ),
          const SizedBox(height: 24),
          _WithdrawalSection(
            speciesLabel: _speciesLabel,
            meatWithdrawal: _meatWithdrawal,
            milkWithdrawal: _milkWithdrawal,
            withdrawalHint: l10n.withdrawalPrefilledHint,
            showPrefilledHint: _mode == _MedicineEntryMode.catalogue &&
                _selectedOption != null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: GhColors.primary),
            child: Text(_saving ? l10n.saving : l10n.addToInventory),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalSection extends StatelessWidget {
  const _WithdrawalSection({
    required this.speciesLabel,
    required this.meatWithdrawal,
    required this.milkWithdrawal,
    required this.withdrawalHint,
    required this.showPrefilledHint,
  });

  final String Function(Species sp) speciesLabel;
  final Map<Species, TextEditingController> meatWithdrawal;
  final Map<Species, TextEditingController> milkWithdrawal;
  final String withdrawalHint;
  final bool showPrefilledHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GhColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: GhColors.primary),
              SizedBox(width: 6),
              Text(
                'Withdrawal periods (days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: GhColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            showPrefilledHint
                ? withdrawalHint
                : 'Time after last dose before meat or milk is safe for consumption. Values differ by species.',
            style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
          ),
          const SizedBox(height: 14),
          for (final sp in Species.values) ...[
            _WithdrawalSpeciesRow(
              speciesLabel: speciesLabel(sp),
              meatController: meatWithdrawal[sp]!,
              milkController: milkWithdrawal[sp]!,
            ),
            if (sp != Species.values.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _WithdrawalSpeciesRow extends StatelessWidget {
  const _WithdrawalSpeciesRow({
    required this.speciesLabel,
    required this.meatController,
    required this.milkController,
  });

  final String speciesLabel;
  final TextEditingController meatController;
  final TextEditingController milkController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            speciesLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: meatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Meat (days)',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.restaurant, size: 16),
                    ),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 32, minHeight: 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: milkController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Milk (days)',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.water_drop_outlined, size: 16),
                    ),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 32, minHeight: 0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
