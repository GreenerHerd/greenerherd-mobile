import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gh_colors.dart';

/// Tasks due summary matching design handoff dashboard / tasks header.
class TasksDueCard extends StatelessWidget {
  const TasksDueCard({
    super.key,
    required this.overdue,
    required this.today,
    required this.thisWeek,
    this.onViewAll,
  });

  final int overdue;
  final int today;
  final int thisWeek;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GhColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onViewAll ?? () => context.go('/tasks'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GhColors.border),
          ),
          child: TasksDueSummary(
            overdue: overdue,
            today: today,
            thisWeek: thisWeek,
            onViewAll: onViewAll ?? () => context.go('/tasks'),
          ),
        ),
      ),
    );
  }
}

/// Reusable header + three mini-stat tiles (dashboard card and tasks screen).
class TasksDueSummary extends StatelessWidget {
  const TasksDueSummary({
    super.key,
    required this.overdue,
    required this.today,
    required this.thisWeek,
    this.onViewAll,
    this.showHeader = true,
  });

  final int overdue;
  final int today;
  final int thisWeek;
  final VoidCallback? onViewAll;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tasks due',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GhColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GhColors.primary,
                  ),
                ),
              ),
            ],
          ),
        if (showHeader) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TasksDueMiniStat(
                count: overdue,
                label: 'Overdue',
                color: GhColors.error,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TasksDueMiniStat(
                count: today,
                label: 'Today',
                color: GhColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TasksDueMiniStat(
                count: thisWeek,
                label: 'This week',
                color: GhColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TasksDueMiniStat extends StatelessWidget {
  const TasksDueMiniStat({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: GhColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
