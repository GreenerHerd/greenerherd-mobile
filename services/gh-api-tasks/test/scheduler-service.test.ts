import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { loadBddNotificationTaskCatalog } from '../../gh-shared/test-fixtures/bdd-notification-task-catalog.js';
import { InMemoryFarmTaskRepository } from '../src/repositories/in-memory-farm-task-repository.js';
import { SchedulerService } from '../src/services/scheduler-service.js';

describe('SchedulerService', { concurrency: 1 }, () => {
  it('creates tasks for demo farm on run', async () => {
    const catalog = loadBddNotificationTaskCatalog();
    const repo = new InMemoryFarmTaskRepository();
    const service = new SchedulerService(catalog, repo);

    const result = await service.run('farm-1');
    assert.ok(result.tasks_created > 0);
    const tasks = await repo.listByFarm('farm-1');
    assert.equal(tasks.length, result.tasks_created);
  });

  it('processes accept product domain event', async () => {
    const catalog = loadBddNotificationTaskCatalog();
    const repo = new InMemoryFarmTaskRepository();
    const service = new SchedulerService(catalog, repo);

    const result = await service.processEvent('farm-1', {
      type: 'nutrition.product_accepted',
      farm_id: 'farm-1',
      occurred_at: new Date().toISOString(),
      group_id: 'g1',
      payload: { product_name: 'Barley' },
    });
    assert.ok(result.tasks_created >= 1);
  });

});
