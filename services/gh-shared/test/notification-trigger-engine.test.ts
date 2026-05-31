import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { computeDueDate, formatDueDateIso } from '../db/notification-due-date.js';
import { resolveTriggerKey } from '../db/notification-trigger-registry.js';
import { NotificationTriggerEngine } from '../db/notification-trigger-engine.js';
import { loadBddNotificationTaskCatalog } from '../test-fixtures/bdd-notification-task-catalog.js';

describe('notification trigger registry', () => {
  it('resolves common catalogue events', () => {
    assert.equal(resolveTriggerKey('Accept Product'), 'ACCEPT_PRODUCT');
    assert.equal(resolveTriggerKey('Low Inventory'), 'LOW_INVENTORY');
    assert.equal(resolveTriggerKey('Change in Lactation'), 'CHANGE_IN_LACTATION');
    assert.equal(
      resolveTriggerKey('Tomorrow min temp <-5C'),
      'WEATHER_COLD_NIGHT',
    );
  });

  it('returns UNKNOWN for unrecognised trigger text', () => {
    assert.equal(resolveTriggerKey('Not a real trigger'), 'UNKNOWN');
    assert.equal(resolveTriggerKey(''), 'UNKNOWN');
  });
});

describe('notification due dates', () => {
  it('parses next day and days after', () => {
    const asOf = new Date('2026-05-17T12:00:00Z');
    const next = computeDueDate('Next Day', asOf);
    assert.equal(formatDueDateIso(next), '2026-05-18');
    const two = computeDueDate('2 Days After', asOf);
    assert.equal(formatDueDateIso(two), '2026-05-19');
  });

  it('defaults unknown rules to tomorrow', () => {
    const asOf = new Date('2026-05-17T12:00:00Z');
    const fallback = computeDueDate('Whenever the moon aligns', asOf);
    assert.equal(formatDueDateIso(fallback), '2026-05-18');
  });

  it('treats blank rules as next day', () => {
    const asOf = new Date('2026-05-17T12:00:00Z');
    const due = computeDueDate(null, asOf);
    assert.equal(formatDueDateIso(due), '2026-05-18');
  });
});

describe('notification trigger engine', () => {
  const catalog = loadBddNotificationTaskCatalog();
  const engine = new NotificationTriggerEngine(catalog.list({ go_live_only: true }));

  const baseCtx = {
    farm_id: 'farm-1',
    country_code: 'SA',
    as_of: '2026-05-17T12:00:00Z',
    animals: [],
    groups: [
      {
        id: 'g1',
        name: 'Milking A',
        species: 'CATTLE' as const,
        head_count: 22,
      },
    ],
    inventory: [
      {
        id: 'inv1',
        name: 'Alfalfa hay',
        quantity_kg: 50,
        reorder_threshold_kg: 200,
        is_feed: true,
      },
    ],
    anchors: [],
    farm_user_ids: ['user-1'],
    preferences_by_user: new Map([
      [
        'user-1',
        [],
      ],
    ]),
  };

  it('creates tasks on product accepted event', () => {
    const result = engine.processDomainEvent(
      {
        type: 'nutrition.product_accepted',
        farm_id: 'farm-1',
        occurred_at: '2026-05-17T12:00:00Z',
        group_id: 'g1',
        payload: { product_name: 'Barley' },
      },
      baseCtx,
      new Set(),
    );
    assert.ok(result.created.length >= 1);
    assert.ok(result.created.some((t) => t.title.includes('Feed') || t.title.includes('Barley')));
  });

  it('creates low inventory tasks on sweep', () => {
    const result = engine.runScheduledSweep(baseCtx, new Set());
    assert.ok(result.created.some((t) => t.title.toLowerCase().includes('alfalfa')));
  });

  it('respects disabled preferences', () => {
    const def = catalog.list().find((d) => resolveTriggerKey(d.trigger_event) === 'LOW_INVENTORY');
    assert.ok(def);
    const ctx = {
      ...baseCtx,
      preferences_by_user: new Map([
        [
          'user-1',
          [
            {
              task_definition_id: def!.id,
              enabled: false,
              push_enabled: false,
              in_app_enabled: false,
            },
          ],
        ],
      ]),
    };
    const result = engine.runScheduledSweep(ctx, new Set());
    assert.ok(
      !result.created.some((t) => t.task_definition_id === def!.id),
      'disabled definition should not create tasks',
    );
    assert.ok(result.skipped_preferences > 0);
  });

  it('skips duplicate dedupe keys on repeat sweep', () => {
    const existing = new Set<string>();
    const first = engine.runScheduledSweep(baseCtx, existing);
    assert.ok(first.created.length > 0);
    for (const task of first.created) {
      existing.add(task.dedupe_key);
    }
    const second = engine.runScheduledSweep(baseCtx, existing);
    assert.equal(second.created.length, 0);
    assert.ok(second.skipped_dedupe > 0);
  });

});
