# GREENER HERD — Nutrition Feature
> AI Engineering Harness Memory Artifact · v1.0

---

## Overview
Nutrition management operates at the **group level**. It computes the aggregate nutritional requirements of all animals in a group and compares against what they are actually being fed.

---

## Nutritional Requirements

### Individual Requirement Lookup
Requirements are derived from a reference table keyed on:
- Species (Cattle / Goat / Sheep)
- Sex (Male / Female)
- Age or age range
- Physiological state modifiers:
  - Pregnant
  - Lactating (post-birth, milking)
  - Ready to breed
  - Fattening (Goat / Sheep only — increases DM intake target)

### Nutritional Parameters Tracked
- Dry Matter (DM) kg/day
- Crude Protein (CP) g/day
- Metabolisable Energy (ME) MJ/day
- NDF (Neutral Detergent Fibre) g/day

### Group Aggregation
- Sum individual requirements across all ACTIVE animals in the group
- Display: total group requirement per day

---

## Feed Recommendation Algorithm

### Inputs
- Group's aggregated nutritional requirements
- Available feed types: `FODDER`, `CONCENTRATE`, `ADDITIVE`
- Feed inventory (optional — can use generic reference feeds)

### Constraints
- Concentrates must not exceed 40% of total DM
- Additives must not exceed 5% of total DM
- Recommended minimum 50% DM from Fodder

### Algorithm Steps
1. Calculate base DM requirement
2. Allocate max concentrate allowance (≤40% DM)
3. Fill remainder with Fodder sources
4. Add Additives within 5% limit if nutritional gaps remain
5. Rank recommended feeds by: (a) inventory availability, (b) cost efficiency, (c) nutritional match
6. Output: recommended kg per feed type per day for the group

### Feed Sources (priority order)
1. **Farm's feed inventory** (existing stock on hand)
2. **Generic product database** (system reference feeds with nutritional values)
3. **Marketplace** (if integrated — placeholder for future)

### Fattening Modifier (Goat / Sheep groups with purpose = FATTENING)
- Increase DM target by 15–20%
- Skew concentrate ratio upward within limits
- Label feed plan as "Fattening Programme"

---

## Meal Types (Farmer-Defined Mixes)

### Meal Type Setup
- Farmer creates a named meal (e.g. "Morning Mix", "Goat Ration A")
- Adds ingredients from feed inventory with kg amounts per batch
- Meal can be set as active/inactive

### Feeding a Group with a Meal
- On group screen → Record Feeding
- Select meal type
- Enter total weight given (kg)
- System computes per-head amount
- Nutrition page updates to show actual vs required based on meal composition

### Meal Management Screen
- List of all farm meal types
- Edit / deactivate / duplicate
- View nutritional breakdown per kg of mix
- Also accessible from Feed Inventory module

---

## Group Nutrition Display

### Indicators per Nutrient
| Deviation from Requirement | Colour | Label |
|---|---|---|
| Within ±10% | 🟢 Green | OK |
| 10%–30% over or under | 🟠 Orange | Warning |
| >30% deviation | 🔴 Red | Action Required |

### Actions Available on Group Nutrition Page
- **"Fix the Gap"** — AI-powered recommendation to adjust current feed to resolve gaps without full change
- **"Full Feed Recommendation"** — AI-powered replacement feed plan
- Both options can draw from: inventory only / generic feeds / all sources (user selects)

### Daily Feed Cost per Head
- Computed from: (total feed kg × unit cost) ÷ animal count
- Displayed on group screen
- Requires feed cost data in inventory; otherwise shows "—"

---

## AI Agent Integration for Feed Identification
When a farmer adds a feed item not in the system reference database:
- Trigger: Feed name entered that doesn't match any `FeedReference`
- Claude API call: prompt with feed name + any details provided
- Response: estimated nutritional values (DM%, CP%, ME, NDF)
- Values stored in `FeedReference` table with `ai_generated = true` flag
- Displayed with disclaimer: *"Nutritional values estimated by AI — verify with supplier"*

---

## Feed Inventory Warnings
- Show alert badge when `FeedInventoryItem.quantity_kg` falls below `reorder_threshold_kg`
- Show expiry warning 14 days before `expiry_date`
- Feed consumption is tracked from `GroupFeedingRecord` entries
- Daily consumption view: sum of all group feeding records for the past 7/30 days
