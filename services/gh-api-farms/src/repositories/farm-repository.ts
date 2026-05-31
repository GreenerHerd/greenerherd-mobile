import type {
  AddFarmSpeciesInput,
  CreateFarmInput,
  Farm,
  FarmSpecies,
} from '../domain/types.js';

export interface FarmRepository {
  createFarm(input: CreateFarmInput): Promise<Farm>;
  getFarm(farmId: string): Promise<Farm | null>;
  updateFarm(
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
      >
    >,
  ): Promise<Farm>;
  listSpecies(farmId: string): Promise<FarmSpecies[]>;
  addSpecies(farmId: string, input: AddFarmSpeciesInput): Promise<FarmSpecies>;
  setOnboardingComplete(farmId: string, completed: boolean): Promise<Farm>;
}
