import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { FastifyInstance } from 'fastify';
import type { InventoryService } from '../../src/services/inventory-service.js';

export class InventoryWorld extends World {
  app!: FastifyInstance;
  service!: InventoryService;
  token!: string;
  lastResponse?: { statusCode: number; body: unknown };
  saved: Record<string, string> = {};
}

setWorldConstructor(InventoryWorld);
