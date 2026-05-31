#!/usr/bin/env bash
# Build Flutter web (HTML renderer for DOM accessibility) and serve for Playwright.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-7357}"

cd "$ROOT"

if [[ ! -d build/web ]] || [[ -n "${E2E_FORCE_BUILD:-}" ]] || [[ -n "${CI:-}" ]]; then
  echo "Building Flutter web for E2E (first run may take a few minutes)…"
  # Default web build (no --web-renderer; removed in recent Flutter SDKs).
  flutter build web \
    --dart-define=API_HOST=localhost \
    -t lib/main.dart
fi

echo "Serving GreenerHerd web at http://127.0.0.1:${PORT} (SPA fallback)"
cd build/web
exec npx --yes serve@14.2.4 -s . -l "$PORT"
