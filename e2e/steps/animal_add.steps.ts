import { expect } from '@playwright/test';
import { createBdd } from 'playwright-bdd';

import { signInWithGoogle } from '../support/auth.js';

const { Given, When, Then } = createBdd();

/** Last tag entered in the wizard (avoids collisions with seeded herd data). */
let lastEnteredTag = '';

async function fillWizardTextbox(
  page: import('@playwright/test').Page,
  label: RegExp,
  value: string,
) {
  const field = page.getByRole('textbox', { name: label });
  await field.first().click();
  await field.first().fill(value);
}

Given('the add animal sheet is open', async ({ page }) => {
  await signInWithGoogle(page);
  await page.getByText('Animals', { exact: false }).click();
  await page.waitForTimeout(500);
  await page.getByRole('button', { name: 'Add', exact: true }).click();
  await page.getByText('Onboard new animal', { exact: false }).click();
  await expect(page.getByText('Add animal', { exact: false })).toBeVisible({
    timeout: 20_000,
  });
});

When(
  'the user enters tag {string} and weight {string}',
  async ({ page }, tag: string, weight: string) => {
    lastEnteredTag = `E2E${Date.now() % 1_000_000}`;
    await fillWizardTextbox(page, /e\.g\. 0473/i, lastEnteredTag);
    await page.getByRole('button', { name: 'Continue' }).click();
    await page.waitForTimeout(600);
    await fillWizardTextbox(page, /e\.g\. 412/i, weight);
    await page.getByRole('button', { name: 'Continue' }).click();
    await page.waitForTimeout(600);
  },
);

When('saves the animal', async ({ page }) => {
  await page.getByRole('button', { name: 'Save animal' }).click();
  await page.waitForTimeout(1500);
});

When(
  'the user leaves tag empty and weight {string}',
  async ({ page }, _weight: string) => {
    await page.getByText('Continue', { exact: false }).click();
    await page.waitForTimeout(400);
  },
);

When('attempts to save', async ({ page }) => {
  const save = page.getByText('Save animal', { exact: false });
  if (await save.isVisible().catch(() => false)) {
    await save.click();
  } else {
    await page.getByText('Continue', { exact: false }).click();
  }
  await page.waitForTimeout(600);
});

Then('the sheet closes', async ({ page }) => {
  await expect(page.getByText('Save animal', { exact: false })).toBeHidden({
    timeout: 15_000,
  });
});

Then('tag {string} exists in the herd', async ({ page }, _tag: string) => {
  const tag = lastEnteredTag || _tag;
  const search = page.getByRole('textbox', { name: /search tag/i });
  if (await search.isVisible().catch(() => false)) {
    await search.fill(tag);
    await page.waitForTimeout(800);
  }
  await expect(page.getByText(tag, { exact: false })).toBeVisible({
    timeout: 20_000,
  });
});
