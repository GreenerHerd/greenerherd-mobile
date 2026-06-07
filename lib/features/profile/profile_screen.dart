import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_labels.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_card.dart';

final _profileFarmProvider = FutureProvider<Farm>((ref) async {
  return ref.read(farmRepositoryProvider).getCurrentFarm();
});

final _profileUsersProvider = FutureProvider<List<FarmUser>>((ref) async {
  return ref.read(farmRepositoryProvider).getUsers();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(authSessionProvider).valueOrNull;
    final canInvite = ref.watch(canInviteUsersProvider);
    final farmAsync = ref.watch(_profileFarmProvider);
    final usersAsync = ref.watch(_profileUsersProvider);

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.profile,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (users) => GhCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < users.length; i++) ...[
                    _PersonRow(
                      user: users[i],
                      roleLabel: _roleChipLabel(users[i].role, l10n),
                      onTap: canInvite
                          ? () => context.push('/people')
                          : null,
                    ),
                    if (i < users.length - 1)
                      const Divider(height: 1, color: GhColors.border),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: l10n.farmSection,
            actionLabel: l10n.switchFarm,
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.switchFarmMock)),
              );
            },
          ),
          const SizedBox(height: 8),
          farmAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
            data: (farm) => GhCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _KvRow(label: l10n.farmName, value: farm.name),
                  const Divider(height: 1, color: GhColors.border),
                  _KvRow(label: l10n.location, value: farm.location),
                  const Divider(height: 1, color: GhColors.border),
                  _KvRow(
                    label: l10n.role,
                    value: session != null
                        ? _roleChipLabel(session.role, l10n)
                        : '—',
                    subtitle: l10n.fullAccess,
                    capitalizeValue: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.preferences, style: GhTypography.h03),
          const SizedBox(height: 8),
          GhCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: l10n.notificationsRecommended,
                  subtitle: l10n.notificationsDigestAt,
                  onTap: () => context.push('/profile/notifications'),
                ),
                Divider(height: 1, color: context.ghBorder),
                _ThemeModeRow(),
                Divider(height: 1, color: context.ghBorder),
                _SettingRow(
                  icon: Icons.manage_accounts_outlined,
                  label: l10n.appSettings,
                  onTap: () => context.push('/profile/app-settings'),
                ),
                Divider(height: 1, color: context.ghBorder),
                _SettingRow(
                  icon: Icons.info_outline,
                  label: l10n.helpSupport,
                  onTap: () => context.push('/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/auth/sign-in');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: context.ghPrimary,
              side: BorderSide(color: context.ghPrimary),
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  static String _roleChipLabel(UserRole role, AppLocalizations l10n) {
    final label = switch (role) {
      UserRole.owner => l10n.userRoleOwner,
      UserRole.manager => l10n.userRoleManager,
      UserRole.farmHand => l10n.userRoleFarmHand,
      UserRole.vet => l10n.userRoleVet,
    };
    return label.toLowerCase();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: GhTypography.h03)),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: GhColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: GhTypography.h05.copyWith(color: GhColors.primary),
            ),
          ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.user,
    required this.roleLabel,
    this.onTap,
  });

  final FarmUser user;
  final String roleLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: GhColors.primaryLight,
              child: Text(
                user.initials,
                style: GhTypography.h05.copyWith(color: GhColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: GhTypography.h04),
                  const SizedBox(height: 2),
                  Text(
                    roleLabel,
                    style: GhTypography.body.copyWith(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: GhColors.textFaint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.capitalizeValue = false,
  });

  final String label;
  final String value;
  final String? subtitle;
  final bool capitalizeValue;

  @override
  Widget build(BuildContext context) {
    final display = capitalizeValue && value.isNotEmpty
        ? '${value[0].toUpperCase()}${value.substring(1)}'
        : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GhTypography.body.copyWith(color: GhColors.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(display, style: GhTypography.h04),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GhTypography.body.copyWith(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: context.ghTextSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GhTypography.h04.copyWith(
                    color: context.ghTextPrimary,
                  )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GhTypography.body.copyWith(
                        fontSize: 12,
                        color: context.ghTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.ghTextFaint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    String label;
    IconData icon;
    switch (mode) {
      case ThemeMode.light:
        label = 'Light';
        icon = Icons.light_mode_outlined;
      case ThemeMode.dark:
        label = 'Dark';
        icon = Icons.dark_mode_outlined;
      case ThemeMode.system:
        label = 'System';
        icon = Icons.brightness_auto_outlined;
    }

    return InkWell(
      onTap: () => _showThemePicker(context, ref, mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: context.ghTextSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: GhTypography.h04.copyWith(
                    color: context.ghTextPrimary,
                  )),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GhTypography.body.copyWith(
                      fontSize: 12,
                      color: context.ghTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.ghTextFaint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.light_mode_outlined,
              label: 'Light',
              selected: current == ThemeMode.light,
              onTap: () {
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_outlined,
              label: 'Dark',
              selected: current == ThemeMode.dark,
              onTap: () {
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.brightness_auto_outlined,
              label: 'System default',
              selected: current == ThemeMode.system,
              onTap: () {
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

/// Language, subscription, and account options (design handoff App settings).
class ProfileAppSettingsScreen extends ConsumerWidget {
  const ProfileAppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.appSettings,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GhCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.language),
                  subtitle: Text(
                    localeDisplayName(
                      l10n,
                      ref.watch(localeProvider).languageCode,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickLocale(context, ref, l10n),
                ),
                const Divider(height: 1, color: GhColors.border),
                ListTile(
                  title: Text(l10n.subscription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/subscription'),
                ),
                if (ref.watch(canInviteUsersProvider)) ...[
                  const Divider(height: 1, color: GhColors.border),
                  ListTile(
                    title: Text(l10n.people),
                    subtitle: Text(l10n.inviteManageTeam),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/people'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickLocale(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    const codes = ['en', 'ar', 'ur', 'fr'];
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final code in codes)
              ListTile(
                title: Text(localeDisplayName(l10n, code)),
                trailing: ref.watch(localeProvider).languageCode == code
                    ? const Icon(Icons.check, color: GhColors.primary)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(Locale(code));
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}
