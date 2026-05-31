import { After, Before } from '@cucumber/cucumber';
import { loadBddNotificationTaskCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-notification-task-catalog';
import { buildApp } from '../../src/app.js';
import { InMemoryFarmTaskRepository } from '../../src/repositories/in-memory-farm-task-repository.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  process.env.SCHEDULER_SECRET = this.schedulerSecret;
  const notificationCatalog = loadBddNotificationTaskCatalog();
  const taskRepository = new InMemoryFarmTaskRepository();
  const { app, taskService, schedulerService } = await buildApp({
    jwtSecret: this.secret,
    notificationCatalog,
    taskRepository,
  });
  this.app = app;
  this.taskService = taskService;
  this.schedulerService = schedulerService;
  this.taskRepository = taskRepository;
  this.notificationCatalog = notificationCatalog;
  this.authToken = undefined;
  this.lastResponse = undefined;
  this.saved = { farmId: 'farm-1' };
});

After(async function (this: ApiWorld) {
  await this.app.close();
  delete process.env.SCHEDULER_SECRET;
});
