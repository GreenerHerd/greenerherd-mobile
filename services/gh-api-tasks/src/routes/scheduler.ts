import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import {
  DOMAIN_EVENT_TYPES,
  type DomainEventType,
} from '@greenerherd/shared-db/notification-trigger-registry';
import type { SchedulerService } from '../services/scheduler-service.js';
import { AppError } from '../lib/errors.js';
import { assertFarmAccess } from '../lib/auth.js';

const domainEventTypeSchema = z.enum(DOMAIN_EVENT_TYPES);

const domainEventSchema = z.object({
  type: domainEventTypeSchema,
  farm_id: z.string().optional(),
  occurred_at: z.string().optional(),
  group_id: z.string().optional(),
  animal_id: z.string().optional(),
  payload: z.record(z.unknown()).optional(),
});

const runBodySchema = z.object({
  events: z.array(domainEventSchema).optional(),
});

export async function schedulerRoutes(
  app: FastifyInstance,
  schedulerService: SchedulerService,
): Promise<void> {
  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/scheduler/run',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = runBodySchema.safeParse(request.body ?? {});
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const events = (parsed.data.events ?? []).map((e) => ({
        type: e.type as DomainEventType,
        farm_id: request.params.farmId,
        occurred_at: e.occurred_at ?? new Date().toISOString(),
        group_id: e.group_id,
        animal_id: e.animal_id,
        payload: e.payload,
      }));
      const result = await schedulerService.run(request.params.farmId, events);
      return reply.send({ data: result, meta: {} });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/events',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = domainEventSchema.safeParse(request.body);
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const result = await schedulerService.processEvent(request.params.farmId, {
        type: parsed.data.type as DomainEventType,
        farm_id: request.params.farmId,
        occurred_at: parsed.data.occurred_at ?? new Date().toISOString(),
        group_id: parsed.data.group_id,
        animal_id: parsed.data.animal_id,
        payload: parsed.data.payload,
      });
      return reply.send({ data: result, meta: {} });
    },
  );
}
