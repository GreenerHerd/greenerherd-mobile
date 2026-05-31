import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_card.dart';

class SellAnimalsScreen extends ConsumerStatefulWidget {
  const SellAnimalsScreen({super.key});

  @override
  ConsumerState<SellAnimalsScreen> createState() => _SellAnimalsScreenState();
}

class _SellAnimalsScreenState extends ConsumerState<SellAnimalsScreen> {
  final _purchaserCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  DateTime _saleDate = DateTime.now();
  final List<Animal> _selected = [];
  List<Animal> _searchResults = [];
  bool _searching = false;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreselect());
  }

  @override
  void dispose() {
    _purchaserCtrl.dispose();
    _priceCtrl.dispose();
    _weightCtrl.dispose();
    _purposeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPreselect() async {
    final id = GoRouterState.of(context).uri.queryParameters['animalId'];
    if (id == null || id.isEmpty || !mounted) return;
    final animal = await ref.read(animalRepositoryProvider).getAnimal(id);
    if (animal == null || !mounted) return;
    if (animal.status != AnimalStatus.active) return;
    setState(() {
      if (!_selected.any((a) => a.id == animal.id)) {
        _selected.add(animal);
      }
    });
  }

  Future<void> _runSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final matches = await ref.read(animalRepositoryProvider).listAnimals(
          search: q,
        );
    if (!mounted) return;
    setState(() {
      _searching = false;
      _searchResults = matches
          .where((a) => !_selected.any((s) => s.id == a.id))
          .toList();
    });
  }

  void _addAnimal(Animal animal) {
    if (_selected.any((a) => a.id == animal.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.animalAlreadyInSaleList)),
      );
      return;
    }
    setState(() {
      _selected.add(animal);
      _searchResults = _searchResults.where((a) => a.id != animal.id).toList();
      _searchCtrl.clear();
    });
  }

  void _removeAnimal(Animal animal) {
    setState(() => _selected.removeWhere((a) => a.id == animal.id));
  }

  Future<void> _pickSaleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  Future<void> _confirmSale() async {
    final l10n = context.l10n;
    final purchaser = _purchaserCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim());
    if (purchaser.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPurchaserAndPrice)),
      );
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addAtLeastOneAnimal)),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmSale),
        content: Text(
          '${_selected.length} animal${_selected.length == 1 ? '' : 's'} · '
          '${price.toStringAsFixed(0)} SAR · $purchaser',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmSale),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _confirming = true);
    final weight = double.tryParse(_weightCtrl.text.trim());
    final purpose = _purposeCtrl.text.trim();
    final animalRepo = ref.read(animalRepositoryProvider);
    final commerce = ref.read(commerceRepositoryProvider);
    final ledger = ref.read(financeLedgerProvider);

    try {
      for (final animal in _selected) {
        await animalRepo.markSold(animal.id, saleAmount: price);
      }
      await commerce.recordSale(
        SaleRecord(
          id: const Uuid().v4(),
          saleDate: _saleDate,
          totalAmount: price,
          animalIds: _selected.map((a) => a.id).toList(),
          buyerName: purchaser,
          totalWeightKg: weight,
          salePurpose: purpose.isEmpty ? null : purpose,
        ),
      );
      await ledger.recordLivestockSale(
        totalAmount: price,
        animalTags: _selected.map((a) => a.tag).toList(),
        buyer: purchaser,
        saleDate: _saleDate,
        purpose: purpose.isEmpty ? null : purpose,
      );
      refreshHerdDataProviders(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saleRecorded)),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.sellAnimals,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          GhCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _purchaserCtrl,
                  decoration: InputDecoration(labelText: l10n.purchaser),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceCtrl,
                  decoration: InputDecoration(labelText: l10n.pricePaidSar),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dateOfSale),
                  subtitle: Text(
                    '${_saleDate.day}/${_saleDate.month}/${_saleDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickSaleDate,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightCtrl,
                  decoration:
                      InputDecoration(labelText: l10n.totalWeightKgOptional),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _purposeCtrl,
                  decoration:
                      InputDecoration(labelText: l10n.salePurposeOptional),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchFarmTags,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: l10n.searchFarmTags,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _runSearch('');
                      },
                    )
                  : null,
            ),
            onChanged: (v) {
              setState(() {});
              _runSearch(v);
            },
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchCtrl.text.trim().isNotEmpty &&
              _searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.noAnimalsMatchTag,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          else
            ..._searchResults.map(
              (a) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  title: Text(a.name.isEmpty ? '#${a.tag}' : a.name),
                  subtitle: Text('${a.breed} · ${a.species.name}'),
                  trailing: TextButton(
                    onPressed: () => _addAnimal(a),
                    child: Text(l10n.addToSale),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.animalsToSell,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          if (_selected.isEmpty)
            Text(
              l10n.addAtLeastOneAnimal,
              style: TextStyle(color: Colors.grey.shade700),
            )
          else
            GhCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _selected.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: GhColors.border),
                    ListTile(
                      title: Text(
                        _selected[i].name.isEmpty
                            ? '#${_selected[i].tag}'
                            : _selected[i].name,
                      ),
                      subtitle: Text(_selected[i].breed),
                      trailing: TextButton(
                        onPressed: () => _removeAnimal(_selected[i]),
                        child: Text(l10n.removeFromSaleList),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _confirming ? null : _confirmSale,
            style: FilledButton.styleFrom(
              backgroundColor: GhColors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _confirming
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.confirmSale),
          ),
        ),
      ),
    );
  }
}
