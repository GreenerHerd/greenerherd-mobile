import type pg from 'pg';
import { randomUUID } from 'node:crypto';
import type { UserNotificationPreferenceRecord } from '@greenerherd/shared-db/notification-preferences';
import type { NotificationPreferenceRepository } from './notification-preference-repository.js';

export class PostgresNotificationPreferenceRepository
  implements NotificationPreferenceRepository
{
  constructor(private readonly pool: pg.Pool) {}

  async listPreferences(
    userId: string,
    farmId: string,
  ): Promise<UserNotificationPreferenceRecord[]> {
    const result = await this.pool.query(
      `SELECT task_definition_id, enabled, push_enabled, in_app_enabled
       FROM user_notification_preferences
       WHERE user_id = $1 AND farm_id = $2`,
      [userId, farmId],
    );
    return result.rows.map((row) => ({
      task_definition_id: String(row.task_definition_id),
      enabled: Boolean(row.enabled),
      push_enabled: Boolean(row.push_enabled),
      in_app_enabled: Boolean(row.in_app_enabled),
    }));
  }

  async upsertPreferences(
    userId: string,
    farmId: string,
    records: UserNotificationPreferenceRecord[],
  ): Promise<void> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      for (const r of records) {
        await client.query(
          `INSERT INTO user_notification_preferences (
            id, user_id, farm_id, task_definition_id, enabled, push_enabled, in_app_enabled, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
          ON CONFLICT (user_id, farm_id, task_definition_id) DO UPDATE SET
            enabled = EXCLUDED.enabled,
            push_enabled = EXCLUDED.push_enabled,
            in_app_enabled = EXCLUDED.in_app_enabled,
            updated_at = NOW()`,
          [randomUUID(), userId, farmId, r.task_definition_id, r.enabled, r.push_enabled, r.in_app_enabled],
        );
      }
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}
