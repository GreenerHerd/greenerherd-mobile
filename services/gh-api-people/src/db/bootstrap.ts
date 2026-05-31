import type pg from 'pg';
import {
  getSharedPool,
  shouldUseDatabase,
  verifyDatabaseConnection,
} from '@greenerherd/shared-db/pool';
import { InMemoryPeopleRepository } from '../repositories/in-memory-people-repository.js';
import { seedDemoPeople } from './seed-demo-people.js';
import { PostgresPeopleRepository } from '../repositories/postgres-people-repository.js';
import type { PeopleRepository } from '../repositories/people-repository.js';

export interface PeopleDataBootstrap {
  repository: PeopleRepository;
  pool?: pg.Pool;
}

export async function bootstrapPeopleData(
  repositoryOverride?: PeopleRepository,
): Promise<PeopleDataBootstrap> {
  if (repositoryOverride) {
    return { repository: repositoryOverride };
  }

  if (!shouldUseDatabase()) {
    const repository = new InMemoryPeopleRepository();
    await seedDemoPeople(repository);
    console.log('[gh-api-people] Seeded demo team for farm-1 (in-memory)');
    return { repository };
  }

  const pool = getSharedPool();
  await verifyDatabaseConnection(pool);
  console.log('[gh-api-people] Using PostgreSQL repository');

  return {
    repository: new PostgresPeopleRepository(pool),
    pool,
  };
}
