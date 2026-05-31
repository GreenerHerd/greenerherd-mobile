import type { FarmTaskRecord } from '../repositories/farm-task-repository.js';

export interface PushDispatchRequest {
  user_ids: string[];
  title: string;
  body: string;
  task_id: string;
  farm_id: string;
}

/** Stub FCM dispatcher — logs until Firebase is wired. */
export class PushDispatcher {
  async dispatchForTasks(tasks: FarmTaskRecord[]): Promise<number> {
    let count = 0;
    for (const task of tasks) {
      const userIds = task.metadata.notify_user_ids;
      if (!Array.isArray(userIds) || userIds.length === 0) continue;
      const channels = task.metadata.channels;
      if (Array.isArray(channels) && !channels.includes('PUSH')) continue;

      await this.send({
        user_ids: userIds as string[],
        title: task.title,
        body: task.description ?? 'New farm task',
        task_id: task.id,
        farm_id: task.farm_id,
      });
      count += 1;
    }
    return count;
  }

  async send(req: PushDispatchRequest): Promise<void> {
    console.log(
      `[push] farm=${req.farm_id} users=${req.user_ids.join(',')} title=${req.title}`,
    );
  }
}
