import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import type { FarmTaskRepository } from '../../src/repositories/farm-task-repository.js';
import type { SchedulerService } from '../../src/services/scheduler-service.js';
import type { TaskService } from '../../src/services/task-service.js';

export class ApiWorld extends World {
  app!: FastifyInstance;
  taskService!: TaskService;
  schedulerService!: SchedulerService;
  taskRepository!: FarmTaskRepository;
  notificationCatalog!: NotificationTaskCatalog;
  secret = 'test-jwt-secret';
  authToken?: string;
  schedulerSecret = 'bdd-scheduler-secret';
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string> = {};
}

setWorldConstructor(ApiWorld);
