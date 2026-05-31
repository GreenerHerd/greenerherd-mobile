import type { GroupNutritionStatus } from '@greenerherd/shared-db/group-nutrition-status';

export interface SavedFeedPlan {
  id: string;
  farm_id: string | null;
  group_id: string;
  profile_code: string;
  head_count: number;
  optimizer_pass: 'complete' | 'partial';
  solution: Record<string, number>;
  totals: Record<string, number>;
  nutrient_gaps: GroupNutritionStatus['nutrient_gaps'];
  catalog_achievement: GroupNutritionStatus['catalog_achievement'];
  cost_per_day: number;
  cost_currency: string;
  context: Record<string, unknown>;
  is_active: boolean;
  created_at: string;
}

export interface FeedPlanRepository {
  saveActivePlan(
    farmId: string | null,
    status: GroupNutritionStatus,
  ): Promise<SavedFeedPlan>;
  getActivePlan(groupId: string): Promise<SavedFeedPlan | null>;
}
