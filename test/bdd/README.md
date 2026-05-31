# Frontend BDD tests

Gherkin scenarios live in `features/*.feature` (spec). Executable tests are Dart
`flutter_test` files that mirror those scenarios with `@positive` / `@negative` tags.

## Run

**Widget + domain only (no running APIs):**

```bash
flutter test test/bdd/
```

Key UI BDD coverage includes:

- `animal_add_bdd_test.dart` — add animal/group wizards, breed dropdowns, validation
- `animals_list_bdd_test.dart` — tag/species filters, profile navigation
- `animal_profile_bdd_test.dart` — profile tabs, lactating tag, purpose editor
- `group_detail_bdd_test.dart` — group tab navigation

**Browser E2E (Playwright + Cucumber, `@e2e` scenarios on Flutter web):**

```bash
./scripts/run-e2e-playwright.sh
```

See [e2e/README.md](../../e2e/README.md) for setup, headed mode, and adding steps.

**Device smoke (integration_test on emulator/device):**

```bash
flutter test integration_test/smoke_test.dart -d <device_id>
```

**Comprehensive pack** (Postgres + APIs + backend Cucumber + Flutter BDD + live API/DB checks):

```bash
chmod +x scripts/run-comprehensive-tests.sh
./scripts/run-comprehensive-tests.sh
```

Prerequisites for the comprehensive script:

1. `cd services/db && npm run db:up` (or `./services/setup-db.sh`)
2. `cd services && ./start-all.sh` — all ports 3001–3008 healthy
3. Optional: `flutter run` on emulator for manual UI

**Live stack only** (API + Postgres alignment; uses real HTTP, not `flutter test`):

```bash
LIVE_STACK_TESTS=1 DATABASE_URL=postgres://greenerherd:greenerherd@localhost:5432/greenerherd \
  dart test test/integration/live_stack_test.dart
```

**Backend BDD only** (Cucumber, `fastify.inject`, no HTTP):

```bash
cd services && ./test-all.sh
```

Or all unit + BDD:

```bash
flutter test
```

## Layout

| Path | Role |
|------|------|
| `features/*.feature` | Human-readable scenarios (sync with harness docs) |
| `support/bdd_harness.dart` | `ProviderScope`, mock store, `pumpScreen` |
| `*_bdd_test.dart` | Widget / domain step implementations |

## Conventions

- **Positive** — happy path; UI or domain behaves as designed.
- **Negative** — guard rails; invalid weights, future birth dates, duplicate tags, lifecycle errors, etc.
- **Domain** (`bddDomainScenario`) — validation and lifecycle rules without widgets (fast, many cases).
- **Widget** (`bddScenario`) — screens, sheets, and navigation.
- Update the matching `.feature` and `*_bdd_test.dart` when changing UI flows.

## Coverage areas

| Feature file | Tests | Focus |
|--------------|-------|--------|
| `animal_input_validation` | domain | weight, DOB, tag, BCS, group name |
| `animal_lifecycle` | domain | cull, sale, breeding, calving, milk withdrawal |
| `animal_add` | widget | add animal/group sheets |
| `auth_sign_in`, `onboarding`, `group_detail`, … | widget | auth, tabs, species filter |
| `inventory` | domain + widget | feed/medical stock, low-stock, add feed validation |
| `inventory_meals` | domain + widget | meal batches, ingredients, meal plans screen |
| `tasks` | domain + widget | hybrid tasks repo, complete/dismiss, tasks screen |
| `animals_api` | domain | gh-api-animals mapper, groups head count, mock fallback |
| `offline_sync` | domain | Drift cache, sync queue, offline-first repositories |
| `farms_api` | domain | gh-api-farms profile, mock fallback |
| `people_api` | domain | gh-api-people team list, mock fallback |
