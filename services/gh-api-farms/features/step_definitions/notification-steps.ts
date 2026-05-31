import { Given, Then } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { loadBddNotificationTaskCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-notification-task-catalog';
import type { ApiWorld } from './world.js';

function getAtPath(obj: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc && typeof acc === 'object' && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, obj);
}

function substituteSaved(raw: string, saved: Record<string, string>): string {
  let result = raw;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(`{${key}}`).join(value);
  }
  return result;
}

Given('catalogue definition task_id {int} exists', function (this: ApiWorld, taskId: number) {
  const catalog = loadBddNotificationTaskCatalog();
  const def = catalog.getByTaskId(taskId);
  assert.ok(def);
  this.saved[`taskDef_${taskId}`] = def.id;
});

Then(
  'the response JSON at {string} should not be empty',
  function (this: ApiWorld, jsonPath: string) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    if (Array.isArray(value)) {
      assert.ok(value.length > 0);
      return;
    }
    assert.fail(`expected non-empty array at ${jsonPath}`);
  },
);

Then(
  'the response JSON at {string} should be greater than {int}',
  function (this: ApiWorld, jsonPath: string, minimum: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(typeof value === 'number' && value > minimum);
  },
);

Then(
  'the response JSON at {string} should include disabled task_id {int}',
  function (this: ApiWorld, jsonPath: string, taskId: number) {
    const items = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(Array.isArray(items));
    const catalog = loadBddNotificationTaskCatalog();
    const def = catalog.getByTaskId(taskId);
    assert.ok(def);
    const row = (items as Array<Record<string, unknown>>).find(
      (i) => i.task_definition_id === def.id,
    );
    assert.ok(row);
    assert.equal(row.enabled, false);
    assert.equal(row.push_enabled, false);
  },
);

export { substituteSaved };
