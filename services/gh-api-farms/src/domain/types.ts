export type HousingType = 'INDOOR_FANS' | 'INDOOR_SHADE' | 'PASTURE';
export type PreferredLang = 'EN' | 'AR' | 'UR' | 'FR';
export type Species = 'CATTLE' | 'GOAT' | 'SHEEP';
export type SpeciesPurpose = 'MILK' | 'MEAT' | 'BOTH';

export interface Farm {
  id: string;
  name: string;
  owner_user_id: string;
  country: string;
  location_lat: number | null;
  location_lng: number | null;
  preferred_currency: string;
  housing_type: HousingType;
  preferred_lang: PreferredLang;
  onboarding_completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface FarmSpecies {
  id: string;
  farm_id: string;
  species: Species;
  purpose: SpeciesPurpose;
}

export interface CreateFarmInput {
  name: string;
  country: string;
  housing_type: HousingType;
  preferred_currency: string;
  preferred_lang: PreferredLang;
  location_lat?: number | null;
  location_lng?: number | null;
  owner_user_id: string;
}

export interface AddFarmSpeciesInput {
  species: Species;
  purpose: SpeciesPurpose;
}
