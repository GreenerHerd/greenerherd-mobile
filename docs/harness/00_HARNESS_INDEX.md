# GREENER HERD — AI Engineering Harness Index
> Master Index · v1.0

This directory contains the memory artifacts for the Greener Herd AI Engineering Harness. These files are loaded as context by Claude Design and Coding agents during development of the Greener Herd mobile application.

---

## Artifact Index

| File | Contents | Load For |
|---|---|---|
| `01_PROJECT_OVERVIEW.md` | App purpose, users, tech stack, module map, i18n | Every agent session |
| `02_DATA_MODELS.md` | All database entities and field definitions | Backend coding, schema, API |
| `03_ONBOARDING_AND_PEOPLE.md` | Onboarding flow, user roles, auth | Onboarding screens, auth flows |
| `04_ANIMAL_AND_GROUP_MANAGEMENT.md` | Animal profiles, group screens, buying/selling | Animal feature development |
| `05_FEATURE_NUTRITION.md` | Feed requirements, meal types, AI feed recommendation | Nutrition feature |
| `06_FEATURE_BREEDING.md` | AI, natural mating, pregnancy, birth, metrics | Breeding feature |
| `07_FEATURE_MILKING_HEALTHCARE.md` | Milk recording, health records, vaccinations | Milking & Healthcare features |
| `08_TASKS_FINANCE_DASHBOARD_REPORTING.md` | Tasks, voice, finance, dashboard, reports | All remaining features |
| `09_TECHNICAL_ARCHITECTURE.md` | Flutter structure, Node.js API, Claude integration, DB | All coding sessions |

---

## Agent Usage Guidelines

### For Design Agent
- Always load: `01_PROJECT_OVERVIEW.md` + the feature spec for the screen being designed
- Key constraints:
  - RTL support required (Arabic, Urdu)
  - Flutter Material Design 3
  - Green/amber/red traffic-light system for nutrition indicators
  - Multi-species tabs where applicable
  - Farm-branded colour palette (greens, earthy tones)

### For Coding Agent (Flutter)
- Always load: `01_PROJECT_OVERVIEW.md` + `09_TECHNICAL_ARCHITECTURE.md` + relevant feature spec
- Follow Riverpod state management pattern
- Use Drift for local SQLite offline cache
- All strings must use ARB localisation keys — no hardcoded strings

### For Coding Agent (Node.js)
- Always load: `01_PROJECT_OVERVIEW.md` + `09_TECHNICAL_ARCHITECTURE.md` + `02_DATA_MODELS.md` + relevant feature spec
- All routes must be farm-scoped
- Soft deletes only
- Claude API calls through `src/services/aiAgent.ts` wrapper

### For Schema/Migration Agent
- Load: `02_DATA_MODELS.md` + `09_TECHNICAL_ARCHITECTURE.md`
- Generate `node-pg-migrate` compatible migration files
- Include seed data scripts for reference tables

---

## Key Business Rules (Quick Reference)

| Rule | Detail |
|---|---|
| Weight estimate | If no weight recorded, show age-range average marked as *indicative* |
| Nutrition traffic light | ±10% = green, 10–30% = orange, >30% = red |
| AI breeding alert | After 2 failed AI attempts → recommend alternate AI provider |
| Concentrate limit | Max 40% of total DM; Additives max 5% |
| Gestation periods | Cattle 283d, Goat 150d, Sheep 147d |
| Cull flag | Reversible — `cull_flagged` can be set and cleared |
| Vet access | Multi-farm; selects farm on login; read-heavy access |
| Sold/deceased animals | Never deleted; status = SOLD / DECEASED / CULLED |
| All weights | Kilograms only |
| Supported languages | EN, AR (RTL), UR (RTL), FR |
| Pasture management | OUT OF SCOPE — animals are indoors |
| Twins | Tracked for prolificacy metrics; highlighted on mother's profile |
| Miscarriage threshold | ≥2 miscarriages in 12 months → alert on animal profile |
| Vaccination booster | Auto-task created at 4/6/8/10/12 weeks with 7-day reminder |
| Eid report | Cattle ≥2y, Sheep/Goat ≥1y, not ill, not pregnant |
