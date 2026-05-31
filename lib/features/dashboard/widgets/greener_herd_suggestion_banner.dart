import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gh_colors.dart';
import '../dashboard_providers.dart';

/// Feed / nutrition nudge when a group is below energy target.
class GreenerHerdSuggestionBanner extends StatelessWidget {
  const GreenerHerdSuggestionBanner({
    super.key,
    required this.suggestion,
  });

  final DashboardFeedSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: GhColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Greener Herd suggests',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: GhColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: GhColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.push('/nutrition/${suggestion.groupId}'),
            style: FilledButton.styleFrom(
              backgroundColor: GhColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: const Text('Open feed plan'),
          ),
        ],
      ),
    );
  }
}
