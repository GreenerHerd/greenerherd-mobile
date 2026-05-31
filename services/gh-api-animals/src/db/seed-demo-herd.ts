import type { InMemoryAnimalRepository } from '../repositories/in-memory-animal-repository.js';

/** Demo herd for local dev / mobile API integration (farm-1). */
export async function seedDemoHerd(
  repo: InMemoryAnimalRepository,
  farmId: string,
): Promise<void> {
  const existing = await repo.listAnimals(farmId);
  if (existing.length > 0) return;

  const { group } = await repo.createGroupBulk(farmId, {
    species: 'CATTLE',
    breed: 'Holstein',
    sex: 'FEMALE',
    age_range: '1_2Y',
    count: 4,
    name: 'Milking A',
    purpose: 'MILK',
    notes: 'Demo lactating group',
  });

  await repo.createAnimal(farmId, {
    species: 'CATTLE',
    sex: 'FEMALE',
    breed: 'Holstein',
    ear_tag: '0421',
    name: 'Bessie',
    group_id: group.id,
    current_weight_kg: 580,
    age_range: '1_2Y',
    tags: ['PREGNANT', 'LACTATING'],
  });
}
