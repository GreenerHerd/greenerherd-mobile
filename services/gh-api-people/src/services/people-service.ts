import { AppError } from '../lib/errors.js';
import type { PeopleRepository } from '../repositories/people-repository.js';
import type { FarmRole, InviteDeliveryChannel, InviteUserInput } from '../domain/types.js';
import {
  InviteDeliveryService,
  type InviteDeliveryResult,
} from './invite-delivery-service.js';

export interface InviteUserResult {
  member: Awaited<ReturnType<PeopleRepository['inviteUser']>>;
  delivery: InviteDeliveryResult;
}

export class PeopleService {
  private readonly inviteDelivery: InviteDeliveryService;

  constructor(
    private readonly repo: PeopleRepository,
    jwtSecret: string,
    appInviteBaseUrl?: string,
  ) {
    this.inviteDelivery = new InviteDeliveryService(
      jwtSecret,
      appInviteBaseUrl ??
        process.env.INVITE_APP_BASE_URL ??
        'https://greenerherd.app/join',
    );
  }

  async listMembers(farmId: string) {
    return this.repo.listFarmMembers(farmId);
  }

  async invite(
    farmId: string,
    input: InviteUserInput,
    farmName = 'your farm',
  ): Promise<InviteUserResult> {
    this.validateInviteInput(input);
    if (input.farm_role === 'OWNER') {
      throw new AppError('VALIDATION_ERROR', 'Cannot invite as OWNER', 400);
    }
    try {
      const normalized = this.normalizeInviteInput(input);
      const member = await this.repo.inviteUser(farmId, normalized);
      const delivery = this.inviteDelivery.deliver({
        farmId,
        farmName,
        userId: member.user.id,
        inviteeName: input.name,
        email: normalized.email,
        phone: normalized.phone,
        channel: input.delivery_channel,
      });
      return { member, delivery };
    } catch (e) {
      if (e instanceof Error && e.message === 'USER_ALREADY_ON_FARM') {
        throw new AppError('USER_ALREADY_ON_FARM', 'User is already on this farm', 409);
      }
      throw e;
    }
  }

  private validateInviteInput(input: InviteUserInput): void {
    if (input.delivery_channel === 'EMAIL' && !input.email?.includes('@')) {
      throw new AppError('VALIDATION_ERROR', 'Valid email required for email invite', 400);
    }
    if (input.delivery_channel === 'WHATSAPP') {
      const digits = (input.phone ?? '').replace(/\D/g, '');
      if (digits.length < 8) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Valid phone number required for WhatsApp invite',
          400,
        );
      }
    }
    if (input.delivery_channel === 'BOTH') {
      if (!input.email?.includes('@')) {
        throw new AppError('VALIDATION_ERROR', 'Valid email required', 400);
      }
      const digits = (input.phone ?? '').replace(/\D/g, '');
      if (digits.length < 8) {
        throw new AppError('VALIDATION_ERROR', 'Valid phone required for WhatsApp', 400);
      }
    }
  }

  private normalizeInviteInput(input: InviteUserInput): InviteUserInput {
    const email =
      input.email?.trim() ||
      (input.phone
          ? `${input.phone.replace(/\D/g, '')}@invite.greenerherd.local`
          : undefined);
    return {
      ...input,
      email,
      phone: input.phone?.trim() || undefined,
    };
  }

  async updateRole(farmId: string, userId: string, role: FarmRole) {
    try {
      return await this.repo.updateMemberRole(farmId, userId, role);
    } catch (e) {
      if (e instanceof Error && e.message === 'MEMBER_NOT_FOUND') {
        throw new AppError('MEMBER_NOT_FOUND', 'Member not found', 404);
      }
      if (e instanceof Error && e.message === 'CANNOT_DEMOTE_OWNER') {
        throw new AppError('FORBIDDEN', 'Cannot change owner role', 403);
      }
      throw e;
    }
  }

  async deactivate(farmId: string, userId: string) {
    try {
      return await this.repo.deactivateMember(farmId, userId);
    } catch (e) {
      if (e instanceof Error && e.message === 'MEMBER_NOT_FOUND') {
        throw new AppError('MEMBER_NOT_FOUND', 'Member not found', 404);
      }
      if (e instanceof Error && e.message === 'CANNOT_DEACTIVATE_OWNER') {
        throw new AppError('FORBIDDEN', 'Cannot deactivate farm owner', 403);
      }
      throw e;
    }
  }

  async assignGroup(
    farmId: string,
    groupId: string,
    userId: string,
    canManage: boolean,
  ) {
    try {
      return await this.repo.assignGroupAccess(farmId, groupId, userId, canManage);
    } catch (e) {
      if (e instanceof Error && e.message === 'MEMBER_NOT_FOUND') {
        throw new AppError('MEMBER_NOT_FOUND', 'User is not an active farm member', 404);
      }
      throw e;
    }
  }

  async listGroupAccess(groupId: string) {
    return this.repo.listGroupAccess(groupId);
  }
}
