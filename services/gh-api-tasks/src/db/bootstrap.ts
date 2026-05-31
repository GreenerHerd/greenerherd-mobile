import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';
import { InMemoryFarmTaskRepository } from '../repositories/in-memory-farm-task-repository.js';
import { PostgresFarmTaskRepository } from '../repositories/postgres-farm-task-repository.js';
import type { FarmTaskRepository } from '../repositories/farm-task-repository.js';
import { SchedulerService } from '../services/scheduler-service.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const notificationJsonPath = path.join(
  __dirname,
  '../../../../assets/data/notification_task_definitions.json',
);

export interface TasksDataBootstrap {
  notificationCatalog: NotificationTaskCatalog;
  taskRepository: FarmTaskRepository;
  pool?: import('pg').Pool;
}

function loadNotificationCatalogFromJson(): NotificationTaskCatalog {
  const raw = JSON.parse(readFileSync(notificationJsonPath, 'utf8')) as {
    definitions: Parameters<typeof NotificationTaskCatalog.fromJson>[0]['definitions'];
  };
  return NotificationTaskCatalog.fromJson(raw);
}

export interface BootstrapOverrides {
  notificationCatalog?: NotificationTaskCatalog;
  taskRepository?: FarmTaskRepository;
}

export async function bootstrapTasksData(
  overrides: BootstrapOverrides = {},
): Promise<TasksDataBootstrap> {
  const notificationCatalog =
    overrides.notificationCatalog ?? loadNotificationCatalogFromJson();

  if (overrides.taskRepository) {
    return {
      notificationCatalog,
      taskRepository: overrides.taskRepository,
    };
  }

  if (!shouldUseDatabase()) {
    const taskRepository = new InMemoryFarmTaskRepository();
    const scheduler = new SchedulerService(notificationCatalog, taskRepository);
    const seeded = await scheduler.run('farm-1');
    console.log(
      `[gh-api-tasks] Demo scheduler seeded ${seeded.tasks_created} tasks for farm-1`,
    );
    return {
      notificationCatalog,
      taskRepository,
    };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  const dbCatalog = await NotificationTaskCatalog.load(pool);
  console.log(
    `[gh-api-tasks] Loaded ${dbCatalog.size} notification definitions from Postgres`,
  );

  return {
    notificationCatalog: dbCatalog,
    taskRepository: new PostgresFarmTaskRepository(pool),
    pool,
  };
}
