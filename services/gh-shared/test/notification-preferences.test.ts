import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { loadBddNotificationTaskCatalog } from '../test-fixtures/bdd-notification-task-catalog.js';
import {
  applyPreferenceUpdates,
  buildNotificationPreferences,
} from '../db/notification-preferences.js';

describe('notification preferences', () => {
  const catalog = loadBddNotificationTaskCatalog();

  it('builds defaults from catalogue', () => {
    const payload = buildNotificationPreferences(
      catalog,
      'farm-1',
      'user-1',
      [],
      { go_live_only: true },
    );
    assert.ok(payload.items.length > 0);
    assert.ok(payload.items.every((i) => i.enabled === i.default_enabled));
    assert.ok(payload.categories.length > 0);
  });

  it('applies disable updates', () => {
    const base = buildNotificationPreferences(
      catalog,
      'farm-1',
      'user-1',
      [],
    ).items;
    const first = base[0]!;
    const updated = applyPreferenceUpdates(base, [
      { task_definition_id: first.task_definition_id, enabled: false },
    ]);
    const item = updated.find((i) => i.task_definition_id === first.task_definition_id);
    assert.equal(item?.enabled, false);
    assert.equal(item?.push_enabled, false);
  });

  it('ignores updates for unknown task definition ids', () => {
    const base = buildNotificationPreferences(catalog, 'farm-1', 'user-1', []).items;
    const updated = applyPreferenceUpdates(base, [
      {
        task_definition_id: '00000000-0000-4000-8000-000000009999',
        enabled: false,
      },
    ]);
    assert.deepEqual(
      updated.map((i) => i.enabled),
      base.map((i) => i.enabled),
    );
  });

  it('does not enable push when master toggle is off', () => {
    const base = buildNotificationPreferences(catalog, 'farm-1', 'user-1', []).items;
    const first = base[0]!;
    const updated = applyPreferenceUpdates(base, [
      { task_definition_id: first.task_definition_id, enabled: false },
      { task_definition_id: first.task_definition_id, push_enabled: true },
    ]);
    const item = updated.find((i) => i.task_definition_id === first.task_definition_id);
    assert.equal(item?.enabled, false);
    assert.equal(item?.push_enabled, false);
  });
});
