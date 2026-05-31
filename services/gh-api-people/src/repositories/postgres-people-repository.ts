import { randomUUID } from 'node:crypto';
import type pg from 'pg';
import type {
  FarmMemberView,
  FarmRole,
  FarmUser,
  GroupUserAccess,
  InviteUserInput,
  PreferredLang,
  User,
} from '../domain/types.js';
import type { PeopleRepository } from './people-repository.js';

export class PostgresPeopleRepository implements PeopleRepository {
  constructor(private readonly pool: pg.Pool) {}

  async seedFarmOwner(
    farmId: string,
    owner: { userId: string; name: string; email: string },
  ): Promise<void> {
    await this.pool.query(
      `INSERT INTO users (id, name, email, preferred_lang)
       VALUES ($1, $2, $3, 'EN')
       ON CONFLICT (id) DO NOTHING`,
      [owner.userId, owner.name, owner.email],
    );
    await this.pool.query(
      `INSERT INTO farm_users (id, farm_id, user_id, farm_role, is_active)
       VALUES ($1, $2, $3, 'OWNER', TRUE)
       ON CONFLICT (farm_id, user_id) DO NOTHING`,
      [randomUUID(), farmId, owner.userId],
    );
  }

  async seedMember(
    farmId: string,
    member: { userId: string; name: string; email: string; role: FarmRole },
  ): Promise<void> {
    await this.pool.query(
      `INSERT INTO users (id, name, email, preferred_lang)
       VALUES ($1, $2, $3, 'EN')
       ON CONFLICT (id) DO NOTHING`,
      [member.userId, member.name, member.email],
    );
    await this.pool.query(
      `INSERT INTO farm_users (id, farm_id, user_id, farm_role, is_active)
       VALUES ($1, $2, $3, $4, TRUE)
       ON CONFLICT (farm_id, user_id) DO NOTHING`,
      [randomUUID(), farmId, member.userId, member.role],
    );
  }

  async listFarmMembers(farmId: string): Promise<FarmMemberView[]> {
    const { rows } = await this.pool.query(
      `SELECT fu.*, u.name, u.email, u.phone, u.preferred_lang, u.created_at AS user_created_at
       FROM farm_users fu
       JOIN users u ON u.id = fu.user_id
       WHERE fu.farm_id = $1 AND fu.is_active = TRUE
       ORDER BY fu.farm_role, u.name`,
      [farmId],
    );

    const access = await this.pool.query(
      'SELECT group_id, user_id FROM group_user_access WHERE farm_id = $1',
      [farmId],
    );
    const accessByUser = new Map<string, string[]>();
    for (const row of access.rows) {
      const list = accessByUser.get(String(row.user_id)) ?? [];
      list.push(String(row.group_id));
      accessByUser.set(String(row.user_id), list);
    }

    return rows.map((row) => this.toMemberView(row, accessByUser.get(String(row.user_id)) ?? []));
  }

  async inviteUser(farmId: string, input: InviteUserInput): Promise<FarmMemberView> {
    const existingUser = await this.pool.query('SELECT id FROM users WHERE email = $1', [
      input.email,
    ]);
    let userId = existingUser.rows[0]?.id as string | undefined;

    if (userId) {
      const onFarm = await this.pool.query(
        'SELECT 1 FROM farm_users WHERE farm_id = $1 AND user_id = $2 AND is_active = TRUE',
        [farmId, userId],
      );
      if (onFarm.rowCount && onFarm.rowCount > 0) {
        throw new Error('USER_ALREADY_ON_FARM');
      }
    } else {
      userId = randomUUID();
      await this.pool.query(
        `INSERT INTO users (id, name, email, phone, preferred_lang)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          userId,
          input.name,
          input.email,
          input.phone ?? null,
          input.preferred_lang ?? 'EN',
        ],
      );
    }

    const farmUserId = randomUUID();
    const { rows } = await this.pool.query(
      `INSERT INTO farm_users (id, farm_id, user_id, farm_role, is_active)
       VALUES ($1, $2, $3, $4, TRUE)
       RETURNING *`,
      [farmUserId, farmId, userId, input.farm_role],
    );

    const user = await this.pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    return this.toMemberView(
      { ...rows[0], ...user.rows[0], user_created_at: user.rows[0].created_at },
      [],
    );
  }

  async updateMemberRole(
    farmId: string,
    userId: string,
    role: FarmRole,
  ): Promise<FarmMemberView> {
    const member = await this.pool.query(
      `SELECT * FROM farm_users WHERE farm_id = $1 AND user_id = $2 AND is_active = TRUE`,
      [farmId, userId],
    );
    if (!member.rows[0]) throw new Error('MEMBER_NOT_FOUND');
    if (member.rows[0].farm_role === 'OWNER' && role !== 'OWNER') {
      throw new Error('CANNOT_DEMOTE_OWNER');
    }

    await this.pool.query(
      'UPDATE farm_users SET farm_role = $3 WHERE farm_id = $1 AND user_id = $2',
      [farmId, userId, role],
    );
    const members = await this.listFarmMembers(farmId);
    const updated = members.find((m) => m.user.id === userId);
    if (!updated) throw new Error('MEMBER_NOT_FOUND');
    return updated;
  }

  async deactivateMember(farmId: string, userId: string): Promise<FarmMemberView> {
    const member = await this.pool.query(
      `SELECT * FROM farm_users WHERE farm_id = $1 AND user_id = $2 AND is_active = TRUE`,
      [farmId, userId],
    );
    if (!member.rows[0]) throw new Error('MEMBER_NOT_FOUND');
    if (member.rows[0].farm_role === 'OWNER') throw new Error('CANNOT_DEACTIVATE_OWNER');

    await this.pool.query(
      'UPDATE farm_users SET is_active = FALSE WHERE farm_id = $1 AND user_id = $2',
      [farmId, userId],
    );

    const user = await this.pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    const farmUser: FarmUser = {
      id: String(member.rows[0].id),
      farm_id: farmId,
      user_id: userId,
      farm_role: member.rows[0].farm_role as FarmRole,
      is_active: false,
      last_active_at: member.rows[0].last_active_at
        ? new Date(String(member.rows[0].last_active_at)).toISOString()
        : null,
    };
    return {
      farm_user: farmUser,
      user: this.rowToUser(user.rows[0]),
      group_ids: [],
    };
  }

  async assignGroupAccess(
    farmId: string,
    groupId: string,
    userId: string,
    canManage: boolean,
  ): Promise<GroupUserAccess> {
    const member = await this.pool.query(
      'SELECT 1 FROM farm_users WHERE farm_id = $1 AND user_id = $2 AND is_active = TRUE',
      [farmId, userId],
    );
    if (!member.rowCount) throw new Error('MEMBER_NOT_FOUND');

    const existing = await this.pool.query(
      `SELECT * FROM group_user_access WHERE farm_id = $1 AND group_id = $2 AND user_id = $3`,
      [farmId, groupId, userId],
    );
    if (existing.rows[0]) {
      const { rows } = await this.pool.query(
        `UPDATE group_user_access SET can_manage = $4
         WHERE farm_id = $1 AND group_id = $2 AND user_id = $3
         RETURNING *`,
        [farmId, groupId, userId, canManage],
      );
      return this.rowToAccess(rows[0]);
    }

    const id = randomUUID();
    const { rows } = await this.pool.query(
      `INSERT INTO group_user_access (id, farm_id, group_id, user_id, can_manage)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [id, farmId, groupId, userId, canManage],
    );
    return this.rowToAccess(rows[0]);
  }

  async listGroupAccess(groupId: string): Promise<GroupUserAccess[]> {
    const { rows } = await this.pool.query(
      'SELECT * FROM group_user_access WHERE group_id = $1',
      [groupId],
    );
    return rows.map((row) => this.rowToAccess(row));
  }

  private rowToAccess(row: Record<string, unknown>): GroupUserAccess {
    return {
      id: String(row.id),
      group_id: String(row.group_id),
      user_id: String(row.user_id),
      can_manage: Boolean(row.can_manage),
    };
  }

  private rowToUser(row: Record<string, unknown>): User {
    return {
      id: String(row.id),
      name: String(row.name),
      email: String(row.email),
      phone: row.phone == null ? null : String(row.phone),
      preferred_lang: row.preferred_lang as PreferredLang,
      created_at: new Date(String(row.created_at)).toISOString(),
    };
  }

  private toMemberView(row: Record<string, unknown>, groupIds: string[]): FarmMemberView {
    const farmUser: FarmUser = {
      id: String(row.id),
      farm_id: String(row.farm_id),
      user_id: String(row.user_id),
      farm_role: row.farm_role as FarmRole,
      is_active: Boolean(row.is_active),
      last_active_at: row.last_active_at
        ? new Date(String(row.last_active_at)).toISOString()
        : null,
    };
    return {
      farm_user: farmUser,
      user: {
        id: String(row.user_id),
        name: String(row.name),
        email: String(row.email),
        phone: row.phone == null ? null : String(row.phone),
        preferred_lang: row.preferred_lang as PreferredLang,
        created_at: new Date(String(row.user_created_at ?? row.created_at)).toISOString(),
      },
      group_ids: groupIds,
    };
  }
}
