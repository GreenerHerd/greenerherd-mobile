import type { Pool } from 'pg';
import type { GroupNutritionStatus } from '@greenerherd/shared-db/group-nutrition-status';
import type { FeedPlanRepository, SavedFeedPlan } from './feed-plan-repository.js';

export class PostgresFeedPlanRepository implements FeedPlanRepository {
  constructor(private readonly pool: Pool) {}

  async saveActivePlan(
    farmId: string | null,
    status: GroupNutritionStatus,
  ): Promise<SavedFeedPlan> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(
        `UPDATE group_feed_plans SET is_active = FALSE WHERE group_id = $1 AND is_active = TRUE`,
        [status.group_id],
      );
      const { rows } = await client.query<SavedFeedPlan>(
        `INSERT INTO group_feed_plans (
          farm_id, group_id, profile_code, head_count, optimizer_pass,
          solution, totals, nutrient_gaps, catalog_achievement,
          cost_per_day, cost_currency, context, is_active
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,TRUE)
        RETURNING *`,
        [
          farmId,
          status.group_id,
          status.profile_code,
          status.head_count,
          status.optimizer_pass,
          JSON.stringify(status.recommendation.solution),
          JSON.stringify(status.recommendation.totals),
          JSON.stringify(status.nutrient_gaps),
          JSON.stringify(status.catalog_achievement),
          status.recommendation.cost_per_day,
          status.recommendation.cost_currency,
          JSON.stringify({
            match_reason: status.match_reason,
            required: status.required,
            plan: status.plan,
          }),
        ],
      );
      await client.query('COMMIT');
      return rows[0]!;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async getActivePlan(groupId: string): Promise<SavedFeedPlan | null> {
    const { rows } = await this.pool.query<SavedFeedPlan>(
      `SELECT * FROM group_feed_plans WHERE group_id = $1 AND is_active = TRUE ORDER BY created_at DESC LIMIT 1`,
      [groupId],
    );
    return rows[0] ?? null;
  }
}
