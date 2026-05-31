import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/feed_eligibility_models.dart';
import '../../data/services/feed_eligibility_service.dart';

class FeedEligibilityRestrictedBanner extends StatelessWidget {
  const FeedEligibilityRestrictedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GhColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: GhColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.feedRestrictedDueToAnimalStatus,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedIngredientEligibilityHint extends StatelessWidget {
  const FeedIngredientEligibilityHint({super.key, required this.check});

  final FeedEligibilityProductCheck check;

  @override
  Widget build(BuildContext context) {
    if (!check.hasImpacts) return const SizedBox.shrink();
    final tags = FeedEligibilityService.formatImpactedTags(check.impacts);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: GhColors.warning),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.feedEligibilityImpactedAnimals(tags),
              style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Warns when a feed or meal plan affects animals that fail eligibility rules.
Future<bool> confirmFeedEligibilityImpacts(
  BuildContext context, {
  required String title,
  required String message,
  required List<FeedEligibilityAnimalImpact> impacts,
}) async {
  if (impacts.isEmpty) return true;
  final l10n = context.l10n;
  final tags = FeedEligibilityService.formatImpactedTags(impacts);
  final reason = impacts.first.reason;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Text(
              l10n.feedEligibilityImpactedAnimals(tags),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.addAnyway),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> confirmMealEligibilityImpacts(
  BuildContext context,
  FeedEligibilityMealCheck check,
) async {
  if (!check.hasImpacts) return true;
  final l10n = context.l10n;
  final lines = <String>[];
  for (final product in check.productChecks) {
    if (!product.hasImpacts) continue;
    final tags = FeedEligibilityService.formatImpactedTags(product.impacts);
    lines.add('${product.productName}: $tags — ${product.impacts.first.reason}');
  }
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.feedMealPlanRestrictedTitle(check.mealName)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.feedMealPlanRestrictedBody),
            const SizedBox(height: 12),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.addAnyway),
        ),
      ],
    ),
  );
  return result ?? false;
}
