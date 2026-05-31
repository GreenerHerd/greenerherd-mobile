import { loadBddFeedCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-feed-catalog';
import { loadBddFeedPricingCatalog } from '@greenerherd/shared-db/test-fixtures/bdd-feed-pricing-catalog';
import { buildApp } from './app.js';

const { app } = await buildApp(
  process.env.DATABASE_URL
    ? {}
    : {
        feedCatalog: loadBddFeedCatalog(),
        pricingCatalog: loadBddFeedPricingCatalog(),
      },
);

const port = Number(process.env.PORT ?? 3003);
await app.listen({ port, host: '0.0.0.0' });
app.log.info({ port }, 'gh-api-nutrition listening');
