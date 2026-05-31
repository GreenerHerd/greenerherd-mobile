import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import { bootstrapAnimalData } from './db/bootstrap.js';
import { AnimalService } from './services/animal-service.js';
import { animalRoutes } from './routes/animals.js';
import { referenceRoutes } from './routes/reference.js';
import type { AnimalRepository } from './repositories/animal-repository.js';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';

export interface AppOptions {
  jwtSecret?: string;
  repository?: AnimalRepository;
  breedCatalog?: BreedCatalog;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const { repository, breedCatalog, pool } = await bootstrapAnimalData(
    options.repository,
    options.breedCatalog,
  );
  const animalService = new AnimalService(repository, breedCatalog);

  const app = Fastify({ logger: createFastifyLogger('gh-api-animals') });
  await app.register(cors, { origin: true });

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send(errorBody(error.code, error.message));
    }
    const statusCode =
      typeof error === 'object' &&
      error !== null &&
      'statusCode' in error &&
      typeof (error as { statusCode: number }).statusCode === 'number'
        ? (error as { statusCode: number }).statusCode
        : 500;
    if (statusCode === 400) {
      return reply
        .status(400)
        .send(errorBody('VALIDATION_ERROR', error.message ?? 'Bad request'));
    }
    return reply.status(500).send(errorBody('INTERNAL_ERROR', error.message));
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'gh-api-animals',
    storage: pool ? 'postgres' : breedCatalog ? 'memory+breeds' : 'memory',
    breeds_loaded: breedCatalog?.size ?? 0,
    breeds_by_species: breedCatalog?.countsBySpecies() ?? null,
  }));

  if (breedCatalog) {
    await referenceRoutes(app, breedCatalog, pool);
  }

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await animalRoutes(scoped, animalService, breedCatalog);
  });

  return { app, animalService, repo: repository, secret, breedCatalog, pool };
}
