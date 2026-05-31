import type { BreedCatalog } from '@greenerherd/shared-db/breed-catalog';
import { toPublicBreed } from '@greenerherd/shared-db/breed-catalog';
import type { Animal } from '../domain/types.js';

export type AnimalResponse = Animal & {
  breed_id?: string | null;
  breed_ref?: ReturnType<typeof toPublicBreed> | null;
};

export function presentAnimal(
  animal: Animal & { breed_id?: string | null },
  catalog?: BreedCatalog,
): AnimalResponse {
  if (!catalog) {
    return { ...animal, breed_id: animal.breed_id ?? null, breed_ref: null };
  }

  const record =
    (animal.breed_id ? catalog.getById(animal.breed_id) : null) ??
    catalog.resolve(animal.species, animal.breed);

  return {
    ...animal,
    breed_id: record?.id ?? animal.breed_id ?? null,
    breed_ref: record ? toPublicBreed(record) : null,
  };
}

export function presentAnimals(
  animals: Array<Animal & { breed_id?: string | null }>,
  catalog?: BreedCatalog,
): AnimalResponse[] {
  return animals.map((a) => presentAnimal(a, catalog));
}
