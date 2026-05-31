import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/gh_number_format.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/finance_ledger_service.dart';
import '../../shared/widgets/gh_bottom_sheet.dart';
import 'finance_screen.dart';

/// Add income/expense entry (FAB and app bar).
Future<void> showAddFinanceEntrySheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  var type = FinanceEntryType.expense;

  await GhBottomSheet.show(
    context,
    title: l10n.addEntry,
    child: StatefulBuilder(
      builder: (ctx, setSheetState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<FinanceEntryType>(
            segments: [
              ButtonSegment(
                value: FinanceEntryType.income,
                label: Text(l10n.income),
              ),
              ButtonSegment(
                value: FinanceEntryType.expense,
                label: Text(l10n.expense),
              ),
            ],
            selected: {type},
            onSelectionChanged: (s) => setSheetState(() => type = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: l10n.categoryOptionalPreset),
            items: (type == FinanceEntryType.income
                    ? [
                        FinanceCategories.milkSale,
                        FinanceCategories.livestockSale,
                        FinanceCategories.otherIncome,
                      ]
                    : [
                        FinanceCategories.feedPurchase,
                        FinanceCategories.medicinePurchase,
                        FinanceCategories.livestockPurchase,
                        FinanceCategories.otherExpense,
                      ])
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) categoryCtrl.text = v;
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: categoryCtrl,
            decoration: InputDecoration(labelText: l10n.category),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountCtrl,
            decoration: InputDecoration(labelText: l10n.amount),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descCtrl,
            decoration: InputDecoration(labelText: l10n.description),
            maxLines: 2,
          ),
        ],
      ),
    ),
    footer: FilledButton(
      onPressed: () async {
        final amount = GhNumberFormat.parseAmount(amountCtrl.text);
        if (amount == null || amount <= 0) return;
        await ref.read(financeRepositoryProvider).addEntry(
              FinanceEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                dateLabel: l10n.today,
                category: categoryCtrl.text.trim().isEmpty
                    ? l10n.general
                    : categoryCtrl.text.trim(),
                type: type,
                amount: amount,
                description: descCtrl.text.trim(),
              ),
            );
        ref.invalidate(financeSummaryProvider);
        if (context.mounted) Navigator.pop(context);
      },
      child: Text(l10n.save),
    ),
  );

  amountCtrl.dispose();
  categoryCtrl.dispose();
  descCtrl.dispose();
}
