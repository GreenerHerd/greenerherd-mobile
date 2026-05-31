import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { FeedPricingCatalog } from '../db/feed-pricing-catalog.js';

describe('FeedPricingCatalog', () => {
  const catalog = FeedPricingCatalog.fromRecords(
    [
      {
        id: '1',
        price_number: 2001,
        name_en: 'Barley',
        name_ar: null,
        feed_type: 'FODDER',
        usd_per_kg: 0.63,
        prices_by_country: {
          SA: { currency: 'SAR', price_per_kg: 2.36 },
        },
        price_source: 'Alex Pricing',
      },
    ],
    [
      {
        country_code: 'SA',
        country_name: 'Saudi Arabia',
        currency_code: 'SAR',
        rate_per_usd: 3.75,
        peg_type: 'Hard Peg',
        notes: null,
      },
    ],
  );

  it('resolves pricing by product name and type', () => {
    const p = catalog.resolve('Barley', 'FODDER');
    assert.equal(p?.price_number, 2001);
    const local = catalog.resolveForProduct('Barley', 'FODDER', 'SA');
    assert.equal(local?.local_price_per_kg, 2.36);
    assert.equal(local?.currency, 'SAR');
  });
});
