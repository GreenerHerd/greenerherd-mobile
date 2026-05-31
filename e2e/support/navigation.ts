import type { Page } from '@playwright/test';

/** Flutter web + go_router path navigation. */
export async function gotoPath(page: Page, path: string) {
  await page.goto(path, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
}
