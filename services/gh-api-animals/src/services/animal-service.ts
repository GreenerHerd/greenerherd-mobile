import { AppError } from '../lib/errors.js';
import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import type { AnimalRepository } from '../repositories/animal-repository.js';
import type {
  CreateAnimalInput,
  CreateGroupBulkInput,
  AnimalTagType,
  Species,
} from '../domain/types.js';
import { AnimalLifecycle } from './animal-lifecycle.js';

type CreateAnimalPayload = CreateAnimalInput & { breed_id?: string | null };

export class AnimalService {
  private lifecycle = new AnimalLifecycle();

  constructor(
    private readonly repo: AnimalRepository,
    private readonly breedCatalog?: BreedCatalog,
  ) {}

  private resolveBreedInput(
    species: Species,
    input: Pick<CreateAnimalInput, 'breed' | 'breed_id'>,
  ): Pick<CreateAnimalPayload, 'breed' | 'breed_id'> {
    if (!this.breedCatalog) {
      const breed = input.breed?.trim();
      if (!breed) {
        throw new AppError('VALIDATION_ERROR', 'Breed is required', 400);
      }
      return { breed, breed_id: input.breed_id ?? null };
    }

    if (input.breed_id) {
      const record = this.breedCatalog.getById(input.breed_id);
      if (!record || record.species !== species) {
        throw new AppError(
          'UNKNOWN_BREED',
          `Unknown breed id for species ${species}`,
          400,
        );
      }
      return { breed: record.name_en, breed_id: record.id };
    }

    const breed = input.breed?.trim();
    if (!breed) {
      throw new AppError('VALIDATION_ERROR', 'breed or breed_id is required', 400);
    }

    const record = this.breedCatalog.resolve(species, breed);
    if (!record) {
      throw new AppError(
        'UNKNOWN_BREED',
        `Unknown breed "${breed}" for species ${species}`,
        400,
      );
    }
    return { breed: record.name_en, breed_id: record.id };
  }

  async createAnimal(farmId: string, input: CreateAnimalInput) {
    const breedResolved = this.resolveBreedInput(input.species, input);
    const payload: CreateAnimalPayload = { ...input, ...breedResolved };
    try {
      return await this.repo.createAnimal(farmId, payload);
    } catch (e) {
      if (e instanceof Error && e.message === 'EAR_TAG_EXISTS') {
        throw new AppError('EAR_TAG_EXISTS', 'Ear tag already used on this farm', 409);
      }
      throw e;
    }
  }

  async getAnimal(farmId: string, animalId: string) {
    const animal = await this.repo.getAnimal(farmId, animalId);
    if (!animal) throw new AppError('ANIMAL_NOT_FOUND', 'Animal not found', 404);
    return animal;
  }

  async listAnimals(
    farmId: string,
    filter?: Parameters<AnimalRepository['listAnimals']>[1],
  ) {
    return this.repo.listAnimals(farmId, filter);
  }

  async createGroupBulk(farmId: string, input: CreateGroupBulkInput) {
    if (input.count < 1 || input.count > 500) {
      throw new AppError('VALIDATION_ERROR', 'Count must be between 1 and 500');
    }
    const breedResolved = this.resolveBreedInput(input.species, input);
    return this.repo.createGroupBulk(farmId, {
      ...input,
      breed: breedResolved.breed!,
      breed_id: breedResolved.breed_id,
    });
  }

  async listGroups(farmId: string) {
    return this.repo.listGroups(farmId);
  }

  async applyTag(farmId: string, animalId: string, tag: AnimalTagType) {
    const animal = await this.getAnimal(farmId, animalId);
    const updated = this.lifecycle.applyTag(animal, tag);
    return this.repo.updateAnimal(farmId, updated);
  }

  async removeTag(farmId: string, animalId: string, tag: AnimalTagType) {
    const animal = await this.getAnimal(farmId, animalId);
    const updated = this.lifecycle.removeTag(animal, tag);
    return this.repo.updateAnimal(farmId, updated);
  }

  async flagCull(farmId: string, animalId: string) {
    const animal = await this.getAnimal(farmId, animalId);
    const updated = this.lifecycle.flagCull(animal);
    return this.repo.updateAnimal(farmId, updated);
  }

  async markSold(farmId: string, animalId: string) {
    const animal = await this.getAnimal(farmId, animalId);
    const updated = this.lifecycle.markSold(animal);
    return this.repo.updateAnimal(farmId, updated);
  }
}
