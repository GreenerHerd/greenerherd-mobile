import type { UserNotificationPreferenceRecord } from '@greenerherd/shared-db/notification-preferences';
import type { NotificationPreferenceRepository } from './notification-preference-repository.js';

function key(userId: string, farmId: string): string {
  return `${userId}:${farmId}`;
}

export class InMemoryNotificationPreferenceRepository
  implements NotificationPreferenceRepository
{
  private readonly store = new Map<string, Map<string, UserNotificationPreferenceRecord>>();

  async listPreferences(
    userId: string,
    farmId: string,
  ): Promise<UserNotificationPreferenceRecord[]> {
    const bucket = this.store.get(key(userId, farmId));
    if (!bucket) return [];
    return [...bucket.values()];
  }

  async upsertPreferences(
    userId: string,
    farmId: string,
    records: UserNotificationPreferenceRecord[],
  ): Promise<void> {
    const k = key(userId, farmId);
    let bucket = this.store.get(k);
    if (!bucket) {
      bucket = new Map();
      this.store.set(k, bucket);
    }
    for (const r of records) {
      bucket.set(r.task_definition_id, { ...r });
    }
  }
}
