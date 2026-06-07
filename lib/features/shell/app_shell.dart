import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../shared/widgets/gh_design_icons.dart';
import '../animals/add_entity_sheets.dart';
import '../finance/add_finance_entry_sheet.dart';
import '../tasks/tasks_screen.dart';
import 'burger_menu.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final burgerOpen = ref.watch(burgerMenuOpenProvider);
    final canFinance = ref.watch(canAccessFinanceProvider);
    final location = GoRouterState.of(context).uri.path;
    final hideFab = location.contains('/animals/') && location.split('/').length > 2;

    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          floatingActionButton: hideFab
              ? null
              : Semantics(
                  label: 'Add',
                  button: true,
                  child: FloatingActionButton(
                    key: const Key('shell_fab_add'),
                    onPressed: () =>
                        _onFab(context, ref, navigationShell.currentIndex),
                    child: const Icon(Icons.add),
                  ),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.ghSurface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode
                        ? const Color(0x50000000)
                        : const Color(0x24000000),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Tab(
                      icon: Icons.home_outlined,
                      label: l10n.tabHome,
                      selected: navigationShell.currentIndex == 0,
                      onTap: () => _goToTab(navigationShell, 0),
                    ),
                    _Tab(
                      icon: Icons.pets_outlined,
                      label: l10n.tabAnimals,
                      selected: navigationShell.currentIndex == 1,
                      onTap: () => _goToTab(navigationShell, 1),
                    ),
                    _Tab(
                      icon: Icons.checklist_outlined,
                      label: l10n.tabTasks,
                      selected: navigationShell.currentIndex == 2,
                      onTap: () => _goToTab(navigationShell, 2),
                    ),
                    if (canFinance)
                      _Tab(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.tabFinance,
                        selected: navigationShell.currentIndex == 3,
                        onTap: () => _goToTab(navigationShell, 3),
                      ),
                    _Tab(
                      icon: Icons.bar_chart_outlined,
                      label: l10n.tabReports,
                      selected: navigationShell.currentIndex == 4,
                      onTap: () => _goToTab(navigationShell, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (burgerOpen) const BurgerMenu(),
      ],
    );
  }

  void _goToTab(StatefulNavigationShell shell, int index) {
    shell.goBranch(index, initialLocation: true);
  }

  void _onFab(BuildContext context, WidgetRef ref, int tabIndex) {
    final canFinance = ref.read(canAccessFinanceProvider);
    switch (tabIndex) {
      case 1:
        GhBottomSheetChooser.showAdd(context, ref);
      case 2:
        showNewTaskSheet(context, ref);
      case 3 when canFinance:
        showAddFinanceEntrySheet(context, ref);
      default:
        GhBottomSheetChooser.showAdd(context, ref);
    }
  }

}

class GhBottomSheetChooser {
  static void showAdd(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return Material(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text(l10n.onboardNewAnimal),
                  onTap: () {
                    Navigator.pop(ctx);
                    showAddAnimalSheet(context, ref);
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    GhDesignIcons.animalGroup,
                    width: 28,
                    height: 28,
                  ),
                  title: Text(l10n.onboardNewGroup),
                  onTap: () {
                    Navigator.pop(ctx);
                    showAddGroupWizard(context, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.ghPrimaryLight.withValues(alpha: 0.5) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? context.ghPrimary : context.ghTextSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected ? context.ghPrimary : context.ghTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
