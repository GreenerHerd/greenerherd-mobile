import { After, Before } from '@cucumber/cucumber';
import { loadBddBreedCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-breed-catalog';
import { loadBddNotificationTaskCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-notification-task-catalog';
import { buildApp } from '../../src/app.js';
import { InMemoryFarmRepository } from '../../src/repositories/in-memory-farm-repository.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  const breedCatalog = loadBddBreedCatalog();
  const notificationCatalog = loadBddNotificationTaskCatalog();
  const { app, repo, farmService, secret } = await buildApp({
    jwtSecret: 'test-jwt-secret',
    repository: new InMemoryFarmRepository(),
    breedCatalog,
    notificationCatalogOverride: notificationCatalog,
  });
  this.app = app;
  this.repo = repo;
  this.farmService = farmService;
  this.secret = secret;
  this.authToken = undefined;
  this.lastResponse = undefined;
  this.saved = {};
});

After(async function (this: ApiWorld) {
  await this.app.close();
});
