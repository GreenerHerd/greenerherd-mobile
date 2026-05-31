export type InventorySourceType = 'STANDARD' | 'MARKETPLACE' | 'CUSTOM';
export type FeedType = 'FODDER' | 'CONCENTRATE' | 'ADDITIVE' | 'CUSTOM';
export type UsageReason = 'PURCHASE' | 'FEEDING' | 'ADJUSTMENT' | 'WASTE';

export interface CustomNutrition {
  feed_type?: FeedType;
  dry_matter_percent?: number;
  crude_protein_percent?: number;
  nem_mcal_per_kg?: number;
  ndf_percent?: number;
  calcium_percent?: number;
  phosphorus_percent?: number;
}

export interface FeedInventoryItem {
  id: string;
  farm_id: string;
  name: string;
  source_type: InventorySourceType;
  feed_product_number: number | null;
  marketplace_product_id: string | null;
  feed_type: FeedType | null;
  quantity_kg: number;
  purchased_volume_kg: number | null;
  unit_cost: number | null;
  currency: string;
  supplier_name: string | null;
  supplier_phone: string | null;
  supplier_notes: string | null;
  custom_nutrition: CustomNutrition;
  weekly_usage_kg: number;
  reorder_threshold_kg: number;
  unit: string;
  expiry_date: string | null;
  notes: string | null;
  is_active: boolean;
  updated_at: string;
}

export interface MedicalInventoryItem {
  id: string;
  farm_id: string;
  name: string;
  medicine_type: string;
  purpose: string | null;
  quantity: number;
  unit: 'kg' | 'litre' | 'unit' | 'dose';
  unit_cost: number | null;
  currency: string;
  purchased_volume: number | null;
  batch_number: string | null;
  expiry_date: string | null;
  reorder_threshold: number;
  weekly_usage: number;
  supplier_name: string | null;
  supplier_phone: string | null;
  supplier_notes: string | null;
  source_type: InventorySourceType;
  notes: string | null;
  is_active: boolean;
  updated_at: string;
}

export interface MealIngredient {
  id: string;
  meal_type_id: string;
  feed_inventory_item_id: string;
  amount_kg: number;
  sort_order: number;
  feed_item_name?: string;
}

export interface MealType {
  id: string;
  farm_id: string;
  name: string;
  description: string | null;
  is_active: boolean;
  ingredients: MealIngredient[];
  total_kg_per_batch: number;
  created_at: string;
  updated_at: string;
}

export interface GroupFeedingRecord {
  id: string;
  farm_id: string;
  group_id: string;
  meal_type_id: string | null;
  recorded_date: string;
  total_weight_kg: number;
  per_head_kg: number | null;
  head_count: number | null;
  notes: string | null;
  recorded_by: string | null;
  created_at: string;
}

export interface InventoryUsageLog {
  id: string;
  farm_id: string;
  feed_inventory_item_id: string;
  delta_kg: number;
  reason: UsageReason;
  group_id: string | null;
  meal_type_id: string | null;
  feeding_record_id: string | null;
  notes: string | null;
  created_at: string;
}

export interface FeedItemPublic extends FeedInventoryItem {
  low_stock: boolean;
  weeks_of_supply: number | null;
}
