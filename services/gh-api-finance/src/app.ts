import Fastify from 'fastify';
import cors from '@fastify/cors';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';
import { AppError, errorBody } from './lib/errors.js';
import { createAuthHook } from './lib/auth.js';
import { bootstrapFinanceData } from './db/bootstrap.js';
import { FinanceService } from './services/finance-service.js';
import { financeRoutes } from './routes/finance.js';
import type { FinanceRepository } from './repositories/finance-repository.js';

export interface AppOptions {
  jwtSecret?: string;
  repository?: FinanceRepository;
}

export async function buildApp(options: AppOptions = {}) {
  const secret = options.jwtSecret ?? process.env.JWT_SECRET ?? 'dev-secret-change-me';
  const { repository } = await bootstrapFinanceData(options.repository);
  const financeService = new FinanceService(repository);

  const app = Fastify({ logger: createFastifyLogger('gh-api-finance') });
  await app.register(cors, { origin: true });

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send(errorBody(error.code, error.message));
    }
    return reply.status(500).send(errorBody('INTERNAL_ERROR', error.message));
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'gh-api-finance',
    storage: 'memory',
  }));

  app.register(async (scoped) => {
    scoped.addHook('onRequest', createAuthHook(secret));
    await financeRoutes(scoped, financeService);
  });

  return { app, financeService, repo: repository, secret };
}
