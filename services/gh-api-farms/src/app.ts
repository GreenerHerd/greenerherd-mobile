import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import { bootstrapFarmData } from './db/bootstrap.js';
import { FarmService } from './services/farm-service.js';
import { farmRoutes } from './routes/farms.js';
import { notificationPreferenceRoutes } from './routes/notification-preferences.js';
import { referenceRoutes } from './routes/reference.js';
import { NotificationPreferenceService } from './services/notification-preference-service.js';
import type { FarmRepository } from './repositories/farm-repository.js';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import type { NotificationTaskCatalog } from '@greenerherd/shared-db/notification-task-catalog';

export interface AppOptions {
  jwtSecret?: string;
  repository?: FarmRepository;
  breedCatalog?: BreedCatalog;
  notificationCatalogOverride?: NotificationTaskCatalog;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const {
    repository,
    breedCatalog,
    notificationCatalog,
    notificationPreferenceRepository,
    pool,
  } = await bootstrapFarmData(
    options.repository,
    options.breedCatalog,
    options.notificationCatalogOverride,
  );
  const farmService = new FarmService(repository);
  const notificationPreferenceService = new NotificationPreferenceService(
    notificationCatalog,
    notificationPreferenceRepository,
  );

  const app = Fastify({ logger: createFastifyLogger('gh-api-farms') });

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
    service: 'gh-api-farms',
    storage: pool ? 'postgres' : breedCatalog ? 'memory+breeds' : 'memory',
    breeds_loaded: breedCatalog?.size ?? 0,
  }));

  if (breedCatalog) {
    await referenceRoutes(app, breedCatalog, pool);
  }

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await farmRoutes(scoped, farmService, secret);
    await notificationPreferenceRoutes(scoped, notificationPreferenceService);
  });

  return {
    app,
    farmService,
    notificationPreferenceService,
    repo: repository,
    secret,
    breedCatalog,
    pool,
  };
}
