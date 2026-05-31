import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  FeedPricingCatalog,
  type FeedFxRateRecord,
  type FeedIndicativePriceRecord,
} from '../db/feed-pricing-catalog.js';
import type { FeedType } from '../db/feed-catalog.js';

function jsonPath(): string {
  return path.resolve(
    fileURLToPath(new URL('.', import.meta.url)),
    '../../../assets/data/feed_indicative_prices.json',
  );
}

let cached: FeedPricingCatalog | undefined;

export function loadBddFeedPricingCatalog(): FeedPricingCatalog {
  if (cached) return cached;
  const parsed = JSON.parse(readFileSync(jsonPath(), 'utf8')) as {
    prices: FeedIndicativePriceRecord[];
    fx_rates: FeedFxRateRecord[];
  };
  cached = FeedPricingCatalog.fromRecords(parsed.prices, parsed.fx_rates);
  return cached;
}
