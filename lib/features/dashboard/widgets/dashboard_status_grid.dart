import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/gh_design_icon.dart';
import '../../../shared/widgets/gh_design_icons.dart';

/// Herd status KPI tiles on the home dashboard.
class DashboardStatusGrid extends StatelessWidget {
  const DashboardStatusGrid({
    super.key,
    required this.stats,
    this.pregnantSubtitle,
    this.readySubtitle,
    this.lactatingSubtitle,
    this.weaningSubtitle,
  });

  final DashboardStats stats;
  final String? pregnantSubtitle;
  final String? readySubtitle;
  final String? lactatingSubtitle;
  final String? weaningSubtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.05,
      children: [
        _StatusTile(
          label: l10n.dashboardKpiPregnant,
          value: '${stats.pregnant}',
          subtitle: pregnantSubtitle ?? '',
          designIcon: GhDesignIcons.welfare,
          valueColor: GhColors.textPrimary,
        ),
        _StatusTile(
          label: l10n.dashboardKpiReadyToBreed,
          value: '${stats.readyToBreed}',
          subtitle: readySubtitle ?? '',
          designIcon: GhDesignIcons.readyToBreed,
          valueColor: GhColors.textPrimary,
        ),
        _StatusTile(
          label: l10n.dashboardKpiLactating,
          value: '${stats.lactating}',
          subtitle: lactatingSubtitle ?? '',
          designIcon: GhDesignIcons.calfFeeding,
          valueColor: GhColors.primary,
        ),
        _StatusTile(
          label: l10n.dashboardKpiWeaning,
          value: '${stats.weaning}',
          subtitle: weaningSubtitle ?? l10n.dashboardKpiWeaningHint,
          designIcon: GhDesignIcons.weaningBottle,
          valueColor: GhColors.textPrimary,
        ),
        _StatusTile(
          label: l10n.dashboardKpiSick,
          value: '${stats.sick}',
          subtitle: l10n.dashboardKpiSickHint,
          designIcon: GhDesignIcons.medication,
          valueColor: GhColors.error,
        ),
        _StatusTile(
          label: l10n.dashboardKpiCullFlagged,
          value: '${stats.cullFlagged}',
          subtitle: l10n.dashboardKpiCullHint,
          designIcon: GhDesignIcons.cullTag,
          valueColor: GhColors.warning,
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.designIcon,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final String designIcon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.ghSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.ghBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: context.ghTextSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              GhDesignIcon(
                assetPath: designIcon,
                size: 24,
                opacity: 0.85,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: context.ghTextSecondary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
