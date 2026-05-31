import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/auth/role_access.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';

void main() {
  test('only owner and manager access finance', () {
    expect(RoleAccess.canAccessFinance(UserRole.owner), isTrue);
    expect(RoleAccess.canAccessFinance(UserRole.manager), isTrue);
    expect(RoleAccess.canAccessFinance(UserRole.farmHand), isFalse);
    expect(RoleAccess.canAccessFinance(UserRole.vet), isFalse);
  });

  test('only owner and manager can invite', () {
    expect(RoleAccess.canInviteUsers(UserRole.owner), isTrue);
    expect(RoleAccess.canInviteUsers(UserRole.manager), isTrue);
    expect(RoleAccess.canInviteUsers(UserRole.farmHand), isFalse);
  });

  test('session helpers', () {
    const session = AuthSession(
      userId: 'u1',
      farmId: 'farm-1',
      role: UserRole.farmHand,
      displayName: 'Hand',
      accessToken: 't',
    );
    expect(RoleAccess.canAccessFinanceSession(session), isFalse);
    expect(RoleAccess.canInviteUsersSession(session), isFalse);
  });
}
