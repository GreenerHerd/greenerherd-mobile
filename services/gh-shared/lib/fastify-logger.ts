/**
 * Shared Pino logger options for GreenerHerd Fastify services.
 *
 * Set `LOG_LEVEL` (trace | debug | info | warn | error | fatal). Default: `info`.
 * Request/response lines are emitted automatically when passed to `Fastify({ logger })`.
 */
export function createFastifyLogger(service: string) {
  const level = process.env.LOG_LEVEL ?? 'info';
  return {
    level,
    base: { service },
  };
}
