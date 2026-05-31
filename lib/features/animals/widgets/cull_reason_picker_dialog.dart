import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../data/models/cull_reasons.dart';

/// Type + subcategory picker for cull or death recording.
class CullReasonPickerDialog extends StatefulWidget {
  const CullReasonPickerDialog({
    super.key,
    required this.title,
  });

  final String title;

  static Future<CullReasonSelection?> show(
    BuildContext context, {
    required String title,
  }) {
    return showDialog<CullReasonSelection>(
      context: context,
      builder: (_) => CullReasonPickerDialog(title: title),
    );
  }

  @override
  State<CullReasonPickerDialog> createState() => _CullReasonPickerDialogState();
}

class _CullReasonPickerDialogState extends State<CullReasonPickerDialog> {
  late String _type;
  String? _reason;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = CullReasonCatalog.types.first;
    _reason = CullReasonCatalog.reasonsFor(_type).first;
  }

  void _save() {
    final reason = _reason;
    if (reason == null || reason.isEmpty) {
      setState(() => _error = 'Required');
      return;
    }
    Navigator.pop(
      context,
      CullReasonSelection(type: _type, reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasons = CullReasonCatalog.reasonsFor(_type);

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: InputDecoration(labelText: l10n.cullType),
            items: [
              for (final type in CullReasonCatalog.types)
                DropdownMenuItem(value: type, child: Text(type)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _type = value;
                _reason = CullReasonCatalog.reasonsFor(value).first;
                _error = null;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _reason,
            decoration: InputDecoration(
              labelText: l10n.cullReason,
              errorText: _error,
            ),
            items: [
              for (final reason in reasons)
                DropdownMenuItem(value: reason, child: Text(reason)),
            ],
            onChanged: (value) => setState(() {
              _reason = value;
              _error = null;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
