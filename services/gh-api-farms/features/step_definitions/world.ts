import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { FarmRepository } from '../../src/repositories/farm-repository.js';
import type { FarmService } from '../../src/services/farm-service.js';

export class ApiWorld extends World {
  app!: FastifyInstance;
  repo!: FarmRepository;
  farmService!: FarmService;
  secret = 'test-jwt-secret';
  authToken?: string;
  lastResponse?: {
    statusCode: number;
    body: unknown;
  };
  saved: Record<string, string> = {};
}

setWorldConstructor(ApiWorld);
