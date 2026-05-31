import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/role_access.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'invite_user_sheet.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canInvite = ref.watch(canInviteUsersProvider);

    return Scaffold(
      appBar: GhAppBar(
        title: l10n.people,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: canInvite
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showInviteUserSheet(context, ref);
                setState(() => _refresh++);
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Invite'),
            )
          : null,
      body: FutureBuilder(
        key: ValueKey(_refresh),
        future: ref.watch(peopleRepositoryProvider).listPeople(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final people = snap.data ?? [];
          if (people.isEmpty) {
            return Center(
              child: Text(
                canInvite
                    ? 'No team members yet. Tap Invite to add someone.'
                    : 'No team members to show.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: GhColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: people.length,
            itemBuilder: (_, i) {
              final u = people[i];
              return ListTile(
                leading: CircleAvatar(child: Text(u.initials)),
                title: Text(u.name),
                subtitle: Text(RoleAccess.roleLabel(u.role)),
              );
            },
          );
        },
      ),
    );
  }
}
