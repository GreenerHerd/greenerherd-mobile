import type { DomainEventType } from '../db/notification-trigger-registry.js';

export interface DomainEventPayload {
  type: DomainEventType;
  farm_id: string;
  occurred_at?: string;
  group_id?: string;
  animal_id?: string;
  payload?: Record<string, unknown>;
}

/**
 * Fire-and-forget POST to gh-api-tasks `/api/v1/farms/:farmId/events`.
 * No-op when TASKS_API_BASE_URL is unset (BDD / local memory mode).
 */
export async function emitDomainEvent(
  event: DomainEventPayload,
  options?: { bearerToken?: string },
): Promise<void> {
  const base = process.env.TASKS_API_BASE_URL?.replace(/\/$/, '');
  if (!base) return;

  const url = `${base}/api/v1/farms/${event.farm_id}/events`;
  const headers: Record<string, string> = {
    'content-type': 'application/json',
  };
  if (options?.bearerToken) {
    headers.authorization = `Bearer ${options.bearerToken}`;
  }

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        type: event.type,
        farm_id: event.farm_id,
        occurred_at: event.occurred_at ?? new Date().toISOString(),
        group_id: event.group_id,
        animal_id: event.animal_id,
        payload: event.payload,
      }),
    });
    if (!res.ok) {
      const text = await res.text();
      console.warn(
        `[domain-event] ${event.type} failed (${res.status}): ${text.slice(0, 200)}`,
      );
    }
  } catch (err) {
    console.warn(`[domain-event] ${event.type} error:`, err);
  }
}

export async function emitInventoryBelowThreshold(
  farmId: string,
  items: Array<{ id: string; name: string; quantity_kg: number }>,
  options?: { bearerToken?: string },
): Promise<void> {
  for (const item of items) {
    await emitDomainEvent(
      {
        type: 'inventory.below_threshold',
        farm_id: farmId,
        payload: {
          inventory_id: item.id,
          product_name: item.name,
          quantity_kg: item.quantity_kg,
        },
      },
      options,
    );
  }
}
