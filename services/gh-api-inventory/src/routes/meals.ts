import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { assertFarmAccess } from '../lib/auth.js';
import type { InventoryService } from '../services/inventory-service.js';

const mealSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
});

const ingredientsSchema = z.object({
  ingredients: z
    .array(
      z.object({
        feed_inventory_item_id: z.string().uuid(),
        amount_kg: z.number().positive(),
      }),
    )
    .min(1),
});

const feedingSchema = z.object({
  group_id: z.string().min(1),
  meal_type_id: z.string().uuid().optional().nullable(),
  total_weight_kg: z.number().positive(),
  head_count: z.number().int().positive().optional().nullable(),
  notes: z.string().optional().nullable(),
});

export async function mealRoutes(
  app: FastifyInstance,
  service: InventoryService,
): Promise<void> {
  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/meals',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const data = service.listMeals(request.params.farmId);
      return reply.send({ data, meta: { count: data.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/meals',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = mealSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: parsed.error.message },
        });
      }
      const data = service.createMeal(request.params.farmId, parsed.data);
      return reply.status(201).send({ data, meta: {} });
    },
  );

  app.put<{ Params: { farmId: string; mealId: string } }>(
    '/api/v1/farms/:farmId/meals/:mealId/ingredients',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = ingredientsSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: parsed.error.message },
        });
      }
      const data = await service.setMealIngredients(
        request.params.farmId,
        request.params.mealId,
        parsed.data.ingredients,
      );
      return reply.send({ data, meta: {} });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/feeding-records',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = feedingSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: parsed.error.message },
        });
      }
      const data = await service.recordFeeding(request.params.farmId, {
        ...parsed.data,
        recorded_by: request.user?.user_id,
      });
      return reply.status(201).send({ data, meta: {} });
    },
  );
}
