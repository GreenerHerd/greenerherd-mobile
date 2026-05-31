# GREENER HERD — Onboarding & People Management
> AI Engineering Harness Memory Artifact · v1.0

---

## Onboarding Flow

### Step 1 — Farm Profile Setup
Collect:
- Farm name
- Country (dropdown, drives vaccination programmes)
- Housing type: `INDOOR_FANS | INDOOR_SHADE | PASTURE`
- Location (lat/lng) — optional, used for weather alerts
- Preferred currency (ISO 4217 dropdown)
- Preferred language: EN / AR / UR / FR

### Step 2 — Species Setup
For each species the farmer has (Cattle / Goats / Sheep):
- Add species
- Select purpose: `MILK | MEAT | BOTH`
- Can add multiple species

### Step 3 — Animal Entry Choice
Present two paths:
- **A: Enter animals individually**
- **B: Enter animals as a group**
- **C: Skip for now** (can be done later)

---

### Path A — Individual Animal Entry
Collect per animal in a stepped form:
1. Species
2. Tag number (optional note: "You can add this later")
3. Breed
4. Sex: Male / Female
5. Age OR age range (if exact age unknown)
6. Weight (optional)
7. Status flags (multi-select):
   - Pregnant → prompt: "How many months pregnant?"
   - Ready to breed
   - Sick → pop-up: "Brief description of illness"

After saving each animal:
- Ask: **"Add to a group?"**
  - If yes and no groups exist → prompt to create group first
  - If yes and groups exist → show group picker
- Ask: **"Add another animal?"**

---

### Path B — Group Entry
Collect:
1. Species
2. Breed
3. Sex
4. Age range (0–3m, 3–6m, 6–12m, 1–2y, 2–3y, 3–5y, 5y+)
5. Number of animals in group
6. Group name
7. Group purpose: `MAINTENANCE | BREEDING | MILK | PREGNANT | SICK | FATTENING`

System generates a **draft animal list** (numbered placeholders e.g. "Goat #1 … Goat #12")

Farmer can then:
- Edit individual placeholder: add tag, name, weight
- Mark individual animals with flags:
  - Pregnant → ask months pregnant
  - Ready to breed
  - Sick → brief illness description
  - To be culled
  - Weaning

On save → group is created and all draft animals become Animal records.

---

## People Management

### User Roles
| Role | Permissions |
|---|---|
| OWNER | Full admin; can add/remove all users; sees all modules |
| MANAGER | Admin; can add FARM_HAND and VET users; sees all modules |
| FARM_HAND | Standard; sees own tasks and assigned groups only |
| VET | Read-heavy; sees Nutrition, Breeding, Healthcare, Milking across assigned farms |

### Inviting Users
- Admin/Owner navigates to **People → Invite User**
- Enters name, email/phone, role
- System sends invite link
- On first login user sets language preference and password

### Group Access Control
- Admin can assign specific users to specific AnimalGroups
- Assignment has `can_manage` flag (true = read+write; false = read-only)
- FARM_HAND users only see groups assigned to them

### Vet Multi-Farm Access
- A vet user can be linked to multiple farms via `FarmUser` records
- On login, vet sees a **Farm Selector** screen
- After selecting a farm, vet can view: Nutrition, Breeding, Healthcare, Milking
- Vet cannot create tasks, modify animals, or access Finance/Reporting

### People Screen (Admin View)
Displays:
- List of all users on the farm
- Role badge
- Last active date
- Group assignments
- Actions: Edit role, Remove from farm, Reassign groups

---

## Authentication Notes
- JWT-based auth with refresh tokens
- Session scoped to `farm_id` for vet multi-farm flow
- Password reset via email or SMS OTP
- Admin can deactivate a user account (does not delete historical records)
