/**
 * Maps free-text `trigger_event` strings from the catalogue to canonical keys
 * the scheduler / domain-event router can evaluate.
 */
export type TriggerKey =
  | 'ACCEPT_PRODUCT'
  | 'CHANGE_IN_BREEDING'
  | 'CHANGE_IN_LACTATION'
  | 'GROUP_SIZE_CHANGED'
  | 'LOW_INVENTORY'
  | 'ANIMAL_MARKED_ILL'
  | 'MISCARRIAGE'
  | 'PREGNANT'
  | 'BIRTH'
  | 'READY_TO_BREED'
  | 'MOVED_TO_READY_TO_BREED'
  | 'FIRST_HEAT_CHECK'
  | 'WEATHER_TEMP_SWING'
  | 'WEATHER_COLD_NIGHT'
  | 'WEATHER_HEAT'
  | 'WEATHER_WIND'
  | 'WEATHER_RAIN'
  | 'WEATHER_SNOW'
  | 'WEATHER_DUST'
  | 'WEATHER_SEVERE'
  | 'SCHEDULED_CAMPAIGN'
  | 'RELATIVE_AFTER_ANCHOR'
  | 'UNKNOWN';

const RULES: Array<{ key: TriggerKey; patterns: RegExp[] }> = [
  { key: 'ACCEPT_PRODUCT', patterns: [/accept product/i] },
  { key: 'CHANGE_IN_BREEDING', patterns: [/change in breeding/i] },
  { key: 'CHANGE_IN_LACTATION', patterns: [/change in lactation/i, /lacation/i] },
  { key: 'GROUP_SIZE_CHANGED', patterns: [/group size changed/i] },
  { key: 'LOW_INVENTORY', patterns: [/low inventory/i] },
  { key: 'ANIMAL_MARKED_ILL', patterns: [/animal marked ill/i, /marked ill/i] },
  { key: 'MISCARRIAGE', patterns: [/miscarriage/i] },
  { key: 'PREGNANT', patterns: [/^pregnant$/i] },
  { key: 'BIRTH', patterns: [/^birth$/i] },
  {
    key: 'MOVED_TO_READY_TO_BREED',
    patterns: [/moved to ready to breed/i],
  },
  {
    key: 'READY_TO_BREED',
    patterns: [/ready to breed/i, /ready for breeding/i],
  },
  {
    key: 'FIRST_HEAT_CHECK',
    patterns: [/first heat/i, /8 weeks after last lambing/i],
  },
  {
    key: 'WEATHER_TEMP_SWING',
    patterns: [/temperature fluctuations/i, /15°c within a 24-hour/i],
  },
  {
    key: 'WEATHER_COLD_NIGHT',
    patterns: [/overnight temperatures below 0/i, /min temp\s*<\s*-5/i, /tomorrow min temp/i],
  },
  {
    key: 'WEATHER_HEAT',
    patterns: [/max temp\s*>\s*40/i, /tomorrow max temp/i],
  },
  {
    key: 'WEATHER_WIND',
    patterns: [/sustained winds above 40/i, /gusts exceeding 60/i],
  },
  {
    key: 'WEATHER_RAIN',
    patterns: [/rainfall exceeding 50 mm/i, /continuous rain over 3 days/i],
  },
  {
    key: 'WEATHER_SNOW',
    patterns: [/snow accumulation exceeding 10 cm/i, /freezing rain/i],
  },
  {
    key: 'WEATHER_DUST',
    patterns: [/particulate matter reducing visibility/i],
  },
  {
    key: 'WEATHER_SEVERE',
    patterns: [/severe weather warnings/i, /lightning strikes/i],
  },
  {
    key: 'SCHEDULED_CAMPAIGN',
    patterns: [
      /send march\/april/i,
      /october,novemeber/i,
      /mar,apr, may/i,
      /feb,mar,april/i,
    ],
  },
  {
    key: 'RELATIVE_AFTER_ANCHOR',
    patterns: [
      /\d+\s*(day|days|week|weeks|hour|hours)\s+after/i,
      /\d+\s*(day|days|week|weeks)\s+before/i,
      /weeks after set as ready/i,
      /days after birth/i,
      /before the estmimated due date/i,
      /before due date/i,
    ],
  },
];

export function resolveTriggerKey(triggerEvent: string | null | undefined): TriggerKey {
  if (!triggerEvent?.trim()) return 'UNKNOWN';
  const text = triggerEvent.trim();
  for (const rule of RULES) {
    if (rule.patterns.some((p) => p.test(text))) return rule.key;
  }
  return 'UNKNOWN';
}

/** Domain events the API can emit to fire immediate triggers. */
export const DOMAIN_EVENT_TYPES = [
  'nutrition.product_accepted',
  'breeding.stage_changed',
  'lactation.stage_changed',
  'group.head_count_changed',
  'inventory.below_threshold',
  'animal.tag_added',
  'animal.miscarriage',
  'animal.birth',
  'animal.marked_ill',
  'animal.ready_to_breed',
  'task.acknowledged',
  'weather.alert',
  'scheduler.tick',
] as const;

export type DomainEventType = (typeof DOMAIN_EVENT_TYPES)[number];

const EVENT_TO_TRIGGERS: Record<DomainEventType, TriggerKey[]> = {
  'nutrition.product_accepted': ['ACCEPT_PRODUCT'],
  'breeding.stage_changed': ['CHANGE_IN_BREEDING', 'MOVED_TO_READY_TO_BREED', 'READY_TO_BREED'],
  'lactation.stage_changed': ['CHANGE_IN_LACTATION'],
  'group.head_count_changed': ['GROUP_SIZE_CHANGED'],
  'inventory.below_threshold': ['LOW_INVENTORY'],
  'animal.tag_added': ['PREGNANT', 'READY_TO_BREED', 'ANIMAL_MARKED_ILL'],
  'animal.miscarriage': ['MISCARRIAGE'],
  'animal.birth': ['BIRTH'],
  'animal.marked_ill': ['ANIMAL_MARKED_ILL'],
  'animal.ready_to_breed': ['MOVED_TO_READY_TO_BREED', 'READY_TO_BREED'],
  'task.acknowledged': ['RELATIVE_AFTER_ANCHOR'],
  'weather.alert': [
    'WEATHER_TEMP_SWING',
    'WEATHER_COLD_NIGHT',
    'WEATHER_HEAT',
    'WEATHER_WIND',
    'WEATHER_RAIN',
    'WEATHER_SNOW',
    'WEATHER_DUST',
    'WEATHER_SEVERE',
  ],
  'scheduler.tick': [
    'LOW_INVENTORY',
    'FIRST_HEAT_CHECK',
    'SCHEDULED_CAMPAIGN',
    'RELATIVE_AFTER_ANCHOR',
    'PREGNANT',
    'BIRTH',
  ],
};

export function triggerKeysForDomainEvent(type: DomainEventType): TriggerKey[] {
  return EVENT_TO_TRIGGERS[type] ?? [];
}
