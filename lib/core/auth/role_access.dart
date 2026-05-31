import '../../data/models/enums.dart';
import '../../data/models/models.dart';

/// Role-based UI and route access (harness § People Management).
abstract final class RoleAccess {
  static bool canAccessFinance(UserRole role) =>
      role == UserRole.owner || role == UserRole.manager;

  static bool canInviteUsers(UserRole role) =>
      role == UserRole.owner || role == UserRole.manager;

  static bool canAccessFinanceSession(AuthSession? session) =>
      session != null && canAccessFinance(session.role);

  static bool canInviteUsersSession(AuthSession? session) =>
      session != null && canInviteUsers(session.role);

  static String roleLabel(UserRole role) => switch (role) {
        UserRole.owner => 'Farm owner',
        UserRole.manager => 'Manager',
        UserRole.farmHand => 'Farm hand',
        UserRole.vet => 'Veterinarian',
      };
}
