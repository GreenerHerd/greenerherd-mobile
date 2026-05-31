import { randomUUID } from 'node:crypto';
import type {
  FarmMemberView,
  FarmRole,
  FarmUser,
  GroupUserAccess,
  InviteUserInput,
  User,
} from '../domain/types.js';
import type { PeopleRepository } from './people-repository.js';

export class InMemoryPeopleRepository implements PeopleRepository {
  private users = new Map<string, User>();
  private farmUsers = new Map<string, FarmUser[]>();
  private groupAccess = new Map<string, GroupUserAccess[]>();

  async seedFarmOwner(
    farmId: string,
    owner: { userId: string; name: string; email: string },
  ): Promise<void> {
    const now = new Date().toISOString();
    this.users.set(owner.userId, {
      id: owner.userId,
      name: owner.name,
      email: owner.email,
      phone: null,
      preferred_lang: 'EN',
      created_at: now,
    });
    const list = this.farmUsers.get(farmId) ?? [];
    if (!list.find((f) => f.user_id === owner.userId)) {
      list.push({
        id: randomUUID(),
        farm_id: farmId,
        user_id: owner.userId,
        farm_role: 'OWNER',
        is_active: true,
        last_active_at: now,
      });
      this.farmUsers.set(farmId, list);
    }
  }

  async seedMember(
    farmId: string,
    member: { userId: string; name: string; email: string; role: FarmRole },
  ): Promise<void> {
    const now = new Date().toISOString();
    this.users.set(member.userId, {
      id: member.userId,
      name: member.name,
      email: member.email,
      phone: null,
      preferred_lang: 'EN',
      created_at: now,
    });
    const list = this.farmUsers.get(farmId) ?? [];
    list.push({
      id: randomUUID(),
      farm_id: farmId,
      user_id: member.userId,
      farm_role: member.role,
      is_active: true,
      last_active_at: null,
    });
    this.farmUsers.set(farmId, list);
  }

  async listFarmMembers(farmId: string): Promise<FarmMemberView[]> {
    const members = this.farmUsers.get(farmId) ?? [];
    return members
      .filter((m) => m.is_active)
      .map((farmUser) => ({
        farm_user: farmUser,
        user: this.users.get(farmUser.user_id)!,
        group_ids: (this.groupAccess.get(farmId) ?? [])
          .filter((g) => g.user_id === farmUser.user_id)
          .map((g) => g.group_id),
      }));
  }

  async inviteUser(farmId: string, input: InviteUserInput): Promise<FarmMemberView> {
    const email = input.email ?? `${input.phone?.replace(/\D/g, '')}@invite.greenerherd.local`;
    const existing = [...this.users.values()].find((u) => u.email === email);
    if (existing) {
      const onFarm = (this.farmUsers.get(farmId) ?? []).find((f) => f.user_id === existing.id);
      if (onFarm?.is_active) throw new Error('USER_ALREADY_ON_FARM');
    }
    const userId = existing?.id ?? randomUUID();
    const now = new Date().toISOString();
    if (!existing) {
      this.users.set(userId, {
        id: userId,
        name: input.name,
        email,
        phone: input.phone ?? null,
        preferred_lang: input.preferred_lang ?? 'EN',
        created_at: now,
      });
    }
    const farmUser: FarmUser = {
      id: randomUUID(),
      farm_id: farmId,
      user_id: userId,
      farm_role: input.farm_role,
      is_active: true,
      last_active_at: null,
    };
    const list = this.farmUsers.get(farmId) ?? [];
    list.push(farmUser);
    this.farmUsers.set(farmId, list);
    return {
      farm_user: farmUser,
      user: this.users.get(userId)!,
      group_ids: [],
    };
  }

  async updateMemberRole(
    farmId: string,
    userId: string,
    role: FarmRole,
  ): Promise<FarmMemberView> {
    const list = this.farmUsers.get(farmId) ?? [];
    const member = list.find((f) => f.user_id === userId && f.is_active);
    if (!member) throw new Error('MEMBER_NOT_FOUND');
    if (member.farm_role === 'OWNER' && role !== 'OWNER') {
      throw new Error('CANNOT_DEMOTE_OWNER');
    }
    member.farm_role = role;
    return {
      farm_user: member,
      user: this.users.get(userId)!,
      group_ids: [],
    };
  }

  async deactivateMember(farmId: string, userId: string): Promise<FarmMemberView> {
    const list = this.farmUsers.get(farmId) ?? [];
    const member = list.find((f) => f.user_id === userId && f.is_active);
    if (!member) throw new Error('MEMBER_NOT_FOUND');
    if (member.farm_role === 'OWNER') throw new Error('CANNOT_DEACTIVATE_OWNER');
    member.is_active = false;
    return {
      farm_user: member,
      user: this.users.get(userId)!,
      group_ids: [],
    };
  }

  async assignGroupAccess(
    farmId: string,
    groupId: string,
    userId: string,
    canManage: boolean,
  ): Promise<GroupUserAccess> {
    const members = this.farmUsers.get(farmId) ?? [];
    if (!members.find((m) => m.user_id === userId && m.is_active)) {
      throw new Error('MEMBER_NOT_FOUND');
    }
    const key = `${farmId}:${groupId}`;
    const list = this.groupAccess.get(key) ?? [];
    const existing = list.find((g) => g.user_id === userId);
    if (existing) {
      existing.can_manage = canManage;
      return existing;
    }
    const row: GroupUserAccess = {
      id: randomUUID(),
      group_id: groupId,
      user_id: userId,
      can_manage: canManage,
    };
    list.push(row);
    this.groupAccess.set(key, list);
    return row;
  }

  async listGroupAccess(groupId: string): Promise<GroupUserAccess[]> {
    const all: GroupUserAccess[] = [];
    for (const [key, list] of this.groupAccess) {
      if (key.endsWith(`:${groupId}`)) all.push(...list);
    }
    return all;
  }
}
