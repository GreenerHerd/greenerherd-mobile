import { randomUUID } from 'node:crypto';
import type { Pool } from 'pg';
import type { FarmTaskDraft } from '@greenerherd/shared-db/notification-trigger-engine';
import type { FarmTaskRecord, FarmTaskRepository } from './farm-task-repository.js';

function mapRow(row: Record<string, unknown>): FarmTaskRecord {
  return {
    id: String(row.id),
    farm_id: String(row.farm_id),
    task_definition_id:
      row.task_definition_id == null ? null : String(row.task_definition_id),
    title: String(row.title),
    description: row.description == null ? null : String(row.description),
    task_type: String(row.task_type),
    group_id: row.group_id == null ? null : String(row.group_id),
    animal_id: row.animal_id == null ? null : String(row.animal_id),
    assigned_to: row.assigned_to == null ? null : String(row.assigned_to),
    due_date: String(row.due_date).slice(0, 10),
    status: String(row.status),
    priority: row.priority == null ? null : String(row.priority),
    created_at: String(row.created_at),
    completed_at: row.completed_at == null ? null : String(row.completed_at),
    metadata: (row.metadata as Record<string, unknown>) ?? {},
  };
}

export class PostgresFarmTaskRepository implements FarmTaskRepository {
  constructor(private readonly pool: Pool) {}

  async listByFarm(
    farmId: string,
    filter?: { status?: string; group_id?: string },
  ): Promise<FarmTaskRecord[]> {
    const clauses = ['farm_id = $1'];
    const params: unknown[] = [farmId];
    if (filter?.status) {
      params.push(filter.status);
      clauses.push(`status = $${params.length}`);
    }
    if (filter?.group_id) {
      params.push(filter.group_id);
      clauses.push(`group_id = $${params.length}`);
    }
    const { rows } = await this.pool.query(
      `SELECT * FROM farm_tasks WHERE ${clauses.join(' AND ')} ORDER BY due_date NULLS LAST, created_at DESC`,
      params,
    );
    return rows.map((r) => mapRow(r as Record<string, unknown>));
  }

  async getById(id: string): Promise<FarmTaskRecord | null> {
    const { rows } = await this.pool.query(`SELECT * FROM farm_tasks WHERE id = $1`, [
      id,
    ]);
    return rows[0] ? mapRow(rows[0] as Record<string, unknown>) : null;
  }

  async createMany(drafts: FarmTaskDraft[]): Promise<FarmTaskRecord[]> {
    const created: FarmTaskRecord[] = [];
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      for (const draft of drafts) {
        const dup = await client.query(
          `SELECT 1 FROM farm_task_dedupe
           WHERE farm_id = $1 AND task_definition_id = $2 AND dedupe_key = $3`,
          [draft.farm_id, draft.task_definition_id, draft.dedupe_key],
        );
        if (dup.rowCount && dup.rowCount > 0) continue;

        const id = randomUUID();
        const { rows } = await client.query(
          `INSERT INTO farm_tasks (
            id, farm_id, task_definition_id, title, description, task_type,
            group_id, animal_id, assigned_to, due_date, status, priority, metadata
          ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'PENDING',$11,$12)
          RETURNING *`,
          [
            id,
            draft.farm_id,
            draft.task_definition_id,
            draft.title,
            draft.description,
            draft.task_type,
            draft.group_id,
            draft.animal_id,
            draft.assigned_to,
            draft.due_date,
            draft.priority,
            JSON.stringify({ ...draft.metadata, dedupe_key: draft.dedupe_key }),
          ],
        );
        await client.query(
          `INSERT INTO farm_task_dedupe (farm_id, task_definition_id, dedupe_key, farm_task_id)
           VALUES ($1,$2,$3,$4)`,
          [draft.farm_id, draft.task_definition_id, draft.dedupe_key, id],
        );
        created.push(mapRow(rows[0] as Record<string, unknown>));
      }
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
    return created;
  }

  async updateStatus(
    id: string,
    status: string,
    completedAt: string | null = null,
  ): Promise<FarmTaskRecord> {
    const { rows } = await this.pool.query(
      `UPDATE farm_tasks SET status = $2, completed_at = $3 WHERE id = $1 RETURNING *`,
      [id, status, completedAt],
    );
    if (!rows[0]) throw new Error('Task not found');
    return mapRow(rows[0] as Record<string, unknown>);
  }

  async listActiveDedupeKeys(farmId: string): Promise<Set<string>> {
    const { rows } = await this.pool.query(
      `SELECT dedupe_key FROM farm_task_dedupe d
       JOIN farm_tasks t ON t.id = d.farm_task_id
       WHERE d.farm_id = $1 AND t.status NOT IN ('COMPLETE', 'DISMISSED')`,
      [farmId],
    );
    return new Set(rows.map((r) => String(r.dedupe_key)));
  }
}
