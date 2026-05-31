import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../auth/role_access.dart';
import 'providers.dart';

/// Current signed-in user session (null when logged out).
final authSessionProvider = FutureProvider<AuthSession?>((ref) async {
  return ref.watch(authRepositoryProvider).currentSession();
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.role;
});

final canAccessFinanceProvider = Provider<bool>((ref) {
  return RoleAccess.canAccessFinanceSession(
    ref.watch(authSessionProvider).valueOrNull,
  );
});

final canInviteUsersProvider = Provider<bool>((ref) {
  return RoleAccess.canInviteUsersSession(
    ref.watch(authSessionProvider).valueOrNull,
  );
});
