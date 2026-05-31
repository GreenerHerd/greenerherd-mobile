import 'package:url_launcher/url_launcher.dart';

/// Opens the device email or WhatsApp app with a pre-filled farm invite.
class InviteShareService {
  Future<bool> openEmailInvite({
    required String to,
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> openWhatsAppInvite(String whatsappUrl) async {
    final uri = Uri.parse(whatsappUrl);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
