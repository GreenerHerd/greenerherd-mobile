# GREENER HERD — Animal & Group Management
> AI Engineering Harness Memory Artifact · v1.0

---

## Individual Animal Profile

### Fields Displayed
| Field | Notes |
|---|---|
| Species | Cattle / Goat / Sheep |
| Ear tag | Optional; unique within farm |
| Additional tag | Secondary identifier |
| Name | Optional |
| Sex | Male / Female |
| Breed | Text |
| Date of birth | Optional |
| Age range | Used if DOB unknown |
| Status | ACTIVE / SOLD / DECEASED / CULLED |
| Cull flagged | Boolean; can be toggled on/off |
| Origin | Born on farm / Purchased |
| Weight (current) | With indicative flag if estimated |
| Weight (born) | Optional |
| Weight (weaning) | Optional |
| Height (cm) | Optional |
| BCS | Body Condition Score, numeric |
| Is Heifer | Cattle females only |
| Has papers | Boolean |
| Parent: Sire | Name/tag + breed |
| Parent: Dam | Name/tag + breed |
| Group | Current group assignment |
| Notes | Free text |
| Media | Images, documents |
| Status Tags | Weaning, Ready to Breed, Pregnant, Cull, Miscarriage, Sick |

### Weight Logic
- If `current_weight_kg` is null → system provides an age-range-based average weight
- Display shows weight value with label: *"Indicative — based on age range"*
- `weight_indicative = true` in this case

### Animal Status Tags
Tags are independent of `status` field. Multiple tags allowed simultaneously.
- `WEANING` — young animal still on mother's milk
- `READY_TO_BREED` — female at breeding age / season
- `PREGNANT` — active pregnancy
- `CULL` — flagged for culling (reversible)
- `MISCARRIAGE` — recent pregnancy loss
- `SICK` — under health observation

### Parents
- If born on farm and breeding module has records → auto-populate from BreedingEvent / Birth records
- Otherwise manually entered (sire/dam name+tag + breed)
- Tapping parent navigates to that animal's profile (if on same farm)

### Children (Females)
- Scrollable list of Birth records where `mother_id = this animal`
- Highlights twins
- Each child is a tappable link to animal profile

### Animal History Tabs
Each animal profile has tabs:
- **Overview** — core details above
- **Weight History** — chart + log
- **Breeding** (females) — AI events, pregnancies, births, miscarriages
- **Milking** (females post-birth) — daily volume, cycle stages
- **Healthcare** — treatments, vaccinations
- **Tasks** — tasks linked to this animal

### Sold / Deceased / Culled Animals
- Remain in the database and searchable
- Shown with a status badge
- Removed from active group counts
- Can be included in reports (e.g. traceability certificate)

---

## Group Management

### Group Record Fields
| Field | Value |
|---|---|
| Name | User-defined |
| Species | Single species per group |
| Purpose | MAINTENANCE / BREEDING / MILK / PREGNANT / SICK / FATTENING |
| Animal count | Computed |
| Notes | Free text |

### Moving Animals Between Groups
- From animal profile → "Change Group" action
- From group screen → drag-and-drop or bulk-select + move
- Move is logged with timestamp and user

### Group Summary Screen Sections

#### Demographics Bar
- Count by sex, age range, status tags

#### Nutrition Summary
- Required nutrition vs actual (green/orange/red indicators — see Nutrition spec)
- Daily feed cost per head
- Over/under feed warnings

#### Milking Summary
- Daily milk volume total (if milk group)
- Average per head

#### Healthcare Summary
- Number of sick animals
- Average milk withdrawal days remaining
- Average meat withdrawal days remaining

#### Breeding Summary
- Number pregnant
- Number ready to breed
- AI events in last 30 days

#### Tasks Strip
- Tasks due in next 7 days for this group

### Group Purpose — Logic Impact
| Purpose | Special Behaviour |
|---|---|
| FATTENING | Animals receive intensified feed plan (Goat/Sheep only) |
| PREGNANT | Breeding tab prominent; due dates visible |
| SICK | Healthcare tab prominent; isolation flag shown |
| MILK | Milking tab prominent; milk cycle stage tracked |
| BREEDING | Breeding status flags shown |
| MAINTENANCE | Standard view |

---

## Buying Animals

### Purchase Flow
1. Select species
2. Enter animal details (repeating for each):
   - Tag number (optional)
   - Sex
   - Breed
   - Age / age range
   - Weight (optional)
3. Enter purchase details:
   - Supplier name
   - Supplier contact
   - Purchase date
   - Total price (system calculates avg per head)
   - Upload purchase documents (optional)
4. Assign to group(s):
   - "Add all to one group" or "Split across groups"
   - Can add to existing group or create new one

### Records Created
- One `PurchaseRecord`
- One `Animal` per animal with `origin = PURCHASED`, `purchase_price` set
- `FinanceEntry` of type `EXPENSE` with category `ANIMAL_PURCHASE` auto-created

---

## Selling Animals

### Sale Flow
1. Select species
2. Search / browse animal list (filter by tag, name, breed)
3. Multi-select animals for sale
4. Review list — confirm details
5. Enter sale details:
   - Buyer name + contact
   - Sale date
   - Total price
6. Confirm → animals set to `status = SOLD`, removed from groups

### Records Created
- One `SaleRecord`
- Each sold animal: `status = SOLD`, `group_id = null`
- `FinanceEntry` of type `INCOME` with category `ANIMAL_SALE` auto-created

---

## Culling
- Admin can flag animal as `cull_flagged = true` — reversible
- Animal gets `CULL` status tag
- Cull Report aggregates all flagged animals (see Reporting spec)
- When animal is actually culled, status set to `CULLED`
