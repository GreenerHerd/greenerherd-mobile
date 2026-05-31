import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/gh_app_bar.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: GhAppBar(
        title: l10n.subscription,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: ref.watch(subscriptionRepositoryProvider).getPlan(),
        builder: (context, snap) {
          final plan = snap.data;
          if (plan == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: GhColors.primaryLight.withOpacity(0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.label,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('${plan.trialDaysLeft} days left in trial'),
                        const SizedBox(height: 16),
                        const Text(
                          'RevenueCat integration deferred — mock entitlements active.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(onPressed: () {}, child: const Text('Upgrade plan')),
              ],
            ),
          );
        },
      ),
    );
  }
}
