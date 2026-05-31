import type pg from 'pg';
import type { FeedType } from './feed-catalog.js';

export interface CountryPrice {
  currency: string;
  price_per_kg: number;
}

export interface FeedIndicativePriceRecord {
  id: string;
  price_number: number;
  name_en: string;
  name_ar: string | null;
  feed_type: FeedType;
  usd_per_kg: number | null;
  prices_by_country: Record<string, CountryPrice>;
  price_source: string | null;
}

export interface FeedFxRateRecord {
  country_code: string;
  country_name: string;
  currency_code: string;
  rate_per_usd: number;
  peg_type: string | null;
  notes: string | null;
}

function num(v: string | number | null | undefined): number | null {
  if (v === null || v === undefined || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

export class FeedPricingCatalog {
  private readonly prices: FeedIndicativePriceRecord[];
  private readonly byNumber = new Map<number, FeedIndicativePriceRecord>();
  private readonly byKey = new Map<string, FeedIndicativePriceRecord>();
  private readonly fxRates: FeedFxRateRecord[];

  private constructor(
    prices: FeedIndicativePriceRecord[],
    fxRates: FeedFxRateRecord[],
  ) {
    this.prices = prices;
    this.fxRates = fxRates;
    for (const row of prices) {
      this.byNumber.set(row.price_number, row);
      this.byKey.set(lookupKey(row.name_en, row.feed_type), row);
    }
  }

  static fromRecords(
    prices: FeedIndicativePriceRecord[],
    fxRates: FeedFxRateRecord[] = [],
  ): FeedPricingCatalog {
    return new FeedPricingCatalog(prices, fxRates);
  }

  static async load(pool: pg.Pool): Promise<FeedPricingCatalog> {
    const { rows: priceRows } = await pool.query(
      `SELECT id, price_number, name_en, name_ar, feed_type, usd_per_kg,
              prices_by_country, price_source
       FROM feed_indicative_prices
       WHERE is_active = TRUE
       ORDER BY price_number`,
    );
    const { rows: fxRows } = await pool.query(
      `SELECT country_code, country_name, currency_code, rate_per_usd, peg_type, notes
       FROM feed_fx_rates
       ORDER BY country_name`,
    );
    if (priceRows.length === 0) {
      throw new Error(
        'No indicative prices in database. Run: cd services/db && npm run db:extract-pricing && npm run db:seed',
      );
    }
    const prices = priceRows.map((r) => mapPriceRow(r));
    const fxRates = fxRows.map((r) => ({
      country_code: String(r.country_code),
      country_name: String(r.country_name),
      currency_code: String(r.currency_code),
      rate_per_usd: Number(r.rate_per_usd),
      peg_type: r.peg_type == null ? null : String(r.peg_type),
      notes: r.notes == null ? null : String(r.notes),
    }));
    return new FeedPricingCatalog(prices, fxRates);
  }

  get size(): number {
    return this.prices.length;
  }

  list(): FeedIndicativePriceRecord[] {
    return [...this.prices];
  }

  getByPriceNumber(priceNumber: number): FeedIndicativePriceRecord | null {
    return this.byNumber.get(priceNumber) ?? null;
  }

  resolve(nameEn: string, feedType: FeedType): FeedIndicativePriceRecord | null {
    return this.byKey.get(lookupKey(nameEn, feedType)) ?? null;
  }

  /** Price for a feed product row (nutrition catalogue) */
  resolveForProduct(
    nameEn: string,
    feedType: FeedType,
    countryCode?: string,
  ): {
    price_number: number;
    usd_per_kg: number | null;
    local_price_per_kg: number | null;
    currency: string | null;
    price_source: string | null;
  } | null {
    const record = this.resolve(nameEn, feedType);
    if (!record) return null;
    const local = countryCode
      ? record.prices_by_country[countryCode.toUpperCase()]
      : undefined;
    return {
      price_number: record.price_number,
      usd_per_kg: record.usd_per_kg,
      local_price_per_kg: local?.price_per_kg ?? null,
      currency: local?.currency ?? null,
      price_source: record.price_source,
    };
  }

  listFxRates(): FeedFxRateRecord[] {
    return [...this.fxRates];
  }
}

export function lookupKey(nameEn: string, feedType: FeedType): string {
  return `${nameEn.trim().toLowerCase()}::${feedType}`;
}

function mapPriceRow(row: Record<string, unknown>): FeedIndicativePriceRecord {
  const prices =
    typeof row.prices_by_country === 'string'
      ? (JSON.parse(row.prices_by_country) as Record<string, CountryPrice>)
      : (row.prices_by_country as Record<string, CountryPrice>);
  return {
    id: String(row.id),
    price_number: Number(row.price_number),
    name_en: String(row.name_en),
    name_ar: row.name_ar == null ? null : String(row.name_ar),
    feed_type: row.feed_type as FeedType,
    usd_per_kg: num(row.usd_per_kg as string | number | null),
    prices_by_country: prices ?? {},
    price_source: row.price_source == null ? null : String(row.price_source),
  };
}

export function toPublicIndicativePrice(
  p: FeedIndicativePriceRecord,
  countryCode?: string,
) {
  const country = countryCode?.toUpperCase();
  const local = country ? p.prices_by_country[country] : undefined;
  return {
    price_number: p.price_number,
    name_en: p.name_en,
    name_ar: p.name_ar,
    feed_type: p.feed_type,
    usd_per_kg: p.usd_per_kg,
    price_source: p.price_source,
    ...(country && local
      ? {
          country_code: country,
          currency: local.currency,
          price_per_kg: local.price_per_kg,
        }
      : { prices_by_country: p.prices_by_country }),
  };
}
