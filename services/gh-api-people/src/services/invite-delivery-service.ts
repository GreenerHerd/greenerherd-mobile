import jwt from 'jsonwebtoken';
import type { InviteDeliveryChannel } from '../domain/types.js';

export interface InviteDeliveryInput {
  farmId: string;
  farmName: string;
  userId: string;
  inviteeName: string;
  email?: string;
  phone?: string;
  channel: InviteDeliveryChannel;
}

export interface InviteDeliveryResult {
  invite_link: string;
  message: string;
  email_sent: boolean;
  whatsapp_url: string | null;
}

export class InviteDeliveryService {
  constructor(
    private readonly secret: string,
    private readonly appBaseUrl: string,
  ) {}

  deliver(input: InviteDeliveryInput): InviteDeliveryResult {
    const inviteLink = this.buildInviteLink(input.farmId, input.userId);
    const message = this.buildMessage(input.inviteeName, input.farmName, inviteLink);

    let emailSent = false;
    let whatsappUrl: string | null = null;

    if (input.channel === 'EMAIL' || input.channel === 'BOTH') {
      if (input.email) {
        emailSent = this.sendEmail(input.email, message, input.inviteeName, input.farmName);
      }
    }

    if (input.channel === 'WHATSAPP' || input.channel === 'BOTH') {
      if (input.phone) {
        whatsappUrl = this.buildWhatsAppUrl(input.phone, message);
        console.log(
          `[gh-api-people] WhatsApp invite for ${input.phone}: ${whatsappUrl}`,
        );
      }
    }

    return {
      invite_link: inviteLink,
      message,
      email_sent: emailSent,
      whatsapp_url: whatsappUrl,
    };
  }

  buildInviteLink(farmId: string, userId: string): string {
    const token = jwt.sign(
      {
        typ: 'farm_invite',
        farm_id: farmId,
        user_id: userId,
      },
      this.secret,
      { expiresIn: '7d' },
    );
    const base = this.appBaseUrl.replace(/\/$/, '');
    return `${base}?invite=${encodeURIComponent(token)}`;
  }

  private buildMessage(
    inviteeName: string,
    farmName: string,
    inviteLink: string,
  ): string {
    return (
      `Hi ${inviteeName},\n\n` +
      `You have been invited to join ${farmName} on GreenerHerd.\n\n` +
      `Open the app to accept your invitation:\n${inviteLink}\n\n` +
      `If you do not have the app yet, install GreenerHerd from your app store, then open this link.`
    );
  }

  private sendEmail(
    to: string,
    body: string,
    inviteeName: string,
    farmName: string,
  ): boolean {
    // Production: plug in SendGrid/SES. Dev: log intent.
    console.log(
      `[gh-api-people] Email invite → ${to} | subject: Join ${farmName} on GreenerHerd`,
    );
    console.log(`[gh-api-people] Email body:\n${body}`);
    return true;
  }

  private buildWhatsAppUrl(phone: string, message: string): string {
    const digits = phone.replace(/\D/g, '');
    const text = encodeURIComponent(message);
    return `https://wa.me/${digits}?text=${text}`;
  }
}
