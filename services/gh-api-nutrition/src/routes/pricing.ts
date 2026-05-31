import type { FastifyInstance } from 'fastify';
import type { NutritionService } from '../services/nutrition-service.js';

export async function pricingRoutes(
  app: FastifyInstance,
  nutritionService: NutritionService,
): Promise<void> {
  app.get<{ Querystring: { country?: string } }>(
    '/api/v1/reference/feeds/prices',
    async (request, reply) => {
      const country = request.query.country?.toUpperCase();
      const data = nutritionService.listIndicativePrices(country);
      return reply.send({
        data,
        meta: { total: data.length, country_code: country ?? null },
      });
    },
  );

  app.get<{ Params: { priceNumber: string }; Querystring: { country?: string } }>(
    '/api/v1/reference/feeds/prices/:priceNumber',
    async (request, reply) => {
      const priceNumber = Number(request.params.priceNumber);
      if (!Number.isInteger(priceNumber)) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid price number' },
        });
      }
      const country = request.query.country?.toUpperCase();
      const data = nutritionService.getIndicativePrice(priceNumber, country);
      return reply.send({ data, meta: {} });
    },
  );

  app.get<{ Params: { productNumber: string }; Querystring: { country?: string } }>(
    '/api/v1/reference/feeds/:productNumber/pricing',
    async (request, reply) => {
      const productNumber = Number(request.params.productNumber);
      if (!Number.isInteger(productNumber)) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid product number' },
        });
      }
      const country = request.query.country?.toUpperCase();
      const data = nutritionService.getProductPricing(productNumber, country);
      return reply.send({ data, meta: { country_code: country ?? null } });
    },
  );

  app.get('/api/v1/reference/feeds/fx-rates', async (_request, reply) => {
    const data = nutritionService.listFxRates();
    return reply.send({ data, meta: { total: data.length } });
  });
}
