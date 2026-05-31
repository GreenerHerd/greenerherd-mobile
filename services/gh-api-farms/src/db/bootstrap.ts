import type pg from 'pg';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';
import { InMemoryFarmRepository } from '../repositories/in-memory-farm-repository.js';
import { seedDemoFarm } from './seed-demo-farm.js';
import { InMemoryNotificationPreferenceRepository } from '../repositories/in-memory-notification-preference-repository.js';
import { PostgresFarmRepository } from '../repositories/postgres-farm-repository.js';
import { PostgresNotificationPreferenceRepository } from '../repositories/postgres-notification-preference-repository.js';
import type { FarmRepository } from '../repositories/farm-repository.js';
import type { NotificationPreferenceRepository } from '../repositories/notification-preference-repository.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const notificationJsonPath = path.join(
  __dirname,
  '../../../../assets/data/notification_task_definitions.json',
);

export interface FarmDataBootstrap {
  repository: FarmRepository;
  breedCatalog?: BreedCatalog;
  notificationCatalog: NotificationTaskCatalog;
  notificationPreferenceRepository: NotificationPreferenceRepository;
  pool?: pg.Pool;
}

function loadNotificationCatalogFromJson(): NotificationTaskCatalog {
  const raw = JSON.parse(readFileSync(notificationJsonPath, 'utf8')) as {
    definitions: Parameters<typeof NotificationTaskCatalog.fromJson>[0]['definitions'];
  };
  return NotificationTaskCatalog.fromJson(raw);
}

export async function bootstrapFarmData(
  repositoryOverride?: FarmRepository,
  breedCatalogOverride?: BreedCatalog,
  notificationCatalogOverride?: NotificationTaskCatalog,
): Promise<FarmDataBootstrap> {
  const notificationCatalog =
    notificationCatalogOverride ?? loadNotificationCatalogFromJson();

  if (repositoryOverride) {
    return {
      repository: repositoryOverride,
      breedCatalog: breedCatalogOverride,
      notificationCatalog,
      notificationPreferenceRepository: new InMemoryNotificationPreferenceRepository(),
    };
  }

  if (!shouldUseDatabase()) {
    const repository = new InMemoryFarmRepository();
    await seedDemoFarm(repository);
    console.log('[gh-api-farms] Seeded demo farm farm-1 (in-memory)');
    return {
      repository,
      notificationCatalog,
      notificationPreferenceRepository: new InMemoryNotificationPreferenceRepository(),
    };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  const breedCatalog = await BreedCatalog.load(pool);
  const dbNotificationCatalog = await NotificationTaskCatalog.load(pool);
  console.log(
    `[gh-api-farms] Loaded ${breedCatalog.size} breeds, ${dbNotificationCatalog.size} notification definitions`,
  );

  return {
    repository: new PostgresFarmRepository(pool),
    breedCatalog,
    notificationCatalog: dbNotificationCatalog,
    notificationPreferenceRepository: new PostgresNotificationPreferenceRepository(pool),
    pool,
  };
}

