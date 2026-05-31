import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { loadBddNotificationTaskCatalog } from '../../gh-shared/test-fixtures/bdd-notification-task-catalog.js';
import { InMemoryFarmTaskRepository } from '../src/repositories/in-memory-farm-task-repository.js';
import { TaskService } from '../src/services/task-service.js';

describe('TaskService', () => {
  it('lists tasks for a farm', async () => {
    const catalog = loadBddNotificationTaskCatalog();
    const repo = new InMemoryFarmTaskRepository();
    const def = catalog.getByTaskId(1);
    assert.ok(def);
    await repo.createMany([
      {
        farm_id: 'farm-1',
        task_definition_id: def.id,
        title: 'Buy feed',
        description: null,
        task_type: 'AUTO_NUTRITION',
        group_id: 'g1',
        animal_id: null,
        assigned_to: null,
        due_date: '2026-05-18',
        priority: 'MEDIUM',
        metadata: { dedupe_key: 'test:1' },
        dedupe_key: 'test:1',
        notify_user_ids: ['u1'],
      },
    ]);
    const service = new TaskService(repo);
    const tasks = await service.listTasks('farm-1');
    assert.equal(tasks.length, 1);
    assert.equal(tasks[0]?.farm_id, 'farm-1');
  });

  it('returns null for unknown task id', async () => {
    const service = new TaskService(new InMemoryFarmTaskRepository());
    const task = await service.getTask('00000000-0000-4000-8000-000000009999');
    assert.equal(task, null);
  });

  it('completes an existing task', async () => {
    const catalog = loadBddNotificationTaskCatalog();
    const repo = new InMemoryFarmTaskRepository();
    const def = catalog.getByTaskId(1);
    assert.ok(def);
    const [created] = await repo.createMany([
      {
        farm_id: 'farm-1',
        task_definition_id: def.id,
        title: 'Buy feed',
        description: null,
        task_type: 'AUTO_NUTRITION',
        group_id: null,
        animal_id: null,
        assigned_to: null,
        due_date: '2026-05-18',
        priority: 'LOW',
        metadata: { dedupe_key: 'test:2' },
        dedupe_key: 'test:2',
        notify_user_ids: [],
      },
    ]);
    const service = new TaskService(repo);
    const completed = await service.completeTask(created.id);
    assert.equal(completed.status, 'COMPLETE');
    assert.ok(completed.completed_at);
  });

  it('throws when completing a missing task', async () => {
    const service = new TaskService(new InMemoryFarmTaskRepository());
    await assert.rejects(
      () => service.completeTask('00000000-0000-4000-8000-000000009999'),
      /Task not found/,
    );
  });

  it('dismisses an existing task', async () => {
    const catalog = loadBddNotificationTaskCatalog();
    const repo = new InMemoryFarmTaskRepository();
    const def = catalog.getByTaskId(9);
    assert.ok(def);
    const [created] = await repo.createMany([
      {
        farm_id: 'farm-1',
        task_definition_id: def.id,
        title: 'Low stock',
        description: null,
        task_type: 'AUTO_NUTRITION',
        group_id: null,
        animal_id: null,
        assigned_to: null,
        due_date: '2026-05-18',
        priority: 'HIGH',
        metadata: { dedupe_key: 'test:3' },
        dedupe_key: 'test:3',
        notify_user_ids: [],
      },
    ]);
    const service = new TaskService(repo);
    const dismissed = await service.dismissTask(created.id);
    assert.equal(dismissed.status, 'DISMISSED');
  });
});
