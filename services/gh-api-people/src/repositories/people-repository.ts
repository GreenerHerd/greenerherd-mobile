import type {
  FarmMemberView,
  FarmRole,
  GroupUserAccess,
  InviteUserInput,
} from '../domain/types.js';

export interface PeopleRepository {
  listFarmMembers(farmId: string): Promise<FarmMemberView[]>;
  inviteUser(farmId: string, input: InviteUserInput): Promise<FarmMemberView>;
  updateMemberRole(farmId: string, userId: string, role: FarmRole): Promise<FarmMemberView>;
  deactivateMember(farmId: string, userId: string): Promise<FarmMemberView>;
  assignGroupAccess(
    farmId: string,
    groupId: string,
    userId: string,
    canManage: boolean,
  ): Promise<GroupUserAccess>;
  listGroupAccess(groupId: string): Promise<GroupUserAccess[]>;
  seedFarmOwner(farmId: string, owner: { userId: string; name: string; email: string }): Promise<void>;
  seedMember(
    farmId: string,
    member: { userId: string; name: string; email: string; role: import('../domain/types.js').FarmRole },
  ): Promise<void>;
}
