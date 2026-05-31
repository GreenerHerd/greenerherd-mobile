# GREENER HERD — Tasks, Finance, Dashboard & Reporting
> AI Engineering Harness Memory Artifact · v1.0

---

# TASK MANAGEMENT

## Task Types
| Type | Created By |
|---|---|
| MANUAL | Admin/Owner creates manually |
| AUTO_BREEDING | System — from breeding events and due dates |
| AUTO_VACCINATION | System — from vaccination boosters and schedule |
| AUTO_HEALTH | System — from recurring health treatments |

---

## Creating a Manual Task
Fields:
- Title
- Description (text)
- Assigned to (user picker)
- Related group (optional)
- Related animal (optional)
- Due date
- Due time (optional)
- Recurrence: NONE / DAILY / WEEKLY / MONTHLY
- Reminder notice: SAME_DAY / 1_DAY / 3_DAYS / 7_DAYS

---

## Task Updates
Any user assigned to or creator of a task can add:
- Text note
- Voice note (audio recording uploaded to storage)
- Image / photo

Admins can see all updates and play all voice notes from the task detail screen.

---

## Task States
`PENDING → IN_PROGRESS → COMPLETE`
Also computed: `OVERDUE` (past due date, not complete)

Completed tasks removed from active task list.
Visible in **History** section (filterable by date, type, assignee).

---

## Voice Feature
- Task descriptions can be played back as synthesised voice (TTS)
- Supported languages: EN, AR, UR, FR
- Voice notes recorded by users stored as audio files in object storage
- Playback available in task detail screen

---

## Push Notifications
- FCM push at reminder notice time
- Format: "[Task Title] is due in [X days]"
- Tapping notification opens task detail

---

---

# FINANCE

## Milk & Meat Prices
- Set per species in Finance settings
- Historical prices stored (`MilkPrice`, `MeatPrice` tables)
- Used for: livestock value computation, milk revenue tracking

## Income Entry
Manual income entries:
| Field | Notes |
|---|---|
| Category | Dropdown: Animal Sale, Milk Sale, Other (+ custom) |
| Amount | Decimal |
| Date | Date picker |
| Description | Free text |

Animal sale and purchase records auto-generate finance entries.

## Expense Entry
Manual expense entries:
| Field | Notes |
|---|---|
| Category | Dropdown: Wages, Feed, Medical, Vet, AI Visits, Equipment, Fuel, Electricity, Rent, Other (+ custom) |
| Amount | Decimal |
| Date | Date picker |
| Description | Free text |

## Finance Summary Screen
- **Income vs Outgoings**: 3-month rolling bar chart (month-by-month)
- **Current period**: income total, expense total, net
- **Asset Value**:
  - Livestock value = (count × avg live weight × meat price) per species
  - Plus: milk output value for past 3 months
- **Animal Transactions**: list of sale/purchase records with links

---

---

# DASHBOARD

## Overview Dashboard
Displayed on app home. Refreshes on each open.

### Farm-Level Sections

#### Species Breakdown
- Animal count per species (if multiple species → overview + per-species tabs)
- Demographics: sex ratio, age range distribution

#### Status Summary Counts
| Metric | Source |
|---|---|
| Pregnant | Animals with PREGNANT tag |
| Ready to breed | Animals with READY_TO_BREED tag |
| Flagged for cull | Animals with CULL tag |
| Sick | Animals with SICK tag |
| Weaning | Animals with WEANING tag |

#### Upcoming Births
- Animals due to give birth in next **14 days** (from Pregnancy due dates)
- Count + tappable list

#### Tasks Due
- Number of tasks due in next **7 days**
- Breakdown: manual vs auto-generated
- Tappable → opens filtered task list

#### Upcoming Critical Events (next 7 days)
- Vaccination boosters due
- Pregnancy tests due
- AI visits scheduled
- Shown as alert-style cards

#### Feed Cost
- Average daily feed cost per head across herd (if feed cost data available)
- Per-species breakdown if multiple species

#### Finance (if finance data entered)
- 3-month income vs cost trend (mini chart)
- Current month net

#### Livestock Value (if prices set)
- Estimated value of current herd
- Based on meat price × live weight + 3-month milk revenue

---

---

# REPORTING

Reports are generated as PDF documents (downloadable, shareable).

## Available Reports

### 1. Successful Births Report
- Animals that successfully gave birth in selected date range
- Includes: mother, sire, offspring count, birth date, weight

### 2. Cull Report
- Animals flagged with any of: low milk yield, recurring medical issues, confirmed infertile, above-average miscarriages
- Each animal listed with: tag, breed, age, reason(s) for cull flag

### 3. Animal Sales Report
- List of sold animals in date range
- Includes: tag, breed, sale date, buyer, price

### 4. Animal Purchases Report
- List of purchased animals in date range
- Includes: tag, breed, purchase date, supplier, price

### 5. Eid Sacrifice Eligibility Report
- Animals that meet criteria (species, sex, age, health) for Eid sacrifice
- Based on Islamic rules: age minimums (Cattle ≥2y, Sheep/Goat ≥1y), no illness, not pregnant

### 6. Animal Traceability Certificate
- Per-animal certificate similar to EU traceability documents
- Includes: animal details, origin, all health treatments, all vaccinations, withdrawal clearance dates
- Suitable for export or veterinary documentation

### 7. Vaccination History Report
- All animals vaccinated + vaccine + date over past 12 months
- Grouped by: vaccine name, species, group

### 8. Unvaccinated / Overdue Animals Report
- Animals with no vaccination record for required vaccines
- Animals past recommended re-vaccination interval
- Grouped by species and vaccine

---

## Report Generation
- Date range selectable for all date-range reports
- Species filter where applicable
- Output format: PDF
- Reports use farm logo (if uploaded) and farm name in header
- Reports available in English only in v1.0 (multi-language report generation is a future enhancement)
