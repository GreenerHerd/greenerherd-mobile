import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { signTestToken } from '../../src/lib/auth.js';
import type { ApiWorld } from './world.js';
import type { Species, SpeciesPurpose } from '../../src/domain/types.js';
import { substituteSaved } from './notification-steps.js';

function parseBody(raw: string): unknown {
  return JSON.parse(raw.trim());
}

function getAtPath(obj: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc && typeof acc === 'object' && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, obj);
}

Given('the farms API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given(
  'I am authenticated as farm owner {string}',
  function (this: ApiWorld, userId: string) {
    this.authToken = signTestToken(this.secret, {
      user_id: userId,
      farm_ids: [],
      role: 'OWNER',
    });
  },
);

Given('I have no auth token', function (this: ApiWorld) {
  this.authToken = undefined;
});

Given(
  'my token includes farm {string}',
  function (this: ApiWorld, farmKey: string) {
    const farmId = this.saved[farmKey] ?? farmKey;
    this.authToken = signTestToken(this.secret, {
      user_id: 'owner-1',
      farm_ids: [farmId],
      role: 'OWNER',
    });
  },
);

Given(
  'a farm exists with id {string}',
  async function (this: ApiWorld, farmKey: string) {
    const farm = await this.farmService.createFarm({
      name: `Farm ${farmKey}`,
      country: 'SA',
      housing_type: 'INDOOR_FANS',
      preferred_currency: 'SAR',
      preferred_lang: 'EN',
      owner_user_id: 'owner-1',
    });
    this.saved[farmKey] = farm.id;
    this.saved.farmId = farm.id;
  },
);

function resolvePath(path: string, saved: Record<string, string>): string {
  let result = path;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(key).join(value);
  }
  return result;
}

function parseResponseBody(raw: string): unknown {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function authHeaders(token?: string, withJson = false): Record<string, string> {
  const headers: Record<string, string> = {};
  if (withJson) headers['content-type'] = 'application/json';
  if (token) headers.authorization = `Bearer ${token}`;
  return headers;
}

Given(
  'farm {string} has species {word} for {word}',
  async function (
    this: ApiWorld,
    farmKey: string,
    species: Species,
    purpose: SpeciesPurpose,
  ) {
    const farmId = this.saved[farmKey];
    assert.ok(farmId, `Farm ${farmKey} must exist`);
    await this.farmService.addSpecies(farmId, { species, purpose });
  },
);

When(
  'I POST {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const resolved = resolvePath(path, this.saved);
    const res = await this.app.inject({
      method: 'POST',
      url: resolved,
      headers: authHeaders(this.authToken, true),
      payload: parseBody(substituteSaved(doc, this.saved)),
    });
    this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
    const id = getAtPath(this.lastResponse.body, 'data.id');
    if (typeof id === 'string') this.saved.farmId = id;
  },
);

When(
  'I PUT {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const resolved = resolvePath(path, this.saved);
    const res = await this.app.inject({
      method: 'PUT',
      url: resolved,
      headers: authHeaders(this.authToken, true),
      payload: parseBody(substituteSaved(doc, this.saved)),
    });
    this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
  },
);

When('I GET {string}', async function (this: ApiWorld, path: string) {
  const resolved = resolvePath(path, this.saved);
  const res = await this.app.inject({
    method: 'GET',
    url: resolved,
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
});

Then(
  'the response status should be {int}',
  function (this: ApiWorld, status: number) {
    assert.equal(this.lastResponse?.statusCode, status);
  },
);

Then(
  'the response JSON at {string} should be {string}',
  function (this: ApiWorld, path: string, expected: string) {
    const value = getAtPath(this.lastResponse?.body, path);
    if (expected === 'true') assert.equal(value, true);
    else if (expected === 'false') assert.equal(value, false);
    else if (!Number.isNaN(Number(expected))) assert.equal(value, Number(expected));
    else assert.equal(value, expected);
  },
);

Then(
  'the response JSON at {string} should be true',
  function (this: ApiWorld, path: string) {
    assert.equal(getAtPath(this.lastResponse?.body, path), true);
  },
);

Then(
  'the response JSON at {string} should be false',
  function (this: ApiWorld, path: string) {
    assert.equal(getAtPath(this.lastResponse?.body, path), false);
  },
);

Then(
  'the response JSON at {string} should be {int}',
  function (this: ApiWorld, path: string, expected: number) {
    assert.equal(getAtPath(this.lastResponse?.body, path), expected);
  },
);

Then(
  'I save {string} as {string}',
  function (this: ApiWorld, path: string, key: string) {
    const value = getAtPath(this.lastResponse?.body, path);
    assert.ok(typeof value === 'string');
    this.saved[key] = value;
  },
);
