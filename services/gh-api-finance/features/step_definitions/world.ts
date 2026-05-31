import type { FastifyInstance } from 'fastify';
import type { FinanceService } from '../../src/services/finance-service.js';
import type { FinanceRepository } from '../../src/repositories/finance-repository.js';

export interface ApiWorld {
  app: FastifyInstance;
  repo: FinanceRepository;
  financeService: FinanceService;
  secret: string;
  authToken?: string;
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string>;
}
