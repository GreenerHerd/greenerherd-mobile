import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { resolveTriggerKey } from '@greenerherd/shared-db/notification-trigger-registry';
import type { ApiWorld } from './world.js';

const LOW_INVENTORY_TASK_ID = 9;

Given(
  'user notification preferences disable low inventory for farm {string}',
  function (this: ApiWorld, farmKey: string) {
    const def = this.notificationCatalog
      .list()
      .find((d) => d.task_id === LOW_INVENTORY_TASK_ID);
    assert.ok(def);
    this.saved.disabledLowInventoryDefId = def.id;
    this.saved.prefFarmKey = farmKey;
  },
);

When(
  'I run the notification scheduler for farm {string}',
  async function (this: ApiWorld, farmKey: string) {
    const farmId = this.saved[farmKey] ?? farmKey;
    this.saved.farmId = farmId;
    const originalLoad = this.schedulerService.loadContext.bind(this.schedulerService);
    this.schedulerService.loadContext = async (id: string) => {
      const ctx = await originalLoad(id);
      if (
        id === farmId &&
        this.saved.disabledLowInventoryDefId &&
        this.saved.prefFarmKey === farmKey
      ) {
        for (const userId of ctx.farm_user_ids) {
          const prefs = ctx.preferences_by_user.get(userId) ?? [];
          prefs.push({
            task_definition_id: this.saved.disabledLowInventoryDefId,
            enabled: false,
            push_enabled: false,
            in_app_enabled: false,
          });
          ctx.preferences_by_user.set(userId, prefs);
        }
      }
      return ctx;
    };
    const result = await this.schedulerService.run(farmId);
    this.lastResponse = {
      statusCode: 200,
      body: { data: result },
    };
  },
);

When(
  'I emit inventory below threshold on farm {string}',
  async function (this: ApiWorld, farmKey: string) {
    const farmId = this.saved[farmKey] ?? farmKey;
    this.saved.farmId = farmId;
    const result = await this.schedulerService.processEvent(farmId, {
      type: 'inventory.below_threshold',
      farm_id: farmId,
      occurred_at: new Date().toISOString(),
      payload: {
        inventory_id: 'feed-alfalfa',
        product_name: 'Alfalfa hay (mid-bloom)',
        quantity_kg: 5,
      },
    });
    this.lastResponse = {
      statusCode: 200,
      body: { data: result },
    };
  },
);

Then(
  'created tasks should include a low inventory task',
  async function (this: ApiWorld) {
    const farmId = this.saved.farmId ?? 'farm-1';
    const tasks = await this.taskRepository.listByFarm(farmId);
    const lowInv = this.notificationCatalog
      .list()
      .find((d) => d.task_id === LOW_INVENTORY_TASK_ID);
    assert.ok(lowInv);
    const match = tasks.some((t) => t.task_definition_id === lowInv.id);
    assert.ok(match, 'expected low inventory task from event');
  },
);

When(
  'I emit nutrition product accepted for group {string} on farm {string}',
  async function (this: ApiWorld, groupKey: string, farmKey: string) {
    const farmId = this.saved[farmKey] ?? farmKey;
    const groupId = this.saved[groupKey] ?? groupKey;
    this.saved.farmId = farmId;
    const result = await this.schedulerService.processEvent(farmId, {
      type: 'nutrition.product_accepted',
      farm_id: farmId,
      occurred_at: new Date().toISOString(),
      group_id: groupId,
      payload: { product_name: 'Barley concentrate' },
    });
    this.lastResponse = {
      statusCode: 200,
      body: { data: result },
    };
  },
);

Then(
  'created tasks should not include low inventory titles',
  async function (this: ApiWorld) {
    const farmId = this.saved.farmId ?? 'farm-1';
    const tasks = await this.taskRepository.listByFarm(farmId);
    const lowInv = this.notificationCatalog
      .list()
      .find((d) => d.task_id === LOW_INVENTORY_TASK_ID);
    assert.ok(lowInv);
    const blocked = tasks.filter((t) => t.task_definition_id === lowInv.id);
    assert.equal(blocked.length, 0);
  },
);

Then(
  'created tasks should include an accept-product task',
  async function (this: ApiWorld) {
    const farmId = this.saved.farmId ?? 'farm-1';
    const tasks = await this.taskRepository.listByFarm(farmId);
    const acceptDefs = this.notificationCatalog
      .list()
      .filter((d) => resolveTriggerKey(d.trigger_event) === 'ACCEPT_PRODUCT');
    assert.ok(acceptDefs.length > 0);
    const match = tasks.some((t) =>
      acceptDefs.some((d) => d.id === t.task_definition_id),
    );
    assert.ok(match);
  },
);

Then(
  'catalogue definition task_id {int} exists',
  function (this: ApiWorld, taskId: number) {
    const def = this.notificationCatalog.getByTaskId(taskId);
    assert.ok(def);
    this.saved[`taskDef_${taskId}`] = def.id;
  },
);
