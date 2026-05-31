import type { FastifyInstance } from 'fastify';
import type pg from 'pg';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import { registerReferenceRoutes } from '../../../gh-shared/routes/reference-routes.js';

export async function referenceRoutes(
  app: FastifyInstance,
  breedCatalog: BreedCatalog,
  pool?: pg.Pool,
): Promise<void> {
  await registerReferenceRoutes(app, breedCatalog, pool);
}
