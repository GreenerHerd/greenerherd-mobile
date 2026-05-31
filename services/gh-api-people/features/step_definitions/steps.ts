import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { signTestToken } from '../../src/lib/auth.js';
import type { ApiWorld } from './world.js';
import type { InMemoryPeopleRepository } from '../../src/repositories/in-memory-people-repository.js';

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

Given('the people API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given(
  'farm {string} has owner {string}',
  async function (this: ApiWorld, farmId: string, ownerId: string) {
    const repo = this.repo as InMemoryPeopleRepository;
    await repo.seedFarmOwner(farmId, {
      userId: ownerId,
      name: 'Farm Owner',
      email: 'owner@alfalah.test',
    });
    this.saved[farmId] = farmId;
  },
);

Given(
  'farm {string} has member {string} with role {word}',
  async function (this: ApiWorld, farmId: string, userId: string, role: string) {
    const repo = this.repo as InMemoryPeopleRepository;
    await repo.seedMember(farmId, {
      userId,
      name: userId,
      email: `${userId}@test.com`,
      role: role as 'MANAGER' | 'FARM_HAND' | 'VET',
    });
    this.saved[userId] = userId;
  },
);

Given(
  'I am authenticated as OWNER on farm {string}',
  function (this: ApiWorld, farmId: string) {
    this.authToken = signTestToken(this.secret, {
      user_id: 'owner-1',
      farm_ids: [farmId],
      role: 'OWNER',
    });
  },
);

Given(
  'I am authenticated as MANAGER on farm {string}',
  function (this: ApiWorld, farmId: string) {
    this.authToken = signTestToken(this.secret, {
      user_id: 'manager-1',
      farm_ids: [farmId],
      role: 'MANAGER',
    });
  },
);

Given(
  'I am authenticated as FARM_HAND {string} on farm {string}',
  function (this: ApiWorld, userId: string, farmId: string) {
    this.authToken = signTestToken(this.secret, {
      user_id: userId,
      farm_ids: [farmId],
      role: 'FARM_HAND',
    });
  },
);

When('I GET {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'GET',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
});

When(
  'I POST {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: resolvePath(path, this.saved),
      headers: authHeaders(this.authToken, true),
      payload: parseBody(doc),
    });
    this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
  },
);

When('I DELETE {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'DELETE',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = { statusCode: res.statusCode, body: parseResponseBody(res.body) };
});

When('I PATCH {string} with body:', async function (this: ApiWorld, path: string, doc: string) {
  const res = await this.app.inject({
    method: 'PATCH',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken, true),
    payload: parseBody(doc),
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
  'the response JSON at {string} should contain {string}',
  function (this: ApiWorld, path: string, fragment: string) {
    const value = getAtPath(this.lastResponse?.body, path);
    assert.ok(typeof value === 'string' && value.includes(fragment));
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
