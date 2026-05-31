import type { FarmTaskRepository, FarmTaskRecord } from '../repositories/farm-task-repository.js';

export class TaskService {
  constructor(private readonly repo: FarmTaskRepository) {}

  listTasks(
    farmId: string,
    filter?: { status?: string; group_id?: string },
  ): Promise<FarmTaskRecord[]> {
    return this.repo.listByFarm(farmId, filter);
  }

  getTask(id: string): Promise<FarmTaskRecord | null> {
    return this.repo.getById(id);
  }

  completeTask(id: string): Promise<FarmTaskRecord> {
    return this.repo.updateStatus(id, 'COMPLETE', new Date().toISOString());
  }

  dismissTask(id: string): Promise<FarmTaskRecord> {
    return this.repo.updateStatus(id, 'DISMISSED', new Date().toISOString());
  }
}
