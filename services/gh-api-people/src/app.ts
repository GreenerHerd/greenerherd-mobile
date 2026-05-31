import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import { bootstrapPeopleData } from './db/bootstrap.js';
import { PeopleService } from './services/people-service.js';
import { peopleRoutes } from './routes/people.js';
import type { PeopleRepository } from './repositories/people-repository.js';

export interface AppOptions {
  jwtSecret?: string;
  repository?: PeopleRepository;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const { repository } = await bootstrapPeopleData(options.repository);
  const peopleService = new PeopleService(repository, secret);

  const app = Fastify({ logger: createFastifyLogger('gh-api-people') });
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
    service: 'gh-api-people',
    storage: process.env.DATABASE_URL ? 'postgres' : 'memory',
  }));

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await peopleRoutes(scoped, peopleService);
  });

  return { app, peopleService, repo: repository, secret };
}
