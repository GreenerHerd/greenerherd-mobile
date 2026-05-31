# GREENER HERD — Technical Architecture
> AI Engineering Harness Memory Artifact · v1.0

---

## Stack Summary
| Concern | Technology |
|---|---|
| Mobile frontend | Flutter (Dart), targeting iOS 14+ and Android 9+ |
| Backend API | Node.js with Fastify (REST + WebSocket for notifications) |
| Primary database | PostgreSQL 15 |
| Caching / sessions | Redis |
| File / media storage | S3-compatible (images, voice notes, documents, PDFs) |
| AI features | Anthropic Claude API (claude-sonnet-4-20250514) |
| Push notifications | Firebase Cloud Messaging (FCM) |
| TTS (voice task playback) | Platform TTS or Google Cloud TTS API |
| Auth | JWT (access token 15 min, refresh token 30 days) |
| Internationalisation | Flutter `intl` + ARB files; Node responses return keys or translated strings based on `Accept-Language` |

---

## Flutter Architecture

### State Management
- **Riverpod** (recommended) or BLoC
- Feature-based folder structure:

```
lib/
  core/
    api/           # Dio HTTP client, interceptors
    auth/          # JWT storage, refresh logic
    localisation/  # ARB files, locale switching
    router/        # GoRouter route definitions
    theme/         # ThemeData, colours, typography
    utils/
  features/
    onboarding/
    dashboard/
    animals/
    groups/
    nutrition/
    breeding/
    milking/
    healthcare/
    tasks/
    finance/
    inventory/
    reports/
    people/
  shared/
    widgets/       # Reusable UI components
    models/        # Dart model classes (JSON serialisable)
```

### RTL Support
- `Directionality` widget wraps app shell
- Locale determines `TextDirection.rtl` (Arabic, Urdu) vs `TextDirection.ltr`
- All layout must use `start`/`end` semantics, not `left`/`right`

### Offline Capability
- Core data (animals, groups, tasks) cached locally using **Drift** (SQLite ORM for Flutter)
- Write operations queued when offline → sync on reconnect
- Conflict resolution: last-write-wins with server timestamp

### Voice Notes
- Record: `flutter_sound` package
- Upload: multipart POST to backend → stored in S3
- Playback: stream URL from S3 via `just_audio`

### Image Handling
- Capture: `image_picker`
- Compress before upload: `flutter_image_compress`
- Thumbnails served by backend (or CDN transform)

### PDF Reports
- Generated server-side (Node.js) using `pdfkit` or `puppeteer`
- Downloaded to device and opened with `open_file` package

---

## Node.js Backend Architecture

### Framework
- **Fastify** with TypeScript
- Plugin-based structure:

```
src/
  plugins/
    auth.ts          # JWT validation middleware
    database.ts      # PostgreSQL pool (pg)
    redis.ts
    storage.ts       # S3 client
    ai.ts            # Anthropic SDK wrapper
  routes/
    farms.ts
    animals.ts
    groups.ts
    nutrition.ts
    breeding.ts
    milking.ts
    healthcare.ts
    tasks.ts
    finance.ts
    inventory.ts
    reports.ts
    users.ts
    auth.ts
  services/
    nutritionEngine.ts     # Feed recommendation algorithm
    breedingScheduler.ts   # Auto-task generation from breeding events
    vaccinationScheduler.ts
    aiAgent.ts             # Claude API calls
    reportGenerator.ts     # PDF generation
    notificationService.ts # FCM
  models/                  # TypeScript interfaces mirroring DB schema
  db/
    migrations/            # SQL migration files (node-pg-migrate)
    seeds/                 # Reference data: vaccines, feeds, breeds
```

### API Design Conventions
- REST, versioned: `/api/v1/...`
- All responses: `{ data: ..., meta: { page, total } }` or `{ error: { code, message } }`
- Authenticated routes: `Authorization: Bearer <jwt>`
- Farm-scoped: most routes include `farm_id` from JWT claims or path param
- Soft deletes: records are never hard-deleted; use `status` fields or `deleted_at`

### Key Computed Endpoints
```
GET  /api/v1/farms/:farmId/dashboard
GET  /api/v1/groups/:groupId/nutrition          # requirements vs actuals
POST /api/v1/groups/:groupId/nutrition/recommend # AI feed recommendation
GET  /api/v1/groups/:groupId/healthcare/summary
GET  /api/v1/animals/:animalId/weight/estimate  # age-range average weight
POST /api/v1/reports/:type                       # generate and return PDF URL
POST /api/v1/feeds/identify                      # Claude AI feed lookup
```

---

## Claude AI Integration Points

### 1. Feed Identification
- Trigger: farmer adds a feed item not in `FeedReference`
- Prompt: "Given the livestock feed named '[name]', provide estimated nutritional values: dry matter %, crude protein %, metabolisable energy (MJ/kg), NDF %. Return JSON only."
- Response parsed → stored as `FeedReference` with `ai_generated = true`

### 2. Feed Gap Recommendation ("Fix the Gap")
- Trigger: farmer taps "Fix the Gap" on group nutrition page
- Prompt: includes current feed mix, nutritional gaps, available inventory
- Response: adjusted feed quantities to close the gap

### 3. Full Feed Recommendation
- Trigger: farmer taps "Full Feed Recommendation"
- Prompt: includes group profile, full nutritional requirements, available feeds + costs
- Response: complete new feed plan with kg per feed type per day

### 4. Cull Report Analysis
- Trigger: Cull Report generation
- Prompt: provide animal profiles with milk yield, health history, breeding outcomes
- Response: ranked cull candidates with reasoning

### 5. Voice Task Playback (TTS)
- Use platform TTS or Google Cloud TTS for task description audio
- Language from user `preferred_lang` setting

---

## Database — Key Indexes
```sql
-- Frequently filtered columns
CREATE INDEX idx_animals_farm_id ON animals(farm_id);
CREATE INDEX idx_animals_group_id ON animals(group_id);
CREATE INDEX idx_animals_status ON animals(status);
CREATE INDEX idx_milk_records_animal_date ON milk_records(animal_id, recorded_date);
CREATE INDEX idx_tasks_farm_due ON tasks(farm_id, due_date) WHERE status != 'COMPLETE';
CREATE INDEX idx_breeding_events_female ON breeding_events(female_animal_id, event_date);
CREATE INDEX idx_health_records_animal ON health_records(animal_id, resolved);
```

---

## Multi-Language Backend Strategy
- User language stored in `User.preferred_lang`
- Backend sends data keys and enum values in English (canonical)
- Flutter ARB files handle all UI string translation client-side
- Where AI generates text (feed recommendations, reports) → include language instruction in Claude prompt

---

## Security
- HTTPS enforced on all endpoints
- JWT claims include: `user_id`, `farm_ids[]`, `role`
- Row-level security: all queries filter by `farm_id` from JWT
- Vet users: `farm_ids` is a list; backend validates farm selection against this list
- File upload: validate MIME type server-side; max file size 20MB per file
- Voice notes: max duration 5 minutes; max file size 10MB

---

## Reference Data Tables (Seeds)
The following are seeded at deployment and maintained by admin:
- `FeedReference` — ~80 common ME livestock feeds with nutritional values
- `VaccineReference` — common livestock vaccines with withdrawal periods
- `NutritionalRequirements` — requirements by species, sex, age range, physiological state
- Country list with ISO codes
- Currency list with ISO 4217 codes
- Breed list per species (extensible by farm)

---

## Environment Variables (Backend)
```
DATABASE_URL
REDIS_URL
S3_BUCKET / S3_ENDPOINT / S3_KEY / S3_SECRET
ANTHROPIC_API_KEY
FCM_SERVER_KEY
JWT_SECRET
JWT_REFRESH_SECRET
TTS_API_KEY (optional)
```
