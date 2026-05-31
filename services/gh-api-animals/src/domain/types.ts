export type Species = 'CATTLE' | 'GOAT' | 'SHEEP';
export type Sex = 'MALE' | 'FEMALE';
export type AnimalStatus = 'ACTIVE' | 'SOLD' | 'DECEASED' | 'CULLED';
export type AnimalTagType =
  | 'WEANING'
  | 'READY_TO_BREED'
  | 'PREGNANT'
  | 'CULL'
  | 'MISCARRIAGE'
  | 'SICK'
  | 'LACTATING'
  | 'STILLBORN';
export type GroupPurpose =
  | 'MAINTENANCE'
  | 'BREEDING'
  | 'MILK'
  | 'PREGNANT'
  | 'SICK'
  | 'FATTENING';
export type AgeRange = '0_3M' | '3_6M' | '6_12M' | '1_2Y' | '2_3Y' | '3_5Y' | '5PLUS_Y';
export type Origin = 'BORN_ON_FARM' | 'PURCHASED';

export interface AnimalGroup {
  id: string;
  farm_id: string;
  species: Species;
  name: string;
  purpose: GroupPurpose;
  notes: string | null;
  created_at: string;
}

export interface Animal {
  id: string;
  farm_id: string;
  group_id: string | null;
  species: Species;
  ear_tag: string | null;
  name: string | null;
  sex: Sex;
  breed: string;
  breed_id?: string | null;
  dob: string | null;
  age_range: AgeRange | null;
  current_weight_kg: number | null;
  weight_indicative: boolean;
  status: AnimalStatus;
  cull_flagged: boolean;
  origin: Origin;
  tags: AnimalTagType[];
  created_at: string;
  updated_at: string;
}

export interface CreateAnimalInput {
  species: Species;
  sex: Sex;
  breed?: string;
  breed_id?: string;
  ear_tag?: string | null;
  name?: string | null;
  group_id?: string | null;
  dob?: string | null;
  age_range?: AgeRange | null;
  current_weight_kg?: number | null;
  origin?: Origin;
  tags?: AnimalTagType[];
}

export interface CreateGroupBulkInput {
  species: Species;
  breed?: string;
  breed_id?: string | null;
  sex: Sex;
  age_range: AgeRange;
  count: number;
  name: string;
  purpose: GroupPurpose;
  notes?: string;
}
