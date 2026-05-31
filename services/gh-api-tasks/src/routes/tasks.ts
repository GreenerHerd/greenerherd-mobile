import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { TaskService } from '../services/task-service.js';
import { AppError } from '../lib/errors.js';
import { assertFarmAccess } from '../lib/auth.js';

export async function taskRoutes(
  app: FastifyInstance,
  taskService: TaskService,
): Promise<void> {
  app.get<{ Params: { farmId: string }; Querystring: { status?: string; group_id?: string } }>(
    '/api/v1/farms/:farmId/tasks',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const tasks = await taskService.listTasks(request.params.farmId, {
        status: request.query.status,
        group_id: request.query.group_id,
      });
      return reply.send({ data: tasks, meta: { total: tasks.length } });
    },
  );

  app.get<{ Params: { taskId: string } }>(
    '/api/v1/tasks/:taskId',
    async (request, reply) => {
      const task = await taskService.getTask(request.params.taskId);
      if (!task) {
        throw new AppError('TASK_NOT_FOUND', 'Task not found', 404);
      }
      assertFarmAccess(request, task.farm_id);
      return reply.send({ data: task, meta: {} });
    },
  );

  app.post<{ Params: { taskId: string } }>(
    '/api/v1/tasks/:taskId/complete',
    async (request, reply) => {
      const existing = await taskService.getTask(request.params.taskId);
      if (!existing) {
        throw new AppError('TASK_NOT_FOUND', 'Task not found', 404);
      }
      assertFarmAccess(request, existing.farm_id);
      const task = await taskService.completeTask(request.params.taskId);
      return reply.send({ data: task, meta: {} });
    },
  );

  app.post<{ Params: { taskId: string } }>(
    '/api/v1/tasks/:taskId/dismiss',
    async (request, reply) => {
      const existing = await taskService.getTask(request.params.taskId);
      if (!existing) {
        throw new AppError('TASK_NOT_FOUND', 'Task not found', 404);
      }
      assertFarmAccess(request, existing.farm_id);
      const task = await taskService.dismissTask(request.params.taskId);
      return reply.send({ data: task, meta: {} });
    },
  );
}
