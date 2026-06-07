import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/enums.dart';
import '../../data/models/milking_session.dart';
import '../../data/models/models.dart';
import '../../data/services/milk_record_service.dart';

/// Records group milking volume per animal (no finance — use Finance for milk sales).
Future<void> showGroupMilkRecordDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<Animal> lactatingAnimals,
  required String groupName,
  MilkingSession session = MilkingSession.daily,
  DateTime? onDate,
}) async {
  final litresCtrl = TextEditingController();

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total litres',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (ok != true || lactatingAnimals.isEmpty) {
    litresCtrl.dispose();
    return;
  }

  final totalLitres = double.tryParse(litresCtrl.text.trim()) ?? 0;
  litresCtrl.dispose();
  if (totalLitres <= 0) return;

  final lifecycle = ref.read(lifecycleServiceProvider);
  final animals = ref.read(animalRepositoryProvider);
  final lactation = ref.read(lactationRepositoryProvider);
  final perHead = totalLitres / lactatingAnimals.length;
  final date = onDate ?? DateTime.now();
  final day = DateTime(date.year, date.month, date.day);

  for (final animal in lactatingAnimals) {
    if (lifecycle.milkBlockedByWithdrawal(animal)) continue;
    try {
      await lactation.recordMilk(
        animalId: animal.id,
        litres: perHead,
        onDate: day,
        session: session,
      );
      if (MilkRecordService.isSameDay(day, DateTime.now())) {
        final history = await lactation.milkHistory(animal.id);
        final total =
            MilkRecordService.totalLitresForDay(history, day) ?? perHead;
        final updated = lifecycle.recordMilk(animal, total);
        await animals.updateAnimal(updated);
      }
    } catch (_) {}
  }

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
