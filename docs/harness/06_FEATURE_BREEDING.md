# GREENER HERD — Breeding Feature
> AI Engineering Harness Memory Artifact · v1.0

---

## Overview
The breeding module tracks reproductive events for female animals across all species, including natural mating, Artificial Insemination (AI), and embryonic transfer. It auto-generates tasks and alerts based on breeding timelines.

---

## Farm Breeding Preferences
Set at **species level** during farm setup or in Settings:
- Preferred breeding method per species: `NATURAL | AI | EMBRYONIC`
- Note: AI is predominantly used for Cattle in the Middle East context

---

## Female Reproductive Tracking

### Key Female Attributes (on Animal record)
- `is_heifer` — Boolean, Cattle only (first-calf female)
- Menstrual cycle tracking (onset / interval — recorded manually or derived from events)
- Min age at breeding (species defaults; can be overridden per animal)

### Status Tags Relevant to Breeding
- `READY_TO_BREED` — female in season / at breeding age
- `PREGNANT` — active pregnancy confirmed
- `MISCARRIAGE` — pregnancy loss event

---

## Breeding Event Recording

### Natural Mating
Fields:
- Female animal (selected)
- Sire — linked animal on farm or free-text name + breed
- Event date
- Notes

### Artificial Insemination (AI)
Fields:
- Female animal
- AI provider / person name
- Sire breed
- Straw details (batch / breed)
- Straw image upload
- Attempt number (auto-incremented per female per cycle)
- Event date

#### AI Rules
- After **2 failed AI attempts** on the same female in one cycle → system alert: *"Consider finding an alternative AI provider"*
- AI success tracked at group level: `(confirmed pregnancies) / (total AI attempts)` → shown on breeding group summary
- If group success rate falls below 50% → recommend farmer reviews AI provider
- AI cost tracked via Finance entries (category: `AI_VISIT`); system can compute average cost per successful pregnancy

### Embryonic Transfer
Fields:
- Female (recipient)
- Donor details (free text)
- Embryo details
- Transfer date
- Notes

---

## Pregnancy Management

### Creating a Pregnancy Record
Triggered when:
- Female is tagged `PREGNANT`

Collect:
- How many months pregnant? (if insemination date unknown)
- If insemination date is recorded → expected due date auto-calculated
- Species gestation defaults (used for due date calc):
  - Cattle: 283 days (~9.5 months)
  - Goats: 150 days (~5 months)
  - Sheep: 147 days (~5 months)

### Pregnancy Checks
- System creates recurring tasks to prompt regular pregnancy checks
- Frequency: monthly (configurable)
- Vet can view and annotate check outcomes

### Miscarriage Recording
- Mark pregnancy as `MISCARRIAGE`
- Pop-up: "Does this animal require medical treatment?" → if yes, creates a HealthRecord prompt
- Frequent miscarriages tracked per female: threshold ≥2 in 12 months → alert on animal profile and cull report

---

## Auto-Generated Breeding Tasks

### Natural Mating Events
| Days from Event | Task |
|---|---|
| Day 21 | Check if female returned to heat (cycle check) |
| Day 45 | Pregnancy confirmation check |
| 30 days before due date | Move to PREGNANT group (recommendation) |
| 7 days before due date | Prepare birthing area |
| Due date | Birth check alert |

### AI Events (more granular)
| Days from AI | Task |
|---|---|
| Day 0 | AI completed — record straw details |
| Day 14–18 | Heat detection / conception check |
| Day 21 | Cycle check — did female return to heat? |
| Day 45 | Pregnancy scan/confirmation |
| Day 60 | Nutrition adjustment for pregnancy |
| 30 days before due | Transition to pre-calving nutrition |
| 7 days before due | Prepare facilities |
| Due date | Birth alert |

---

## Birth Recording

### Birth Entry Screen
- Accessed from list of **pregnant females** filtered by species, sorted by nearest due date
- Fields:
  - Mother (pre-filled from due date list)
  - Birth date
  - Number of offspring (1 or 2 — twins)
  - For each offspring: Sex, Weight (optional), Ear tag (optional)
  - Is twin? (auto-set if 2 offspring)
  - Sire (if known)
  - Notes

### On Save
- New `Animal` records created with `origin = BORN_ON_FARM`, `status = ACTIVE`
- `WEANING` tag automatically applied to newborn
- `Birth` record created
- Mother's `PREGNANT` tag removed
- Newborn added to mother's children list
- System prompts: "Add newborn to a group?"

### Twins
- Twins flagged on both Birth record and individual Animal records
- Shown on mother's children list with twin indicator
- Tracked for herd prolificacy metrics

### Historical Birth Entry
- Accessed via "Add Historical Birth" option
- Fields: birth date, sex, breed, twin (Y/N), mother (searchable), sire (optional)
- Once saved → prompt to assign to existing group or create new group

---

## Breeding Metrics (Group & Herd Level)

### Per Group
- Total AI attempts
- Confirmed pregnancies
- Success rate %
- Miscarriages count
- Avg days between AI and confirmation
- AI provider performance (success per provider)

### Per Female (on animal profile — Breeding tab)
- Lifetime AI events list
- Lifetime pregnancies
- Children list (tappable)
- Miscarriage count
- Twin births

### Herd-Level Mortality Rate
- Animals born on farm that died under 12 months → mortality rate %
- Displayed on Dashboard and Breeding summary
- Alert threshold: >10% (configurable)

---

## Breeding Group Recommendation
- When a female is flagged `READY_TO_BREED` or a breeding event is created → system suggests: *"Consider moving this animal to a Breeding group"*
- Admin can accept → animal moved to a group with purpose = BREEDING
