import { createBdd } from 'playwright-bdd';

import { gotoPath } from '../support/navigation.js';

const { Given } = createBdd();

Given('the user is signed out', async ({ page }) => {
  await gotoPath(page, '/auth/sign-in');
});
