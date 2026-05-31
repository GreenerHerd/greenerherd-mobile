import { randomUUID } from 'node:crypto';
import type { GroupNutritionStatus } from '@greenerherd/shared-db/group-nutrition-status';
import type { FeedPlanRepository, SavedFeedPlan } from './feed-plan-repository.js';

export class InMemoryFeedPlanRepository implements FeedPlanRepository {
  private readonly plans = new Map<string, SavedFeedPlan>();

  async saveActivePlan(
    farmId: string | null,
    status: GroupNutritionStatus,
  ): Promise<SavedFeedPlan> {
    for (const [id, plan] of this.plans) {
      if (plan.group_id === status.group_id && plan.is_active) {
        this.plans.set(id, { ...plan, is_active: false });
      }
    }
    const record: SavedFeedPlan = {
      id: randomUUID(),
      farm_id: farmId,
      group_id: status.group_id,
      profile_code: status.profile_code,
      head_count: status.head_count,
      optimizer_pass: status.optimizer_pass,
      solution: status.recommendation.solution,
      totals: status.recommendation.totals,
      nutrient_gaps: status.nutrient_gaps,
      catalog_achievement: status.catalog_achievement,
      cost_per_day: status.recommendation.cost_per_day,
      cost_currency: status.recommendation.cost_currency,
      context: {
        match_reason: status.match_reason,
        required: status.required,
        plan: status.plan,
      },
      is_active: true,
      created_at: new Date().toISOString(),
    };
    this.plans.set(record.id, record);
    return record;
  }

  async getActivePlan(groupId: string): Promise<SavedFeedPlan | null> {
    for (const plan of this.plans.values()) {
      if (plan.group_id === groupId && plan.is_active) return plan;
    }
    return null;
  }
}
