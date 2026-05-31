import { randomUUID } from 'node:crypto';
import type { FarmTaskDraft } from '@greenerherd/shared-db/notification-trigger-engine';
import type { FarmTaskRecord, FarmTaskRepository } from './farm-task-repository.js';

export class InMemoryFarmTaskRepository implements FarmTaskRepository {
  private readonly tasks = new Map<string, FarmTaskRecord>();
  private readonly dedupe = new Set<string>();

  async listByFarm(
    farmId: string,
    filter?: { status?: string; group_id?: string },
  ): Promise<FarmTaskRecord[]> {
    return [...this.tasks.values()].filter((t) => {
      if (t.farm_id !== farmId) return false;
      if (filter?.status && t.status !== filter.status) return false;
      if (filter?.group_id && t.group_id !== filter.group_id) return false;
      return true;
    });
  }

  async getById(id: string): Promise<FarmTaskRecord | null> {
    return this.tasks.get(id) ?? null;
  }

  async createMany(drafts: FarmTaskDraft[]): Promise<FarmTaskRecord[]> {
    const created: FarmTaskRecord[] = [];
    for (const draft of drafts) {
      if (this.dedupe.has(draft.dedupe_key)) continue;
      const record: FarmTaskRecord = {
        id: randomUUID(),
        farm_id: draft.farm_id,
        task_definition_id: draft.task_definition_id,
        title: draft.title,
        description: draft.description,
        task_type: draft.task_type,
        group_id: draft.group_id,
        animal_id: draft.animal_id,
        assigned_to: draft.assigned_to,
        due_date: draft.due_date,
        status: 'PENDING',
        priority: draft.priority,
        created_at: new Date().toISOString(),
        completed_at: null,
        metadata: draft.metadata,
      };
      this.tasks.set(record.id, record);
      this.dedupe.add(draft.dedupe_key);
      created.push(record);
    }
    return created;
  }

  async updateStatus(
    id: string,
    status: string,
    completedAt: string | null = null,
  ): Promise<FarmTaskRecord> {
    const task = this.tasks.get(id);
    if (!task) throw new Error('Task not found');
    const updated = {
      ...task,
      status,
      completed_at: completedAt,
    };
    this.tasks.set(id, updated);
    return updated;
  }

  async listActiveDedupeKeys(farmId: string): Promise<Set<string>> {
    const keys = new Set<string>();
    for (const task of this.tasks.values()) {
      if (task.farm_id !== farmId) continue;
      if (task.status === 'COMPLETE' || task.status === 'DISMISSED') continue;
      const dk = task.metadata.dedupe_key;
      if (typeof dk === 'string') keys.add(dk);
    }
    return keys;
  }
}
