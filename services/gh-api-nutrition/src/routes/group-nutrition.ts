import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { GroupNutritionOptions } from '@greenerherd/shared-db/group-nutrition-status';
import type { NutritionService } from '../services/nutrition-service.js';
import type { FeedPlanRepository } from '../repositories/feed-plan-repository.js';
import { emitDomainEvent } from '@greenerherd/shared-db/domain-event-client';
import { AppError } from '../lib/errors.js';

const profileBodySchema = z.object({
  species: z.enum(['CATTLE', 'GOAT', 'SHEEP']),
  sex: z.enum(['MALE', 'FEMALE']).optional(),
  age_months: z.number().min(0),
  production_focus: z.enum(['MILK', 'MEAT', 'BOTH']),
  lactating: z.boolean(),
  pregnant: z.boolean().optional(),
  head_count: z.number().int().min(1).optional(),
  months_since_calving: z.number().min(0).optional(),
  fattening: z.boolean().optional(),
  overage_percent: z.number().min(0).max(0.5).optional(),
  country_code: z.string().length(2).optional(),
  current_intake_ratio: z.number().min(0).max(1).optional(),
  /**
   * Optional user selection: accepted recommended feeds to constrain the
   * optimizer input.
   */
  included_product_numbers: z
    .array(z.number().int().positive())
    .optional(),
  current_totals: z
    .object({
      dry_matter_kg: z.number().min(0).optional(),
      energy_mj: z.number().min(0).optional(),
      protein_kg: z.number().min(0).optional(),
      ndf_kg: z.number().min(0).optional(),
    })
    .optional(),
  farm_id: z.string().uuid().optional(),
});

export async function groupNutritionRoutes(
  app: FastifyInstance,
  nutritionService: NutritionService,
  feedPlanRepo?: FeedPlanRepository,
): Promise<void> {
  app.post<{ Params: { groupId: string } }>(
    '/api/v1/groups/:groupId/nutrition',
    async (request, reply) => {
      const parsed = profileBodySchema.safeParse(request.body);
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const { current_intake_ratio, current_totals, farm_id, ...profile } =
        parsed.data;
      const options: GroupNutritionOptions = {
        current_intake_ratio,
        current_totals,
      };

      try {
        const status = nutritionService.getGroupNutrition(
          request.params.groupId,
          profile,
          options,
        );
        const feed_lines = nutritionService.feedPlanLines(status);
        const active_plan = feedPlanRepo
          ? await feedPlanRepo.getActivePlan(request.params.groupId)
          : null;

        return reply.send({
          data: {
            ...status,
            feed_lines,
            active_plan,
          },
          meta: {},
        });
      } catch (err) {
        if (err instanceof AppError) throw err;
        const message = err instanceof Error ? err.message : String(err);
        throw new AppError('NUTRITION_ERROR', message, 500);
      }
    },
  );

  app.post<{ Params: { groupId: string } }>(
    '/api/v1/groups/:groupId/nutrition/plans',
    async (request, reply) => {
      if (!feedPlanRepo) {
        throw new AppError(
          'PLANS_UNAVAILABLE',
          'Feed plan persistence is not configured',
          503,
        );
      }
      const parsed = profileBodySchema.safeParse(request.body);
      if (!parsed.success) {
        throw new AppError(
          'VALIDATION_ERROR',
          parsed.error.issues.map((i) => i.message).join('; '),
          400,
        );
      }
      const { current_intake_ratio, current_totals, farm_id, ...profile } =
        parsed.data;
      const status = nutritionService.getGroupNutrition(
        request.params.groupId,
        profile,
        { current_intake_ratio, current_totals },
      );
      const saved = await feedPlanRepo.saveActivePlan(farm_id ?? null, status);
      const resolvedFarmId =
        farm_id ??
        (request as { user?: { farm_ids?: string[] } }).user?.farm_ids?.[0];
      if (resolvedFarmId) {
        void emitDomainEvent({
          type: 'nutrition.product_accepted',
          farm_id: resolvedFarmId,
          group_id: request.params.groupId,
          payload: {
            plan_id: saved.id,
            group_id: request.params.groupId,
          },
        });
      }
      return reply.status(201).send({
        data: {
          plan: saved,
          feed_lines: nutritionService.feedPlanLines(status),
        },
        meta: {},
      });
    },
  );

  app.get<{ Params: { groupId: string } }>(
    '/api/v1/groups/:groupId/nutrition/plans/active',
    async (request, reply) => {
      if (!feedPlanRepo) {
        throw new AppError(
          'PLANS_UNAVAILABLE',
          'Feed plan persistence is not configured',
          503,
        );
      }
      const plan = await feedPlanRepo.getActivePlan(request.params.groupId);
      if (!plan) {
        throw new AppError('PLAN_NOT_FOUND', 'No active feed plan for group', 404);
      }
      return reply.send({ data: plan, meta: {} });
    },
  );
}
