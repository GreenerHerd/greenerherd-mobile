#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
(cd "$ROOT/gh-shared" && npm install --silent)
cd "$ROOT/db"
npm install
npm run db:up
echo "Waiting for Postgres..."
for _ in $(seq 1 30); do
  if npm run db:migrate 2>/dev/null; then
    break
  fi
  sleep 1
done
npm run db:seed
echo ""
echo "Database ready. Export:"
echo "  export DATABASE_URL=postgres://greenerherd:greenerherd@localhost:5432/greenerherd"
