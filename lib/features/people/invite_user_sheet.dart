import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/invite_models.dart';
import '../../data/services/invite_share_service.dart';

enum _InviteChannel { email, whatsapp }

Future<void> showInviteUserSheet(BuildContext context, WidgetRef ref) async {
  if (!ref.read(canInviteUsersProvider)) return;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var role = UserRole.farmHand;
  var channel = _InviteChannel.email;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final l10n = ctx.l10n;
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.inviteTeamMember,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.inviteTeamSubtitle,
                  style: const TextStyle(color: GhColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.fullName),
                ),
                const SizedBox(height: 12),
                SegmentedButton<_InviteChannel>(
                  segments: [
                    ButtonSegment(
                      value: _InviteChannel.email,
                      label: Text(l10n.email),
                      icon: const Icon(Icons.email_outlined),
                    ),
                    ButtonSegment(
                      value: _InviteChannel.whatsapp,
                      label: Text(l10n.whatsapp),
                      icon: const Icon(Icons.chat_outlined),
                    ),
                  ],
                  selected: {channel},
                  onSelectionChanged: (s) =>
                      setState(() => channel = s.first),
                ),
                const SizedBox(height: 12),
                if (channel == _InviteChannel.email)
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.email),
                  )
                else
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.phoneWithCountryCode,
                      hintText: '+966501234567',
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: InputDecoration(labelText: l10n.role),
                  items: [
                    DropdownMenuItem(
                      value: UserRole.manager,
                      child: Text(l10n.manager),
                    ),
                    DropdownMenuItem(
                      value: UserRole.farmHand,
                      child: Text(l10n.farmHand),
                    ),
                    DropdownMenuItem(
                      value: UserRole.vet,
                      child: Text(l10n.veterinarian),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => role = v);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    if (channel == _InviteChannel.email &&
                        !emailCtrl.text.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.enterValidEmail)),
                      );
                      return;
                    }
                    if (channel == _InviteChannel.whatsapp &&
                        phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length <
                            8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.enterValidPhone)),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    try {
                      final farm = await ref
                          .read(farmRepositoryProvider)
                          .getCurrentFarm();
                      final result = await ref
                          .read(peopleRepositoryProvider)
                          .inviteUser(
                            InviteUserRequest(
                              name: name,
                              role: role,
                              channel: channel == _InviteChannel.email
                                  ? InviteDeliveryChannel.email
                                  : InviteDeliveryChannel.whatsapp,
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              farmName: farm.name,
                            ),
                          );

                      final share = InviteShareService();
                      var opened = false;
                      if (channel == _InviteChannel.email &&
                          emailCtrl.text.isNotEmpty) {
                        opened = await share.openEmailInvite(
                          to: emailCtrl.text.trim(),
                          subject: l10n.joinFarmSubject(farm.name),
                          body: result.message,
                        );
                      } else if (result.whatsappUrl != null) {
                        opened = await share.openWhatsAppInvite(
                          result.whatsappUrl!,
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              opened
                                  ? l10n.inviteSentOpen(
                                      channel == _InviteChannel.email
                                          ? l10n.channelEmail
                                          : l10n.channelWhatsapp,
                                    )
                                  : l10n.inviteCreated(result.inviteLink),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.inviteFailed('$e'))),
                        );
                      }
                    }
                  },
                  child: Text(l10n.sendInvite),
                ),
              ],
            );
          },
        ),
      );
    },
  );

  nameCtrl.dispose();
  emailCtrl.dispose();
  phoneCtrl.dispose();
}
