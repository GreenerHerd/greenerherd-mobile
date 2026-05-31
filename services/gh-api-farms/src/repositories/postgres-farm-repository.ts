import { randomUUID } from 'node:crypto';
import type pg from 'pg';
import type {
  AddFarmSpeciesInput,
  CreateFarmInput,
  Farm,
  FarmSpecies,
  HousingType,
  PreferredLang,
  Species,
  SpeciesPurpose,
} from '../domain/types.js';
import type { FarmRepository } from './farm-repository.js';

function rowToFarm(row: Record<string, unknown>): Farm {
  return {
    id: String(row.id),
    name: String(row.name),
    owner_user_id: String(row.owner_user_id),
    country: String(row.country),
    location_lat: row.location_lat == null ? null : Number(row.location_lat),
    location_lng: row.location_lng == null ? null : Number(row.location_lng),
    preferred_currency: String(row.preferred_currency),
    housing_type: row.housing_type as HousingType,
    preferred_lang: row.preferred_lang as PreferredLang,
    onboarding_completed: Boolean(row.onboarding_completed),
    created_at: new Date(String(row.created_at)).toISOString(),
    updated_at: new Date(String(row.updated_at)).toISOString(),
  };
}

export class PostgresFarmRepository implements FarmRepository {
  constructor(private readonly pool: pg.Pool) {}

  async createFarm(input: CreateFarmInput): Promise<Farm> {
    const id = randomUUID();
    const { rows } = await this.pool.query(
      `INSERT INTO farms (
        id, name, owner_user_id, country, location_lat, location_lng,
        preferred_currency, housing_type, preferred_lang
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *`,
      [
        id,
        input.name,
        input.owner_user_id,
        input.country,
        input.location_lat ?? null,
        input.location_lng ?? null,
        input.preferred_currency,
        input.housing_type,
        input.preferred_lang,
      ],
    );
    return rowToFarm(rows[0]);
  }

  async getFarm(farmId: string): Promise<Farm | null> {
    const { rows } = await this.pool.query('SELECT * FROM farms WHERE id = $1', [farmId]);
    return rows[0] ? rowToFarm(rows[0]) : null;
  }

  async updateFarm(
    farmId: string,
    patch: Partial<
      Pick<
        Farm,
        | 'name'
        | 'country'
        | 'housing_type'
        | 'preferred_currency'
        | 'preferred_lang'
        | 'location_lat'
        | 'location_lng'
        | 'onboarding_completed'
      >
    >,
  ): Promise<Farm> {
    const existing = await this.getFarm(farmId);
    if (!existing) throw new Error('FARM_NOT_FOUND');

    const { rows } = await this.pool.query(
      `UPDATE farms SET
        name = COALESCE($2, name),
        country = COALESCE($3, country),
        housing_type = COALESCE($4, housing_type),
        preferred_currency = COALESCE($5, preferred_currency),
        preferred_lang = COALESCE($6, preferred_lang),
        location_lat = COALESCE($7, location_lat),
        location_lng = COALESCE($8, location_lng),
        onboarding_completed = COALESCE($9, onboarding_completed),
        updated_at = NOW()
      WHERE id = $1
      RETURNING *`,
      [
        farmId,
        patch.name ?? null,
        patch.country ?? null,
        patch.housing_type ?? null,
        patch.preferred_currency ?? null,
        patch.preferred_lang ?? null,
        patch.location_lat ?? null,
        patch.location_lng ?? null,
        patch.onboarding_completed ?? null,
      ],
    );
    return rowToFarm(rows[0]);
  }

  async listSpecies(farmId: string): Promise<FarmSpecies[]> {
    const farm = await this.getFarm(farmId);
    if (!farm) throw new Error('FARM_NOT_FOUND');
    const { rows } = await this.pool.query(
      'SELECT * FROM farm_species WHERE farm_id = $1 ORDER BY species',
      [farmId],
    );
    return rows.map((row) => ({
      id: String(row.id),
      farm_id: String(row.farm_id),
      species: row.species as Species,
      purpose: row.purpose as SpeciesPurpose,
    }));
  }

  async addSpecies(farmId: string, input: AddFarmSpeciesInput): Promise<FarmSpecies> {
    const farm = await this.getFarm(farmId);
    if (!farm) throw new Error('FARM_NOT_FOUND');

    const existing = await this.pool.query(
      'SELECT 1 FROM farm_species WHERE farm_id = $1 AND species = $2',
      [farmId, input.species],
    );
    if (existing.rowCount && existing.rowCount > 0) {
      throw new Error('SPECIES_ALREADY_EXISTS');
    }

    const id = randomUUID();
    const { rows } = await this.pool.query(
      `INSERT INTO farm_species (id, farm_id, species, purpose)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [id, farmId, input.species, input.purpose],
    );
    return {
      id: String(rows[0].id),
      farm_id: String(rows[0].farm_id),
      species: rows[0].species as Species,
      purpose: rows[0].purpose as SpeciesPurpose,
    };
  }

  async setOnboardingComplete(farmId: string, completed: boolean): Promise<Farm> {
    return this.updateFarm(farmId, { onboarding_completed: completed });
  }
}
