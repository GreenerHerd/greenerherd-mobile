import 'package:flutter/material.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';

class GhChip extends StatelessWidget {
  const GhChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : GhColors.textPrimary;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Material(
        color: selected ? GhColors.primary : GhColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? GhColors.primary : GhColors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: GhTypography.h05.copyWith(color: fg, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
