#!/usr/bin/env tsx
/**
 * Nightly / cron entrypoint for the notification scheduler.
 *
 *   export DATABASE_URL=postgres://...
 *   export SCHEDULER_FARM_ID=<uuid>
 *   npm run scheduler:run --workspace=gh-api-tasks
 */
import { buildApp } from '../src/app.js';

const farmId = process.env.SCHEDULER_FARM_ID;
if (!farmId) {
  console.error('Set SCHEDULER_FARM_ID to the farm UUID to process');
  process.exit(1);
}

const { schedulerService } = await buildApp();
const result = await schedulerService.run(farmId);
console.log(JSON.stringify(result, null, 2));
