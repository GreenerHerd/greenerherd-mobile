import type { InMemoryFarmRepository } from '../repositories/in-memory-farm-repository.js';

/** Demo farm for local dev / mobile integration (matches mock `farm-1`). */
export async function seedDemoFarm(
  repo: InMemoryFarmRepository,
  farmId = 'farm-1',
): Promise<void> {
  await repo.ensureDemoFarm({
    id: farmId,
    name: 'Al-Falah Farm',
    owner_user_id: 'u1',
    country: 'SA',
    location_lat: 24.7136,
    location_lng: 46.6753,
    preferred_currency: 'SAR',
    housing_type: 'INDOOR_FANS',
    preferred_lang: 'EN',
    onboarding_completed: true,
  });
}
