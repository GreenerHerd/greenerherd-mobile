import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import {
  NUTRITION_BDD_SCENARIOS,
  type NutritionBddScenario,
} from '@greenerherd/shared-db/nutrition-bdd-scenarios';
import {
  recommendMaxOveragePercent,
  validateRecommendation,
} from '@greenerherd/shared-db/feed-recommendation-validation';
import type { FeedRecommendationResult } from '@greenerherd/shared-db/feed-recommendation';
import { matchesSpeciesScope } from '@greenerherd/shared-db/feed-catalog';
import type { FeedSpeciesScope } from '@greenerherd/shared-db/feed-catalog';
import type { ApiWorld } from './world.js';

function scenarioById(id: string): NutritionBddScenario {
  const scenario = NUTRITION_BDD_SCENARIOS.find((s) => s.id === id);
  if (!scenario) throw new Error(`Unknown nutrition BDD scenario: ${id}`);
  return scenario;
}

function recommendationData(body: unknown): FeedRecommendationResult | null {
  const data = getAtPath(body, 'data');
  if (!data || typeof data !== 'object') return null;
  return data as FeedRecommendationResult;
}

function parseBody(raw: string): unknown {
  return JSON.parse(raw.trim());
}

function parseResponseBody(raw: string): unknown {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function getAtPath(obj: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc && typeof acc === 'object' && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, obj);
}

function substituteSaved(raw: string, saved: Record<string, string>): string {
  let result = raw;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(`{${key}}`).join(value);
  }
  return result;
}

Given('the nutrition API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given(
  'the feed catalog has at least {int} products with eligibility rules',
  function (this: ApiWorld, minimum: number) {
    assert.ok(this.feedCatalog, 'feed catalog required');
    const products = this.feedCatalog!.list();
    assert.ok(
      products.length >= minimum,
      `expected >= ${minimum} products, got ${products.length}`,
    );
    const withoutRules = products.filter((p) => p.eligibility_rules.length === 0);
    assert.equal(
      withoutRules.length,
      0,
      `products missing rules: ${withoutRules.map((p) => p.name_en).join(', ')}`,
    );
    const ruleCount = products.reduce((n, p) => n + p.eligibility_rules.length, 0);
    assert.ok(
      ruleCount >= minimum,
      `expected >= ${minimum} total rules, got ${ruleCount}`,
    );
  },
);

Given(
  'feed product number for {string} is saved as {word}',
  function (this: ApiWorld, productName: string, saveKey: string) {
    assert.ok(this.feedCatalog, 'feed catalog required');
    const product = this.feedCatalog!.list().find((p) => p.name_en === productName);
    assert.ok(product, `product not found: ${productName}`);
    this.saved[saveKey] = String(product.product_number);
  },
);

When(
  'I GET {string}',
  async function (this: ApiWorld, path: string) {
    const res = await this.app.inject({
      method: 'GET',
      url: substituteSaved(path, this.saved),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I POST {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: path,
      headers: { 'content-type': 'application/json' },
      payload: parseBody(substituteSaved(doc, this.saved)),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

Then('the response status should be {int}', function (this: ApiWorld, status: number) {
  assert.equal(this.lastResponse?.statusCode, status);
});

Then(
  'the response JSON at {string} should be {string}',
  function (this: ApiWorld, jsonPath: string, expected: string) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    if (expected === 'true') assert.equal(value, true);
    else if (expected === 'false') assert.equal(value, false);
    else assert.equal(String(value), expected);
  },
);

Then(
  'the response JSON at {string} should be at least {int}',
  function (this: ApiWorld, jsonPath: string, minimum: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(typeof value === 'number' && value >= minimum);
  },
);

Then(
  'the response JSON at {string} should be greater than {int}',
  function (this: ApiWorld, jsonPath: string, minimum: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(typeof value === 'number' && value > minimum);
  },
);

Then(
  'the response JSON at {string} should not be empty',
  function (this: ApiWorld, jsonPath: string) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    if (Array.isArray(value)) {
      assert.ok(value.length > 0);
      return;
    }
    if (value && typeof value === 'object') {
      assert.ok(Object.keys(value as object).length > 0);
      return;
    }
    assert.fail(`expected non-empty value at ${jsonPath}`);
  },
);

Then(
  'the response feed_lines include product number {int}',
  function (this: ApiWorld, productNumber: number) {
    const lines = getAtPath(this.lastResponse?.body, 'data.feed_lines');
    assert.ok(Array.isArray(lines), 'expected data.feed_lines array');
    const match = lines.some(
      (l) => (l as Record<string, unknown>)['product_number'] === productNumber,
    );
    assert.ok(
      match,
      `expected feed_lines to include product_number=${productNumber}`,
    );
  },
);

Then(
  'the response feed_lines entry for product number {int} has name {string}',
  function (this: ApiWorld, productNumber: number, expectedName: string) {
    const lines = getAtPath(this.lastResponse?.body, 'data.feed_lines');
    assert.ok(Array.isArray(lines), 'expected data.feed_lines array');
    const match = lines.find(
      (l) => (l as Record<string, unknown>)['product_number'] === productNumber,
    );
    assert.ok(match, `feed_lines missing product_number=${productNumber}`);
    const name = (match as Record<string, unknown>)['name'];
    assert.equal(String(name), expectedName);
  },
);

When(
  'I request nutrition recommend for scenario {string}',
  async function (this: ApiWorld, scenarioId: string) {
    const scenario = scenarioById(scenarioId);
    this.matrixScenarioId = scenarioId;
    const res = await this.app.inject({
      method: 'POST',
      url: `/api/v1/groups/bdd-${scenarioId}/nutrition/recommend`,
      headers: { 'content-type': 'application/json' },
      payload: { ...scenario.request, country_code: 'SA' },
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

Then('the nutrition matrix result should match expectations', function (this: ApiWorld) {
  const scenario = scenarioById(this.matrixScenarioId ?? '');
  const expectedStatus = scenario.expect_success ? 200 : 422;
  assert.equal(this.lastResponse?.statusCode, expectedStatus);
  if (!scenario.expect_success) return;

  const data = recommendationData(this.lastResponse?.body);
  assert.ok(data, 'expected recommendation data');
  assert.equal(data!.profile_code, scenario.expected_profile_code);
  assert.ok(
    data!.optimizer_pass === 'complete' || data!.optimizer_pass === 'partial',
    `unexpected optimizer_pass for ${scenario.id}`,
  );
  assert.ok(Array.isArray(data!.nutrient_gaps));
  assert.ok(this.feedCatalog, 'feed catalog required for validation');
  const maxOverage =
    scenario.request.overage_percent ??
    recommendMaxOveragePercent(
      data!.profile_code,
      data!.requirements.optimizer,
    );
  const validation = validateRecommendation(data!, this.feedCatalog!, {
    max_overage_percent: maxOverage,
    enforce_feed_type_split: true,
  });
  assert.ok(
    validation.valid,
    `scenario ${scenario.id}: ${validation.errors.join('; ')}`,
  );
});

Then('the recommendation meets optimizer nutrient thresholds', function (this: ApiWorld) {
  const data = recommendationData(this.lastResponse?.body);
  assert.ok(data?.optimizer_pass === 'complete', 'optimizer must complete');
  assert.ok(this.feedCatalog, 'feed catalog required');
  const maxOverage = recommendMaxOveragePercent(
    data!.profile_code,
    data!.requirements.optimizer,
  );
  const validation = validateRecommendation(data!, this.feedCatalog!, {
    max_overage_percent: maxOverage,
    enforce_feed_type_split: false,
  });
  const primaryErrors = validation.errors.filter((e) =>
    /dryMatter|crudeProtein|protein|tdn/i.test(e),
  );
  assert.ok(
    primaryErrors.length === 0,
    primaryErrors.join('; ') || validation.errors.join('; '),
  );
});

Then(
  'the recommendation meets cattle feed-type DM limits when applicable',
  function (this: ApiWorld) {
    const data = recommendationData(this.lastResponse?.body);
    assert.ok(data?.optimizer_pass === 'complete', 'optimizer must complete');
    assert.ok(this.feedCatalog);
    const maxOverage = recommendMaxOveragePercent(
      data!.profile_code,
      data!.requirements.optimizer,
    );
    const validation = validateRecommendation(data!, this.feedCatalog!, {
      max_overage_percent: maxOverage,
      enforce_feed_type_split: true,
    });
    assert.ok(validation.feed_type_compliant, validation.errors.join('; '));
  },
);

function eligibleProducts(body: unknown): Array<Record<string, unknown>> {
  const list = getAtPath(body, 'data.eligible_products');
  if (!Array.isArray(list)) return [];
  return list.filter(
    (p): p is Record<string, unknown> => Boolean(p) && typeof p === 'object',
  );
}

function eligibleProductNames(body: unknown): string[] {
  return eligibleProducts(body)
    .map((p) => p.name_en as string | undefined)
    .filter((n): n is string => Boolean(n));
}

function eligibleProductByName(
  body: unknown,
  feedName: string,
): Record<string, unknown> | undefined {
  return eligibleProducts(body).find((p) => p.name_en === feedName);
}

function referenceFeedProducts(body: unknown): Array<Record<string, unknown>> {
  const list = getAtPath(body, 'data');
  if (!Array.isArray(list)) return [];
  return list.filter(
    (p): p is Record<string, unknown> => Boolean(p) && typeof p === 'object',
  );
}

function referenceFeedByName(
  body: unknown,
  feedName: string,
): Record<string, unknown> | undefined {
  return referenceFeedProducts(body).find((p) => p.name_en === feedName);
}

function responseProduct(body: unknown): Record<string, unknown> | undefined {
  const data = getAtPath(body, 'data');
  if (!data || typeof data !== 'object') return undefined;
  return data as Record<string, unknown>;
}

function rulesFromPayload(
  product: Record<string, unknown>,
): Array<Record<string, unknown>> {
  const rules = product.eligibility_rules;
  if (!Array.isArray(rules)) return [];
  return rules.filter(
    (r): r is Record<string, unknown> => Boolean(r) && typeof r === 'object',
  );
}

Then(
  'eligible feed {string} is included for dairy cattle',
  function (this: ApiWorld, feedName: string) {
    const names = eligibleProductNames(this.lastResponse?.body);
    assert.ok(names.includes(feedName), `expected ${feedName} in eligible list`);
  },
);

Then(
  'eligible feed {string} is excluded for dry cattle',
  function (this: ApiWorld, feedName: string) {
    const names = eligibleProductNames(this.lastResponse?.body);
    assert.ok(!names.includes(feedName), `expected ${feedName} not eligible for dry`);
  },
);

Then(
  'eligible feed {string} is excluded for sheep',
  function (this: ApiWorld, feedName: string) {
    const names = eligibleProductNames(this.lastResponse?.body);
    assert.ok(!names.includes(feedName), `expected ${feedName} not eligible for sheep`);
  },
);

Then(
  'eligible feed {string} is included for sheep',
  function (this: ApiWorld, feedName: string) {
    const names = eligibleProductNames(this.lastResponse?.body);
    assert.ok(names.includes(feedName), `expected ${feedName} in eligible list for sheep`);
  },
);

Then(
  'eligible feed {string} includes eligibility rules in the response',
  function (this: ApiWorld, feedName: string) {
    const product = eligibleProductByName(this.lastResponse?.body, feedName);
    assert.ok(product, `expected ${feedName} in eligible list`);
    const rules = rulesFromPayload(product);
    assert.ok(rules.length > 0, `expected eligibility_rules on ${feedName}`);
  },
);

Then(
  'eligible feed {string} has a matching rule with species_scope {string}',
  function (this: ApiWorld, feedName: string, scope: string) {
    const product = eligibleProductByName(this.lastResponse?.body, feedName);
    assert.ok(product, `expected ${feedName} in eligible list`);
    const rules = rulesFromPayload(product);
    assert.ok(
      rules.some((r) => r.species_scope === scope),
      `expected rule with species_scope ${scope} on ${feedName}`,
    );
  },
);

Then('each reference feed product has at least one eligibility rule', function (this: ApiWorld) {
  const products = referenceFeedProducts(this.lastResponse?.body);
  assert.ok(products.length > 0, 'expected reference feed products');
  for (const product of products) {
    const rules = rulesFromPayload(product);
    assert.ok(
      rules.length > 0,
      `expected eligibility_rules on ${String(product.name_en)}`,
    );
  }
});

Then(
  'each reference feed product has a rule for species {string}',
  function (this: ApiWorld, species: 'CATTLE' | 'GOAT' | 'SHEEP') {
    const products = referenceFeedProducts(this.lastResponse?.body);
    assert.ok(products.length > 0, 'expected reference feed products');
    for (const product of products) {
      const rules = rulesFromPayload(product);
      assert.ok(
        rules.some((r) =>
          matchesSpeciesScope(r.species_scope as FeedSpeciesScope, species),
        ),
        `${String(product.name_en)} has no rule for ${species}`,
      );
    }
  },
);

Then(
  'reference feed {string} is listed with species scope {string}',
  function (this: ApiWorld, feedName: string, scope: string) {
    const product = referenceFeedByName(this.lastResponse?.body, feedName);
    assert.ok(product, `expected ${feedName} in reference list`);
    const scopes = product.species_scopes as string[] | undefined;
    assert.ok(
      Array.isArray(scopes) && scopes.includes(scope),
      `expected species_scopes to include ${scope}, got ${JSON.stringify(scopes)}`,
    );
  },
);

Then(
  'reference feed {string} has exactly {int} eligibility rules',
  function (this: ApiWorld, feedName: string, count: number) {
    const product = referenceFeedByName(this.lastResponse?.body, feedName);
    assert.ok(product, `expected ${feedName} in reference list`);
    assert.equal(rulesFromPayload(product).length, count);
  },
);

Then(
  'reference feed {string} has rules for species scopes {string} and {string}',
  function (this: ApiWorld, feedName: string, scopeA: string, scopeB: string) {
    const product = referenceFeedByName(this.lastResponse?.body, feedName);
    assert.ok(product, `expected ${feedName} in reference list`);
    const scopes = rulesFromPayload(product).map((r) => r.species_scope);
    assert.ok(scopes.includes(scopeA), `missing rule scope ${scopeA}`);
    assert.ok(scopes.includes(scopeB), `missing rule scope ${scopeB}`);
  },
);

Then(
  'the response product has at least {int} eligibility rule',
  function (this: ApiWorld, minimum: number) {
    const product = responseProduct(this.lastResponse?.body);
    assert.ok(product, 'expected single product in data');
    assert.ok(rulesFromPayload(product).length >= minimum);
  },
);

Then(
  'the response product has a rule with species_scope {string}',
  function (this: ApiWorld, scope: string) {
    const product = responseProduct(this.lastResponse?.body);
    assert.ok(product, 'expected single product in data');
    assert.ok(
      rulesFromPayload(product).some((r) => r.species_scope === scope),
      `expected rule with species_scope ${scope}`,
    );
  },
);

Then('no eligible product is restricted to cattle only', function (this: ApiWorld) {
  assert.ok(this.feedCatalog, 'feed catalog required');
  const list = getAtPath(this.lastResponse?.body, 'data.eligible_products');
  assert.ok(Array.isArray(list));
  for (const item of list) {
    if (!item || typeof item !== 'object') continue;
    const num = (item as { product_number?: number }).product_number;
    if (num == null) continue;
    const full = this.feedCatalog!.getByProductNumber(num);
    const cattleOnly =
      full != null &&
      full.eligibility_rules.length > 0 &&
      full.eligibility_rules.every((r) => r.species_scope === 'CATTLE');
    if (cattleOnly) {
      assert.fail(
        `cattle-only product should not be eligible for sheep: ${full.name_en}`,
      );
    }
  }
});

Then(
  'the eligible products include pricing for country {string}',
  function (this: ApiWorld, country: string) {
    const data = getAtPath(this.lastResponse?.body, 'data.eligible_products');
    assert.ok(Array.isArray(data) && data.length > 0);
    const withPricing = data.filter(
      (p) =>
        p &&
        typeof p === 'object' &&
        (p as { indicative_pricing?: { local_price_per_kg?: number } })
          .indicative_pricing?.local_price_per_kg != null,
    );
    assert.ok(withPricing.length > 0, 'expected at least one product with local pricing');
    const first = withPricing[0] as {
      indicative_pricing: { currency: string };
    };
    assert.ok(first.indicative_pricing.currency);
  },
);
