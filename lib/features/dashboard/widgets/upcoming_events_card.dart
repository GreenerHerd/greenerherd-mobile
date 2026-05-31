import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gh_colors.dart';
import '../dashboard_providers.dart';

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({
    super.key,
    required this.events,
    this.badgeCount = 12,
  });

  final List<DashboardUpcomingEvent> events;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming · 7 days',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GhColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GhColors.warningLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: GhColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _EventRow(event: events[i]),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final DashboardUpcomingEvent event;

  Color get _iconBg => switch (event.tone) {
        DashboardEventTone.warning => GhColors.warningLight,
        DashboardEventTone.primary => GhColors.primaryLight,
      };

  Color get _iconFg => switch (event.tone) {
        DashboardEventTone.warning => GhColors.warning,
        DashboardEventTone.primary => GhColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(event.route),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(event.icon, color: _iconFg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GhColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: GhColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
