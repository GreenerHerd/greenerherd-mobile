import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../features/groups/group_mock_extras.dart';

/// Purpose pill matching design_handoff `PurposeBadge` / `Badge` tones.
class GroupPurposeBadge extends StatelessWidget {
  const GroupPurposeBadge({super.key, required this.purpose});

  final GroupPurpose purpose;

  ({Color bg, Color fg}) _colors() => switch (purpose) {
        GroupPurpose.sick => (bg: GhColors.errorLight, fg: GhColors.error),
        GroupPurpose.fattening ||
        GroupPurpose.weaning =>
          (bg: GhColors.secondaryLight.withOpacity(0.35), fg: GhColors.secondary),
        GroupPurpose.maintenance ||
        GroupPurpose.dry =>
          (bg: GhColors.pageBackground, fg: GhColors.textSecondary),
        _ => (bg: GhColors.primaryLight, fg: GhColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        GroupMockExtras.purposeLabel(purpose),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.fg,
        ),
      ),
    );
  }
}
