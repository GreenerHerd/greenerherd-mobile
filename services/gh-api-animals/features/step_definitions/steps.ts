import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { signTestToken } from '../../src/lib/auth.js';
import type { ApiWorld } from './world.js';

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

function resolvePath(path: string, saved: Record<string, string>): string {
  let result = path;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(`{${key}}`).join(value);
    result = result.split(key).join(value);
  }
  return result;
}

function substituteSaved(raw: string, saved: Record<string, string>): string {
  let result = raw;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(`{${key}}`).join(value);
  }
  return result;
}

function authHeaders(token?: string, withJson = false): Record<string, string> {
  const headers: Record<string, string> = {};
  if (withJson) headers['content-type'] = 'application/json';
  if (token) headers.authorization = `Bearer ${token}`;
  return headers;
}

Given('the animals API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given('I am authenticated on farm {string}', function (this: ApiWorld, farmId: string) {
  this.saved[farmId] = farmId;
  this.authToken = signTestToken(this.secret, {
    user_id: 'owner-1',
    farm_ids: [farmId],
    role: 'OWNER',
  });
});

Given(
  'farm {string} has animal with ear tag {string}',
  async function (this: ApiWorld, farmId: string, earTag: string) {
    const animal = await this.animalService.createAnimal(farmId, {
      species: 'SHEEP',
      sex: 'FEMALE',
      breed: 'Najdi',
      ear_tag: earTag,
    });
    this.lastCreatedAnimalId = animal.id;
    this.saved.lastAnimalId = animal.id;
    this.saved.sellTestId = animal.id;
  },
);

Given(
  'farm {string} has animal with ear tag {string} and tags SICK',
  async function (this: ApiWorld, farmId: string, earTag: string) {
    const animal = await this.animalService.createAnimal(farmId, {
      species: 'CATTLE',
      sex: 'FEMALE',
      breed: 'Holstein',
      ear_tag: earTag,
      tags: ['SICK'],
    });
    this.lastCreatedAnimalId = animal.id;
  },
);

Given(
  'I save {string} from last created animal',
  function (this: ApiWorld, key: string) {
    assert.ok(this.lastCreatedAnimalId);
    this.saved[key] = this.lastCreatedAnimalId;
  },
);

When(
  'I POST {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: resolvePath(path, this.saved),
      headers: authHeaders(this.authToken, true),
      payload: parseBody(substituteSaved(doc, this.saved)),
    });
    this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
    const id = getAtPath(this.lastResponse.body, 'data.id');
    if (typeof id === 'string') {
      this.lastCreatedAnimalId = id;
      this.saved.lastAnimalId = id;
    }
  },
);

When('I POST {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'POST',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
});

When('I GET {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'GET',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
});

Then('the response status should be {int}', function (this: ApiWorld, status: number) {
  assert.equal(this.lastResponse?.statusCode, status);
});

Then(
  'the response JSON at {string} should be {string}',
  function (this: ApiWorld, path: string, expected: string) {
    const value = getAtPath(this.lastResponse?.body, path);
    if (expected === 'true') assert.equal(value, true);
    else if (expected === 'false') assert.equal(value, false);
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
    if (key.toLowerCase().includes('animal')) this.lastCreatedAnimalId = value;
  },
);
