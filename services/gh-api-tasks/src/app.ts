import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import type { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';
import { bootstrapTasksData } from './db/bootstrap.js';
import type { FarmTaskRepository } from './repositories/farm-task-repository.js';
import { TaskService } from './services/task-service.js';
import { SchedulerService } from './services/scheduler-service.js';
import { taskRoutes } from './routes/tasks.js';
import { schedulerRoutes } from './routes/scheduler.js';

export interface AppOptions {
  jwtSecret?: string;
  notificationCatalog?: NotificationTaskCatalog;
  taskRepository?: FarmTaskRepository;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const { notificationCatalog, taskRepository, pool } = await bootstrapTasksData({
    notificationCatalog: options.notificationCatalog,
    taskRepository: options.taskRepository,
  });

  const taskService = new TaskService(taskRepository);
  const schedulerService = new SchedulerService(
    notificationCatalog,
    taskRepository,
    pool,
  );

  const app = Fastify({ logger: createFastifyLogger('gh-api-tasks') });
  await app.register(cors, { origin: true });

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send(errorBody(error.code, error.message));
    }
    return reply.status(500).send(errorBody('INTERNAL_ERROR', error.message));
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'gh-api-tasks',
    storage: pool ? 'postgres' : 'memory',
    notification_definitions: notificationCatalog.size,
  }));

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await taskRoutes(scoped, taskService);
    await schedulerRoutes(scoped, schedulerService);
  });

  /** Cron / ops endpoint without JWT when SCHEDULER_SECRET is set */
  app.post<{ Params: { farmId: string } }>(
    '/internal/farms/:farmId/scheduler/run',
    async (request, reply) => {
      const expected = process.env.SCHEDULER_SECRET;
      if (!expected) {
        throw new AppError('NOT_CONFIGURED', 'SCHEDULER_SECRET not set', 503);
      }
      const provided = request.headers['x-scheduler-secret'];
      if (provided !== expected) {
        throw new AppError('FORBIDDEN', 'Invalid scheduler secret', 403);
      }
      const result = await schedulerService.run(request.params.farmId);
      return reply.send({ data: result, meta: {} });
    },
  );

  return { app, taskService, schedulerService, pool };
}
