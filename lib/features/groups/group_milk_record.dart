import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';

/// Records group milking volume and optionally posts milk sale income.
Future<void> showGroupMilkRecordDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<Animal> lactatingAnimals,
  required String groupName,
}) async {
  final litresCtrl = TextEditingController();
  final saleCtrl = TextEditingController();
  var recordSale = false;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Record milk · $groupName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${lactatingAnimals.length} lactating animals in group',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: litresCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total litres (today)',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Record milk sale income'),
                value: recordSale,
                onChanged: (v) => setState(() => recordSale = v),
              ),
              if (recordSale)
                TextField(
                  controller: saleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sale amount (SAR)'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    ),
  );

  if (ok != true || lactatingAnimals.isEmpty) {
    litresCtrl.dispose();
    saleCtrl.dispose();
    return;
  }

  final totalLitres = double.tryParse(litresCtrl.text.trim()) ?? 0;
  if (totalLitres <= 0) {
    litresCtrl.dispose();
    saleCtrl.dispose();
    return;
  }

  final lifecycle = ref.read(lifecycleServiceProvider);
  final animals = ref.read(animalRepositoryProvider);
  final lactation = ref.read(lactationRepositoryProvider);
  final perHead = totalLitres / lactatingAnimals.length;

  for (final animal in lactatingAnimals) {
    if (lifecycle.milkBlockedByWithdrawal(animal)) continue;
    try {
      await lactation.recordDailyMilk(animalId: animal.id, litres: perHead);
      final updated = lifecycle.recordMilk(animal, perHead);
      await animals.updateAnimal(updated);
    } catch (_) {}
  }

  if (recordSale) {
    final amount = double.tryParse(saleCtrl.text.trim()) ?? 0;
    if (amount > 0) {
      await ref.read(financeLedgerProvider).recordMilkSale(
            totalAmount: amount,
            note: 'Group $groupName · ${totalLitres.toStringAsFixed(1)} L',
          );
    }
  }

  litresCtrl.dispose();
  saleCtrl.dispose();

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recorded ${totalLitres.toStringAsFixed(1)} L across ${lactatingAnimals.length} animals',
        ),
      ),
    );
  }
}

List<Animal> lactatingAnimalsInGroup(List<Animal> animals) {
  return animals
      .where(
        (a) =>
            a.status == AnimalStatus.active &&
            (a.tags.contains(AnimalTagType.lactating) ||
                (a.milkTodayLitres != null && a.milkTodayLitres! > 0)),
      )
      .toList();
}
