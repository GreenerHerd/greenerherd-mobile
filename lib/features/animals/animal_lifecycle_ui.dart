import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/cull_reasons.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import 'record_treatment_screen.dart';
import 'widgets/cull_reason_picker_dialog.dart';

export 'record_treatment_screen.dart' show TreatmentDetails;

void showPregnancyOutcomePicker(BuildContext context, String animalId) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      return Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.pregnancyOutcome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(l10n.gaveBirth),
                subtitle: Text(l10n.recordBirthSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/animals/$animalId/record-birth');
                },
              ),
              ListTile(
                leading: const Icon(Icons.healing_outlined),
                title: Text(l10n.miscarriage),
                subtitle: Text(l10n.miscarriageSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/animals/$animalId/record-miscarriage');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

Future<TreatmentDetails?> _openRecordTreatment(
  BuildContext context, {
  required String animalId,
  String? initialIllnessNote,
  AnimalTreatmentDetails? initialTreatment,
}) {
  return context.push<TreatmentDetails>(
    '/animals/$animalId/record-treatment',
    extra: {
      'illnessNote': initialIllnessNote,
      'treatment': initialTreatment,
    },
  );
}

/// Start illness treatment, update details, or mark animal cured.
Future<void> showTreatmentSheet(
  BuildContext context, {
  required String animalId,
  required bool isSick,
  String? illnessNote,
  AnimalTreatmentDetails? initialTreatment,
  required Future<void> Function(TreatmentDetails details) onRecordTreatment,
  required Future<void> Function() onMarkCured,
}) async {
  final l10n = context.l10n;
  if (isSick) {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.recordTreatment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: Text(l10n.updateTreatment),
                subtitle: Text(l10n.updateTreatmentSubtitle),
                onTap: () async {
                  Navigator.pop(ctx);
                  final details = await _openRecordTreatment(
                    context,
                    animalId: animalId,
                    initialIllnessNote: illnessNote,
                    initialTreatment: initialTreatment,
                  );
                  if (details == null || !context.mounted) return;
                  await onRecordTreatment(details);
                },
              ),
              ListTile(
                leading: const Icon(Icons.healing, color: Colors.green),
                title: Text(l10n.markCured),
                onTap: () async {
                  Navigator.pop(ctx);
                  await onMarkCured();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    return;
  }

  final details = await _openRecordTreatment(
    context,
    animalId: animalId,
    initialIllnessNote: illnessNote,
    initialTreatment: initialTreatment,
  );
  if (details == null || !context.mounted) return;
  await onRecordTreatment(details);
}

/// Prompts for cull type/reason, then confirmation. Returns selection if confirmed.
Future<CullReasonSelection?> showRecordDeathFlow(
  BuildContext context, {
  required String animalLabel,
}) async {
  final l10n = context.l10n;
  final selection = await CullReasonPickerDialog.show(
    context,
    title: l10n.recordDeath,
  );
  if (selection == null || !context.mounted) return null;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.confirmRecordDeath),
      content: Text(
        l10n.confirmRecordDeathMessage(animalLabel, selection.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.confirmRecordDeath),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return null;
  return selection;
}

void showCullActionSheet(
  BuildContext context, {
  required bool alreadyFlagged,
  required Future<void> Function(CullReasonSelection selection) onFlag,
  required VoidCallback onClear,
  required VoidCallback onSell,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final l10n = context.l10n;
      return Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const GhDesignListIcon(assetPath: GhDesignIcons.sale),
                title: Text(l10n.sellAnimals),
                onTap: () {
                  Navigator.pop(ctx);
                  onSell();
                },
              ),
              if (!alreadyFlagged)
                ListTile(
                  leading:
                      const GhDesignListIcon(assetPath: GhDesignIcons.cullTag),
                  title: Text(l10n.flagForCull),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final selection = await CullReasonPickerDialog.show(
                      context,
                      title: l10n.flagForCull,
                    );
                    if (selection != null) {
                      await onFlag(selection);
                    }
                  },
                ),
              if (alreadyFlagged)
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: Text(l10n.clearCullFlag),
                  onTap: () {
                    Navigator.pop(ctx);
                    onClear();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
