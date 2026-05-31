#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "=== Installing gh-shared ==="
(cd "$ROOT/gh-shared" && npm install --silent)
echo "=== Unit tests: gh-shared ==="
(cd "$ROOT/gh-shared" && npm test)
SERVICES=(gh-api-farms gh-api-people gh-api-animals gh-api-nutrition gh-api-inventory gh-api-tasks gh-api-finance)
for svc in "${SERVICES[@]}"; do
  echo "=== BDD: $svc ==="
  (cd "$ROOT/$svc" && npm install --silent && npm run test:bdd)
done
echo "All BDD suites passed."
