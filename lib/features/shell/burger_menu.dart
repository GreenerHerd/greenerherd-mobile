import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';

class BurgerMenu extends ConsumerWidget {
  const BurgerMenu({super.key});

  Future<void> _confirmAndExit(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('This will close GreenerHerd.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // Android supports programmatic app close; iOS/macOS/web do not.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await SystemNavigator.pop();
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Close the app from the app switcher.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: () => ref.read(burgerMenuOpenProvider.notifier).state = false,
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        SafeArea(
          child: Material(
            color: context.ghSurface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Row(
                  icon: Icons.person_outline,
                  title: l10n.profile,
                  subtitle: 'Farm owner',
                  onTap: () {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    context.push('/profile');
                  },
                ),
                _Row(
                  leadingWidget: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      GhDesignIcons.animalGroup,
                      width: 28,
                      height: 28,
                    ),
                  ),
                  title: l10n.groups,
                  subtitle: 'Manage groups',
                  onTap: () {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    context.push('/groups');
                  },
                ),
                _Row(
                  icon: Icons.bar_chart,
                  title: l10n.reports,
                  subtitle: 'Export PDF / CSV',
                  onTap: () {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    context.go('/reports');
                  },
                ),
                _Row(
                  leadingWidget: const GhDesignListIcon(
                    assetPath: GhDesignIcons.inventory,
                  ),
                  title: l10n.inventory,
                  subtitle: l10n.inventoryBurgerSubtitle,
                  onTap: () {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    context.push('/inventory');
                  },
                ),
                _Row(
                  leadingWidget: const GhDesignListIcon(
                    assetPath: GhDesignIcons.videoLessons,
                  ),
                  title: l10n.help,
                  subtitle: 'Support & topics',
                  onTap: () {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    context.push('/help');
                  },
                ),
                const Divider(height: 1),
                _Row(
                  icon: Icons.logout,
                  title: 'Exit app',
                  subtitle: 'Close the application',
                  onTap: () async {
                    ref.read(burgerMenuOpenProvider.notifier).state = false;
                    await _confirmAndExit(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.leadingWidget,
  }) : assert(icon != null || leadingWidget != null);

  final IconData? icon;
  final Widget? leadingWidget;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.ghPrimaryLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: leadingWidget ??
            Icon(icon, color: context.ghPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: context.ghTextSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
