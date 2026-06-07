import 'package:flutter/material.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';

class GhStatusTag extends StatelessWidget {
  const GhStatusTag({
    super.key,
    required this.tag,
    this.onTap,
  });

  final AnimalTagType tag;
  final VoidCallback? onTap;

  Color _bg() {
    switch (tag) {
      case AnimalTagType.sick:
        return GhColors.errorLight;
      case AnimalTagType.cull:
      case AnimalTagType.miscarriage:
      case AnimalTagType.stillborn:
        return GhColors.warningLight;
      default:
        return GhColors.primaryLight;
    }
  }

  Color _fg() {
    switch (tag) {
      case AnimalTagType.sick:
        return GhColors.error;
      case AnimalTagType.cull:
        return GhColors.warning;
      default:
        return GhColors.primary;
    }
  }

  String _label() {
    switch (tag) {
      case AnimalTagType.readyToBreed:
        return 'Ready to breed';
      case AnimalTagType.cull:
        return 'Cull flagged';
      default:
        return tag.name[0].toUpperCase() + tag.name.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(99),
        border: onTap != null
            ? Border.all(color: _fg().withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _fg(),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 12, color: _fg()),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: chip,
      ),
    );
  }
}
