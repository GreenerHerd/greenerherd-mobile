#!/usr/bin/env bash
# Run Playwright BDD UI tests (@e2e tagged scenarios) against Flutter web build.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/e2e"

if [[ ! -d node_modules ]]; then
  echo "Installing e2e dependencies…"
  npm install
  npx playwright install chromium
fi

export CI="${CI:-}"
npm test
