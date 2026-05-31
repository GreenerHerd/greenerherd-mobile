import type { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import {
  NotificationTriggerEngine,
  type DomainEvent,
  type FarmSchedulerContext,
} from '@greenerherd/shared-db/notification-trigger-engine';
import type { FarmTaskRepository } from '../repositories/farm-task-repository.js';
import { demoSchedulerContext, loadFarmSchedulerContext } from './farm-context-loader.js';
import { PushDispatcher } from './push-dispatcher.js';
import type { Pool } from 'pg';

export interface SchedulerRunResult {
  tasks_created: number;
  push_dispatched: number;
  summary: {
    skipped_dedupe: number;
    skipped_preferences: number;
    skipped_no_match: number;
  };
}

export class SchedulerService {
  private readonly engine: NotificationTriggerEngine;
  private readonly push = new PushDispatcher();

  constructor(
    catalog: NotificationTaskCatalog,
    private readonly taskRepo: FarmTaskRepository,
    private readonly pool?: Pool,
  ) {
    this.engine = new NotificationTriggerEngine(
      catalog.list({ go_live_only: true, active_only: true }),
    );
  }

  async loadContext(farmId: string): Promise<FarmSchedulerContext> {
    if (this.pool) {
      return loadFarmSchedulerContext(this.pool, farmId);
    }
    return demoSchedulerContext(farmId);
  }

  async run(
    farmId: string,
    events: DomainEvent[] = [],
  ): Promise<SchedulerRunResult> {
    const ctx = await this.loadContext(farmId);
    const dedupeKeys = await this.taskRepo.listActiveDedupeKeys(farmId);
    const tick: DomainEvent = {
      type: 'scheduler.tick',
      farm_id: farmId,
      occurred_at: ctx.as_of,
    };
    const allEvents = [...events, tick];
    const result = this.engine.runAll(ctx, allEvents, dedupeKeys);
    const created = await this.taskRepo.createMany(result.created);
    const push_dispatched = await this.push.dispatchForTasks(created);

    if (this.pool) {
      await this.pool.query(
        `INSERT INTO notification_scheduler_runs (farm_id, finished_at, tasks_created, events_processed, summary)
         VALUES ($1, NOW(), $2, $3, $4)`,
        [
          farmId,
          created.length,
          allEvents.length,
          JSON.stringify({
            skipped_dedupe: result.skipped_dedupe,
            skipped_preferences: result.skipped_preferences,
            skipped_no_match: result.skipped_no_match,
          }),
        ],
      );
    }

    return {
      tasks_created: created.length,
      push_dispatched,
      summary: {
        skipped_dedupe: result.skipped_dedupe,
        skipped_preferences: result.skipped_preferences,
        skipped_no_match: result.skipped_no_match,
      },
    };
  }

  async processEvent(
    farmId: string,
    event: DomainEvent,
  ): Promise<SchedulerRunResult> {
    return this.run(farmId, [event]);
  }
}
