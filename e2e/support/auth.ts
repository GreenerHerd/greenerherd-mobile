import type { Page } from '@playwright/test';

import { gotoPath } from './navigation.js';

/** Mock auth: Google sign-in with onboarding already complete. */
export async function signInWithGoogle(page: Page) {
  await gotoPath(page, '/auth/sign-in');
  await page.getByText('Continue with Google', { exact: false }).click();
  await page.waitForURL(/\/home/, { timeout: 45_000 });
  await page.waitForTimeout(600);
}
