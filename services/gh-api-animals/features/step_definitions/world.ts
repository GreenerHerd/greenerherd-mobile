import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { AnimalRepository } from '../../src/repositories/animal-repository.js';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import type { AnimalService } from '../../src/services/animal-service.js';

export class ApiWorld extends World {
  app!: FastifyInstance;
  repo!: AnimalRepository;
  animalService!: AnimalService;
  breedCatalog?: BreedCatalog;
  secret = 'test-jwt-secret';
  authToken?: string;
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string> = {};
  lastCreatedAnimalId?: string;
}

setWorldConstructor(ApiWorld);
