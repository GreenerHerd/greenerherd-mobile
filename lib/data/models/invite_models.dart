import 'enums.dart';
import 'models.dart';

enum InviteDeliveryChannel { email, whatsapp, both }

/// Result of inviting a user to the farm.
class InviteUserResult {
  const InviteUserResult({
    required this.member,
    required this.inviteLink,
    required this.message,
    this.emailSent = false,
    this.whatsappUrl,
  });

  final FarmUser member;
  final String inviteLink;
  final String message;
  final bool emailSent;
  final String? whatsappUrl;
}

class InviteUserRequest {
  const InviteUserRequest({
    required this.name,
    required this.role,
    required this.channel,
    this.email,
    this.phone,
    this.farmName,
  });

  final String name;
  final UserRole role;
  final InviteDeliveryChannel channel;
  final String? email;
  final String? phone;
  final String? farmName;
}
