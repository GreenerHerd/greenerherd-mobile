import { After, Before } from '@cucumber/cucumber';
import { buildApp } from '../../src/app.js';
import { signTestToken } from '../../src/lib/auth.js';
import type { InventoryWorld } from './world.js';

Before(async function (this: InventoryWorld) {
  const { app, inventoryService, secret } = await buildApp({ seedDemo: true });
  this.app = app;
  this.service = inventoryService;
  this.token = signTestToken(secret, {
    user_id: 'u1',
    farm_ids: ['farm-1'],
    role: 'OWNER',
  });
});

After(async function (this: InventoryWorld) {
  await this.app.close();
});
