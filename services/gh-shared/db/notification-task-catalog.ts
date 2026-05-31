import type pg from 'pg';
import type { HerdSpecies } from './feed-eligibility.js';

export type NotificationChannel = 'IN_APP' | 'PUSH';
export type NotificationActionBy = 'USER' | 'SYSTEM';
export type NotificationPriority = 'HIGH' | 'MEDIUM' | 'LOW';

export interface NotificationTaskDefinition {
  id: string;
  task_id: number;
  category: string;
  country_code: string | null;
  species: HerdSpecies | 'ALL' | 'SMALL_RUMINANT' | null;
  current_state: string | null;
  source: string | null;
  notification_text: string | null;
  task_name: string;
  notification_text_ar: string | null;
  task_name_ar: string | null;
  expanded_detail: string | null;
  expanded_detail_ar: string | null;
  level: string | null;
  trigger_event: string | null;
  trigger_criteria: string | null;
  due_date_rule: string | null;
  action_by: NotificationActionBy | null;
  priority: NotificationPriority | null;
  frequency: string | null;
  system_action: string | null;
  channels: NotificationChannel[];
  go_live: boolean;
  is_active: boolean;
  default_enabled: boolean;
  notes: string | null;
}

function mapRow(row: Record<string, unknown>): NotificationTaskDefinition {
  const channels = Array.isArray(row.channels)
    ? (row.channels as string[]).filter(
        (c): c is NotificationChannel => c === 'IN_APP' || c === 'PUSH',
      )
    : [];

  return {
    id: String(row.id),
    task_id: Number(row.task_id),
    category: String(row.category ?? 'General'),
    country_code: row.country_code == null ? null : String(row.country_code),
    species: row.species == null ? null : (String(row.species) as NotificationTaskDefinition['species']),
    current_state: row.current_state == null ? null : String(row.current_state),
    source: row.source == null ? null : String(row.source),
    notification_text:
      row.notification_text == null ? null : String(row.notification_text),
    task_name: String(row.task_name),
    notification_text_ar:
      row.notification_text_ar == null ? null : String(row.notification_text_ar),
    task_name_ar: row.task_name_ar == null ? null : String(row.task_name_ar),
    expanded_detail:
      row.expanded_detail == null ? null : String(row.expanded_detail),
    expanded_detail_ar:
      row.expanded_detail_ar == null ? null : String(row.expanded_detail_ar),
    level: row.level == null ? null : String(row.level),
    trigger_event: row.trigger_event == null ? null : String(row.trigger_event),
    trigger_criteria:
      row.trigger_criteria == null ? null : String(row.trigger_criteria),
    due_date_rule: row.due_date_rule == null ? null : String(row.due_date_rule),
    action_by:
      row.action_by == null ? null : (String(row.action_by) as NotificationActionBy),
    priority:
      row.priority == null ? null : (String(row.priority) as NotificationPriority),
    frequency: row.frequency == null ? null : String(row.frequency),
    system_action: row.system_action == null ? null : String(row.system_action),
    channels,
    go_live: Boolean(row.go_live),
    is_active: Boolean(row.is_active),
    default_enabled: Boolean(row.default_enabled),
    notes: row.notes == null ? null : String(row.notes),
  };
}

export class NotificationTaskCatalog {
  private readonly all: NotificationTaskDefinition[];
  private readonly byId = new Map<string, NotificationTaskDefinition>();
  private readonly byTaskId = new Map<number, NotificationTaskDefinition>();

  private constructor(rows: NotificationTaskDefinition[]) {
    this.all = rows;
    for (const row of rows) {
      this.byId.set(row.id, row);
      this.byTaskId.set(row.task_id, row);
    }
  }

  get size(): number {
    return this.all.length;
  }

  list(options: { go_live_only?: boolean; active_only?: boolean } = {}): NotificationTaskDefinition[] {
    return this.all.filter((d) => {
      if (options.active_only !== false && !d.is_active) return false;
      if (options.go_live_only && !d.go_live) return false;
      return true;
    });
  }

  getById(id: string): NotificationTaskDefinition | undefined {
    return this.byId.get(id);
  }

  getByTaskId(taskId: number): NotificationTaskDefinition | undefined {
    return this.byTaskId.get(taskId);
  }

  categories(): string[] {
    return [...new Set(this.list().map((d) => d.category))].sort();
  }

  static fromJson(payload: { definitions: NotificationTaskDefinition[] }): NotificationTaskCatalog {
    return new NotificationTaskCatalog(payload.definitions.map((d) => ({ ...d })));
  }

  static async load(pool: pg.Pool): Promise<NotificationTaskCatalog> {
    const result = await pool.query(
      `SELECT * FROM notification_task_definitions ORDER BY task_id`,
    );
    return new NotificationTaskCatalog(
      result.rows.map((row) => mapRow(row as Record<string, unknown>)),
    );
  }
}
