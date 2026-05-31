import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const require = createRequire(import.meta.url);
const dir = path.dirname(fileURLToPath(import.meta.url));

const cattle = require(path.join(dir, 'cattle-optimizer.cjs')) as {
  optimizeFeedMix: (
    requirements: Record<string, number>,
    feeds: Record<string, unknown>[],
    options?: { overagePercent?: number },
  ) => Record<string, unknown>;
};

const smallRuminant = require(path.join(dir, 'small-ruminant-optimizer.cjs')) as {
  optimizeSmallRuminantFeedMix: (
    requirements: Record<string, number>,
    feeds: Record<string, unknown>[],
    options?: { overagePercent?: number },
  ) => Record<string, unknown>;
};

export function optimizeCattleFeedMix(
  requirements: Record<string, number>,
  feeds: Record<string, unknown>[],
  options?: { overagePercent?: number },
) {
  return cattle.optimizeFeedMix(requirements, feeds, options);
}

export function optimizeSmallRuminantFeedMix(
  requirements: Record<string, number>,
  feeds: Record<string, unknown>[],
  options?: { overagePercent?: number },
) {
  return smallRuminant.optimizeSmallRuminantFeedMix(requirements, feeds, options);
}
