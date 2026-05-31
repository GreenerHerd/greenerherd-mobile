import type { FeedCatalog } from '@greenerherd/shared-db/feed-catalog';
import type { FeedPricingCatalog } from '@greenerherd/shared-db/feed-pricing-catalog';
import type { NutritionRequirementsCatalog } from '@greenerherd/shared-db/nutrition-requirements-catalog';
import {
  findEligibleFeeds,
  type FeedEligibilityContext,
} from '@greenerherd/shared-db/feed-eligibility';
import {
  recommendFeedPlan,
  type FeedRecommendationRequest,
} from '@greenerherd/shared-db/feed-recommendation';
import {
  getGroupNutrition as buildGroupNutrition,
  solutionToFeedPlanLines,
  type GroupNutritionOptions,
  type GroupNutritionStatus,
} from '@greenerherd/shared-db/group-nutrition-status';
import { toPublicFeedProduct } from '@greenerherd/shared-db/feed-catalog';
import { toPublicIndicativePrice } from '@greenerherd/shared-db/feed-pricing-catalog';
import { AppError } from '../lib/errors.js';

export class NutritionService {
  constructor(
    private readonly feedCatalog: FeedCatalog,
    private readonly pricingCatalog?: FeedPricingCatalog,
    private readonly requirementsCatalog?: NutritionRequirementsCatalog,
  ) {}

  listProducts(filter?: Parameters<FeedCatalog['list']>[0]) {
    return this.feedCatalog.list(filter);
  }

  getProductByNumber(productNumber: number) {
    const product = this.feedCatalog.getByProductNumber(productNumber);
    if (!product) {
      throw new AppError('FEED_NOT_FOUND', 'Feed product not found', 404);
    }
    return product;
  }

  getEligibleFeeds(
    ctx: FeedEligibilityContext,
    options: { include_reasons?: boolean; country_code?: string } = {},
  ) {
    const result = findEligibleFeeds(this.feedCatalog, ctx, {
      include_reasons: options.include_reasons ?? false,
    });

    if (!this.pricingCatalog) {
      return result;
    }

    const country = options.country_code?.toUpperCase();
    const eligible_products = result.eligible_products.map((p) => {
      const full = this.feedCatalog.getByProductNumber(p.product_number);
      if (!full) return p;
      const pricing = this.pricingCatalog!.resolveForProduct(
        full.name_en,
        full.feed_type,
        country,
      );
      return {
        ...p,
        indicative_pricing: pricing,
      };
    });

    return { ...result, eligible_products };
  }

  listIndicativePrices(countryCode?: string) {
    if (!this.pricingCatalog) {
      throw new AppError(
        'PRICING_UNAVAILABLE',
        'Indicative pricing catalogue not loaded',
        503,
      );
    }
    return this.pricingCatalog
      .list()
      .map((p) => toPublicIndicativePrice(p, countryCode));
  }

  getIndicativePrice(priceNumber: number, countryCode?: string) {
    if (!this.pricingCatalog) {
      throw new AppError(
        'PRICING_UNAVAILABLE',
        'Indicative pricing catalogue not loaded',
        503,
      );
    }
    const record = this.pricingCatalog.getByPriceNumber(priceNumber);
    if (!record) {
      throw new AppError('PRICE_NOT_FOUND', 'Indicative price not found', 404);
    }
    return toPublicIndicativePrice(record, countryCode);
  }

  getProductPricing(productNumber: number, countryCode?: string) {
    const product = this.getProductByNumber(productNumber);
    if (!this.pricingCatalog) {
      throw new AppError(
        'PRICING_UNAVAILABLE',
        'Indicative pricing catalogue not loaded',
        503,
      );
    }
    const pricing = this.pricingCatalog.resolveForProduct(
      product.name_en,
      product.feed_type,
      countryCode,
    );
    if (!pricing) {
      throw new AppError(
        'PRICE_NOT_FOUND',
        'No indicative price for this product name and type',
        404,
      );
    }
    return {
      product: toPublicFeedProduct(product),
      pricing,
    };
  }

  listFxRates() {
    if (!this.pricingCatalog) {
      throw new AppError(
        'PRICING_UNAVAILABLE',
        'Indicative pricing catalogue not loaded',
        503,
      );
    }
    return this.pricingCatalog.listFxRates();
  }

  recommendFeedPlan(request: FeedRecommendationRequest) {
    return this.runOptimizer(request);
  }

  getGroupNutrition(
    groupId: string,
    request: FeedRecommendationRequest,
    options: GroupNutritionOptions = {},
  ): GroupNutritionStatus {
    if (!this.requirementsCatalog) {
      throw new AppError(
        'REQUIREMENTS_UNAVAILABLE',
        'Nutrition requirements catalogue not loaded',
        503,
      );
    }
    try {
      return buildGroupNutrition(
        this.feedCatalog,
        this.requirementsCatalog,
        this.pricingCatalog,
        groupId,
        request,
        options,
      );
    } catch (err) {
      return this.handleOptimizerError(err);
    }
  }

  feedPlanLines(status: GroupNutritionStatus) {
    return solutionToFeedPlanLines(this.feedCatalog, status.recommendation);
  }

  private runOptimizer(request: FeedRecommendationRequest) {
    if (!this.requirementsCatalog) {
      throw new AppError(
        'REQUIREMENTS_UNAVAILABLE',
        'Nutrition requirements catalogue not loaded',
        503,
      );
    }
    try {
      return recommendFeedPlan(
        this.feedCatalog,
        this.requirementsCatalog,
        this.pricingCatalog,
        request,
      );
    } catch (err) {
      return this.handleOptimizerError(err);
    }
  }

  private handleOptimizerError(err: unknown): never {
    const message = err instanceof Error ? err.message : String(err);
    if (message.includes('No feasible solution')) {
      throw new AppError('OPTIMIZER_INFEASIBLE', message, 422);
    }
    throw new AppError('OPTIMIZER_ERROR', message, 500);
  }
}
