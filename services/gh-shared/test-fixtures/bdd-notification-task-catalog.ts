import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { NotificationTaskCatalog } from '../db/notification-task-catalog.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const jsonPath = path.join(
  __dirname,
  '../../../assets/data/notification_task_definitions.json',
);

let cached: NotificationTaskCatalog | undefined;

export function loadBddNotificationTaskCatalog(): NotificationTaskCatalog {
  if (!cached) {
    const raw = JSON.parse(readFileSync(jsonPath, 'utf8')) as {
      definitions: Parameters<typeof NotificationTaskCatalog.fromJson>[0]['definitions'];
    };
    cached = NotificationTaskCatalog.fromJson(raw);
  }
  return cached;
}
