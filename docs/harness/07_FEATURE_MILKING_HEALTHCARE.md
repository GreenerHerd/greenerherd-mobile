# GREENER HERD — Milking & Healthcare Features
> AI Engineering Harness Memory Artifact · v1.0

---

# MILKING

## Overview
Milk recording applies to females that have given birth. Recording is done at the **group level** for efficiency, with per-animal volumes captured in a single screen.

---

## Milk Stages (Cattle Only)
| Stage | Description |
|---|---|
| EARLY | First 1–3 months post-calving |
| MID | Months 3–7 |
| LATE | Months 7–10 |
| DRY_OFF | Final ~60 days before next calving |

Goats and sheep do not track formal milk stages.

---

## Recording Milk

### Group Milking Entry Screen
- Displays list of all eligible females in group (those that have given birth and are not in DRY_OFF)
- Two columns: **Morning (L)** and **Evening (L)**
- Farmer enters volume per animal per session
- Date pre-filled to today (adjustable)
- Save → creates one `MilkRecord` per animal per session

### Individual Entry
- Can also record from the animal profile Milking tab
- Same morning/evening fields

---

## Milk History

### Per Animal
- Daily volume bar chart (last 30/90 days)
- For Cattle: grouped by milk cycle (calving to dry-off)
  - Cycle summary: total litres, peak day, avg per day
  - Cycle comparison: current vs previous cycle
- Table view: date, morning, evening, total

### Herd/Group Level
- Total daily milk production
- Average per head
- Top 5 milk producers (ranked by 30-day average)

---

## Milk Financials
- Milk price per litre set in Finance module (per species)
- Milk price history tracked (`MilkPrice` table)
- Daily milk value = today's volume × current price
- 3-month milk income shown on Dashboard and Finance summary

---

## Withdrawal Periods
- Milk records for animals with active `HealthRecord` or `VaccinationEvent` are flagged
- System computes `milk_safe_date` automatically
- Milk recorded before `milk_safe_date` is highlighted in orange: *"Withdrawal period active — do not sell"*

---

---

# HEALTHCARE

## Overview
Healthcare covers individual animal treatments and group vaccination events. It integrates with the medical inventory and auto-generates tasks for recurring treatments and boosters.

---

## Health Records (Individual Animal)

### Creating a Health Record
Fields:
| Field | Notes |
|---|---|
| Illness / condition | Free text |
| Treatment notes | Free text |
| Medicine | Select from medical inventory; or add new |
| Dosage | Text (e.g. "5ml IM") |
| Date applied | Date picker |
| Frequency | ONCE / DAILY / WEEKLY / MONTHLY |
| Milk withdrawal (days) | Auto-filled if medicine in reference DB |
| Meat withdrawal (days) | Auto-filled if medicine in reference DB |

On selecting a medicine from inventory:
- Auto-fill: withdrawal periods (if available in reference)
- Auto-fill: purpose / medicine type
- `milk_safe_date` and `meat_safe_date` computed from today + withdrawal days

If medicine not in inventory → prompt: *"Add to Medical Inventory?"* → opens quick-add form.

If frequency is DAILY/WEEKLY/MONTHLY → offer: *"Create recurring task for this treatment?"* → auto-generates Task records.

### Resolved Treatments
- Mark as `resolved = true`
- Animal's `SICK` tag removed (if no other active health records)

### Animal Healthcare History Tab
- Chronological list of all health records
- Filter: active / resolved / all
- Each record shows: illness, medicine, date applied, withdrawal status

---

## Vaccinations (Group Level)

### Vaccination Event Entry
Accessed from group screen → Healthcare tab → "Add Vaccination"

Fields:
| Field | Notes |
|---|---|
| Vaccine name | Select from `VaccineReference` list or free text |
| Batch number | Optional |
| Event date | Date picker |
| Milk withdrawal (days) | Auto-filled from reference if known |
| Meat withdrawal (days) | Auto-filled from reference if known |
| Requires booster? | Yes / No |
| Booster interval (if yes) | 4 / 6 / 8 / 10 / 12 weeks |
| Photo | Optional image upload |
| Notes | Free text |

On Save:
- `VaccinationEvent` created
- If `requires_booster = true` → auto-generate Task:
  - Title: *"Booster: [Vaccine Name]"*
  - Due date: event date + booster_weeks
  - Reminder: 7 days before due date
  - Assigned to: group's primary manager

Linking to Existing Event:
- Option to link a new group vaccination to an existing event from past 48 hours (e.g. two groups vaccinated in same session)

---

## Group Healthcare Summary Screen
Shows:
| Metric | Source |
|---|---|
| Number of sick animals | Animals with active SICK tag |
| Avg milk withdrawal days remaining | Mean across all milk_safe_dates in group |
| Avg meat withdrawal days remaining | Mean across all meat_safe_dates in group |
| Upcoming booster tasks | Next 14 days |
| Overdue vaccinations | Based on vaccination schedule reference |

---

## Vaccination Schedules (Reference Table)
System maintains a reference table of recommended vaccinations by:
- Species
- Life stage / age (newborn, weaning, adult)
- Country (for national programme alignment)

Based on this + `Farm.country` → system auto-generates vaccination reminder tasks for animals/groups whose last vaccination date exceeds the recommended interval.

### Vaccination Status per Animal
Computed flag: `VACCINATED | DUE | OVERDUE | NEVER`
- Used in Reporting (Unvaccinated Animals report)

---

## Medical Inventory Management

### Adding an Item
Fields:
- Name
- Medicine type (from system list or custom)
- Purpose
- Quantity + Unit (KG / LITRE / UNIT)
- Unit cost
- Batch number
- Expiry date (or indicative if unknown)
- Milk withdrawal days
- Meat withdrawal days
- Images (1+)
- Notes

### Tracking
- Quantity decreases when a `HealthRecord` records usage (if connected)
- Expiry alerts: 30 days before expiry date
- Low stock: if quantity falls below minimum (user-defined)

### Medicine Reference Database
System-provided list of common livestock medicines with:
- Withdrawal periods (milk + meat)
- Purpose
- Common dosage guidance

New medicines added by farmers without a reference match → stored with `ai_identified = false` until admin confirms details.
