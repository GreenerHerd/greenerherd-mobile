import { After, Before } from '@cucumber/cucumber';
import { buildApp } from '../../src/app.js';
import { InMemoryFinanceRepository } from '../../src/repositories/in-memory-finance-repository.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  const { app, repo, financeService, secret } = await buildApp({
    jwtSecret: 'test-jwt-secret',
    repository: new InMemoryFinanceRepository(),
  });
  this.app = app;
  this.repo = repo;
  this.financeService = financeService;
  this.secret = secret;
  this.authToken = undefined;
  this.lastResponse = undefined;
  this.saved = {};
});

After(async function (this: ApiWorld) {
  await this.app.close();
});
