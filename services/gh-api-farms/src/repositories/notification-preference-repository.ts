import type { UserNotificationPreferenceRecord } from '@greenerherd/shared-db/notification-preferences';

export interface NotificationPreferenceRepository {
  listPreferences(
    userId: string,
    farmId: string,
  ): Promise<UserNotificationPreferenceRecord[]>;
  upsertPreferences(
    userId: string,
    farmId: string,
    records: UserNotificationPreferenceRecord[],
  ): Promise<void>;
}
