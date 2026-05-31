# GreenerHerd backend services (domain repos)

Each folder is a **standalone** Node.js Fastify service with **Cucumber BDD** tests that run via `fastify.inject()` — no frontend or running HTTP server required.

## Services

| Service | Port | Responsibility |
|---------|------|----------------|
| `gh-api-auth` | 3001 | JWT login / refresh |
| `gh-api-farms` | 3002 | Farm profile, species setup, onboarding status |
| `gh-api-nutrition` | 3003 | Group nutrition, eligibility, feed plans |
| `gh-api-tasks` | 3004 | Notification scheduler, domain events → tasks |
| `gh-api-inventory` | 3005 | Feed/medical inventory, meals, feeding records |
| `gh-api-people` | 3007 | People invite, roles, group access |
| `gh-api-animals` | 3006 | Animals, groups, tags, cull/sell lifecycle |
| `gh-api-finance` | 3008 | Finance summary, ledger entries, purchases, sales |

## API summary (new)

### Farms (`gh-api-farms`)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/farms` | Create farm (onboarding step 1) |
| GET/PATCH | `/api/v1/farms/:farmId` | Read/update farm profile |
| GET/POST | `/api/v1/farms/:farmId/species` | List/add farm species (step 2) |
| GET | `/api/v1/farms/:farmId/onboarding/status` | Onboarding progress |
| POST | `/api/v1/farms/:farmId/onboarding/complete` | Complete onboarding (`skip_animals`) |
| GET | `/api/v1/reference/breeds?species=SHEEP` | Breed catalogue (from DB; no auth) |
| GET | `/api/v1/reference/breeds/:breedId/weights` | Indicative weight curve by age/sex |

### People (`gh-api-people`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/farms/:farmId/users` | List farm members |
| POST | `/api/v1/farms/:farmId/users/invite` | Invite user |
| PATCH | `/api/v1/farms/:farmId/users/:userId` | Update role |
| DELETE | `/api/v1/farms/:farmId/users/:userId` | Deactivate member |
| POST/GET | `/api/v1/farms/:farmId/groups/:groupId/access` | Group access control |

### Animals (`gh-api-animals`)

| Method | Path | Description |
|--------|------|-------------|
| GET/POST | `/api/v1/farms/:farmId/animals` | List/create animals |
| GET | `/api/v1/farms/:farmId/animals/:animalId` | Animal detail |
| POST | `/api/v1/farms/:farmId/animals/:animalId/tags` | Apply status tag |
| DELETE | `/api/v1/farms/:farmId/animals/:animalId/tags/:tag` | Remove tag |
| POST | `/api/v1/farms/:farmId/animals/:animalId/cull` | Flag for cull |
| POST | `/api/v1/farms/:farmId/animals/:animalId/sell` | Mark sold |
| GET/POST | `/api/v1/farms/:farmId/groups/bulk` | Bulk group onboarding (path B) |
| GET | `/api/v1/reference/breeds` | Breed catalogue (same as farms; no auth when `DATABASE_URL` set) |

Animal create accepts `breed` (name) or `breed_id` (UUID). Responses include `breed_ref` with full characteristics when using Postgres.

All authenticated routes expect `Authorization: Bearer <jwt>` with `farm_ids` claim (same secret as `gh-api-auth`).

## BDD testing

Each service with BDD has:

```
features/
  *_management.feature   # Happy-path / domain flows
  *_errors.feature       # Auth, validation, 404, 403, 409 contracts
  step_definitions/      # Step bindings (TypeScript)
```

**Coverage matrix** (run via `fastify.inject()` — no HTTP server or frontend):

| Area | Farms | People | Animals |
|------|-------|--------|---------|
| Happy paths | onboarding, species, complete | invite, roles, group access, deactivate | create, bulk group, cull/sell, filters |
| Breed reference (no auth) | list, health | — | list, by id, weights, health |
| Breed validation | — | — | `breed` / `breed_id`, unknown breed, `breed_ref` on responses |
| 401 missing / invalid JWT | yes | yes | yes |
| 403 farm not in token | yes | yes | yes |
| 404 not found | farm, dashboard | member, group access | animal by id, breed by id |
| 400 validation / malformed JSON | create, species, JSON parse | invite email, JSON parse | breed, species, bulk count, JSON parse |
| 409 conflict | duplicate species | duplicate invite | duplicate ear tag |
| Extra positives | PATCH farm profile | PATCH promote to MANAGER | GET animal by id, create by `breed_id` |

Run one service:

```bash
cd services/gh-api-farms && npm install && npm run test:bdd
cd services/gh-api-people && npm install && npm run test:bdd
cd services/gh-api-animals && npm install && npm run test:bdd
```

Run shared unit tests plus all BDD suites (59 scenarios + 3 unit tests as of last run):

```bash
chmod +x services/test-all.sh
./services/test-all.sh
```

BDD loads the full breed catalogue from `assets/data/breeds.json` via `@greenerherd/shared-db/test-fixtures/bdd-breed-catalog` (no Postgres required). Weight-curve scenarios use in-memory sample data for Holstein.

Reports (HTML) are written to `services/<name>/reports/cucumber-report.html` where configured.

## Database (PostgreSQL)

Shared DB under `services/db/` (Docker Compose + SQL migrations + breed seeds).

```bash
chmod +x services/setup-db.sh
./services/setup-db.sh
export DATABASE_URL=postgres://greenerherd:greenerherd@localhost:5432/greenerherd
```

| Mode | When | Behaviour |
|------|------|-----------|
| **Postgres** | `DATABASE_URL` set | DDL in `services/db/migrations/`; breeds/countries seeded via `services/db/seeds/`; each service loads `BreedCatalog` at startup |
| **In-memory** | `DATABASE_URL` unset | Used by Cucumber BDD (`./services/test-all.sh`); breed catalog still loaded from fixture JSON |

See [services/db/README.md](db/README.md) for migrate/seed/reset commands.

## Run services locally

**Logging:** Each API uses Fastify’s Pino logger (request/response lines + errors). Set `LOG_LEVEL` (`trace`, `debug`, `info`, `warn`, `error`; default `info`). Logs go to `services/logs/<service>.log` when using `start-all.sh`, or stdout when you run `npm run dev` in a terminal.

```bash
LOG_LEVEL=debug ./services/start-all.sh restart --force
tail -f services/logs/gh-api-animals.log
```

**All services at once (logs under `services/logs/`):**

```bash
chmod +x services/start-all.sh services/stop-all.sh
cp services/.env.example services/.env   # optional: JWT_SECRET, DATABASE_URL, LOG_LEVEL
./services/start-all.sh                  # start → logs/*.log
./services/start-all.sh status           # PIDs + /health
./services/start-all.sh stop             # or ./services/stop-all.sh
./services/start-all.sh restart --force  # reinstall logs archive + restart
./services/start-all.sh --install        # npm install each service first
```

Or one terminal per service:

```bash
export JWT_SECRET=dev-secret-change-me
export DATABASE_URL=postgres://greenerherd:greenerherd@localhost:5432/greenerherd  # optional
cd services/gh-api-auth && npm run dev    # 3001
cd services/gh-api-farms && npm run dev   # 3002
cd services/gh-api-nutrition && npm run dev  # 3003
cd services/gh-api-tasks && npm run dev      # 3004
cd services/gh-api-inventory && npm run dev  # 3005
cd services/gh-api-animals && npm run dev   # 3006
cd services/gh-api-people && npm run dev    # 3007
cd services/gh-api-finance && npm run dev   # 3008
```

Inventory and nutrition emit domain events when `TASKS_API_BASE_URL=http://localhost:3004` is set (fire-and-forget; no-op in BDD).

The Flutter app loads tasks from `gh-api-tasks` when `AppConfig.useTasksApi` is true (port **3004**). In-memory API mode runs one scheduler sweep for `farm-1` on startup so the Tasks tab has seeded reminders.

**Phase 6 — mobile API wiring:**

| Flag | Service | Port | Notes |
|------|---------|------|-------|
| `useFarmsApi` | `gh-api-farms` | 3002 | Farm profile; in-memory seeds `farm-1` (Al-Falah) |
| `usePeopleApi` | `gh-api-people` | 3007 | Team list; in-memory seeds demo users `u1`–`u4` |
| `useAnimalsApi` | `gh-api-animals` | 3006 | Animals/groups; demo Holstein herd for `farm-1` |
| `useTasksApi` | `gh-api-tasks` | 3004 | Scheduler tasks on startup for `farm-1` |
| `useInventoryApi` | `gh-api-inventory` | 3005 | Feed/medical stock |
| `useNutritionApi` | `gh-api-nutrition` | 3003 | Group nutrition |

**Phase 7 — auth + onboarding:**

| Flag | Service | Port | Notes |
|------|---------|------|-------|
| `useAuthApi` | `gh-api-auth` | 3001 | Social/dev login → JWT; same secret as other APIs |
| `useFarmsApi` | `gh-api-farms` | 3002 | 3-step onboarding: create farm → species → complete (`skip_animals`) |

`POST /api/v1/farms` returns `meta.access_token` with the new farm id in `farm_ids`. Flutter stores the session token and invalidates hybrid API providers after each onboarding step.

Use the dev JWT in `AppConfig.inventoryDevBearerToken` (or sign in) so requests include `farm_ids: ["farm-1"]`.

With Postgres, `GET http://localhost:3002/health` reports `breeds_loaded` (92 from `Breed Information.xlsx`: 26 cattle, 36 goat, 30 sheep).

**Phase 8 — finance, buy/sell, onboarding animals:**

| Flag | Service | Port | Notes |
|------|---------|------|-------|
| `useFinanceApi` | `gh-api-finance` | 3008 | Summary, entries, purchases, sales |
| `useAnimalsApi` | `gh-api-animals` | 3006 | Bulk group onboarding, cull/sell from mobile |

## Next steps

- Port nutrition optimizers into `gh-api-nutrition` (TypeScript)
