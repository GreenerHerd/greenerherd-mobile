import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { errorBody } from '../lib/errors.js';
import { assertFarmAccess } from '../lib/auth.js';
import type { NotificationPreferenceService } from '../services/notification-preference-service.js';

const updateSchema = z.object({
  preferences: z
    .array(
      z.object({
        task_definition_id: z.string().uuid(),
        enabled: z.boolean().optional(),
        push_enabled: z.boolean().optional(),
        in_app_enabled: z.boolean().optional(),
      }),
    )
    .min(1),
});

export async function notificationPreferenceRoutes(
  app: FastifyInstance,
  service: NotificationPreferenceService,
): Promise<void> {
  app.get('/api/v1/notification-task-definitions', async (_request, reply) => {
    const definitions = service.listDefinitions({ go_live_only: true });
    return reply.send({
      data: definitions,
      meta: { count: definitions.length },
    });
  });

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/notification-preferences',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      if (!request.user) {
        return reply.status(401).send(errorBody('UNAUTHORIZED', 'Authentication required'));
      }
      const data = await service.getPreferences(
        request.user.user_id,
        request.params.farmId,
        { go_live_only: true },
      );
      return reply.send({ data });
    },
  );

  app.put<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/notification-preferences',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      if (!request.user) {
        return reply.status(401).send(errorBody('UNAUTHORIZED', 'Authentication required'));
      }
      const parsed = updateSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply
          .status(400)
          .send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      const data = await service.updatePreferences(
        request.user.user_id,
        request.params.farmId,
        parsed.data.preferences,
        { go_live_only: true },
      );
      return reply.send({ data });
    },
  );
}
