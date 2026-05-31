import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import { signTestToken } from '../../src/lib/auth.js';
import type { ApiWorld } from './world.js';

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

Given('the finance API is running', function (this: ApiWorld) {
  assert.ok(this.app);
});

Given('my token includes farm {string}', function (this: ApiWorld, farmId: string) {
  this.authToken = signTestToken(this.secret, {
    user_id: 'u1',
    farm_ids: [farmId],
    role: 'OWNER',
  });
});

When('I GET {string}', async function (this: ApiWorld, path: string) {
  const res = await this.app.inject({
    method: 'GET',
    url: path,
    headers: this.authToken
      ? { authorization: `Bearer ${this.authToken}` }
      : {},
  });
  this.lastResponse = {
    statusCode: res.statusCode,
    body: JSON.parse(res.body || '{}'),
  };
});

When(
  'I POST {string} with body:',
  async function (this: ApiWorld, path: string, body: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: path,
      headers: {
        'content-type': 'application/json',
        ...(this.authToken ? { authorization: `Bearer ${this.authToken}` } : {}),
      },
      payload: parseBody(body),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: JSON.parse(res.body || '{}'),
    };
  },
);

Then('the response status should be {int}', function (this: ApiWorld, status: number) {
  assert.equal(this.lastResponse?.statusCode, status);
});

Then(
  'the response JSON at {string} should be {int}',
  function (this: ApiWorld, path: string, expected: number) {
    const value = getAtPath(this.lastResponse?.body, path);
    assert.equal(value, expected);
  },
);

Then(
  'the response JSON at {string} should be greater than {int}',
  function (this: ApiWorld, path: string, min: number) {
    const value = getAtPath(this.lastResponse?.body, path);
    assert.ok(typeof value === 'number' && value > min);
  },
);
