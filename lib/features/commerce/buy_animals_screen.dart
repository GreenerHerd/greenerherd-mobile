import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_card.dart';
import 'buy_animals_wizard.dart';

class BuyAnimalsScreen extends ConsumerStatefulWidget {
  const BuyAnimalsScreen({super.key});

  @override
  ConsumerState<BuyAnimalsScreen> createState() => _BuyAnimalsScreenState();
}

class _BuyAnimalsScreenState extends ConsumerState<BuyAnimalsScreen> {
  Future<List<PurchaseRecord>>? _purchases;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _purchases = ref.read(commerceRepositoryProvider).listPurchases();
    });
  }

  Future<void> _startPurchase() async {
    final ok = await showBuyAnimalsWizard(context, ref);
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.buyAnimals,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startPurchase,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordPurchase),
        backgroundColor: GhColors.primary,
      ),
      body: FutureBuilder<List<PurchaseRecord>>(
        future: _purchases,
        builder: (context, snap) {
          final list = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    l10n.recordPurchase,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record purchase date, supplier, species, and each animal\'s tag.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final p = list[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GhCard(
                  child: ListTile(
                    title: Text('${p.totalAmount.toStringAsFixed(0)} SAR'),
                    subtitle: Text(_purchaseSubtitle(l10n, p)),
                    trailing: Text(
                      '${p.animalIds.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: GhColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _purchaseSubtitle(AppLocalizations l10n, PurchaseRecord p) {
    final parts = <String>[
      '${p.purchaseDate.day}/${p.purchaseDate.month}/${p.purchaseDate.year}',
      '${p.animalIds.length} animals',
    ];
    if (p.supplierName != null && p.supplierName!.isNotEmpty) {
      parts.insert(0, p.supplierName!);
    }
    if (p.species != null) {
      parts.add(localizedSpecies(p.species!, l10n));
    }
    if (p.breed != null && p.breed!.isNotEmpty) {
      parts.add(p.breed!);
    }
    return parts.join(' · ');
  }
}
