import type { FastifyInstance } from 'fastify';
import type { FeedType } from '@greenerherd/shared-db/feed-catalog';
import {
  matchesSpeciesScope,
  toPublicFeedProduct,
} from '@greenerherd/shared-db/feed-catalog';
import type { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';

export async function referenceRoutes(
  app: FastifyInstance,
  feedCatalog: FeedCatalog,
): Promise<void> {
  app.get<{ Querystring: { species?: string; feed_type?: string } }>(
    '/api/v1/reference/feeds',
    async (request, reply) => {
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

      let products = feedCatalog.list();
      if (species) {
        products = products.filter((p) =>
          p.eligibility_rules.some((r) => matchesSpeciesScope(r.species_scope, species)),
        );
      }
      if (feed_type) {
        products = products.filter((p) => p.feed_type === feed_type);
      }

      return reply.send({
        data: products.map(toPublicFeedProduct),
        meta: { count: products.length },
      });
    },
  );
}
