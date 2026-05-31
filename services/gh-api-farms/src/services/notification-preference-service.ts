import type { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import {
  applyPreferenceUpdates,
  buildNotificationPreferences,
  type NotificationPreferencesPayload,
  type PreferenceUpdateInput,
  type UserNotificationPreferenceRecord,
} from '@greenerherd/shared-db/notification-preferences';
import type { NotificationPreferenceRepository } from '../repositories/notification-preference-repository.js';

export class NotificationPreferenceService {
  constructor(
    private readonly catalog: NotificationTaskCatalog,
    private readonly repository: NotificationPreferenceRepository,
  ) {}

  listDefinitions(options: { go_live_only?: boolean } = {}) {
    return this.catalog.list({
      go_live_only: options.go_live_only ?? true,
      active_only: true,
    });
  }

  async getPreferences(
    userId: string,
    farmId: string,
    options: { go_live_only?: boolean } = {},
  ): Promise<NotificationPreferencesPayload> {
    const stored = await this.repository.listPreferences(userId, farmId);
    return buildNotificationPreferences(
      this.catalog,
      farmId,
      userId,
      stored,
      options,
    );
  }

  async updatePreferences(
    userId: string,
    farmId: string,
    updates: PreferenceUpdateInput[],
    options: { go_live_only?: boolean } = {},
  ): Promise<NotificationPreferencesPayload> {
    const current = await this.getPreferences(userId, farmId, options);
    const merged = applyPreferenceUpdates(current.items, updates);
    const records: UserNotificationPreferenceRecord[] = merged.map((item) => ({
      task_definition_id: item.task_definition_id,
      enabled: item.enabled,
      push_enabled: item.push_enabled,
      in_app_enabled: item.in_app_enabled,
    }));
    await this.repository.upsertPreferences(userId, farmId, records);
    return this.getPreferences(userId, farmId, options);
  }
}
