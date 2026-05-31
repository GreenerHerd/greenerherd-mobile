import type { FastifyInstance, FastifyReply } from 'fastify';
import { z } from 'zod';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import { AppError, errorBody } from '../lib/errors.js';
import { assertFarmAccess } from '../lib/auth.js';
import { presentAnimal, presentAnimals } from '../lib/animal-presenter.js';
import type { AnimalService } from '../services/animal-service.js';
import type { Animal } from '../domain/types.js';

const createAnimalSchema = z
  .object({
    species: z.enum(['CATTLE', 'GOAT', 'SHEEP']),
    sex: z.enum(['MALE', 'FEMALE']),
    breed: z.string().min(1).optional(),
    breed_id: z.string().uuid().optional(),
    ear_tag: z.string().optional().nullable(),
    name: z.string().optional().nullable(),
    group_id: z.string().optional().nullable(),
    dob: z.string().optional().nullable(),
    age_range: z
      .enum(['0_3M', '3_6M', '6_12M', '1_2Y', '2_3Y', '3_5Y', '5PLUS_Y'])
      .optional()
      .nullable(),
    current_weight_kg: z.number().optional().nullable(),
    origin: z.enum(['BORN_ON_FARM', 'PURCHASED']).optional(),
    tags: z
      .array(
        z.enum([
          'WEANING',
          'READY_TO_BREED',
          'PREGNANT',
          'CULL',
          'MISCARRIAGE',
          'SICK',
          'LACTATING',
          'STILLBORN',
        ]),
      )
      .optional(),
  })
  .refine((d) => Boolean(d.breed?.trim() || d.breed_id), {
    message: 'breed or breed_id is required',
  });

const bulkGroupSchema = z
  .object({
    species: z.enum(['CATTLE', 'GOAT', 'SHEEP']),
    breed: z.string().min(1).optional(),
    breed_id: z.string().uuid().optional(),
    sex: z.enum(['MALE', 'FEMALE']),
    age_range: z.enum(['0_3M', '3_6M', '6_12M', '1_2Y', '2_3Y', '3_5Y', '5PLUS_Y']),
    count: z.number().int(),
    name: z.string().min(1),
    purpose: z.enum(['MAINTENANCE', 'BREEDING', 'MILK', 'PREGNANT', 'SICK', 'FATTENING']),
    notes: z.string().optional(),
  })
  .refine((d) => Boolean(d.breed?.trim() || d.breed_id), {
    message: 'breed or breed_id is required',
  });

const tagSchema = z.object({
  tag: z.enum([
    'WEANING',
    'READY_TO_BREED',
    'PREGNANT',
    'CULL',
    'MISCARRIAGE',
    'SICK',
    'LACTATING',
    'STILLBORN',
  ]),
});

function sendAnimal(
  reply: FastifyReply,
  animal: Animal,
  catalog: BreedCatalog | undefined,
  statusCode = 200,
) {
  const body = { data: presentAnimal(animal, catalog), meta: {} };
  return statusCode === 201 ? reply.status(201).send(body) : reply.send(body);
}

export async function animalRoutes(
  app: FastifyInstance,
  animalService: AnimalService,
  breedCatalog?: BreedCatalog,
): Promise<void> {
  app.get<{ Params: { farmId: string }; Querystring: Record<string, string> }>(
    '/api/v1/farms/:farmId/animals',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const animals = await animalService.listAnimals(request.params.farmId, {
          species: request.query.species as never,
          group_id: request.query.group_id,
          tag: request.query.tag as never,
          status: request.query.status as never,
        });
        return reply.send({
          data: presentAnimals(animals, breedCatalog),
          meta: { total: animals.length },
        });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/animals',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = createAnimalSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const animal = await animalService.createAnimal(
          request.params.farmId,
          parsed.data,
        );
        return sendAnimal(reply, animal, breedCatalog, 201);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string; animalId: string } }>(
    '/api/v1/farms/:farmId/animals/:animalId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const animal = await animalService.getAnimal(
          request.params.farmId,
          request.params.animalId,
        );
        return sendAnimal(reply, animal, breedCatalog);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string; animalId: string } }>(
    '/api/v1/farms/:farmId/animals/:animalId/tags',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = tagSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const animal = await animalService.applyTag(
          request.params.farmId,
          request.params.animalId,
          parsed.data.tag,
        );
        return sendAnimal(reply, animal, breedCatalog);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.delete<{ Params: { farmId: string; animalId: string; tag: string } }>(
    '/api/v1/farms/:farmId/animals/:animalId/tags/:tag',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const animal = await animalService.removeTag(
          request.params.farmId,
          request.params.animalId,
          request.params.tag as never,
        );
        return sendAnimal(reply, animal, breedCatalog);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string; animalId: string } }>(
    '/api/v1/farms/:farmId/animals/:animalId/cull',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const animal = await animalService.flagCull(
          request.params.farmId,
          request.params.animalId,
        );
        return sendAnimal(reply, animal, breedCatalog);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string; animalId: string } }>(
    '/api/v1/farms/:farmId/animals/:animalId/sell',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      try {
        const animal = await animalService.markSold(
          request.params.farmId,
          request.params.animalId,
        );
        return sendAnimal(reply, animal, breedCatalog);
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/groups',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const groups = await animalService.listGroups(request.params.farmId);
      return reply.send({ data: groups, meta: { total: groups.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/groups/bulk',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = bulkGroupSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const result = await animalService.createGroupBulk(
          request.params.farmId,
          parsed.data,
        );
        return reply.status(201).send({
          data: result.group,
          meta: {
            animals_created: result.animals.length,
            animals: presentAnimals(result.animals, breedCatalog),
          },
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
