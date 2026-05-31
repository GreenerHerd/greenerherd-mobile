import { After, Before } from '@cucumber/cucumber';
import { buildApp } from '../../src/app.js';
import { InMemoryPeopleRepository } from '../../src/repositories/in-memory-people-repository.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  const { app, repo, peopleService, secret } = await buildApp({
    jwtSecret: 'test-jwt-secret',
    repository: new InMemoryPeopleRepository(),
  });
  this.app = app;
  this.repo = repo;
  this.peopleService = peopleService;
  this.secret = secret;
  this.authToken = undefined;
  this.lastResponse = undefined;
  this.saved = {};
});

After(async function (this: ApiWorld) {
  await this.app.close();
});
