import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { loadBddNotificationTaskCatalog } from '../../gh-shared/test-fixtures/bdd-notification-task-catalog.js';
import { InMemoryNotificationPreferenceRepository } from '../src/repositories/in-memory-notification-preference-repository.js';
import { NotificationPreferenceService } from '../src/services/notification-preference-service.js';

describe('NotificationPreferenceService', () => {
  const catalog = loadBddNotificationTaskCatalog();
  const repo = new InMemoryNotificationPreferenceRepository();
  const service = new NotificationPreferenceService(catalog, repo);

  it('lists go-live definitions', () => {
    const defs = service.listDefinitions({ go_live_only: true });
    assert.ok(defs.length > 0);
    assert.ok(defs.every((d) => d.go_live));
  });

  it('returns default preferences for a new user', async () => {
    const prefs = await service.getPreferences('user-1', 'farm-1');
    assert.equal(prefs.farm_id, 'farm-1');
    assert.equal(prefs.user_id, 'user-1');
    assert.ok(prefs.items.length > 0);
    assert.ok(prefs.items.every((i) => i.enabled === i.default_enabled));
  });

  it('persists disabled preference and reloads it', async () => {
    const def = catalog.getByTaskId(9);
    assert.ok(def);
    await service.updatePreferences('user-2', 'farm-2', [
      { task_definition_id: def.id, enabled: false },
    ]);
    const prefs = await service.getPreferences('user-2', 'farm-2');
    const row = prefs.items.find((i) => i.task_definition_id === def.id);
    assert.ok(row);
    assert.equal(row.enabled, false);
    assert.equal(row.push_enabled, false);
  });

  it('ignores updates for task definitions outside the catalogue', async () => {
    const before = await service.getPreferences('user-3', 'farm-3');
    const after = await service.updatePreferences('user-3', 'farm-3', [
      {
        task_definition_id: '00000000-0000-4000-8000-000000009999',
        enabled: false,
      },
    ]);
    assert.deepEqual(
      after.items.map((i) => [i.task_definition_id, i.enabled]),
      before.items.map((i) => [i.task_definition_id, i.enabled]),
    );
  });
});
