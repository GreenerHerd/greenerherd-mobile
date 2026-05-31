# Playwright BDD UI tests (Flutter web)

Browser end-to-end tests using [Playwright](https://playwright.dev/) and [playwright-bdd](https://github.com/vitalets/playwright-bdd). They reuse Gherkin scenarios from `test/bdd/features/` that are tagged **`@e2e`**.

This is the web counterpart to:

| Layer | Tool | Run |
|-------|------|-----|
| Fast widget BDD | `flutter_test` + `test/bdd/` | `flutter test test/bdd/` |
| Browser E2E | Playwright + Cucumber | `npm test` in this folder |
| Device E2E | `integration_test` | `flutter test integration_test/ -d <device>` |

## Prerequisites

- Flutter SDK (web enabled: `flutter config --enable-web`)
- Node.js 20+
- Chrome (installed by Playwright on first run)

## First-time setup

```bash
cd e2e
npm install
npx playwright install chromium
```

## Run all `@e2e` scenarios

From repo root:

```bash
./scripts/run-e2e-playwright.sh
```

Or manually:

```bash
cd e2e
npm test
```

Headed mode (watch the browser):

```bash
cd e2e
npm run test:headed
```

UI mode (debug steps):

```bash
cd e2e
npm run test:ui
```

## How it works

1. `scripts/serve-flutter-web-e2e.sh` builds Flutter web and serves `build/web` locally.
2. Playwright starts a local static server on port `7357` (override with `E2E_PORT`).
3. `playwright-bdd` generates tests from `../test/bdd/features/**/*.feature` filtered by `@e2e`.
4. Step definitions live in `e2e/steps/*.ts`.

## Adding scenarios

1. Write or extend a `.feature` file under `test/bdd/features/`.
2. Add the **`@e2e`** tag to scenarios that should run in the browser.
3. Implement steps in `e2e/steps/` (reuse step text from widget BDD where possible).
4. Run `npm test` in `e2e/`.

Keep **widget BDD** (`flutter test test/bdd/`) for fast feedback; use **`@e2e`** for full-app flows in a real browser.

## Notes

- The app uses **mock data** (`AppConfig.useMockData`) so no backend is required for sign-in flows.
- Flutter web exposes semantics when `SemanticsBinding.instance.ensureSemantics()` runs (see `lib/main.dart`); prefer `getByRole` / `getByText` in steps.
- The E2E server uses `serve -s` so deep links like `/auth/sign-in` work (hash URLs `#/home` are normal).
- For **Android/iOS** UI automation, use `integration_test/` or extend widget BDD — Playwright does not drive native mobile views.
