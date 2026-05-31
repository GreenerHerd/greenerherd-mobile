import 'package:flutter/material.dart';

import '../../../core/theme/gh_colors.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/gh_design_icon.dart';
import '../../../shared/widgets/gh_design_icons.dart';

/// 2×2 herd status tiles (design handoff dashboard — pregnant, ready, sick, cull).
class DashboardStatusGrid extends StatelessWidget {
  const DashboardStatusGrid({
    super.key,
    required this.stats,
    this.pregnantSubtitle,
    this.readySubtitle,
  });

  final DashboardStats stats;
  final String? pregnantSubtitle;
  final String? readySubtitle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.15,
      children: [
        _StatusTile(
          label: 'PREGNANT',
          value: '${stats.pregnant}',
          subtitle: pregnantSubtitle ?? '',
          designIcon: GhDesignIcons.welfare,
          valueColor: GhColors.textPrimary,
        ),
        _StatusTile(
          label: 'READY TO BREED',
          value: '${stats.readyToBreed}',
          subtitle: readySubtitle ?? '',
          designIcon: GhDesignIcons.readyToBreed,
          valueColor: GhColors.textPrimary,
        ),
        _StatusTile(
          label: 'SICK',
          value: '${stats.sick}',
          subtitle: 'under treatment',
          designIcon: GhDesignIcons.medication,
          valueColor: GhColors.error,
        ),
        _StatusTile(
          label: 'CULL FLAGGED',
          value: '${stats.cullFlagged}',
          subtitle: 'reviewable',
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
