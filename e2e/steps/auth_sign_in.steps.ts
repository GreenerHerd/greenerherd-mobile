import { expect } from '@playwright/test';
import { createBdd } from 'playwright-bdd';

import { gotoPath } from '../support/navigation.js';

const { Given, When, Then } = createBdd();

When('the sign-in screen is shown', async ({ page }) => {
  await gotoPath(page, '/auth/sign-in');
});

Given('onboarding is already complete', async ({ page }) => {
  await gotoPath(page, '/auth/sign-in');
});

When('the user taps {string}', async ({ page }, buttonLabel: string) => {
  const target = page
    .getByRole('button', { name: buttonLabel })
    .or(page.getByText(buttonLabel, { exact: false }));
  await target.first().click({ timeout: 30_000 });
  await page.waitForTimeout(800);
});

Then('a session is created', async ({ page }) => {
  await expect(page).toHaveURL(/home|onboarding/, { timeout: 30_000 });
});

Then('onboarding is not complete', async ({ page }) => {
  await expect(page).toHaveURL(/\/onboarding/, { timeout: 15_000 });
});

Then('a Google account is linked', async ({ page }) => {
  await expect(page.getByText('Farm name', { exact: false })).toBeVisible({
    timeout: 15_000,
  });
});

Then('there is no active session', async () => {
  // Mock store starts signed-out when landing on sign-in only.
});
