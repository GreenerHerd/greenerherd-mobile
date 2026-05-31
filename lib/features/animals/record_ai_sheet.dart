import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../shared/widgets/gh_bottom_sheet.dart';

void showRecordAiSheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  final sireCtrl = TextEditingController(text: 'ISIS-7714 · Holstein');
  final providerCtrl = TextEditingController(text: 'Dr. Rashed');
  final batchCtrl = TextEditingController();

  GhBottomSheet.show(
    context,
    title: l10n.recordAi,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: sireCtrl,
          decoration: InputDecoration(labelText: l10n.sireLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: providerCtrl,
          decoration: InputDecoration(labelText: l10n.technicianLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: batchCtrl,
          decoration: InputDecoration(labelText: l10n.semenBatchLabel),
        ),
      ],
    ),
    footer: FilledButton(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.breedingStatusUpdated)),
        );
      },
      child: Text(l10n.save),
    ),
  ).whenComplete(() {
    sireCtrl.dispose();
    providerCtrl.dispose();
    batchCtrl.dispose();
  });
}
