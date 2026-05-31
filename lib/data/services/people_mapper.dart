import '../models/enums.dart';
import '../models/invite_models.dart';
import '../models/models.dart';

/// Maps `gh-api-people` member views to UI [FarmUser].
abstract final class PeopleMapper {
  static FarmUser fromMemberWire(Map<String, dynamic> wire) {
    final user = Map<String, dynamic>.from(
      wire['user'] as Map? ?? wire,
    );
    final farmUser = Map<String, dynamic>.from(
      wire['farm_user'] as Map? ?? const {},
    );
    final name = user['name'] as String? ?? '';
    final id = user['id'] as String? ?? farmUser['user_id'] as String? ?? '';
    final roleWire =
        (farmUser['farm_role'] as String? ?? wire['farm_role'] as String? ?? 'OWNER')
            .toUpperCase();

    return FarmUser(
      id: id,
      name: name,
      role: _roleFromWire(roleWire),
      initials: _initials(name),
    );
  }

  static List<FarmUser> fromMemberList(List<Map<String, dynamic>> rows) =>
      rows.map(fromMemberWire).toList();

  static UserRole _roleFromWire(String wire) {
    return switch (wire) {
      'MANAGER' => UserRole.manager,
      'FARM_HAND' => UserRole.farmHand,
      'VET' => UserRole.vet,
      _ => UserRole.owner,
    };
  }

  static String roleToWire(UserRole role) => switch (role) {
        UserRole.manager => 'MANAGER',
        UserRole.farmHand => 'FARM_HAND',
        UserRole.vet => 'VET',
        UserRole.owner => 'OWNER',
      };

  static String channelToWire(InviteDeliveryChannel channel) =>
      switch (channel) {
        InviteDeliveryChannel.email => 'EMAIL',
        InviteDeliveryChannel.whatsapp => 'WHATSAPP',
        InviteDeliveryChannel.both => 'BOTH',
      };

  static InviteUserResult inviteResultFromResponse(
    Map<String, dynamic> data,
    Map<String, dynamic>? meta,
  ) {
    return InviteUserResult(
      member: fromMemberWire(data),
      inviteLink: meta?['invite_link'] as String? ?? '',
      message: meta?['invite_message'] as String? ?? '',
      emailSent: meta?['email_sent'] == true,
      whatsappUrl: meta?['whatsapp_url'] as String?,
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
