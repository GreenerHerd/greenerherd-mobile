import type { InMemoryPeopleRepository } from '../repositories/in-memory-people-repository.js';

/** Demo team for `farm-1` (matches Flutter mock seed). */
export async function seedDemoPeople(
  repo: InMemoryPeopleRepository,
  farmId = 'farm-1',
): Promise<void> {
  const existing = await repo.listFarmMembers(farmId);
  if (existing.length > 0) return;

  await repo.seedFarmOwner(farmId, {
    userId: 'u1',
    name: 'Yusuf Al-Harbi',
    email: 'owner@alfalah.test',
  });
  await repo.seedMember(farmId, {
    userId: 'u2',
    name: 'Khaled Saleh',
    email: 'khaled@alfalah.test',
    role: 'MANAGER',
  });
  await repo.seedMember(farmId, {
    userId: 'u3',
    name: 'Ahmad Bilal',
    email: 'ahmad@alfalah.test',
    role: 'FARM_HAND',
  });
  await repo.seedMember(farmId, {
    userId: 'u4',
    name: 'Dr. Rashed',
    email: 'vet@alfalah.test',
    role: 'VET',
  });
}
