import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

const PORT = process.env.E2E_PORT ?? '7357';
const baseURL = `http://127.0.0.1:${PORT}`;

const testDir = defineBddConfig({
  // Reuse widget BDD feature files; only @e2e scenarios run in the browser.
  featuresRoot: '../test/bdd/features',
  features: '../test/bdd/features/**/*.feature',
  steps: 'steps/**/*.ts',
  tags: '@e2e',
});

export default defineConfig({
  testDir,
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: [['html', { open: 'never' }], ['list']],
  timeout: 60_000,
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: `bash ../scripts/serve-flutter-web-e2e.sh ${PORT}`,
    url: baseURL,
    reuseExistingServer: !process.env.CI,
    timeout: 180_000,
  },
});
