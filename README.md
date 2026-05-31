# GreenerHerd Mobile

Flutter mobile app for livestock farm management — animals, groups, nutrition, inventory, breeding, finance, and tasks. Part of the [GreenerHerd](https://github.com/GreenerHerd) platform.

## Features

| Area | Capabilities |
|------|----------------|
| **Animals & groups** | Individual and bulk onboarding, tags (lactating, pregnant, sick, weaning, fattening), breeding, cull/sell lifecycle |
| **Nutrition** | Group feed requirements from masterfile profiles, traffic-light ratings, gap supplements, methane estimates |
| **Inventory** | Feed and medicine stock, meal plans, feeding records, marketplace catalogue |
| **Finance** | Ledger entries, milk sales, purchases, dashboard KPIs |
| **Tasks** | Scheduled notifications driven by herd events |
| **People** | Farm members, roles, group access |
| **Reports** | PDF export of farm summaries |

## Stack

- **Flutter 3.x** — Riverpod, GoRouter, Drift (SQLite offline cache + sync queue)
- **Localisation** — EN, FR, AR (RTL), UR (RTL) via ARB files
- **Backend** — Node.js Fastify microservices (`services/gh-api-*`) with PostgreSQL
- **Testing** — Flutter widget/BDD tests, Cucumber on APIs, Playwright E2E on web

## Prerequisites

- Flutter SDK ≥ 3.5 (`flutter doctor`)
- Node.js ≥ 20 (backend services and DB tooling)
- Docker (PostgreSQL via `services/db`)
- Xcode / Android Studio for device builds

## Quick start — mobile app

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The app ships with mock repositories by default. Point API clients at local services when the backend stack is running (see below).

## Quick start — backend

```bash
# Database
cd services/db
cp .env.example .env
npm install
npm run db:up
npm run db:setup

# All API services (ports 3001–3008)
cd ..
./start-all.sh
```

Full API documentation: [`services/README.md`](services/README.md)  
Database migrations and seeds: [`services/db/README.md`](services/db/README.md)

## Testing

```bash
# Unit + BDD (no running server)
flutter test

# Nutrition and coverage scenarios
flutter test test/nutrition_coverage_test.dart test/bdd/nutrition_requirements_bdd_test.dart

# Backend Cucumber (per service)
cd services/gh-api-animals && npm test

# Playwright E2E (Flutter web)
./scripts/run-e2e-playwright.sh

# Full stack (Postgres + APIs + Flutter BDD)
./scripts/run-comprehensive-tests.sh
```

See [`test/bdd/README.md`](test/bdd/README.md) for the full test matrix.

## Project structure

```
lib/
  core/           Theme, router, l10n, Drift persistence
  data/           Models, repositories, API clients, catalog loaders
  features/       Screens — animals, groups, nutrition, inventory, finance, …
  shared/         Design-system widgets
assets/data/      Bundled catalogues (breeds, feeds, medicines, nutrition profiles)
docs/             Harness, design handoff, knowledge bundle for agents
services/
  gh-api-*/       Domain Fastify services (auth, farms, animals, nutrition, …)
  gh-shared/      Shared DB layer, optimizers, nutrition resolver
  db/             Migrations, seeds, extract scripts
test/bdd/         Executable Gherkin-style scenario tests
e2e/              Playwright + Cucumber browser tests
```

## Data catalogues

Master data is extracted from spreadsheets/SQL into JSON assets and Postgres seeds:

| Asset | Source script |
|-------|---------------|
| `nutrition_requirements.json` | `services/db/scripts/extract_nutrition_requirements_from_xlsx.py` |
| `medicine_products.json` | `services/db/scripts/extract_medicine_products_from_sql.py` |
| `feed_products.json` | `services/db/scripts/extract_feed_products_from_xlsx.py` |

Regenerate after source changes, then run the relevant tests.

## Documentation

- [`docs/README.md`](docs/README.md) — harness index, data models, feature specs
- [`services/README.md`](services/README.md) — API surface and BDD setup

## License

Proprietary — GreenerHerd Ltd. All rights reserved.
