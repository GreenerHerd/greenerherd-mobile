// GreenerHerd — mock data store
// Riyadh-based Al-Falah Farm with Cattle, Goats, Sheep

const TODAY = new Date('2026-05-08');

const FARM = {
  name: 'Al-Falah Farm',
  location: 'Riyadh, KSA',
  currency: 'SAR',
  housing: 'INDOOR_FANS',
  owner: 'Yusuf Al-Harbi',
};

const USERS = [
  { id: 'u1', name: 'Yusuf Al-Harbi', role: 'OWNER',    initials: 'YA' },
  { id: 'u2', name: 'Khaled Saleh',   role: 'MANAGER',  initials: 'KS' },
  { id: 'u3', name: 'Ahmad Bilal',    role: 'FARM_HAND',initials: 'AB' },
  { id: 'u4', name: 'Dr. Rashed',     role: 'VET',      initials: 'DR' },
];

const GROUPS = [
  { id: 'g1', name: 'Milking A',      species: 'cattle', purpose: 'MILK',        count: 22, manager: 'u2', desc: 'Lactating Holstein/Jersey cows in 1st–3rd parity. Twice-daily milking, free-stall barn with fans.' },
  { id: 'g2', name: 'Breeding',       species: 'cattle', purpose: 'BREEDING',    count: 8,  manager: 'u2', desc: 'Cycling cows and heifers ready for AI. Heat detection twice daily.' },
  { id: 'g3', name: 'Pregnant',       species: 'cattle', purpose: 'PREGNANT',    count: 6,  manager: 'u2', desc: 'Confirmed pregnant cattle, days 30+. Move to pre-calving 30 days before due.' },
  { id: 'g4', name: 'Calves',         species: 'cattle', purpose: 'MAINTENANCE', count: 6,  manager: 'u3', desc: 'Calves under 12 months, weaning to 12-month transition.' },
  { id: 'g5', name: 'Maintenance B',  species: 'goat',   purpose: 'MAINTENANCE', count: 48, manager: 'u3', desc: 'Mixed-age does and bucks, general maintenance ration.' },
  { id: 'g6', name: 'Pregnant Does',  species: 'goat',   purpose: 'PREGNANT',    count: 22, manager: 'u3', desc: 'Pregnant goats, second half of gestation. Higher-energy ration.' },
  { id: 'g7', name: 'Fattening',      species: 'goat',   purpose: 'FATTENING',   count: 26, manager: 'u3', desc: 'Male kids and culls being finished for slaughter. Target ADG 0.18 kg/d.' },
  { id: 'g8', name: 'Najdi flock',    species: 'sheep',  purpose: 'MAINTENANCE', count: 32, manager: 'u3', desc: 'Mixed-age Najdi flock on maintenance. Open shelter, mineral block free-choice.' },
  { id: 'g9', name: 'Sick bay',       species: 'sheep',  purpose: 'SICK',        count: 14, manager: 'u4', desc: 'Quarantine pen for sheep under treatment. Daily vet check.' },
];

const BREEDS = {
  cattle: ['Holstein', 'Jersey', 'Brown Swiss', 'Hereford', 'Angus', 'Brahman', 'Friesian', 'Crossbreed', 'Other'],
  goat:   ['Aardi', 'Boer', 'Saanen', 'Damascene', 'Nubian', 'Anglo-Nubian', 'Crossbreed', 'Other'],
  sheep:  ['Najdi', 'Awassi', 'Romanov', 'Sawakni', 'Harri', 'Naimi', 'Crossbreed', 'Other'],
};

const PURPOSES = [
  { value: 'MILK',        label: 'Milking' },
  { value: 'BREEDING',    label: 'Breeding' },
  { value: 'PREGNANT',    label: 'Pregnant' },
  { value: 'FATTENING',   label: 'Fattening' },
  { value: 'MAINTENANCE', label: 'Maintenance' },
  { value: 'WEANING',     label: 'Weaning / calves' },
  { value: 'DRY',         label: 'Dry / dry-off' },
  { value: 'SICK',        label: 'Sick bay' },
];

const SPECIES_LABEL = { all: 'All species', cattle: 'Cattle', goat: 'Goats', sheep: 'Sheep' };
const SPECIES_LABEL_SINGULAR = { all: 'All species', cattle: 'Cattle', goat: 'Goat', sheep: 'Sheep' };

// KPI per group, derived from purpose
const GROUP_KPI = {
  MILK:        { label: 'Avg milk',     value: '21.4 L/head', icon: 'milk',    tone: 'primary' },
  BREEDING:    { label: 'Pregnancy',    value: '64%',         icon: 'heart',   tone: 'primary' },
  PREGNANT:    { label: 'Due ≤30d',     value: '3 head',      icon: 'baby',    tone: 'primary' },
  FATTENING:   { label: 'ADG',          value: '0.42 kg/d',   icon: 'weight',  tone: 'info' },
  MAINTENANCE: { label: 'Avg weight',   value: '184 kg',      icon: 'weight',  tone: 'neutral' },
  WEANING:     { label: 'Avg weight',   value: '74 kg',       icon: 'weight',  tone: 'info' },
  DRY:         { label: 'Days dry',     value: '32 d',        icon: 'milk',    tone: 'neutral' },
  SICK:        { label: 'Under tx',     value: '9 head',      icon: 'syringe', tone: 'error' },
};

const ANIMALS = [
  // Cattle
  { id: 'a1', tag: '0421', name: 'Bessie', species: 'cattle', sex: 'F', breed: 'Holstein', wt: 412, age: '4y 2m', dob: '2022-03-14', group: 'g3', tags: ['PREGNANT','LACTATING'], milkToday: 18.4, withdrawal: 3, sire: 'Tornado', dam: 'Faten', heifer: false, bcs: 3.5 },
  { id: 'a2', tag: '0438', name: 'Mona',   species: 'cattle', sex: 'F', breed: 'Holstein', wt: 398, age: '5y 1m', dob: '2021-04-02', group: 'g1', tags: ['LACTATING'], milkToday: 22.1, sire: 'Tornado', dam: 'Hala' },
  { id: 'a3', tag: '0444', name: 'Sara',   species: 'cattle', sex: 'F', breed: 'Jersey',   wt: 344, age: '3y 6m', dob: '2022-11-04', group: 'g1', tags: ['LACTATING'], milkToday: 14.7, withdrawal: 3, sire: 'Felix', dam: 'Layla' },
  { id: 'a4', tag: '0451', name: 'Hala',   species: 'cattle', sex: 'F', breed: 'Holstein', wt: 426, age: '6y 3m', dob: '2020-02-10', group: 'g1', tags: ['LACTATING'], milkToday: 19.8 },
  { id: 'a5', tag: '0462', name: 'Noor',   species: 'cattle', sex: 'F', breed: 'Holstein', wt: 388, age: '3y 1m', dob: '2023-04-01', group: 'g2', tags: ['READY_TO_BREED'], heifer: true },
  { id: 'a6', tag: '0470', name: 'Khulud', species: 'cattle', sex: 'F', breed: 'Jersey',   wt: 360, age: '4y 9m', dob: '2021-08-04', group: 'g3', tags: ['PREGNANT'] },
  { id: 'a7', tag: '0512', name: 'Yara',   species: 'cattle', sex: 'F', breed: 'Holstein', wt: 96,  age: '8m',   dob: '2025-09-02', group: 'g4', tags: ['WEANING'], dam: 'Bessie' },
  { id: 'a8', tag: '0518', name: '—',      species: 'cattle', sex: 'M', breed: 'Holstein', wt: 64,  age: '4m',   dob: '2026-01-12', group: 'g4', tags: ['WEANING'], twin: true },
  { id: 'a9', tag: '0519', name: '—',      species: 'cattle', sex: 'F', breed: 'Holstein', wt: 62,  age: '4m',   dob: '2026-01-12', group: 'g4', tags: ['WEANING'], twin: true },

  // Goats
  { id: 'b1', tag: 'G014', name: 'Layla',  species: 'goat',  sex: 'F', breed: 'Aardi',     wt: 38, age: '2y 0m', dob: '2024-05-04', group: 'g6', tags: ['PREGNANT'] },
  { id: 'b2', tag: 'G027', name: '—',      species: 'goat',  sex: 'F', breed: 'Aardi',     wt: 32, age: '1y 4m', dob: '2025-01-04', group: 'g5', tags: ['READY_TO_BREED'] },
  { id: 'b3', tag: 'G031', name: 'Zahra',  species: 'goat',  sex: 'F', breed: 'Aardi',     wt: 41, age: '3y 1m', dob: '2023-04-08', group: 'g6', tags: ['PREGNANT'] },
  { id: 'b4', tag: 'G046', name: '—',      species: 'goat',  sex: 'M', breed: 'Aardi',     wt: 55, age: '2y 6m', dob: '2023-11-01', group: 'g7', tags: ['FATTENING'] },
  { id: 'b5', tag: 'G055', name: '—',      species: 'goat',  sex: 'M', breed: 'Aardi',     wt: 49, age: '1y 9m', dob: '2024-08-02', group: 'g7', tags: ['FATTENING'] },

  // Sheep
  { id: 'c1', tag: 'S009', name: 'Najma',  species: 'sheep', sex: 'F', breed: 'Najdi',     wt: 54, age: '3y 2m', dob: '2023-03-12', group: 'g9', tags: ['SICK'] },
  { id: 'c2', tag: 'S012', name: '—',      species: 'sheep', sex: 'M', breed: 'Najdi',     wt: 48, age: '2y 8m', dob: '2023-09-04', group: 'g8', tags: ['CULL'] },
  { id: 'c3', tag: 'S017', name: 'Suha',   species: 'sheep', sex: 'F', breed: 'Najdi',     wt: 52, age: '2y 4m', dob: '2024-01-02', group: 'g8', tags: [] },
  { id: 'c4', tag: 'S023', name: '—',      species: 'sheep', sex: 'F', breed: 'Najdi',     wt: 46, age: '1y 6m', dob: '2024-11-04', group: 'g8', tags: [] },
];

const TASKS = [
  { id: 't1', title: 'Check Bessie #0421 calving signs',      sub: 'Auto · birth alert',              type: 'AUTO_BREEDING',    when: 'Now',         due: 'today',     overdue: true,  icon: 'baby',    tone: 'error',   animal: 'a1', assignee: 'u4' },
  { id: 't2', title: 'Booster: FMD · Goats Maintenance B',     sub: 'Auto · 7-day reminder',          type: 'AUTO_VACCINATION', when: 'Today 14:00', due: 'today',                        icon: 'syringe', tone: 'warning', group:  'g5', assignee: 'u3' },
  { id: 't3', title: 'Pregnancy scan · 6 cattle',              sub: 'Auto · 45-day check',            type: 'AUTO_BREEDING',    when: 'Today 16:30', due: 'today',                        icon: 'check',   tone: 'primary', group:  'g2', assignee: 'u4' },
  { id: 't4', title: 'Refill mineral block — Sheep pen 2',     sub: 'Manual',                         type: 'MANUAL',           when: 'Tomorrow',    due: 'week',                         icon: 'list',    tone: 'neutral', group:  'g8', assignee: 'u3' },
  { id: 't5', title: 'Order alfalfa hay (5 t)',                sub: 'Manual · weekly recurring',      type: 'MANUAL',           when: 'Wed 10 May',  due: 'week',                         icon: 'wallet',  tone: 'neutral',                  assignee: 'u1' },
  { id: 't6', title: 'Mona #0438 udder check',                 sub: 'Manual · vet visit',             type: 'MANUAL',           when: 'Thu 11 May',  due: 'week',                         icon: 'heart',   tone: 'neutral', animal: 'a2',  assignee: 'u4' },
  { id: 't7', title: 'Pre-calving move — Khulud #0470',        sub: 'Auto · 30 days before',          type: 'AUTO_BREEDING',    when: 'Sat 13 May',  due: 'week',                         icon: 'arrow',   tone: 'primary', animal: 'a6',  assignee: 'u2' },
  { id: 't8', title: 'Record morning milking',                 sub: 'Manual · daily recurring',       type: 'MANUAL',           when: 'Daily 06:00', due: 'recurring',                    icon: 'milk',    tone: 'neutral', group:  'g1', assignee: 'u3' },
];

const FINANCE = {
  income3mo:   84200,
  expense3mo:  41600,
  net3mo:      42600,
  livestockValue: 412800,
  monthly: [
    { m: 'Mar', inc: 24000, exp: 12200 },
    { m: 'Apr', inc: 28000, exp: 14600 },
    { m: 'May', inc: 32200, exp: 14800 },
  ],
  recent: [
    { id: 'f1', date: '8 May', cat: 'Milk Sale',      type: 'INCOME',  amount: 1240,  desc: 'Daily collection · Tabuk Dairy' },
    { id: 'f2', date: '7 May', cat: 'AI Visits',      type: 'EXPENSE', amount: 480,   desc: 'Dr. Rashed · 2 cows' },
    { id: 'f3', date: '6 May', cat: 'Feed',           type: 'EXPENSE', amount: 3200,  desc: 'Alfalfa hay · 4 t' },
    { id: 'f4', date: '4 May', cat: 'Animal Sale',    type: 'INCOME',  amount: 4400,  desc: '2 lambs · #S031, #S033' },
    { id: 'f5', date: '2 May', cat: 'Milk Sale',      type: 'INCOME',  amount: 8800,  desc: 'Weekly settlement' },
    { id: 'f6', date: '1 May', cat: 'Wages',          type: 'EXPENSE', amount: 5200,  desc: 'Ahmad · April' },
    { id: 'f7', date: '29 Apr',cat: 'Medical',        type: 'EXPENSE', amount: 720,   desc: 'Penicillin G · 6 vials' },
  ],
};

const REPORTS = [
  { id: 'r1', name: 'Successful Births',           desc: 'Births in date range with offspring details',  icon: 'baby',    count: '14 events' },
  { id: 'r2', name: 'Cull Report',                 desc: 'Animals flagged with cull reasons',            icon: 'overdue', count: '5 animals' },
  { id: 'r3', name: 'Animal Sales',                desc: 'Sales with buyer and price',                   icon: 'wallet',  count: '8 sales' },
  { id: 'r4', name: 'Animal Purchases',            desc: 'Purchases with supplier and price',            icon: 'wallet',  count: '12 purchases' },
  { id: 'r5', name: 'Eid Sacrifice Eligibility',   desc: 'Cattle ≥2y · Sheep/Goat ≥1y · healthy',         icon: 'check',   count: '38 eligible' },
  { id: 'r6', name: 'Animal Traceability',         desc: 'Per-animal certificate · health, vaccinations', icon: 'list',    count: 'Per animal' },
  { id: 'r7', name: 'Vaccination History',         desc: 'Last 12 months of vaccinations',                icon: 'syringe', count: '186 events' },
  { id: 'r8', name: 'Unvaccinated / Overdue',      desc: 'Animals past recommended interval',             icon: 'overdue', count: '11 overdue' },
];

window.GH = { TODAY, FARM, USERS, GROUPS, ANIMALS, TASKS, FINANCE, REPORTS, BREEDS, PURPOSES, SPECIES_LABEL, SPECIES_LABEL_SINGULAR, GROUP_KPI };
