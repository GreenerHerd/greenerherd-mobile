import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { AppError, errorBody } from '../lib/errors.js';
import { assertFarmAccess, assertFinanceRole } from '../lib/auth.js';
import type { FinanceService } from '../services/finance-service.js';

const entrySchema = z.object({
  date_label: z.string().min(1),
  category: z.string().min(1),
  type: z.enum(['INCOME', 'EXPENSE']),
  amount: z.number().positive(),
  description: z.string().min(1),
});

const purchaseSchema = z.object({
  purchase_date: z.string().min(1),
  total_amount: z.number().positive(),
  animal_ids: z.array(z.string()).optional(),
  supplier: z.string().optional(),
  notes: z.string().optional(),
});

const saleSchema = z.object({
  sale_date: z.string().min(1),
  total_amount: z.number().positive(),
  animal_ids: z.array(z.string()).min(1),
  buyer: z.string().optional(),
  notes: z.string().optional(),
});

export async function financeRoutes(
  app: FastifyInstance,
  financeService: FinanceService,
): Promise<void> {
  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/summary',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertFinanceRole(request);
      const summary = await financeService.getSummary(request.params.farmId);
      return reply.send({ data: summary, meta: {} });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/entries',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertFinanceRole(request);
      const parsed = entrySchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      const entry = await financeService.addEntry(
        request.params.farmId,
        parsed.data,
      );
      return reply.status(201).send({ data: entry, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/purchases',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const list = await financeService.listPurchases(request.params.farmId);
      return reply.send({ data: list, meta: { total: list.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/purchases',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertFinanceRole(request);
      const parsed = purchaseSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      const record = await financeService.recordPurchase(
        request.params.farmId,
        parsed.data,
      );
      return reply.status(201).send({ data: record, meta: {} });
    },
  );

  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/sales',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const list = await financeService.listSales(request.params.farmId);
      return reply.send({ data: list, meta: { total: list.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/finance/sales',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertFinanceRole(request);
      const parsed = saleSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      const record = await financeService.recordSale(
        request.params.farmId,
        parsed.data,
      );
      return reply.status(201).send({ data: record, meta: {} });
    },
  );
}
