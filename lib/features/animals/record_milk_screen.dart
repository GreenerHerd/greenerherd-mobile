import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'animal_providers.dart';
import 'lactation_providers.dart';

class RecordMilkScreen extends ConsumerStatefulWidget {
  const RecordMilkScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<RecordMilkScreen> createState() => _RecordMilkScreenState();
}

class _RecordMilkScreenState extends ConsumerState<RecordMilkScreen> {
  final _litres = TextEditingController();
  final _saleAmount = TextEditingController();
  var _recordSale = false;
  bool _saving = false;

  @override
  void dispose() {
    _litres.dispose();
    _saleAmount.dispose();
    super.dispose();
  }

  Future<void> _save(Animal animal) async {
    final l10n = context.l10n;
    final litres = double.tryParse(_litres.text.trim());
    if (litres == null || litres < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validMilkVolume)),
      );
      return;
    }
    final lifecycle = ref.read(lifecycleServiceProvider);
    if (lifecycle.milkBlockedByWithdrawal(animal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.milkBlockedWithdrawal)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(lactationRepositoryProvider).recordDailyMilk(
            animalId: animal.id,
            litres: litres,
          );
      final updated = lifecycle.recordMilk(animal, litres);
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      if (_recordSale) {
        final amount = double.tryParse(_saleAmount.text.trim()) ?? 0;
        if (amount > 0) {
          await ref.read(financeLedgerProvider).recordMilkSale(
                totalAmount: amount,
                note: 'Milk · #${animal.tag} · ${litres.toStringAsFixed(1)} L',
              );
        }
      }
      ref
        ..invalidate(animalProvider(widget.animalId))
        ..invalidate(animalsListProvider)
        ..invalidate(milkHistoryProvider(widget.animalId))
        ..invalidate(lactationCycleProvider(widget.animalId));
      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.recordedMilkFor(
                litres.toStringAsFixed(1),
                animal.tag,
              ),
            ),
          ),
        );
      }
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
    final animalAsync = ref.watch(animalProvider(widget.animalId));
    return animalAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (animal) {
        if (animal == null) {
          return Scaffold(body: Center(child: Text(l10n.animalNotFound)));
        }
        return Scaffold(
          appBar: GhAppBar(
            title: l10n.recordMilk,
            subtitle: '#${animal.tag}',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (animal.milkTodayLitres != null)
                Text(
                  l10n.previousTodayMilk(
                    animal.milkTodayLitres!.toStringAsFixed(1),
                  ),
                  style: const TextStyle(color: GhColors.textSecondary),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _litres,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.todaysMilkLitres,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.recordMilkSaleIncome),
                subtitle: Text(l10n.recordMilkSaleIncomeSubtitle),
                value: _recordSale,
                onChanged: (v) => setState(() => _recordSale = v),
              ),
              if (_recordSale)
                TextField(
                  controller: _saleAmount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.saleAmountSar,
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(animal),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }
}
