import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/feed_eligibility_service.dart';
import '../../data/services/meal_stock_analyzer.dart';
import '../../shared/io/local_image.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'add_feed_route_args.dart';
import 'feed_eligibility_ui.dart';

class AddFeedScreen extends ConsumerStatefulWidget {
  const AddFeedScreen({super.key, this.prefill});

  final AddFeedRouteArgs? prefill;

  @override
  ConsumerState<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends ConsumerState<AddFeedScreen> {
  InventorySourceType _source = InventorySourceType.standard;
  FeedCatalogProduct? _catalogProduct;
  final _name = TextEditingController();
  final _volume = TextEditingController();
  final _price = TextEditingController();
  final _supplier = TextEditingController();
  final _supplierPhone = TextEditingController();
  final _dm = TextEditingController();
  final _cp = TextEditingController();
  final _nem = TextEditingController();
  InventoryFeedType _customFeedType = InventoryFeedType.fodder;
  InventoryFeedType? _catalogFilter;
  List<FeedCatalogProduct>? _catalog;
  List<FeedInventoryItem> _existingFeed = [];
  List<Animal> _farmAnimals = [];

  // Marketplace state
  List<MarketplaceFeedProduct> _marketplaceAll = [];
  InventoryFeedType? _mpCategoryFilter;
  String? _mpSupplierFilter;
  MarketplaceFeedProduct? _selectedMpProduct;
  int _mpPage = 0;
  static const _mpPageSize = 10;

  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    final existing = await ref.read(inventoryRepositoryProvider).listFeed();
    final animals = await ref.read(animalRepositoryProvider).listAnimals();
    if (mounted) {
      setState(() {
        _catalog = catalog;
        _marketplaceAll = marketplace;
        _existingFeed = existing;
        _farmAnimals = animals
            .where((a) => a.status == AnimalStatus.active)
            .toList();
      });
      _applyPrefillIfNeeded();
    }
  }

  void _applyPrefillIfNeeded() {
    final prefill = widget.prefill;
    if (prefill == null) return;

    FeedCatalogProduct? catalog;
    if (prefill.source == InventorySourceType.standard &&
        prefill.catalogProductNumber != null) {
      for (final p in _catalog ?? <FeedCatalogProduct>[]) {
        if (p.productNumber == prefill.catalogProductNumber) {
          catalog = p;
          break;
        }
      }
    }

    MarketplaceFeedProduct? mp;
    if (prefill.source == InventorySourceType.marketplace &&
        prefill.marketplaceProductId != null) {
      for (final p in _marketplaceAll) {
        if (p.id == prefill.marketplaceProductId) {
          mp = p;
          break;
        }
      }
    }

    setState(() {
      _source = prefill.source;
      _catalogProduct = catalog;
      _selectedMpProduct = mp;
      _mpCategoryFilter = null;
      _mpSupplierFilter = null;
      _photoPath = null;
      _volume.clear();
      _price.clear();
      _supplier.clear();
      _supplierPhone.clear();
      _dm.clear();
      _cp.clear();
      _nem.clear();

      if (catalog != null) {
        if (catalog.dryMatterPercent != null) {
          _dm.text = catalog.dryMatterPercent.toString();
        }
        if (catalog.crudeProteinPercent != null) {
          _cp.text = catalog.crudeProteinPercent.toString();
        }
        if (catalog.nemMcalPerKg != null) {
          _nem.text = catalog.nemMcalPerKg.toString();
        }
      } else if (mp != null) {
        _name.text = mp.nameEn;
        _price.text = mp.pricePerKg.toStringAsFixed(2);
        _supplier.text = mp.supplierName;
        _supplierPhone.text = mp.supplierPhone;
        if (mp.dryMatterPercent != null) {
          _dm.text = mp.dryMatterPercent.toString();
        }
        if (mp.crudeProteinPercent != null) {
          _cp.text = mp.crudeProteinPercent.toString();
        }
        if (mp.nemMcalPerKg != null) {
          _nem.text = mp.nemMcalPerKg.toString();
        }
      } else {
        final name = prefill.productName;
        if (name != null && name.isNotEmpty) {
          _name.text = name;
        }
        if (prefill.dryMatterPercent != null) {
          _dm.text = prefill.dryMatterPercent.toString();
        }
        if (prefill.crudeProteinPercent != null) {
          _cp.text = prefill.crudeProteinPercent.toString();
        }
        if (prefill.nemMcalPerKg != null) {
          _nem.text = prefill.nemMcalPerKg.toString();
        }
      }

      if (prefill.supplierName != null && prefill.supplierName!.isNotEmpty) {
        _supplier.text = prefill.supplierName!;
      }
    });
  }

  List<FeedCatalogProduct> get _filteredCatalog {
    final all = _catalog ?? [];
    final byType = _catalogFilter == null
        ? all
        : all
            .where(
              (p) =>
                  p.feedType.toUpperCase() == _catalogFilter!.name.toUpperCase(),
            )
            .toList();
    return FeedEligibilityService.filterProductsForAnimals(byType, _farmAnimals);
  }

  bool get _hasRestrictedCatalogProducts {
    if (_farmAnimals.isEmpty || _catalog == null) return false;
    final all = _catalog!;
    final byType = _catalogFilter == null
        ? all
        : all
            .where(
              (p) =>
                  p.feedType.toUpperCase() == _catalogFilter!.name.toUpperCase(),
            )
            .toList();
    return FeedEligibilityService.restrictedProductCount(byType, _farmAnimals) > 0;
  }

  List<String> get _mpSuppliers {
    final set = <String>{};
    for (final p in _marketplaceAll) {
      set.add(p.supplierName);
    }
    final list = set.toList()..sort();
    return list;
  }

  bool get _hasRestrictedMarketplaceProducts {
    if (_farmAnimals.isEmpty || _marketplaceAll.isEmpty) return false;
    var list = _marketplaceAll;
    if (_mpCategoryFilter != null) {
      final key = _mpCategoryFilter!.name.toUpperCase();
      list = list.where((p) => p.feedType.toUpperCase() == key).toList();
    }
    if (_mpSupplierFilter != null) {
      list = list.where((p) => p.supplierName == _mpSupplierFilter).toList();
    }
    return FeedEligibilityService.restrictedMarketplaceProductCount(
          list,
          _farmAnimals,
        ) >
        0;
  }

  List<MarketplaceFeedProduct> get _filteredMarketplace {
    var list = _marketplaceAll;
    if (_mpCategoryFilter != null) {
      final key = _mpCategoryFilter!.name.toUpperCase();
      list = list.where((p) => p.feedType.toUpperCase() == key).toList();
    }
    if (_mpSupplierFilter != null) {
      list = list.where((p) => p.supplierName == _mpSupplierFilter).toList();
    }
    return FeedEligibilityService.filterMarketplaceProductsForAnimals(
      list,
      _farmAnimals,
    );
  }

  void _onCatalogProductSelected(FeedCatalogProduct? p) {
    setState(() => _catalogProduct = p);
    if (p == null) return;
    if (p.dryMatterPercent != null) _dm.text = p.dryMatterPercent.toString();
    if (p.crudeProteinPercent != null) _cp.text = p.crudeProteinPercent.toString();
    if (p.nemMcalPerKg != null) _nem.text = p.nemMcalPerKg.toString();
  }

  void _selectMpProduct(MarketplaceFeedProduct p) {
    setState(() {
      _selectedMpProduct = p;
      _name.text = p.nameEn;
      _price.text = p.pricePerKg.toStringAsFixed(2);
      _supplier.text = p.supplierName;
      _supplierPhone.text = p.supplierPhone;
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photoPath = picked.path);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              subtitle: const Text(
                  'Capture the feed bag label with supplier & product name'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _volume.dispose();
    _price.dispose();
    _supplier.dispose();
    _supplierPhone.dispose();
    _dm.dispose();
    _cp.dispose();
    _nem.dispose();
    super.dispose();
  }

  bool get _needsNutrition => _source == InventorySourceType.custom;

  FeedInventoryItem? get _existingForSelection {
    if (_catalogProduct != null) {
      for (final f in _existingFeed) {
        if (f.feedProductNumber == _catalogProduct!.productNumber) return f;
      }
      return null;
    }
    if (_selectedMpProduct != null) {
      for (final f in _existingFeed) {
        if (f.marketplaceProductId == _selectedMpProduct!.id) return f;
      }
      return null;
    }
    if (_source == InventorySourceType.custom) {
      return _matchedExistingFeed(_name.text.trim());
    }
    return null;
  }

  List<Widget> _buildExistingStockHint(AppLocalizations l10n) {
    final existing = _existingForSelection;
    if (existing == null) return const [];
    return [
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedProductAlreadyInInventory,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.orange.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.inventoryCurrentStockKg(
                existing.quantityKg.toStringAsFixed(0),
              ),
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.feedAddProductOnlyHint,
              style: const TextStyle(
                fontSize: 12,
                color: GhColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  FeedInventoryItem? _matchedExistingFeed(String name) {
    if (_catalogProduct != null) {
      return _existingFeed
          .where((f) => f.feedProductNumber == _catalogProduct!.productNumber)
          .firstOrNull;
    }
    if (_selectedMpProduct != null) {
      return _existingFeed
          .where((f) => f.marketplaceProductId == _selectedMpProduct!.id)
          .firstOrNull;
    }
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _existingFeed
        .where((f) => f.name.trim().toLowerCase() == key)
        .firstOrNull;
  }

  Future<void> _save() async {
    final volRaw = double.tryParse(_volume.text.trim());
    if (volRaw == null || volRaw <= 0) {
      _snack(context.l10n.purchasedVolumeRequired);
      return;
    }
    final vol = clampFeedQuantityKg(volRaw);
    final unitCost = double.tryParse(_price.text.trim());
    if (unitCost == null || unitCost <= 0) {
      _snack(context.l10n.unitCostRequired);
      return;
    }

    String name;
    if (_source == InventorySourceType.standard && _catalogProduct != null) {
      name = _catalogProduct!.nameEn;
    } else if (_source == InventorySourceType.marketplace &&
        _selectedMpProduct != null) {
      name = _selectedMpProduct!.nameEn;
    } else {
      name = _name.text.trim();
    }
    if (name.isEmpty) {
      _snack('Enter a product name');
      return;
    }

    if (_source == InventorySourceType.standard && _catalogProduct != null) {
      final impacts = FeedEligibilityService.impactedAnimals(
        _catalogProduct!,
        _farmAnimals,
      );
      if (impacts.isNotEmpty) {
        final proceed = await confirmFeedEligibilityImpacts(
          context,
          title: context.l10n.feedEligibilityWarningTitle,
          message: context.l10n.feedEligibilityAddProductWarning(
            _catalogProduct!.nameEn,
          ),
          impacts: impacts,
        );
        if (!proceed) return;
      }
    } else if (_source == InventorySourceType.marketplace &&
        _selectedMpProduct != null) {
      final impacts = FeedEligibilityService.impactedAnimalsForMarketplace(
        _selectedMpProduct!,
        _farmAnimals,
      );
      if (impacts.isNotEmpty) {
        final proceed = await confirmFeedEligibilityImpacts(
          context,
          title: context.l10n.feedEligibilityWarningTitle,
          message: context.l10n.feedEligibilityAddProductWarning(
            _selectedMpProduct!.nameEn,
          ),
          impacts: impacts,
        );
        if (!proceed) return;
      }
    }

    final supplierName = _supplier.text.trim();
    final supplierPhone = _supplierPhone.text.trim();
    if (_source != InventorySourceType.marketplace &&
        supplierName.isEmpty) {
      _snack('Supplier name is required');
      return;
    }

    CustomNutritionInput? nutrition;
    if (_needsNutrition) {
      final dm = double.tryParse(_dm.text);
      final cp = double.tryParse(_cp.text);
      final nem = double.tryParse(_nem.text);
      if (dm == null && cp == null && nem == null) {
        _snack('Add at least one nutritional value (DM%, CP%, or NEm)');
        return;
      }
      nutrition = CustomNutritionInput(
        feedType: _customFeedType,
        dryMatterPercent: dm,
        crudeProteinPercent: cp,
        nemMcalPerKg: nem,
      );
    } else if (_catalogProduct != null) {
      nutrition = CustomNutritionInput(
        dryMatterPercent: _catalogProduct!.dryMatterPercent,
        crudeProteinPercent: _catalogProduct!.crudeProteinPercent,
        nemMcalPerKg: _catalogProduct!.nemMcalPerKg,
        ndfPercent: _catalogProduct!.ndfPercent,
      );
    } else if (_selectedMpProduct != null) {
      nutrition = CustomNutritionInput(
        dryMatterPercent: _selectedMpProduct!.dryMatterPercent,
        crudeProteinPercent: _selectedMpProduct!.crudeProteinPercent,
        nemMcalPerKg: _selectedMpProduct!.nemMcalPerKg,
        ndfPercent: _selectedMpProduct!.ndfPercent,
      );
    }

    InventoryFeedType? feedType;
    if (_needsNutrition) {
      feedType = _customFeedType;
    } else if (_catalogProduct != null) {
      feedType = _feedTypeFromCatalog(_catalogProduct!.feedType);
    } else if (_selectedMpProduct != null) {
      feedType = _feedTypeFromCatalog(_selectedMpProduct!.feedType);
    }

    final existing = _matchedExistingFeed(name);
    if (existing != null) {
      _snack(context.l10n.feedProductAlreadyInInventory);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).addFeed(
            CreateFeedInventoryInput(
              name: name,
              sourceType: _source,
              quantityKg: vol,
              purchasedVolumeKg: vol,
              feedProductNumber: _catalogProduct?.productNumber ??
                  _selectedMpProduct?.standardProductNumber,
              marketplaceProductId: _selectedMpProduct?.id ??
                  (_source == InventorySourceType.marketplace
                      ? 'mp-${name.toLowerCase().replaceAll(' ', '-')}'
                      : null),
              feedType: feedType,
              unitCost: unitCost,
              supplierName:
                  supplierName.isNotEmpty ? supplierName : null,
              supplierPhone:
                  supplierPhone.isNotEmpty ? supplierPhone : null,
              customNutrition: nutrition,
              estimatedDailyUsageKg: vol / 30,
              photoPath: _photoPath,
            ),
          );
      await ref.read(financeLedgerProvider).recordFeedPurchase(
            productName: name,
            quantityKg: vol,
            unitCostPerKg: unitCost,
            supplierName:
                supplierName.isNotEmpty ? supplierName : null,
          );
      refreshFinanceProviders(ref);
      if (widget.prefill?.taskId != null) {
        await ref
            .read(taskRepositoryProvider)
            .completeTask(widget.prefill!.taskId!);
      }
      if (mounted) context.pop(true);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InventoryFeedType? _feedTypeFromCatalog(String raw) {
    switch (raw.toUpperCase()) {
      case 'FODDER':
        return InventoryFeedType.fodder;
      case 'CONCENTRATE':
        return InventoryFeedType.concentrate;
      case 'ADDITIVE':
        return InventoryFeedType.additive;
      default:
        return InventoryFeedType.custom;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  ({double? dm, double? cp, double? nem, double? ndf})? get _nutritionPreviewData {
    if (_catalogProduct != null) {
      final p = _catalogProduct!;
      if (p.dryMatterPercent != null ||
          p.crudeProteinPercent != null ||
          p.nemMcalPerKg != null) {
        return (dm: p.dryMatterPercent, cp: p.crudeProteinPercent, nem: p.nemMcalPerKg, ndf: p.ndfPercent);
      }
    }
    if (_selectedMpProduct != null) {
      final p = _selectedMpProduct!;
      if (p.dryMatterPercent != null ||
          p.crudeProteinPercent != null ||
          p.nemMcalPerKg != null) {
        return (dm: p.dryMatterPercent, cp: p.crudeProteinPercent, nem: p.nemMcalPerKg, ndf: p.ndfPercent);
      }
    }
    return null;
  }

  Widget _buildNutritionPreview(
      ({double? dm, double? cp, double? nem, double? ndf}) data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: GhColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, size: 16, color: GhColors.primary),
              SizedBox(width: 6),
              Text(
                'Nutrition profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GhColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (data.dm != null) _NutritionInfoRow('Dry matter', '${data.dm}%'),
          if (data.cp != null)
            _NutritionInfoRow('Crude protein', '${data.cp}%'),
          if (data.nem != null)
            _NutritionInfoRow('Energy (NEm)', '${data.nem} Mcal/kg'),
          if (data.ndf != null)
            _NutritionInfoRow('NDF (fibre)', '${data.ndf}%'),
        ],
      ),
    );
  }

  Widget _buildMarketplaceSection(Locale locale) {
    final suppliers = _mpSuppliers;
    final products = _filteredMarketplace;
    final totalPages = products.isEmpty
        ? 1
        : ((products.length - 1) / _mpPageSize).floor() + 1;
    final pageIndex = products.isEmpty
        ? 0
        : _mpPage.clamp(0, totalPages - 1);
    final pageStart = pageIndex * _mpPageSize;
    final pageProducts = products
        .skip(pageStart)
        .take(_mpPageSize)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _mpCategoryFilter == null,
              onSelected: (_) => setState(() {
                _mpCategoryFilter = null;
                _selectedMpProduct = null;
                _mpPage = 0;
              }),
            ),
            FilterChip(
              label: const Text('Fodder'),
              selected: _mpCategoryFilter == InventoryFeedType.fodder,
              onSelected: (_) => setState(() {
                _mpCategoryFilter = InventoryFeedType.fodder;
                _selectedMpProduct = null;
                _mpPage = 0;
              }),
            ),
            FilterChip(
              label: const Text('Concentrates'),
              selected: _mpCategoryFilter == InventoryFeedType.concentrate,
              onSelected: (_) => setState(() {
                _mpCategoryFilter = InventoryFeedType.concentrate;
                _selectedMpProduct = null;
                _mpPage = 0;
              }),
            ),
            FilterChip(
              label: const Text('Additives'),
              selected: _mpCategoryFilter == InventoryFeedType.additive,
              onSelected: (_) => setState(() {
                _mpCategoryFilter = InventoryFeedType.additive;
                _selectedMpProduct = null;
                _mpPage = 0;
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Supplier',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('mp-supplier-$_mpCategoryFilter'),
          decoration: const InputDecoration(
            hintText: 'All suppliers',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          initialValue: _mpSupplierFilter,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All suppliers'),
            ),
            ...suppliers.map(
              (s) => DropdownMenuItem(value: s, child: Text(s)),
            ),
          ],
          onChanged: (v) => setState(() {
            _mpSupplierFilter = v;
            _selectedMpProduct = null;
            _mpPage = 0;
          }),
        ),
        const SizedBox(height: 16),
        Text(
          '${products.length} product${products.length == 1 ? '' : 's'} found',
          style: const TextStyle(
              fontSize: 12, color: GhColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ...pageProducts.map((p) => _MarketplaceProductTile(
              product: p,
              locale: locale,
              selected: _selectedMpProduct?.id == p.id,
              onTap: () => _selectMpProduct(p),
            )),
        if (products.length > _mpPageSize) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: pageIndex > 0
                    ? () => setState(() => _mpPage -= 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),
              Expanded(
                child: Text(
                  'Page ${pageIndex + 1} of $totalPages',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: GhColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                onPressed: pageIndex < totalPages - 1
                    ? () => setState(() => _mpPage += 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No marketplace products match these filters',
                style: TextStyle(color: GhColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomFeedSection(dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_photoPath == null) ...[
          InkWell(
            onTap: _showPhotoOptions,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: GhColors.pageBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GhColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 36, color: GhColors.primary),
                  SizedBox(height: 8),
                  Text(
                    'Add a photo of the feed product',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GhColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Take a picture of the bag label showing the\nsupplier name and product details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: buildLocalFileImage(
                  path: _photoPath!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PhotoActionButton(
                      icon: Icons.refresh,
                      onTap: _showPhotoOptions,
                    ),
                    const SizedBox(width: 6),
                    _PhotoActionButton(
                      icon: Icons.close,
                      onTap: () => setState(() => _photoPath = null),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.productName),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: GhAppBar(title: l10n.addFeedProduct),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        children: [
          Text(l10n.source, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<InventorySourceType>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            segments: [
              ButtonSegment(
                value: InventorySourceType.standard,
                label: Text(
                  l10n.standard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ButtonSegment(
                value: InventorySourceType.marketplace,
                label: Text(
                  l10n.marketplace,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ButtonSegment(
                value: InventorySourceType.custom,
                label: Text(
                  l10n.custom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            selected: {_source},
            onSelectionChanged: (s) => setState(() {
              _source = s.first;
              _catalogProduct = null;
              _selectedMpProduct = null;
            _mpPage = 0;
              _mpCategoryFilter = null;
              _mpSupplierFilter = null;
              _photoPath = null;
              _name.clear();
              _price.clear();
              _supplier.clear();
              _supplierPhone.clear();
            }),
          ),
          const SizedBox(height: 20),
          if (_source == InventorySourceType.standard) ...[
            if (_hasRestrictedCatalogProducts) ...[
              const FeedEligibilityRestrictedBanner(),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _catalogFilter == null,
                  onSelected: (_) => setState(() {
                    _catalogFilter = null;
                    _catalogProduct = null;
                  }),
                ),
                FilterChip(
                  label: const Text('Fodder'),
                  selected: _catalogFilter == InventoryFeedType.fodder,
                  onSelected: (_) => setState(() {
                    _catalogFilter = InventoryFeedType.fodder;
                    _catalogProduct = null;
                  }),
                ),
                FilterChip(
                  label: const Text('Concentrates'),
                  selected: _catalogFilter == InventoryFeedType.concentrate,
                  onSelected: (_) => setState(() {
                    _catalogFilter = InventoryFeedType.concentrate;
                    _catalogProduct = null;
                  }),
                ),
                FilterChip(
                  label: const Text('Additives'),
                  selected: _catalogFilter == InventoryFeedType.additive,
                  onSelected: (_) => setState(() {
                    _catalogFilter = InventoryFeedType.additive;
                    _catalogProduct = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FeedCatalogProduct>(
              key: ValueKey(_catalogFilter),
              decoration: InputDecoration(labelText: l10n.catalogueProduct),
              items: _filteredCatalog
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        '${p.productNumber} — ${p.displayName(locale)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _onCatalogProductSelected,
              initialValue: _catalogProduct,
            ),
          ] else if (_source == InventorySourceType.marketplace) ...[
            if (_hasRestrictedMarketplaceProducts) ...[
              const FeedEligibilityRestrictedBanner(),
              const SizedBox(height: 12),
            ],
            _buildMarketplaceSection(locale),
          ] else ...[
            _buildCustomFeedSection(l10n),
          ],
          ..._buildExistingStockHint(l10n),
          const SizedBox(height: 12),
          TextField(
            controller: _volume,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.purchasedVolumeKg} *',
            ),
          ),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.unitCostSar} *',
            ),
          ),
          if (_source != InventorySourceType.marketplace) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _supplier,
              decoration: InputDecoration(labelText: l10n.supplierName),
            ),
            TextField(
              controller: _supplierPhone,
              decoration: InputDecoration(labelText: l10n.supplierPhone),
            ),
          ],
          if (_needsNutrition) ...[
            const SizedBox(height: 16),
            Text(
              l10n.nutritionalInformation,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            DropdownButtonFormField<InventoryFeedType>(
              initialValue: _customFeedType,
              decoration: InputDecoration(labelText: l10n.feedType),
              items: InventoryFeedType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _customFeedType = v!),
            ),
            TextField(
              controller: _dm,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.dryMatterPercent),
            ),
            TextField(
              controller: _cp,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.crudeProteinPercent),
            ),
            TextField(
              controller: _nem,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.nemMcalPerKg),
            ),
          ] else if (_nutritionPreviewData != null) ...[
            const SizedBox(height: 16),
            _buildNutritionPreview(_nutritionPreviewData!),
          ],
          const SizedBox(height: 24),
          if (_existingForSelection != null)
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final id = _existingForSelection!.id;
                      if (mounted) context.pop(false);
                      await context.push<bool>('/inventory/restock/$id');
                    },
              style: FilledButton.styleFrom(
                backgroundColor: GhColors.primary,
              ),
              child: Text(l10n.feedRecordNewPurchase),
            )
          else
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: GhColors.primary,
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.addToInventory),
            ),
        ],
      ),
    );
  }
}

class _NutritionInfoRow extends StatelessWidget {
  const _NutritionInfoRow(this.label, this.value);
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

class _MarketplaceProductTile extends StatelessWidget {
  const _MarketplaceProductTile({
    required this.product,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final MarketplaceFeedProduct product;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  String get _categoryLabel => switch (product.feedType.toUpperCase()) {
        'FODDER' => 'Fodder',
        'CONCENTRATE' => 'Concentrate',
        'ADDITIVE' => 'Additive',
        _ => product.feedType,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? GhColors.primaryLight.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? GhColors.primary
                    : GhColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.displayName(locale),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle,
                          size: 20, color: GhColors.primary),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.store_outlined,
                        size: 14, color: GhColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.supplierName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: GhColors.pageBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categoryLabel,
                        style: const TextStyle(
                            fontSize: 11, color: GhColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.currency} ${product.pricePerKg.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: GhColors.primary,
                      ),
                    ),
                    if (product.packSizeKg != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${product.packSizeKg!.toStringAsFixed(0)} kg packs',
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    ],
                    if (product.minOrderKg != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Min ${product.minOrderKg!.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!product.inStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: GhColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Out of stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GhColors.error,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  const _PhotoActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
