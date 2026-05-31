# GREENER HERD — Data Models
> AI Engineering Harness Memory Artifact · v1.0

---

## Farm
```
Farm {
  id                  UUID (PK)
  name                String
  owner_user_id       UUID (FK → User)
  country             String              // drives vaccination programmes
  location_lat        Float?              // optional, for weather alerts
  location_lng        Float?
  preferred_currency  String              // ISO 4217 e.g. "AED", "SAR"
  housing_type        Enum [INDOOR_FANS, INDOOR_SHADE, PASTURE]
  created_at          DateTime
}
```

## FarmSpecies
```
FarmSpecies {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  species     Enum [CATTLE, GOAT, SHEEP]
  purpose     Enum [MILK, MEAT, BOTH]
}
```

## User
```
User {
  id              UUID (PK)
  name            String
  email           String (unique)
  phone           String?
  role            Enum [OWNER, MANAGER, FARM_HAND, VET]
  preferred_lang  Enum [EN, AR, UR, FR]
  created_at      DateTime
}
```

## FarmUser  (many-to-many: User ↔ Farm)
```
FarmUser {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  user_id     UUID (FK → User)
  farm_role   Enum [OWNER, MANAGER, FARM_HAND, VET]
  is_active   Boolean
}
```

## AnimalGroup
```
AnimalGroup {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  species     Enum [CATTLE, GOAT, SHEEP]
  name        String
  purpose     Enum [MAINTENANCE, BREEDING, MILK, PREGNANT, SICK, FATTENING]
  notes       String?
  created_at  DateTime
}
```

## GroupUserAccess  (which users can see/manage which groups)
```
GroupUserAccess {
  id          UUID (PK)
  group_id    UUID (FK → AnimalGroup)
  user_id     UUID (FK → User)
  can_manage  Boolean    // true = read+write, false = read-only
}
```

## Animal
```
Animal {
  id                  UUID (PK)
  farm_id             UUID (FK → Farm)
  group_id            UUID? (FK → AnimalGroup)   // current group; nullable if unassigned
  species             Enum [CATTLE, GOAT, SHEEP]
  ear_tag             String?              // unique within farm; optional for ME context
  additional_tag      String?
  name                String?
  sex                 Enum [MALE, FEMALE]
  breed               String
  dob                 Date?
  age_range           Enum [0_3M, 3_6M, 6_12M, 1_2Y, 2_3Y, 3_5Y, 5PLUS_Y]?  // used when DOB unknown
  birth_weight_kg     Float?
  weaning_weight_kg   Float?
  current_weight_kg   Float?
  weight_indicative   Boolean  DEFAULT false   // true if weight is AI-estimated from age range
  height_cm           Float?
  bcs                 Float?               // Body Condition Score
  is_heifer           Boolean?             // cattle females only
  origin              Enum [BORN_ON_FARM, PURCHASED]
  status              Enum [ACTIVE, SOLD, DECEASED, CULLED]
  cull_flagged        Boolean  DEFAULT false
  has_papers          Boolean  DEFAULT false
  sire_id             UUID? (FK → Animal)  // father
  dam_id              UUID? (FK → Animal)  // mother
  sire_breed          String?
  dam_breed           String?
  purchase_price      Decimal?
  purchase_record_id  UUID? (FK → PurchaseRecord)
  notes               String?
  created_at          DateTime
  updated_at          DateTime
}
```

## AnimalTag  (status tags on an animal — multiple allowed)
```
AnimalTag {
  id          UUID (PK)
  animal_id   UUID (FK → Animal)
  tag         Enum [WEANING, READY_TO_BREED, PREGNANT, CULL, MISCARRIAGE, SICK]
  applied_at  DateTime
  removed_at  DateTime?
}
```

## AnimalWeight  (weight history log)
```
AnimalWeight {
  id          UUID (PK)
  animal_id   UUID (FK → Animal)
  weight_kg   Float
  recorded_at DateTime
  recorded_by UUID (FK → User)
  is_estimated Boolean DEFAULT false
}
```

## AnimalMedia  (images, documents per animal)
```
AnimalMedia {
  id          UUID (PK)
  animal_id   UUID (FK → Animal)
  media_type  Enum [IMAGE, DOCUMENT, VOICE_NOTE]
  url         String
  caption     String?
  uploaded_at DateTime
  uploaded_by UUID (FK → User)
}
```

## BreedingEvent
```
BreedingEvent {
  id                  UUID (PK)
  female_animal_id    UUID (FK → Animal)
  method              Enum [NATURAL, AI, EMBRYONIC]
  event_date          Date
  sire_id             UUID? (FK → Animal)   // if natural + recorded
  sire_breed          String?
  ai_provider_name    String?
  ai_straw_details    String?
  ai_attempt_number   Int?
  outcome             Enum [PENDING, CONFIRMED_PREGNANT, FAILED, MISCARRIAGE, BORN]?
  confirmed_date      Date?
  notes               String?
  media_url           String?              // picture of AI record
}
```

## Pregnancy
```
Pregnancy {
  id                    UUID (PK)
  animal_id             UUID (FK → Animal)
  breeding_event_id     UUID? (FK → BreedingEvent)
  months_pregnant_at_entry Int?
  insemination_date     Date?
  expected_due_date     Date?
  actual_birth_date     Date?
  outcome               Enum [ONGOING, BORN, MISCARRIAGE, STILLBIRTH]
  notes                 String?
}
```

## Birth
```
Birth {
  id              UUID (PK)
  mother_id       UUID (FK → Animal)
  sire_id         UUID? (FK → Animal)
  pregnancy_id    UUID? (FK → Pregnancy)
  birth_date      Date
  is_twin         Boolean DEFAULT false
  historical      Boolean DEFAULT false   // entered after the fact
  offspring       UUID[] (FK → Animal[])  // one or two animals born
}
```

## MilkRecord
```
MilkRecord {
  id              UUID (PK)
  animal_id       UUID (FK → Animal)
  group_id        UUID? (FK → AnimalGroup)
  session         Enum [MORNING, EVENING]
  volume_litres   Float
  recorded_date   Date
  recorded_by     UUID (FK → User)
  milk_stage      Enum [EARLY, MID, LATE, DRY_OFF]?  // cattle only
}
```

## MealType  (farmer-defined feed mix)
```
MealType {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  name        String
  description String?
  is_active   Boolean DEFAULT true
  created_at  DateTime
}
```

## MealIngredient
```
MealIngredient {
  id              UUID (PK)
  meal_type_id    UUID (FK → MealType)
  feed_item_id    UUID (FK → FeedInventoryItem)
  amount_kg       Float   // amount per batch
}
```

## GroupFeedingRecord
```
GroupFeedingRecord {
  id              UUID (PK)
  group_id        UUID (FK → AnimalGroup)
  recorded_date   Date
  meal_type_id    UUID? (FK → MealType)
  total_weight_kg Float?
  per_head_kg     Float?
  notes           String?
  recorded_by     UUID (FK → User)
}
```

## HealthRecord
```
HealthRecord {
  id                      UUID (PK)
  animal_id               UUID (FK → Animal)
  illness_description     String
  treatment_notes         String?
  medicine_id             UUID? (FK → MedicalInventoryItem)
  dosage                  String?
  date_applied            Date
  frequency               Enum [ONCE, DAILY, WEEKLY, MONTHLY]?
  milk_withdrawal_days    Int?
  meat_withdrawal_days    Int?
  milk_safe_date          Date?    // computed
  meat_safe_date          Date?    // computed
  recorded_by             UUID (FK → User)
  resolved                Boolean DEFAULT false
}
```

## VaccinationEvent
```
VaccinationEvent {
  id                    UUID (PK)
  group_id              UUID (FK → AnimalGroup)
  vaccine_name          String
  vaccine_id            UUID? (FK → VaccineReference)
  batch_number          String?
  event_date            Date
  milk_withdrawal_days  Int?
  meat_withdrawal_days  Int?
  milk_safe_date        Date?
  meat_safe_date        Date?
  requires_booster      Boolean DEFAULT false
  booster_weeks         Int?    // 4,6,8,10,12
  media_url             String?
  notes                 String?
  recorded_by           UUID (FK → User)
}
```

## VaccineReference  (system table of known vaccines)
```
VaccineReference {
  id                    UUID (PK)
  name                  String
  species               Enum[] [CATTLE, GOAT, SHEEP]
  milk_withdrawal_days  Int?
  meat_withdrawal_days  Int?
  recommended_interval_weeks Int?
  notes                 String?
}
```

## Task
```
Task {
  id              UUID (PK)
  farm_id         UUID (FK → Farm)
  title           String
  description     String?
  voice_note_url  String?
  task_type       Enum [MANUAL, AUTO_BREEDING, AUTO_VACCINATION, AUTO_HEALTH]
  assigned_to     UUID? (FK → User)
  group_id        UUID? (FK → AnimalGroup)
  animal_id       UUID? (FK → Animal)
  due_date        Date?
  due_time        Time?
  recurrence      Enum [NONE, DAILY, WEEKLY, MONTHLY]?
  reminder_notice Enum [SAME_DAY, 1_DAY, 3_DAYS, 7_DAYS]?
  status          Enum [PENDING, IN_PROGRESS, COMPLETE, OVERDUE]
  created_by      UUID (FK → User)
  created_at      DateTime
  completed_at    DateTime?
}
```

## TaskUpdate
```
TaskUpdate {
  id          UUID (PK)
  task_id     UUID (FK → Task)
  author_id   UUID (FK → User)
  note        String?
  voice_url   String?
  image_url   String?
  created_at  DateTime
}
```

## FeedInventoryItem
```
FeedInventoryItem {
  id                UUID (PK)
  farm_id           UUID (FK → Farm)
  name              String
  feed_type         Enum [FODDER, CONCENTRATE, ADDITIVE, CUSTOM]
  feed_category_ref UUID? (FK → FeedReference)   // link to system feed table
  quantity_kg       Float
  unit_cost         Decimal?   // per kg, in farm currency
  expiry_date       Date?
  reorder_threshold_kg Float?
  notes             String?
  last_updated      DateTime
}
```

## FeedReference  (system-provided feed nutritional data)
```
FeedReference {
  id              UUID (PK)
  name            String
  feed_type       Enum [FODDER, CONCENTRATE, ADDITIVE]
  dry_matter_pct  Float?
  crude_protein_pct Float?
  me_mj_per_kg    Float?   // Metabolisable Energy
  ndf_pct         Float?
  max_pct_diet    Float?   // upper limit in ration
  notes           String?
}
```

## FeedPurchase
```
FeedPurchase {
  id              UUID (PK)
  farm_id         UUID (FK → Farm)
  feed_item_id    UUID (FK → FeedInventoryItem)
  quantity_kg     Float
  unit_cost       Decimal
  total_cost      Decimal
  purchase_date   Date
  arrival_date    Date?
  supplier        String?
  notes           String?
}
```

## MedicalInventoryItem
```
MedicalInventoryItem {
  id                    UUID (PK)
  farm_id               UUID (FK → Farm)
  name                  String
  medicine_type         String
  purpose               String?
  quantity              Float
  unit                  Enum [KG, LITRE, UNIT]
  unit_cost             Decimal?
  batch_number          String?
  expiry_date           Date?
  milk_withdrawal_days  Int?
  meat_withdrawal_days  Int?
  image_urls            String[]
  notes                 String?
  last_updated          DateTime
}
```

## MedicalPurchase
```
MedicalPurchase {
  id            UUID (PK)
  farm_id       UUID (FK → Farm)
  medicine_id   UUID (FK → MedicalInventoryItem)
  quantity      Float
  unit_cost     Decimal
  total_cost    Decimal
  purchase_date Date
  supplier      String?
  batch_number  String?
}
```

## PurchaseRecord  (buying animals)
```
PurchaseRecord {
  id              UUID (PK)
  farm_id         UUID (FK → Farm)
  species         Enum [CATTLE, GOAT, SHEEP]
  purchase_date   Date
  supplier_name   String?
  supplier_contact String?
  total_price     Decimal
  animal_count    Int
  avg_price_per_head Decimal?
  document_urls   String[]
  notes           String?
}
```

## SaleRecord  (selling animals)
```
SaleRecord {
  id              UUID (PK)
  farm_id         UUID (FK → Farm)
  sale_date       Date
  buyer_name      String?
  buyer_contact   String?
  total_price     Decimal
  animals         UUID[]  (FK → Animal[])
  notes           String?
}
```

## FinanceEntry
```
FinanceEntry {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  entry_type  Enum [INCOME, EXPENSE]
  category    String   // from dropdown or custom
  amount      Decimal
  entry_date  Date
  description String?
  ref_id      UUID?    // optional link to sale/purchase record
  recorded_by UUID (FK → User)
}
```

## MilkPrice  (historical milk price)
```
MilkPrice {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  species     Enum [CATTLE, GOAT, SHEEP]
  price_per_litre Decimal
  effective_from Date
}
```

## MeatPrice
```
MeatPrice {
  id          UUID (PK)
  farm_id     UUID (FK → Farm)
  species     Enum [CATTLE, GOAT, SHEEP]
  price_per_kg Decimal
  effective_from Date
}
```
