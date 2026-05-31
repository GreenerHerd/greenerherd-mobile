import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { PeopleRepository } from '../../src/repositories/people-repository.js';
import type { PeopleService } from '../../src/services/people-service.js';

export class ApiWorld extends World {
  app!: FastifyInstance;
  repo!: PeopleRepository;
  peopleService!: PeopleService;
  secret = 'test-jwt-secret';
  authToken?: string;
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string> = {};
}

setWorldConstructor(ApiWorld);
