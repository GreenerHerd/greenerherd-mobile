# Handoff: GreenerHerd — Livestock Management App (iOS)

## Overview

GreenerHerd is a livestock management application for small-to-mid-size mixed-species farms (cattle, goats, sheep). The design covers the full app: dashboard, animals/groups management, individual animal profiles, tasks, finance, reports, feed recommendations, inventory, and supporting settings/help screens.

The prototype is built around a fictional Saudi farm ("Al-Falah Farm" in Riyadh) with multilingual support in scope (EN, AR, UR, FR — RTL handled), and SAR currency throughout.

## About the Design Files

The files in this bundle are **design references created in HTML/React/JSX** — interactive prototypes showing intended look, layout, navigation, and behavior. They are **not production code to copy directly**.

The task is to **recreate these designs in the target codebase's existing environment** (e.g. React Native, SwiftUI, Flutter, native iOS) using its established patterns, navigation, and component libraries. If no environment exists yet, pick the most appropriate framework for a livestock-focused mobile app (React Native or SwiftUI recommended for iOS-first).

The prototype is mounted inside a simulated iOS device frame (402×874pt) — production should use the platform's standard safe areas, status bar, and home indicator.

## Fidelity

**High-fidelity (hifi)**. Final colors, typography, spacing, iconography, layout, and interactions are all pinned. The developer should reproduce screens pixel-perfectly within the codebase's design language. Where the target codebase already has a design system, prefer its primitives and apply the GreenerHerd tokens (colors, type) on top.

## Tech Used in the Prototype (for reference only)

- React 18 + Babel standalone (in-browser JSX, no build step)
- Inline styles only — no CSS modules or styled-components in the prototype
- `localStorage` for persistence (animal photos, prices, profile pics)
- All data is mocked in `src/data.js`

Production should use proper state management, a real backend, real auth, real image upload, etc.

---

## Design Tokens

### Colors

**Brand**
- Primary green:        `#3B5A2A`  (deep forest — CTAs, primary buttons, accents)
- Primary hover:        `#2F4822`  (button hover/press)
- Primary light:        `#ABCF98`  (chips, selection fills, soft backgrounds)
- Secondary blue:       `#1A107A`  (data series, links)
- Secondary light:      `#877BEE`  (secondary buttons, info tags)

**Surfaces**
- Surface (cards):      `#FFFFFF`
- Page background:      `#E8EFDD`  (soft sage — note: lighter than `tokens.css` default `#F6F6F6`, applied in `src/Primitives.jsx` as `GH_GREY_BG`)
- Outer frame bg:       `#D9E4C8`  (sage surround behind device)
- Border / divider:     `#E6E6E6`

**Text**
- Primary text:         `#111111`
- Secondary text:       `#525252`  (muted)
- Faint / placeholder:  `#A3A3A3`

**Status**
- Success:              `#16A34A`  /  light `#BBF7D0`
- Warning:              `#D97706`  /  light `#FDE68A`
- Error:                `#DC2626`  /  light `#FECACA`

**Green scale (data viz)** — `#D2E5C7` (00) → `#3B5A2A` (50, brand) → `#0C1208` (90)
**Blue scale (primary data series)** — `#F2F6FE` (05) → `#80A5F9` (50) → `#041A4E` (100)
**Pink/Purple scale (secondary data series)** — `#FDEFFD` (05) → `#E85DEA` (50) → `#441645` (90)

Full ramps in `styles/tokens.css`.

### Typography

**Families**
- Display + body:       Helvetica Neue → Helvetica → Arial → sans-serif
- Data / numerics:      Roboto (via Google Fonts) → Helvetica Neue → Arial → sans-serif

All headings are **700 weight**. Body copy is **400**. The prototype uses inline-style shorthand throughout (e.g. `font: '700 14px/1.3 Helvetica, Arial, sans-serif'`).

**Mobile type scale** (use these in production, not the desktop scale)
| Token        | Size / line-height | Weight | Use |
|--------------|--------------------|--------|-----|
| m-display    | 32 / 40            | 700    | Hero numbers (rare on mobile) |
| m-h01        | 24 / 32            | 700    | Screen titles (Dashboard "Good morning, Yusuf") |
| m-h02        | 18 / 24            | 700    | Card titles, modal titles |
| m-h03        | 16 / 24            | 700    | List item primary text, buttons |
| m-h04        | 14 / 20            | 700    | List item primary (smaller), badges |
| m-h05        | 12 / 16            | 700    | Captions, meta info |
| m-h06        | 10 / 14            | 700    | Labels, eyebrow text |
| m-body       | 14 / 20            | 400    | Body prose |

**Special**
- Eyebrow / label-xs: 10px/1 700, **uppercase**, letter-spacing `0.08em`, color `#525252`
- Stat values: 24px/1 700 (`Stat` component)
- Tab bar labels: 10px/1 700

### Spacing

Hard 8-pt scale:
- `xs` 4 · `sm` 8 · `md` 16 · `lg` 24 · `xl` 32 · `2xl` 48

Most screens use 16px outer padding, 14px card padding, 10–14px row gaps.

### Radii

- Small (buttons sm, web): 6
- Medium (buttons mobile, inputs): 8
- Large (cards, tabs): 12
- XL (sheet top corners): 20
- Pill (badges, progress, FAB): 99

### Elevation / Shadows

- Card:      `0 2px 8px rgba(0,0,0,0.06)`
- Elevated:  `0 8px 24px rgba(0,0,0,0.10)`
- FAB:       `0 8px 20px rgba(59,90,42,0.35), 0 2px 6px rgba(0,0,0,0.10)`
- Tab bar:   `0 12px 30px rgba(0,0,0,0.14), 0 2px 6px rgba(0,0,0,0.08)`
- Focus ring: `0 0 0 3px rgba(59,90,42,0.20)`

### Motion

- Standard easing: `cubic-bezier(0.2, 0.0, 0.0, 1.0)`
- Fast: 120ms · Base: 200ms
- Sheet slide-up: 220ms · Burger slide-down: 220ms
- Fade overlay: 200ms
- Recording pulse (red ring): 1.2s ease-out infinite

---

## Iconography

Two icon sets are used, both registered in `src/Primitives.jsx`:

1. **`<Icon name="…">`** — Lucide-style stroke icons, 24px viewBox, 2px stroke, rounded caps/joins. Used everywhere for utility icons (chevrons, plus, search, bell, mic, camera, etc.). Inline SVG. Use the platform's standard icon library (SF Symbols on iOS, Material on Android) to match these where possible — names map closely to Lucide.

2. **`<II name="…">`** — Illustrated raster icons (PNG, brand-specific personality). 12 icons in `assets/icons/`:

| Name                 | Use case |
|----------------------|----------|
| `calf-feeding`       | Newborn / children section |
| `inventory`          | Inventory screen header |
| `welfare`            | Welfare / care indicator |
| `breeding-confirmed` | Confirmed pregnancy action |
| `records`            | Add task / records button |
| `tag-id`             | **Cull** — flag for cull / sold workflow |
| `sheep-happy`        | Mark cured / healthy |
| `sheep-sick`         | Active illness card |
| `medication`         | Treatment action, medical inventory |
| `bottle`             | Feed item, milk price card |
| `sale`               | Sold animals, meat price card |
| `rip`                | Deceased / stillborn outcome |

Production should re-export these as platform-native vectors (SVG or PDF) if possible; raster is fine if vector originals are unavailable.

---

## Information Architecture

```
Bottom tab bar (floats with margin from edges, blurred glass-white, pill shape)
├── Home (Dashboard)
│   ├── Burger menu → Profile · Groups · Reports · Inventory · Help
│   └── Bell → Alerts & Tasks
├── Animals (Groups carousel + animals list)
│   ├── + New → Chooser (New animal / New group)
│   ├── Group → Group detail
│   └── Animal → Animal profile (Overview / Weight / Breeding / Milking / Health / Tasks / Media)
├── Tasks
│   ├── Voice add a task
│   ├── + New → New task sheet
│   └── Tap row → Edit task (with media + voice notes)
├── Finance
│   ├── + Entry → Income / Expense
│   ├── Milk price · per litre (editable)
│   └── Meat price · per kg (editable)
└── Reports
    └── Tap any row → Report detail (preview + CSV / PDF export)
```

The FAB (floating + button) is context-aware:
- Home / Animals → opens Add chooser (new animal / new group)
- Tasks → opens New task sheet
- Finance → opens Add entry sheet
- Group detail (milking tab) → opens Record milk sheet

---

## Screens / Views

### 1. Dashboard (`src/screens/Dashboard.jsx`)

**Purpose**: At-a-glance herd status, daily priorities, and quick drills into species/groups.

**Layout** (top to bottom, 16px outer padding except header):
1. **Header bar** (sticky, white, 14px padding) — burger button (left), logo + wordmark, bell, avatar circle (initials in primary-light bg)
2. **Greeting block** — day/location (12px muted) · "Good morning, Yusuf" (26px bold) · farm name + animal count (13px)
3. **Species chips** — horizontally-scrollable row of pill chips: "All species 22", "Cattle 9", "Goats 5", "Sheep 4". Selected chip: green fill + white text. Unselected: white with 1px border.
4. **Status grid (2×2)** — `Stat` cards: Pregnant, Ready to breed, Sick (red value), Cull flagged (orange value + `tag-id` illustration top-right). Each card tappable → Animals list filtered by that tag.
5. **(When species selected only)** Demographics card + Groups KPI list
6. **Tasks today summary** — 3 mini-stat columns (Overdue red / Today orange / This week green)
7. **Recent activity / feed cards** as designed

**Burger menu** — slides down from top with a 220ms transform, 32px backdrop fade, semitransparent overlay. Five rows: Profile, Groups, Reports, Inventory, Help — each with a 38×38 light-green icon tile, label (15px 700), and 12px muted sub-text.

### 2. Animals list (`src/screens/AnimalsList.jsx`)

**Purpose**: Browse, filter, and search every animal on the farm.

**Layout**:
1. **AppBar** — "Animals" / count subtitle / "+ Add" right label
2. **Search field** — white pill input with search glyph; placeholder is context-aware ("Search pregnant cattle…")
3. **Species chips** — All / Cattle / Goat / Sheep
4. **Status chips** — Any status / **Due soon** / Pregnant / Lactating / Ready to breed / Sick / Cull / Weaning. "Due soon" filters to pregnant cattle near due date.
5. **Groups carousel** — horizontally-scrollable cards (184px wide each), snap-scroll. Each card: species avatar (with red attention dot if animals need attention), group name, purpose badge, KPI (label + big value), head count. **Tapping a card filters the animals list below by that group** (selected card gets green border + light-green fill + "Clear" pill near heading).
6. **All animals heading** — group name when filtered, with count on right
7. **Animal cards** — 48px species avatar, name + tag, breed/weight/age (12px muted), status tags row, milk-today value (right) or chevron

### 3. Animal profile (`src/screens/AnimalProfile.jsx`)

**Purpose**: Everything about one animal.

**Layout**:
1. **AppBar** — "#0421" / name subtitle / back + edit icons
2. **Identity card** (white, 14px padding):
   - **Tappable profile picture** (64×64 rounded square) — upload via camera button overlay, persists in `localStorage` per-animal
   - Name (22px bold), breed/age/group (13px muted, group link is green tappable)
   - Status tag pills row
3. **Quick actions row** (horizontally-scrollable, 44×44 tiles with label below):
   - **Record milk** (milk icon) — only if `LACTATING` tag or `milkToday` value
   - **Treatment / Mark cured** — toggles based on `SICK` tag. Treatment uses `medication` illustration; cured uses `sheep-happy` with success tone
   - **Move group** (arrow icon)
   - **Status** (`tag-id` illustration) — opens StatusChangeSheet
   - **Add task** (`records` illustration)
   - **Add photo** (camera icon)
4. **Tabs row** — Overview / Weight / Breeding / Milking / Health / Tasks / Media. Active tab: green text + 2px green underline.
5. **Tab content** — varies (see below)

**Tabs**:
- **Overview** — KV rows (tag, name, sex, DOB, origin, weight, BCS, group, sire, dam). Children section uses `calf-feeding` icon and clickable child tiles.
- **Weight** — 5-month bar chart + history KV rows
- **Breeding** — Active pregnancy card (progress bar to due date), method KV, breeding history KV list. Females only.
- **Milking** — 30-day bar chart, today's morning/evening/total stats, + **Record milk** CTA. Shown when `LACTATING` or `milkToday` is set.
- **Health** — Withdrawal warning banner (if active), **Active illness card** with `sheep-sick` illustration + Mark cured button (when `SICK`), history KVs, vaccinations KVs, + Record treatment button.
- **Tasks** — Auto-generated upcoming task list + "Add task for [name]" CTA
- **Media** — Add photos button + 2-col grid of uploaded photos with delete overlay

### 4. Groups (`src/screens/Groups.jsx`)

**Purpose**: Browse all groups; view single group with members, nutrition, milking, tasks.

**Group list** — Cards with species avatar (red dot if needs attention), name, purpose badge, head count, attention summary.

**Group detail** — Header with name, purpose pill, head count. Tabs: Animals / Nutrition / Milking / Health / Tasks. Animals list shows up to 2 status tags stacked vertically on the right of each row.

### 5. Tasks (`src/screens/Tasks.jsx`)

**Purpose**: View and manage tasks across the farm.

**Layout**:
1. AppBar — count + overdue subtitle, "+ New" right label
2. **Voice add a task** card — green-light circle with mic icon, "Hold to talk" outline button
3. Tab chips — Today / This week / Recurring / All
4. **Task rows** — Each row: 36×36 tone-coloured icon tile, title (14px bold), tone badge or due time (right), sub-text below (12px muted). Tap → opens **Edit task sheet** (with photos + voice notes).

### 6. Edit task sheet (`src/screens/Sheets.jsx` → `EditTaskSheet`)

**Purpose**: Full task editing with media attachments and recorded voice notes.

Sections:
- Title, description
- Assignee (Select) + Due date (Field), side-by-side
- Recurrence (Select)
- **Photos** — Add photos button + 3-col thumbnail grid with delete chips
- **Voice notes** — Recorder card (44×44 mic button → red pulse ring while recording, live timer) + waveform list of recorded notes (play button, fake waveform, duration, trash)
- Delete task (red text button)

### 7. Finance (`src/screens/FinanceReports.jsx`)

**Purpose**: 3-month finance overview, edit prices, log entries.

**Layout**:
1. AppBar — Finance / farm name / "+ Entry"
2. **3-month bar chart card** — paired income (green) / expense (blue) bars per month, with legend
3. **Stats grid (2×2)** — Income / Expense / Net / Livestock value
4. **Recent entries card** — KVHead "Recent entries" then list rows with income/expense icon, category, description+date, amount (green for income with +, neutral with −)
5. **Milk price card** — bottle icon, "Edit" button → opens EditPricesSheet (scoped to milk). Rows per species with SAR/L value and trend badge.
6. **Meat price card** — sale icon, same pattern. SAR/kg.

**Editable prices**: Persisted in `localStorage` under `gh_prices_v1`. Cards subscribe to a `gh-prices-changed` window event for live refresh.

### 8. Reports (`src/screens/FinanceReports.jsx` → `ReportsScreen` + `ReportDetailScreen`)

**Reports list** — Date range card (read-only fields), then "Available reports" card with rows. Each row navigates to a report detail screen.

**Report detail** — AppBar "back / report name / Report preview". Header tile (icon + name + desc), 4-cell summary grid (Records / Window / Species / Generated), then 3 cards (Headline / Per-group / Auditable detail) with bulleted summaries, then Export card (CSV outline button + Download PDF primary button, signature line note).

### 9. Inventory (`src/screens/Inventory.jsx`)

**Purpose**: Feed and medical stock management.

Top strip with `inventory` illustration + 1-line explanation. Tabbed segmented control: **Feed / Medical**. Items list — each item card: tone-coloured square with `bottle` or `medication` illustration, name + Low stock / Expiring soon badges, cost/expiry/withdrawal sub-line, quantity + unit right-aligned.

### 10. Feed recommendations (`src/screens/FeedRecommendations.jsx`)

**Purpose**: Fix nutrition gaps for a specific group (drill-down from "Fix the gap" CTA).

1. AppBar — Fix the gap / group name / back
2. **Gap summary card** — "Energy gap detected" eyebrow, big −41% with "below target", warning badge top-right. Three `Progress` rows: Energy, Dry matter, Protein (each with deviation-coloured fill — green ≤10%, warning ≤30%, error otherwise).
3. **Source tabs** — Inventory / Standard / Marketplace (white pill bar, active tab green-filled with sub-text)
4. **Recommendation cards** — leaf icon tile, name + Top pick badge, supplier/inventory tag, cost/energy/protein row, +Add / ✓ Added button (right). When added: quantity stepper (−/+ around editable kg/day).
5. **Cost + CTA bar** — Projected daily cost left, SAR total right. Action buttons: **Save plan** (or **Add to inventory** when on Marketplace tab) + **Apply to morning mix** primary.

### 11. Alerts & Tasks (Settings.jsx)

Notifications card + today's tasks card (auto-pulled from TASKS list). No farm profile details here — that was moved out per teammate feedback.

### 12. Help (`src/screens/Inventory.jsx` → `HelpScreen`)

Support hero card (green-light card with help icon, "Chat" button), then "Browse topics" card with 8 topic rows, then "Reach the team" (email + version).

### 13. Sheets / Modals (`src/screens/Sheets.jsx`)

All sheets use a common pattern: full-width bottom sheet, 20px top-corner radius, dim overlay (rgba(0,0,0,0.40)), slide-up 220ms, optional footer (border-top, 24px bottom padding for safe area). 40×4 drag handle at top.

Sheets:
- **NewTaskSheet** — context-aware (animal context card if invoked from an animal)
- **VoiceTaskSheet** — voice-add UI with phases (idle / recording / transcribed)
- **RecordMilkSheet / RecordFeedingSheet / RecordVaccinationSheet / RecordHealthSheet** — log entries
- **AddAnimalSheet** — multi-step wizard (species/sex/breed → details → confirm)
- **EditAnimalSheet** — edit existing animal
- **AddGroupSheet** — name/species/purpose/manager, then "Group of livestock" segmented (Existing / New (born) / New (purchased)) — uses `NewLivestockList` for batch entry of new animals
- **AddChooserSheet** — "Add new" decision sheet (New animal vs New group)
- **MoveAnimalSheet** — list of same-species groups, current group highlighted
- **AddFinanceEntrySheet** — Income/Expense toggle, amount, category, date
- **StatusChangeSheet** — context-aware status transitions:
  - No tag → Flag for cull
  - CULL → Mark as sold / Clear cull flag
  - SOLD → Undo sale
  - READY_TO_BREED → Mark pregnant (gestation months + prolificacy + method)
  - PREGNANT → Record calving outcome (Born live / Stillborn / Miscarriage)
- **EditPricesSheet** — edit milk + meat prices per species, persisted to localStorage

---

## Status Tags (`TAG_LOOKUP` in `src/Primitives.jsx`)

| Tag             | Label           | Tone     |
|-----------------|-----------------|----------|
| PREGNANT        | Pregnant        | primary  |
| LACTATING       | Lactating       | primary  |
| READY_TO_BREED  | Ready to breed  | primary  |
| WEANING         | Weaning         | info     |
| CULL            | Cull flagged    | warning  |
| SOLD            | Sold            | neutral  |
| MISCARRIAGE     | Miscarriage     | warning  |
| STILLBORN       | Stillbirth      | warning  |
| SICK            | Sick            | error    |
| FATTENING       | Fattening       | info     |

Status tags can stack: a cow can be both `PREGNANT` and `LACTATING`. Animal list rows show up to 2 stacked; profile shows all.

---

## State Transitions (must be enforced server-side too)

1. **Cull lifecycle**: `none` → `CULL` → `SOLD` (terminal) or back to `none`.
2. **Breeding lifecycle**: `READY_TO_BREED` → `PREGNANT` (with `gestMonths` and `prolificacy` set) → one of: `LACTATING` (born live, dam gets LACTATING + new animal records created), `STILLBORN`, `MISCARRIAGE`.
3. **Illness lifecycle**: recording a treatment **adds** `SICK`. "Mark cured" removes `SICK`. Withdrawal periods are tracked separately and gate milk sales.

---

## Interactions & Behavior

### Floating tab bar
- Bottom tab bar floats with 12px margin from screen edges, 14px from bottom safe area, 22px radius
- Background: `rgba(255,255,255,0.96)` with `backdrop-filter: saturate(140%) blur(14px)`
- Active tab: green text + light-green pill background (14px radius), 160ms transition
- 5 tabs: Home / Animals / Tasks / Finance / Reports

### Burger menu
- Slides down from top of screen (220ms), full-width white card with bottom-only rounded corners (16px)
- Backdrop fades in 160ms (32% black)
- Item rows have 38×38 light-green icon tile + label + sub + chev right
- Tapping a row dismisses then navigates

### FAB
- 52×52 round green button, 96px from bottom (above tab bar), 16px from right
- Context-aware action (see IA section)
- Hidden when viewing an animal profile (would clash with quick actions row)

### Forms
- Inputs: 1.5px border (border or error red), 8px radius, white bg, 12×14 padding, 16px bold text
- Labels: 10px uppercase 700 muted, 0.08em letter-spacing, 6px gap below
- Selects: same shape, with chev-down glyph 12px from right
- Error / hint text: 12px below input, error in red, hint in muted

### Sheets
- Tap dim overlay → close
- Drag handle (visual only in prototype — production should make it interactive)
- Footer always white with border-top, 24px bottom padding

### Treatment workflow
- "Treatment" quick action → `RecordHealthSheet`. On close, animal gains `SICK` tag automatically (via `onCloseTreatment` callback passed in params).
- "Mark cured" quick action appears only when `SICK` is present; removes the tag.

### Calving outcome
- Three-way segmented control with illustrated tiles (calf-feeding / rip / sheep-sick)
- Born live: pregnant → lactating, number of young (prefilled from prolificacy), avg birth weight **optional**
- Stillborn / Miscarriage: pregnant tag removed, respective tag added

### Animal photo upload
- Profile pic: tap the 64×64 avatar → file picker → reads as data URL → setState + writes to `localStorage` under `gh_animal_prof_${animalId}`
- Gallery: tap "Add photo" quick action or "Add photos" in Media tab → multi-select → each gets a unique id, prepended to gallery → `localStorage` under `gh_animal_media_${animalId}`

### Price edits
- `EditPricesSheet` reads `gh_prices_v1` from localStorage; on save, writes back + dispatches `gh-prices-changed` window event
- Finance screen subscribes to that event and re-renders price cards

### Group switching in Animals list
- The horizontal groups carousel **filters the animals list below** (does not navigate). Selected card visual: green border + light-green fill. Heading near the list shows the group name. A "Clear" pill (light green) resets the filter.

### Attention dots
- Red 16×16 badge in top-right corner of any group avatar where any member has `SICK`, `CULL`, or `MISCARRIAGE`. Shows count, "9+" if more than 9. White 2px border.

### Recurrence / reminders
- All record-style sheets default to "1 day before" reminder, no recurrence. Options: SAME_DAY / 1_DAY / 3_DAYS / 7_DAYS for reminder; NONE / DAILY / WEEKLY / MONTHLY for recurrence.

### RTL
- The root container respects `dir` based on language tweak. Currently only language toggle drives this. Production should mirror flex directions, chevrons, swipe directions, etc.

---

## State Management

The prototype uses local React state + `localStorage`. Production needs proper state management.

**Persisted in localStorage**:
- `gh_animal_prof_<animalId>` — profile picture data URL
- `gh_animal_media_<animalId>` — JSON array of `{id, url, name}` photo objects
- `gh_prices_v1` — `{ milk: {cattle, goat, sheep}, meat: {cattle, goat, sheep} }`
- `gh_farmPic` — (legacy, no longer wired in)

**In-memory data models** (see `src/data.js`):
- `FARM` — single-tenant farm meta
- `USERS` — owner / manager / farm hand / vet
- `GROUPS` — id, name, species, purpose, count
- `ANIMALS` — id, tag, name, species, sex, breed, wt, age, dob, group, tags[], milkToday?, withdrawal?, sire?, dam?, bcs?, heifer?, twin?, gestMonths?, prolificacy?
- `TASKS` — id, title, sub, type, when, due, overdue?, icon, tone, animal?, group?, assignee
- `FINANCE` — monthly[], income3mo, expense3mo, net3mo, livestockValue, recent[]
- `REPORTS` — id, name, desc, count, icon
- `BREEDS`, `PURPOSES`, `SPECIES_LABEL`, `GROUP_KPI` — lookup maps

**State transitions you'll need server-side**:
- Cull/sold lifecycle
- Breeding → pregnancy → calving outcome
- Treatment → SICK → cured
- Milk recording → withdrawal updates
- Photo upload → CDN URL (replace data URL flow)

---

## Assets

In `assets/`:
- `logo.svg` — original wordmark glyph (not currently used; replaced by bull image)
- `logo-bull.png` — current logo (bull illustration with green halo, used in Dashboard header)
- `species/cattle.svg`, `species/goat.svg`, `species/sheep.svg`, `species/cattle.png` — species avatar glyphs
- `icons/*.png` — 12 illustrated brand icons (see Iconography)

All illustrated icons are PNGs. Re-export to SVG/PDF if the target platform supports vector for these sizes (28–48px). They're round, have distinct color personality, and lean playful — keep that DNA when redrawing.

---

## Files in This Bundle

```
GreenerHerd App.html                  Entry point — loads React/Babel + all scripts
src/
  App.jsx                             Router, FAB, sheet host, tweaks panel
  Primitives.jsx                      Tokens, Icon, II, Button, Badge, Card, AppBar,
                                       TabBar, Progress, Stat, Field, Select, Chip,
                                       SpeciesAvatar, StatusTag, Sheet, InfoBanner, Logo
  data.js                             All mock data
  screens/
    Dashboard.jsx
    AnimalsList.jsx
    AnimalProfile.jsx
    Groups.jsx                        GroupsList + GroupDetail
    Tasks.jsx
    FinanceReports.jsx                FinanceScreen + ReportsScreen + ReportDetailScreen
    Sheets.jsx                        All bottom sheets / modals
    Settings.jsx                      Alerts & Tasks screen
    Profile.jsx
    FeedRecommendations.jsx
    Inventory.jsx                     InventoryScreen + HelpScreen
styles/
  tokens.css                          Source-of-truth design tokens (CSS variables)
ios-frame.jsx                         iOS device frame component (status bar + bezel)
tweaks-panel.jsx                      Design-time tweaks UI (not part of the app)
assets/                               Logo + species + icon assets
```

To preview the prototype:
1. Open `GreenerHerd App.html` in a modern browser (Chrome/Safari/Firefox) — needs internet for the React/Babel CDN scripts and Google Fonts
2. No build step required

---

## Brand Voice / Copy Notes

- Friendly, direct, never cute. "Good morning, Yusuf" not "Hello there!"
- Use SAR for currency, metric units (kg, L, °C), 24h time, day-month dates (e.g. "08 May 2026")
- Status terms use farming vernacular ("Cull flagged" not "Marked for removal", "Withdrawal" not "Hold period")
- Error states should suggest the next action, not apologise

---

## What's Mocked (don't ship as-is)

- All data lives in `src/data.js` — replace with real API
- Voice transcription is faked (delays + prefilled text)
- Photo "upload" is a `FileReader.readAsDataURL` → `localStorage` write. Production needs real upload + CDN.
- Recording timer ticks but no audio is actually captured
- Trends ("+0.10", "−0.20") on price cards are hard-coded
- Reports show fake summaries — production should generate from real records
- Map / location-based features are not in the prototype

---

## Known Open Items

See `TODO.md` at the project root (in the parent project, not in this handoff folder):
- Farm profile photo upload needs a new home — was on the old Settings screen, removed when Settings became "Alerts & Tasks"

---

## Questions?

The original prototype project is the authoritative source. If anything in this README contradicts a file, **the files win** — the README is a guide to navigating them.
