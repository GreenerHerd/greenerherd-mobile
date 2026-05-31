import { Given, When } from '@cucumber/cucumber';
import { signTestToken } from '../../src/lib/auth.js';
import type { ApiWorld } from './world.js';

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

Given('I have an invalid auth token', function (this: ApiWorld) {
  this.authToken = 'not.a.valid.jwt.token';
});

Given(
  'I am authenticated for farm id {string}',
  function (this: ApiWorld, farmId: string) {
    this.authToken = signTestToken(this.secret, {
      user_id: 'owner-1',
      farm_ids: [farmId],
      role: 'OWNER',
    });
  },
);

When(
  'I POST {string} with malformed JSON',
  async function (this: ApiWorld, path: string) {
    const res = await this.app.inject({
      method: 'POST',
      url: resolvePath(path, this.saved),
      headers: authHeaders(this.authToken, true),
      payload: '{ not valid json',
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

When(
  'I PATCH {string} with body:',
  async function (this: ApiWorld, path: string, doc: string) {
    const res = await this.app.inject({
      method: 'PATCH',
      url: resolvePath(path, this.saved),
      headers: authHeaders(this.authToken, true),
      payload: JSON.parse(doc.trim()),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);
