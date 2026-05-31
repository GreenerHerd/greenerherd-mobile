import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { NutritionService } from '../services/nutrition-service.js';
import { AppError } from '../lib/errors.js';

const eligibilityBodySchema = z.object({
  species: z.enum(['CATTLE', 'GOAT', 'SHEEP']),
  sex: z.enum(['MALE', 'FEMALE']).optional(),
  age_months: z.number().min(0),
  production_focus: z.enum(['MILK', 'MEAT', 'BOTH']),
  lactating: z.boolean(),
  pregnant: z.boolean().optional(),
  feed_types: z.array(z.enum(['FODDER', 'CONCENTRATE', 'ADDITIVE'])).optional(),
  include_reasons: z.boolean().optional(),
  country_code: z.string().length(2).optional(),
});

const recommendBodySchema = eligibilityBodySchema.extend({
  head_count: z.number().int().min(1).optional(),
  months_since_calving: z.number().min(0).optional(),
  fattening: z.boolean().optional(),
  overage_percent: z.number().min(0).max(0.5).optional(),
  included_product_numbers: z.array(z.number().int().positive()).optional(),
});

export async function eligibilityRoutes(
  app: FastifyInstance,
  nutritionService: NutritionService,
): Promise<void> {
  app.post('/api/v1/feeds/eligible', async (request, reply) => {
    const parsed = eligibilityBodySchema.safeParse(request.body);
    if (!parsed.success) {
      throw new AppError(
        'VALIDATION_ERROR',
        parsed.error.issues.map((i) => i.message).join('; '),
        400,
      );
    }
    const result = nutritionService.getEligibleFeeds(parsed.data, {
      include_reasons: parsed.data.include_reasons ?? false,
      country_code: parsed.data.country_code,
    });
    return reply.send({ data: result, meta: {} });
  });

  app.post<{ Params: { groupId: string } }>(
    '/api/v1/groups/:groupId/feeds/eligible',
    async (request, reply) => {
      const parsed = eligibilityBodySchema.safeParse(request.body);
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const result = nutritionService.getEligibleFeeds(parsed.data, {
        include_reasons: parsed.data.include_reasons ?? false,
        country_code: parsed.data.country_code,
      });
      return reply.send({
        data: { ...result, group_id: request.params.groupId },
        meta: {},
      });
    },
  );

  app.post<{ Params: { groupId: string } }>(
    '/api/v1/groups/:groupId/nutrition/recommend',
    async (request, reply) => {
      const parsed = recommendBodySchema.safeParse(request.body);
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const result = nutritionService.recommendFeedPlan(parsed.data);
      return reply.send({
        data: { ...result, group_id: request.params.groupId },
        meta: {},
      });
    },
  );
}
