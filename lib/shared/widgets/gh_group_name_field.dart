import 'package:flutter/material.dart';

/// Group / herd name entry without dictation-oriented keyboard affordances.
class GhGroupNameField extends StatelessWidget {
  const GhGroupNameField({
    super.key,
    required this.controller,
    this.decoration,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: decoration,
      autofocus: autofocus,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: false,
      enableSuggestions: false,
      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      onChanged: onChanged,
    );
  }
}
