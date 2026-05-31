import { randomUUID } from 'node:crypto';
import type {
  Animal,
  AnimalGroup,
  CreateAnimalInput,
  CreateGroupBulkInput,
} from '../domain/types.js';
import type { AnimalRepository, ListAnimalsFilter } from './animal-repository.js';

export class InMemoryAnimalRepository implements AnimalRepository {
  private animals = new Map<string, Animal[]>();
  private groups = new Map<string, AnimalGroup[]>();

  async createAnimal(farmId: string, input: CreateAnimalInput): Promise<Animal> {
    if (input.ear_tag) {
      const existing = (this.animals.get(farmId) ?? []).find(
        (a) => a.ear_tag === input.ear_tag && a.status === 'ACTIVE',
      );
      if (existing) throw new Error('EAR_TAG_EXISTS');
    }
    const now = new Date().toISOString();
    const tags = input.tags ?? [];
    const withBreedId = input as CreateAnimalInput & { breed_id?: string | null };
    const animal: Animal = {
      id: randomUUID(),
      farm_id: farmId,
      group_id: input.group_id ?? null,
      species: input.species,
      ear_tag: input.ear_tag ?? null,
      name: input.name ?? null,
      sex: input.sex,
      breed: input.breed!,
      breed_id: withBreedId.breed_id ?? null,
      dob: input.dob ?? null,
      age_range: input.age_range ?? null,
      current_weight_kg: input.current_weight_kg ?? null,
      weight_indicative: input.current_weight_kg == null && input.age_range != null,
      status: 'ACTIVE',
      cull_flagged: tags.includes('CULL'),
      origin: input.origin ?? 'BORN_ON_FARM',
      tags,
      created_at: now,
      updated_at: now,
    };
    const list = this.animals.get(farmId) ?? [];
    list.push(animal);
    this.animals.set(farmId, list);
    return animal;
  }

  async getAnimal(farmId: string, animalId: string): Promise<Animal | null> {
    return (this.animals.get(farmId) ?? []).find((a) => a.id === animalId) ?? null;
  }

  async listAnimals(farmId: string, filter?: ListAnimalsFilter): Promise<Animal[]> {
    let list = [...(this.animals.get(farmId) ?? [])];
    if (filter?.species) list = list.filter((a) => a.species === filter.species);
    if (filter?.group_id) list = list.filter((a) => a.group_id === filter.group_id);
    if (filter?.tag) list = list.filter((a) => a.tags.includes(filter.tag!));
    if (filter?.status) list = list.filter((a) => a.status === filter.status);
    return list;
  }

  async updateAnimal(farmId: string, animal: Animal): Promise<Animal> {
    const list = this.animals.get(farmId) ?? [];
    const i = list.findIndex((a) => a.id === animal.id);
    if (i < 0) throw new Error('ANIMAL_NOT_FOUND');
    const updated = { ...animal, updated_at: new Date().toISOString() };
    list[i] = updated;
    this.animals.set(farmId, list);
    return updated;
  }

  async createGroupBulk(
    farmId: string,
    input: CreateGroupBulkInput,
  ): Promise<{ group: AnimalGroup; animals: Animal[] }> {
    const now = new Date().toISOString();
    const group: AnimalGroup = {
      id: randomUUID(),
      farm_id: farmId,
      species: input.species,
      name: input.name,
      purpose: input.purpose,
      notes: input.notes ?? null,
      created_at: now,
    };
    const groupList = this.groups.get(farmId) ?? [];
    groupList.push(group);
    this.groups.set(farmId, groupList);

    const created: Animal[] = [];
    for (let n = 1; n <= input.count; n++) {
      const animal = await this.createAnimal(farmId, {
        species: input.species,
        sex: input.sex,
        breed: input.breed,
        age_range: input.age_range,
        group_id: group.id,
        name: `${input.species} #${n}`,
        origin: 'BORN_ON_FARM',
      });
      created.push(animal);
    }
    return { group, animals: created };
  }

  async getGroup(farmId: string, groupId: string): Promise<AnimalGroup | null> {
    return (this.groups.get(farmId) ?? []).find((g) => g.id === groupId) ?? null;
  }

  async listGroups(farmId: string): Promise<AnimalGroup[]> {
    return [...(this.groups.get(farmId) ?? [])];
  }
}
