import { After, Before } from '@cucumber/cucumber';
import { loadBddBreedCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-breed-catalog';
import { buildApp } from '../../src/app.js';
import { InMemoryAnimalRepository } from '../../src/repositories/in-memory-animal-repository.js';
import type { ApiWorld } from './world.js';

Before(async function (this: ApiWorld) {
  const breedCatalog = loadBddBreedCatalog();
  const { app, repo, animalService, secret } = await buildApp({
    jwtSecret: 'test-jwt-secret',
    repository: new InMemoryAnimalRepository(),
    breedCatalog,
  });
  this.app = app;
  this.repo = repo;
  this.animalService = animalService;
  this.breedCatalog = breedCatalog;
  this.secret = secret;
  this.authToken = undefined;
  this.lastResponse = undefined;
  this.saved = {};
  this.lastCreatedAnimalId = undefined;
});

After(async function (this: ApiWorld) {
  await this.app.close();
});
