import type {
  Animal,
  AnimalGroup,
  AnimalTagType,
  CreateAnimalInput,
  CreateGroupBulkInput,
  Species,
} from '../domain/types.js';

export interface ListAnimalsFilter {
  species?: Species;
  group_id?: string;
  tag?: AnimalTagType;
  status?: Animal['status'];
}

export interface AnimalRepository {
  createAnimal(farmId: string, input: CreateAnimalInput): Promise<Animal>;
  getAnimal(farmId: string, animalId: string): Promise<Animal | null>;
  listAnimals(farmId: string, filter?: ListAnimalsFilter): Promise<Animal[]>;
  updateAnimal(farmId: string, animal: Animal): Promise<Animal>;
  createGroupBulk(farmId: string, input: CreateGroupBulkInput): Promise<{
    group: AnimalGroup;
    animals: Animal[];
  }>;
  getGroup(farmId: string, groupId: string): Promise<AnimalGroup | null>;
  listGroups(farmId: string): Promise<AnimalGroup[]>;
}
