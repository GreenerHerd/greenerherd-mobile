import type { FarmTaskDraft } from '@greenerherd/shared-db/notification-trigger-engine';

export interface FarmTaskRecord {
  id: string;
  farm_id: string;
  task_definition_id: string | null;
  title: string;
  description: string | null;
  task_type: string;
  group_id: string | null;
  animal_id: string | null;
  assigned_to: string | null;
  due_date: string;
  status: string;
  priority: string | null;
  created_at: string;
  completed_at: string | null;
  metadata: Record<string, unknown>;
}

export interface FarmTaskRepository {
  listByFarm(
    farmId: string,
    filter?: { status?: string; group_id?: string },
  ): Promise<FarmTaskRecord[]>;
  getById(id: string): Promise<FarmTaskRecord | null>;
  createMany(drafts: FarmTaskDraft[]): Promise<FarmTaskRecord[]>;
  updateStatus(
    id: string,
    status: string,
    completedAt?: string | null,
  ): Promise<FarmTaskRecord>;
  listActiveDedupeKeys(farmId: string): Promise<Set<string>>;
}
