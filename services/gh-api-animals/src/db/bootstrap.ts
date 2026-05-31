import type pg from 'pg';
import { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';
import {
  InMemoryAnimalRepository,
} from '../repositories/in-memory-animal-repository.js';
import { seedDemoHerd } from './seed-demo-herd.js';
import { PostgresAnimalRepository } from '../repositories/postgres-animal-repository.js';
import type { AnimalRepository } from '../repositories/animal-repository.js';

export interface AnimalDataBootstrap {
  repository: AnimalRepository;
  breedCatalog?: BreedCatalog;
  pool?: pg.Pool;
}

export async function bootstrapAnimalData(
  repositoryOverride?: AnimalRepository,
  breedCatalogOverride?: BreedCatalog,
): Promise<AnimalDataBootstrap> {
  if (repositoryOverride) {
    return {
      repository: repositoryOverride,
      breedCatalog: breedCatalogOverride,
    };
  }

  if (!shouldUseDatabase()) {
    const repository = new InMemoryAnimalRepository();
    await seedDemoHerd(repository, 'farm-1');
    console.log('[gh-api-animals] Seeded demo herd for farm-1 (in-memory)');
    return { repository };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  const breedCatalog = await BreedCatalog.load(pool);
  console.log(
    `[gh-api-animals] Loaded ${breedCatalog.size} breeds from database`,
  );

  const repository = new PostgresAnimalRepository(pool, (species, breed) => {
    return breedCatalog.resolve(species, breed)?.id ?? null;
  });

  const existing = await repository.listAnimals('farm-1');
  if (existing.length === 0) {
    await seedDemoHerd(repository, 'farm-1');
    console.log('[gh-api-animals] Seeded demo herd for farm-1 (postgres)');
  }

  return { repository, breedCatalog, pool };
}
