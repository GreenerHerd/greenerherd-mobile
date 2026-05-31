import type { FastifyInstance } from 'fastify';
import { normalizeCatalogLocale } from '@greenerherd/shared-db/catalog-i18n';
import type { FeedType } from '@greenerherd/shared-db/feed-catalog';
import { toPublicFeedProduct } from '@greenerherd/shared-db/feed-catalog';
import type { NutritionService } from '../services/nutrition-service.js';

export async function feedRoutes(
  app: FastifyInstance,
  nutritionService: NutritionService,
): Promise<void> {
  app.get('/api/v1/reference/feeds/health', async () => ({
    data: {
      loaded: nutritionService.listProducts().length,
      by_type: nutritionService.listProducts().reduce(
        (acc, p) => {
          acc[p.feed_type] = (acc[p.feed_type] ?? 0) + 1;
          return acc;
        },
        {} as Record<string, number>,
      ),
    },
    meta: {},
  }));

  app.get<{ Querystring: { species?: string; feed_type?: string; locale?: string } }>(
    '/api/v1/reference/feeds',
    async (request, reply) => {
      const locale = normalizeCatalogLocale(request.query.locale);
      const species = request.query.species as
        | 'CATTLE'
        | 'GOAT'
        | 'SHEEP'
        | undefined;
      const feed_type = request.query.feed_type as FeedType | undefined;

      if (species && !['CATTLE', 'GOAT', 'SHEEP'].includes(species)) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid species filter' },
        });
      }
      if (feed_type && !['FODDER', 'CONCENTRATE', 'ADDITIVE'].includes(feed_type)) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid feed_type filter' },
        });
      }

      const products = nutritionService.listProducts({ species, feed_type });
      return reply.send({
        data: products.map((p) => toPublicFeedProduct(p, locale)),
        meta: { total: products.length, locale },
      });
    },
  );

  app.get<{ Params: { productNumber: string }; Querystring: { locale?: string } }>(
    '/api/v1/reference/feeds/:productNumber',
    async (request, reply) => {
      const locale = normalizeCatalogLocale(request.query.locale);
      const productNumber = Number(request.params.productNumber);
      if (!Number.isInteger(productNumber)) {
        return reply.status(400).send({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid product number' },
        });
      }
      try {
        const product = nutritionService.getProductByNumber(productNumber);
        return reply.send({
          data: toPublicFeedProduct(product, locale),
          meta: { locale },
        });
      } catch (e) {
        if (e instanceof Error && 'statusCode' in e) throw e;
        throw e;
      }
    },
  );
}
