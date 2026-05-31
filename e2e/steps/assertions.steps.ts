import { expect } from '@playwright/test';
import { createBdd } from 'playwright-bdd';

const { Then } = createBdd();

Then('they see {string}', async ({ page }, message: string) => {
  const locator = page
    .getByRole('button', { name: message })
    .or(page.getByText(message, { exact: false }));
  await expect(locator.first()).toBeVisible({ timeout: 30_000 });
});
