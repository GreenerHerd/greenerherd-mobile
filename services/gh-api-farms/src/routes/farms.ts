import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { AppError, errorBody } from '../lib/errors.js';
import { assertFarmAccess, signTestToken } from '../lib/auth.js';
import type { FarmService } from '../services/farm-service.js';

const createFarmSchema = z.object({
  name: z.string().min(1),
  country: z.string().min(1),
  housing_type: z.enum(['INDOOR_FANS', 'INDOOR_SHADE', 'PASTURE']),
  preferred_currency: z.string().length(3),
  preferred_lang: z.enum(['EN', 'AR', 'UR', 'FR']),
  location_lat: z.number().optional().nullable(),
  location_lng: z.number().optional().nullable(),
});

const speciesSchema = z.object({
  species: z.enum(['CATTLE', 'GOAT', 'SHEEP']),
  purpose: z.enum(['MILK', 'MEAT', 'BOTH']),
});

export async function farmRoutes(
  app: FastifyInstance,
  farmService: FarmService,
  jwtSecret: string,
): Promise<void> {
  app.post('/api/v1/farms', async (request, reply) => {
    const parsed = createFarmSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.status(400).send(
        errorBody('VALIDATION_ERROR', parsed.error.message),
      );
    }
    if (!request.user) {
      return reply.status(401).send(errorBody('UNAUTHORIZED', 'Authentication required'));
    }
    try {
      const farm = await farmService.createFarm({
        ...parsed.data,
        owner_user_id: request.user.user_id,
      });
      const tokenFarmIds = [...new Set([...(request.user.farm_ids ?? []), farm.id])];
      const accessToken = signTestToken(jwtSecret, {
        user_id: request.user.user_id,
        farm_ids: tokenFarmIds,
        role: request.user.role ?? 'OWNER',
      });
      return reply.status(201).send({
        data: farm,
        meta: { farm_ids: tokenFarmIds, access_token: accessToken },
      });
    } catch (e) {
      if (e instanceof AppError) {
        return reply.status(e.statusCode).send(errorBody(e.code, e.message));
      }
      throw e;
    }
  });

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const farm = await farmService.getFarm(request.params.farmId);
        return reply.send({ data: farm });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.patch<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const farm = await farmService.updateFarm(
          request.params.farmId,
          request.body as Record<string, unknown>,
        );
        return reply.send({ data: farm });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/species',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const species = await farmService.listSpecies(request.params.farmId);
        return reply.send({ data: species, meta: { total: species.length } });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/species',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = speciesSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(
          errorBody('VALIDATION_ERROR', parsed.error.message),
        );
      }
      try {
        const row = await farmService.addSpecies(request.params.farmId, parsed.data);
        return reply.status(201).send({ data: row });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/onboarding/status',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const status = await farmService.getOnboardingStatus(request.params.farmId);
        return reply.send({ data: status });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/onboarding/complete',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const skipAnimals = Boolean(
        (request.body as { skip_animals?: boolean } | undefined)?.skip_animals,
      );
      try {
        const farm = await farmService.completeOnboarding(
          request.params.farmId,
          skipAnimals,
        );
        return reply.send({ data: farm });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/dashboard',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const farm = await farmService.getFarm(request.params.farmId);
        return reply.send({
          data: {
            farm_id: farm.id,
            farm_name: farm.name,
            onboarding_completed: farm.onboarding_completed,
          },
          meta: {},
        });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );
}
