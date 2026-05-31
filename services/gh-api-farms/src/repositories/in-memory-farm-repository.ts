import { randomUUID } from 'node:crypto';
import type {
  AddFarmSpeciesInput,
  CreateFarmInput,
  Farm,
  FarmSpecies,
} from '../domain/types.js';
import type { FarmRepository } from './farm-repository.js';

export class InMemoryFarmRepository implements FarmRepository {
  private farms = new Map<string, Farm>();
  private species = new Map<string, FarmSpecies[]>();

  async createFarm(input: CreateFarmInput): Promise<Farm> {
    const now = new Date().toISOString();
    const farm: Farm = {
      id: randomUUID(),
      name: input.name,
      owner_user_id: input.owner_user_id,
      country: input.country,
      location_lat: input.location_lat ?? null,
      location_lng: input.location_lng ?? null,
      preferred_currency: input.preferred_currency,
      housing_type: input.housing_type,
      preferred_lang: input.preferred_lang,
      onboarding_completed: false,
      created_at: now,
      updated_at: now,
    };
    this.farms.set(farm.id, farm);
    this.species.set(farm.id, []);
    return farm;
  }

  async getFarm(farmId: string): Promise<Farm | null> {
    return this.farms.get(farmId) ?? null;
  }

  async updateFarm(
    farmId: string,
    patch: Partial<Farm>,
  ): Promise<Farm> {
    const existing = this.farms.get(farmId);
    if (!existing) throw new Error('FARM_NOT_FOUND');
    const updated: Farm = {
      ...existing,
      ...patch,
      id: existing.id,
      owner_user_id: existing.owner_user_id,
      updated_at: new Date().toISOString(),
    };
    this.farms.set(farmId, updated);
    return updated;
  }

  async listSpecies(farmId: string): Promise<FarmSpecies[]> {
    return [...(this.species.get(farmId) ?? [])];
  }

  async addSpecies(farmId: string, input: AddFarmSpeciesInput): Promise<FarmSpecies> {
    if (!this.farms.has(farmId)) throw new Error('FARM_NOT_FOUND');
    const list = this.species.get(farmId) ?? [];
    const duplicate = list.find((s) => s.species === input.species);
    if (duplicate) throw new Error('SPECIES_ALREADY_EXISTS');
    const row: FarmSpecies = {
      id: randomUUID(),
      farm_id: farmId,
      species: input.species,
      purpose: input.purpose,
    };
    list.push(row);
    this.species.set(farmId, list);
    return row;
  }

  async setOnboardingComplete(farmId: string, completed: boolean): Promise<Farm> {
    return this.updateFarm(farmId, { onboarding_completed: completed });
  }

  /** Idempotent demo seed for `farm-1` (mobile dev JWT). */
  async ensureDemoFarm(
    input: Omit<Farm, 'created_at' | 'updated_at'>,
  ): Promise<void> {
    if (this.farms.has(input.id)) return;
    const now = new Date().toISOString();
    const farm: Farm = {
      ...input,
      created_at: now,
      updated_at: now,
    };
    this.farms.set(farm.id, farm);
    this.species.set(farm.id, []);
  }
}
