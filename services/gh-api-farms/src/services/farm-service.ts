import { AppError } from '../lib/errors.js';
import type { FarmRepository } from '../repositories/farm-repository.js';
import type { AddFarmSpeciesInput, CreateFarmInput } from '../domain/types.js';

export class FarmService {
  constructor(private readonly repo: FarmRepository) {}

  async createFarm(input: CreateFarmInput) {
    if (!input.name?.trim()) {
      throw new AppError('VALIDATION_ERROR', 'Farm name is required');
    }
    if (!input.country?.trim()) {
      throw new AppError('VALIDATION_ERROR', 'Country is required');
    }
    return this.repo.createFarm(input);
  }

  async getFarm(farmId: string) {
    const farm = await this.repo.getFarm(farmId);
    if (!farm) throw new AppError('FARM_NOT_FOUND', 'Farm not found', 404);
    return farm;
  }

  async updateFarm(
    farmId: string,
    patch: Parameters<FarmRepository['updateFarm']>[1],
  ) {
    try {
      return await this.repo.updateFarm(farmId, patch);
    } catch (e) {
      if (e instanceof Error && e.message === 'FARM_NOT_FOUND') {
        throw new AppError('FARM_NOT_FOUND', 'Farm not found', 404);
      }
      throw e;
    }
  }

  async addSpecies(farmId: string, input: AddFarmSpeciesInput) {
    try {
      return await this.repo.addSpecies(farmId, input);
    } catch (e) {
      if (e instanceof Error && e.message === 'FARM_NOT_FOUND') {
        throw new AppError('FARM_NOT_FOUND', 'Farm not found', 404);
      }
      if (e instanceof Error && e.message === 'SPECIES_ALREADY_EXISTS') {
        throw new AppError('SPECIES_ALREADY_EXISTS', 'Species already configured for farm', 409);
      }
      throw e;
    }
  }

  async listSpecies(farmId: string) {
    await this.getFarm(farmId);
    return this.repo.listSpecies(farmId);
  }

  async getOnboardingStatus(farmId: string) {
    const farm = await this.getFarm(farmId);
    const species = await this.repo.listSpecies(farmId);
    return {
      farm_id: farm.id,
      step_1_farm_profile: true,
      step_2_species: species.length > 0,
      step_3_animals: farm.onboarding_completed,
      onboarding_completed: farm.onboarding_completed,
      species_count: species.length,
    };
  }

  async completeOnboarding(farmId: string, skipAnimals = false) {
    const farm = await this.getFarm(farmId);
    const species = await this.repo.listSpecies(farmId);
    if (species.length === 0) {
      throw new AppError(
        'ONBOARDING_INCOMPLETE',
        'Add at least one species before completing onboarding',
        400,
      );
    }
    if (!skipAnimals) {
      // Animals are created via gh-api-animals; farms marks complete when client confirms
    }
    return this.repo.setOnboardingComplete(farmId, true);
  }
}
