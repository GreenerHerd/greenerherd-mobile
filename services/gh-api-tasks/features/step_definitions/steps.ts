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
    result = result.replaceAll(`{${key}}`, value);
    if (result.includes(key)) {
      result = result.split(key).join(value);
    }
  }
  return result;
}

function authHeaders(token?: string, withJson = false): Record<string, string> {
  const headers: Record<string, string> = {};
  if (withJson) headers['content-type'] = 'application/json';
  if (token) headers.authorization = `Bearer ${token}`;
  return headers;
}

Given('the tasks API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given('I have no auth token', function (this: ApiWorld) {
  this.authToken = undefined;
});

Given('I have an invalid auth token', function (this: ApiWorld) {
  this.authToken = 'not.a.valid.jwt';
});

Given(
  'I am authenticated for farm {string}',
  function (this: ApiWorld, farmKey: string) {
    const farmId = this.saved[farmKey] ?? farmKey;
    this.saved.farmId = farmId;
    this.authToken = signTestToken(this.secret, {
      user_id: 'owner-1',
      farm_ids: [farmId],
      role: 'OWNER',
    });
  },
);

Given(
  'my token includes farm {string} but not {string}',
  function (this: ApiWorld, allowed: string, denied: string) {
    const allowedId = this.saved[allowed] ?? allowed;
    this.authToken = signTestToken(this.secret, {
      user_id: 'owner-1',
      farm_ids: [allowedId],
      role: 'OWNER',
    });
    this.saved.deniedFarmId = this.saved[denied] ?? denied;
  },
);

When('I GET {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'GET',
    url: resolvePath(path, this.saved),
    headers: authHeaders(this.authToken),
  });
  this.lastResponse = {
    statusCode: res.statusCode,
    body: parseResponseBody(res.body),
  };
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
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I POST {string} with scheduler secret {string} and body:',
  async function (this: ApiWorld, path: string, secret: string, doc: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: resolvePath(path, this.saved),
      headers: {
        'content-type': 'application/json',
        'x-scheduler-secret': secret,
      },
      payload: parseBody(doc),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I POST {string} with wrong scheduler secret',
  async function (this: ApiWorld, path: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: resolvePath(path, this.saved),
      headers: {
        'content-type': 'application/json',
        'x-scheduler-secret': 'wrong-secret',
      },
      payload: {},
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
  'the response JSON at {string} should be greater than {int}',
  function (this: ApiWorld, jsonPath: string, minimum: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(typeof value === 'number' && value > minimum);
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
  'the response JSON at {string} should be {int}',
  function (this: ApiWorld, jsonPath: string, expected: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.equal(value, expected);
  },
);

Then(
  'I save {string} as {string}',
  function (this: ApiWorld, jsonPath: string, key: string) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(value !== undefined && value !== null);
    this.saved[key] = String(value);
  },
);

Then(
  'the response JSON at {string} should equal saved {string}',
  function (this: ApiWorld, jsonPath: string, key: string) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.equal(String(value), this.saved[key]);
  },
);
