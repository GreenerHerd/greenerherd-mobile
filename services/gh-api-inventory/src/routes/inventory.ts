import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { assertFarmAccess } from '../lib/auth.js';
import type { InventoryService } from '../services/inventory-service.js';

const customNutritionSchema = z.object({
  feed_type: z.enum(['FODDER', 'CONCENTRATE', 'ADDITIVE', 'CUSTOM']).optional(),
  dry_matter_percent: z.number().min(0).max(100).optional(),
  crude_protein_percent: z.number().min(0).max(100).optional(),
  nem_mcal_per_kg: z.number().min(0).optional(),
  ndf_percent: z.number().min(0).max(100).optional(),
  calcium_percent: z.number().min(0).optional(),
  phosphorus_percent: z.number().min(0).optional(),
});

const createFeedSchema = z.object({
  name: z.string().min(1),
  source_type: z.enum(['STANDARD', 'MARKETPLACE', 'CUSTOM']),
  feed_product_number: z.number().int().positive().optional().nullable(),
  marketplace_product_id: z.string().optional().nullable(),
  feed_type: z.enum(['FODDER', 'CONCENTRATE', 'ADDITIVE', 'CUSTOM']).optional().nullable(),
  quantity_kg: z.number().min(0),
  purchased_volume_kg: z.number().min(0).optional().nullable(),
  unit_cost: z.number().min(0).optional().nullable(),
  currency: z.string().length(3).optional(),
  supplier_name: z.string().optional().nullable(),
  supplier_phone: z.string().optional().nullable(),
  supplier_notes: z.string().optional().nullable(),
  custom_nutrition: customNutritionSchema.optional(),
  estimated_daily_usage_kg: z.number().min(0).optional(),
  reorder_threshold_kg: z.number().min(0).optional(),
  expiry_date: z.string().optional().nullable(),
  notes: z.string().optional().nullable(),
});

const createMedicalSchema = z.object({
  name: z.string().min(1),
  medicine_type: z.string().min(1),
  purpose: z.string().optional().nullable(),
  quantity: z.number().min(0),
  unit: z.enum(['kg', 'litre', 'unit', 'dose']),
  unit_cost: z.number().min(0).optional().nullable(),
  currency: z.string().length(3).optional(),
  purchased_volume: z.number().min(0).optional().nullable(),
  batch_number: z.string().optional().nullable(),
  expiry_date: z.string().optional().nullable(),
  supplier_name: z.string().optional().nullable(),
  supplier_phone: z.string().optional().nullable(),
  supplier_notes: z.string().optional().nullable(),
  source_type: z.enum(['STANDARD', 'MARKETPLACE', 'CUSTOM']).optional(),
  estimated_weekly_usage: z.number().min(0).optional(),
  notes: z.string().optional().nullable(),
});

export async function inventoryRoutes(
  app: FastifyInstance,
  service: InventoryService,
): Promise<void> {
  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/inventory/feed',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      return reply.send({
        data: service.listFeed(request.params.farmId),
        meta: { count: service.listFeed(request.params.farmId).length },
      });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/inventory/feed',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = createFeedSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: parsed.error.message },
        });
      }
      const data = await service.createFeed(request.params.farmId, parsed.data);
      return reply.status(201).send({ data, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string; itemId: string } }>(
    '/api/v1/farms/:farmId/inventory/feed/:itemId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const data = service.getFeed(request.params.farmId, request.params.itemId);
      return reply.send({ data, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string; itemId: string } }>(
    '/api/v1/farms/:farmId/inventory/feed/:itemId/usage',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const data = service.usageSummary(
        request.params.farmId,
        request.params.itemId,
      );
      return reply.send({ data, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/inventory/medical',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const data = service.listMedical(request.params.farmId);
      return reply.send({ data, meta: { count: data.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/inventory/medical',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const parsed = createMedicalSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: parsed.error.message },
        });
      }
      const data = service.createMedical(request.params.farmId, parsed.data);
      return reply.status(201).send({ data, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/inventory/low-stock',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const data = service.lowStockSummary(request.params.farmId);
      return reply.send({ data, meta: {} });
    },
  );
}
