import { Given, Then, When } from '@cucumber/cucumber';
import assert from 'node:assert/strict';
import type { ApiWorld } from './world.js';

function resolvePath(path: string, saved: Record<string, string>): string {
  let result = path;
  for (const [key, value] of Object.entries(saved)) {
    result = result.split(`{${key}}`).join(value);
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

function getAtPath(obj: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc && typeof acc === 'object' && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, obj);
}

When(
  'I GET {string} without auth',
  async function (this: ApiWorld, path: string) {
    const res = await this.app.inject({
      method: 'GET',
      url: resolvePath(path, this.saved),
    });
    this.lastResponse = {
      statusCode: res.statusCode,
      body: parseResponseBody(res.body),
    };
  },
);

Given(
  'cattle breed {string} is saved as {string}',
  function (this: ApiWorld, nameEn: string, key: string) {
    assert.ok(this.breedCatalog, 'breed catalog not loaded');
    const breed = this.breedCatalog
      .list('CATTLE')
      .find((b) => b.name_en === nameEn);
    assert.ok(breed, `cattle breed not found: ${nameEn}`);
    this.saved[key] = breed.id;
  },
);

Then(
  'the response JSON at {string} should be at least {int}',
  function (this: ApiWorld, jsonPath: string, minimum: number) {
    const value = getAtPath(this.lastResponse?.body, jsonPath);
    assert.ok(typeof value === 'number' && value >= minimum, `${jsonPath}=${value}`);
  },
);

Then(
  'the response data includes a breed named {string}',
  function (this: ApiWorld, nameEn: string) {
    const data = getAtPath(this.lastResponse?.body, 'data');
    assert.ok(Array.isArray(data), 'expected data array');
    const found = data.some(
      (item) =>
        item &&
        typeof item === 'object' &&
        (item as { name_en?: string }).name_en === nameEn,
    );
    assert.ok(found, `breed not found in response: ${nameEn}`);
  },
);
