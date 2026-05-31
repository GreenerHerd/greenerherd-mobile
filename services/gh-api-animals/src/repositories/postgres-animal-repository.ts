import { randomUUID } from 'node:crypto';
import type pg from 'pg';
import type {
  AgeRange,
  Animal,
  AnimalGroup,
  AnimalStatus,
  AnimalTagType,
  CreateAnimalInput,
  CreateGroupBulkInput,
  GroupPurpose,
  Origin,
  Sex,
  Species,
} from '../domain/types.js';
import type { AnimalRepository, ListAnimalsFilter } from './animal-repository.js';

function rowToAnimal(row: Record<string, unknown>): Animal {
  const tags = Array.isArray(row.tags)
    ? (row.tags as AnimalTagType[])
    : (JSON.parse(String(row.tags ?? '[]')) as AnimalTagType[]);
  return {
    id: String(row.id),
    farm_id: String(row.farm_id),
    group_id: row.group_id == null ? null : String(row.group_id),
    species: row.species as Species,
    ear_tag: row.ear_tag == null ? null : String(row.ear_tag),
    name: row.name == null ? null : String(row.name),
    sex: row.sex as Sex,
    breed: String(row.breed),
    breed_id: row.breed_id == null ? null : String(row.breed_id),
    dob: row.dob == null ? null : String(row.dob).slice(0, 10),
    age_range: (row.age_range as AgeRange | null) ?? null,
    current_weight_kg:
      row.current_weight_kg == null ? null : Number(row.current_weight_kg),
    weight_indicative: Boolean(row.weight_indicative),
    status: row.status as AnimalStatus,
    cull_flagged: Boolean(row.cull_flagged),
    origin: row.origin as Origin,
    tags,
    created_at: new Date(String(row.created_at)).toISOString(),
    updated_at: new Date(String(row.updated_at)).toISOString(),
  };
}

export class PostgresAnimalRepository implements AnimalRepository {
  constructor(
    private readonly pool: pg.Pool,
    private readonly resolveBreedId?: (
      species: Species,
      breed: string,
    ) => string | null,
  ) {}

  async createAnimal(
    farmId: string,
    input: CreateAnimalInput & { breed_id?: string | null },
  ): Promise<Animal> {
    if (input.ear_tag) {
      const dup = await this.pool.query(
        `SELECT 1 FROM animals
         WHERE farm_id = $1 AND ear_tag = $2 AND status = 'ACTIVE'`,
        [farmId, input.ear_tag],
      );
      if (dup.rowCount && dup.rowCount > 0) throw new Error('EAR_TAG_EXISTS');
    }

    const id = randomUUID();
    const tags = input.tags ?? [];
    const breedId =
      input.breed_id ??
      this.resolveBreedId?.(input.species, input.breed) ??
      null;

    const { rows } = await this.pool.query(
      `INSERT INTO animals (
        id, farm_id, group_id, species, ear_tag, name, sex, breed, breed_id,
        dob, age_range, current_weight_kg, weight_indicative, status,
        cull_flagged, origin, tags
      ) VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,'ACTIVE',$14,$15,$16::jsonb
      )
      RETURNING *`,
      [
        id,
        farmId,
        input.group_id ?? null,
        input.species,
        input.ear_tag ?? null,
        input.name ?? null,
        input.sex,
        input.breed,
        breedId,
        input.dob ?? null,
        input.age_range ?? null,
        input.current_weight_kg ?? null,
        input.current_weight_kg == null && input.age_range != null,
        tags.includes('CULL'),
        input.origin ?? 'BORN_ON_FARM',
        JSON.stringify(tags),
      ],
    );
    return rowToAnimal(rows[0]);
  }

  async getAnimal(farmId: string, animalId: string): Promise<Animal | null> {
    const { rows } = await this.pool.query(
      'SELECT * FROM animals WHERE farm_id = $1 AND id = $2',
      [farmId, animalId],
    );
    return rows[0] ? rowToAnimal(rows[0]) : null;
  }

  async listAnimals(farmId: string, filter?: ListAnimalsFilter): Promise<Animal[]> {
    const clauses = ['farm_id = $1'];
    const params: unknown[] = [farmId];
    let i = 2;

    if (filter?.species) {
      clauses.push(`species = $${i++}`);
      params.push(filter.species);
    }
    if (filter?.group_id) {
      clauses.push(`group_id = $${i++}`);
      params.push(filter.group_id);
    }
    if (filter?.status) {
      clauses.push(`status = $${i++}`);
      params.push(filter.status);
    }
    if (filter?.tag) {
      clauses.push(`tags @> $${i++}::jsonb`);
      params.push(JSON.stringify([filter.tag]));
    }

    const { rows } = await this.pool.query(
      `SELECT * FROM animals WHERE ${clauses.join(' AND ')} ORDER BY created_at`,
      params,
    );
    return rows.map(rowToAnimal);
  }

  async updateAnimal(farmId: string, animal: Animal): Promise<Animal> {
    const { rows } = await this.pool.query(
      `UPDATE animals SET
        group_id = $3,
        ear_tag = $4,
        name = $5,
        sex = $6,
        breed = $7,
        dob = $8,
        age_range = $9,
        current_weight_kg = $10,
        weight_indicative = $11,
        status = $12,
        cull_flagged = $13,
        origin = $14,
        tags = $15::jsonb,
        updated_at = NOW()
      WHERE farm_id = $1 AND id = $2
      RETURNING *`,
      [
        farmId,
        animal.id,
        animal.group_id,
        animal.ear_tag,
        animal.name,
        animal.sex,
        animal.breed,
        animal.dob,
        animal.age_range,
        animal.current_weight_kg,
        animal.weight_indicative,
        animal.status,
        animal.cull_flagged,
        animal.origin,
        JSON.stringify(animal.tags),
      ],
    );
    if (!rows[0]) throw new Error('ANIMAL_NOT_FOUND');
    return rowToAnimal(rows[0]);
  }

  async createGroupBulk(
    farmId: string,
    input: CreateGroupBulkInput,
  ): Promise<{ group: AnimalGroup; animals: Animal[] }> {
    const groupId = randomUUID();
    const now = new Date().toISOString();
    const { rows: groupRows } = await this.pool.query(
      `INSERT INTO animal_groups (id, farm_id, species, name, purpose, notes, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        groupId,
        farmId,
        input.species,
        input.name,
        input.purpose,
        input.notes ?? null,
        now,
      ],
    );

    const group: AnimalGroup = {
      id: String(groupRows[0].id),
      farm_id: farmId,
      species: groupRows[0].species as Species,
      name: String(groupRows[0].name),
      purpose: groupRows[0].purpose as GroupPurpose,
      notes: groupRows[0].notes == null ? null : String(groupRows[0].notes),
      created_at: new Date(String(groupRows[0].created_at)).toISOString(),
    };

    const animals: Animal[] = [];
    for (let n = 1; n <= input.count; n++) {
      const animal = await this.createAnimal(farmId, {
        species: input.species,
        sex: input.sex,
        breed: input.breed!,
        breed_id: input.breed_id ?? undefined,
        age_range: input.age_range,
        group_id: group.id,
        name: `${input.species} #${n}`,
        origin: 'BORN_ON_FARM',
      });
      animals.push(animal);
    }

    return { group, animals };
  }

  async getGroup(farmId: string, groupId: string): Promise<AnimalGroup | null> {
    const { rows } = await this.pool.query(
      'SELECT * FROM animal_groups WHERE farm_id = $1 AND id = $2',
      [farmId, groupId],
    );
    if (!rows[0]) return null;
    return {
      id: String(rows[0].id),
      farm_id: String(rows[0].farm_id),
      species: rows[0].species as Species,
      name: String(rows[0].name),
      purpose: rows[0].purpose as GroupPurpose,
      notes: rows[0].notes == null ? null : String(rows[0].notes),
      created_at: new Date(String(rows[0].created_at)).toISOString(),
    };
  }

  async listGroups(farmId: string): Promise<AnimalGroup[]> {
    const { rows } = await this.pool.query(
      'SELECT * FROM animal_groups WHERE farm_id = $1 ORDER BY created_at',
      [farmId],
    );
    return rows.map((row) => ({
      id: String(row.id),
      farm_id: String(row.farm_id),
      species: row.species as Species,
      name: String(row.name),
      purpose: row.purpose as GroupPurpose,
      notes: row.notes == null ? null : String(row.notes),
      created_at: new Date(String(row.created_at)).toISOString(),
    }));
  }
}
