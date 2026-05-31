#!/usr/bin/env bash
# Comprehensive GreenerHerd test pack: Postgres + API health + backend BDD + Flutter BDD + live stack checks.
#
# Prerequisites (manual, before running):
#   1. Docker running
#   2. ./services/setup-db.sh   (or db up + migrate + seed)
#   3. ./services/start-all.sh  (all APIs healthy on 3001–3008)
#   4. Optional: flutter run on emulator for manual UI (not required for this script)
#
# Usage:
#   ./scripts/run-comprehensive-tests.sh              # backend BDD + flutter BDD + live checks
#   ./scripts/run-comprehensive-tests.sh --with-unit  # also flutter test/ (all unit tests)
#   ./scripts/run-comprehensive-tests.sh --skip-backend-bdd
#   ./scripts/run-comprehensive-tests.sh --skip-flutter
#   ./scripts/run-comprehensive-tests.sh --with-playwright  # browser E2E (@e2e), no APIs required
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVICES_ROOT="$ROOT/services"
DB_URL="${DATABASE_URL:-postgres://greenerherd:greenerherd@localhost:5432/greenerherd}"
JWT="${JWT_SECRET:-dev-secret-change-me}"
TOKEN="${GH_DEV_BEARER:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLTEiXSwicm9sZSI6Ik9XTkVSIiwiaWF0IjoxNzc5MTI1NzQzLCJleHAiOjE4MTA2NjE3NDN9.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo}"

WITH_UNIT=false
WITH_PLAYWRIGHT=false
SKIP_BACKEND_BDD=false
SKIP_FLUTTER=false
RUN_SHARED_UNIT=false

for arg in "$@"; do
  case "$arg" in
    --with-unit) WITH_UNIT=true ;;
    --with-playwright) WITH_PLAYWRIGHT=true ;;
    --with-shared-unit) RUN_SHARED_UNIT=true ;;
    --skip-backend-bdd) SKIP_BACKEND_BDD=true ;;
    --skip-flutter) SKIP_FLUTTER=true ;;
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0
      ;;
  esac
done

export DATABASE_URL="$DB_URL"
export JWT_SECRET="$JWT"
export LIVE_STACK_TESTS=1

log() { echo ""; echo "=== $* ==="; }

fail() { echo "FAIL: $*" >&2; exit 1; }

# --- 1. Postgres ---
log "Postgres"
if ! docker ps --format '{{.Names}}' | grep -q '^greenerherd-postgres$'; then
  echo "Postgres container not running. Starting via services/db…"
  (cd "$SERVICES_ROOT/db" && npm run db:up)
  sleep 3
fi
docker exec greenerherd-postgres pg_isready -U greenerherd -d greenerherd >/dev/null \
  || fail "Postgres not ready (run: cd services && ./setup-db.sh)"

# --- 2. API services health ---
log "API services (3001–3008)"
if [[ -x "$SERVICES_ROOT/start-all.sh" ]]; then
  "$SERVICES_ROOT/start-all.sh" status || true
fi
PORTS=(3001 3002 3003 3004 3005 3006 3007 3008)
for p in "${PORTS[@]}"; do
  curl -sf "http://127.0.0.1:${p}/health" >/dev/null \
    || fail "Service on port $p not healthy. Run: cd services && ./start-all.sh"
done
echo "All API /health endpoints OK."

# --- 3. Database row counts (farm-1) ---
log "Database counts (farm-1)"
psql_query() {
  docker exec greenerherd-postgres psql -U greenerherd -d greenerherd -tAc "$1"
}
DB_GROUPS="$(psql_query "SELECT COUNT(*) FROM animal_groups WHERE farm_id='farm-1';")"
DB_ANIMALS="$(psql_query "SELECT COUNT(*) FROM animals WHERE farm_id='farm-1';")"
echo "animal_groups: $DB_GROUPS"
echo "animals:       $DB_ANIMALS"

# --- 4. Live API vs DB alignment ---
log "Live API vs database"
API_GROUPS="$(curl -sf -H "Authorization: Bearer $TOKEN" \
  "http://127.0.0.1:3006/api/v1/farms/farm-1/groups" \
  | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',[])))")"
API_ANIMALS="$(curl -sf -H "Authorization: Bearer $TOKEN" \
  "http://127.0.0.1:3006/api/v1/farms/farm-1/animals" \
  | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',[])))")"
echo "API groups:  $API_GROUPS"
echo "API animals: $API_ANIMALS"
if [[ "$DB_GROUPS" != "$API_GROUPS" ]]; then
  echo "WARN: group count mismatch API=$API_GROUPS DB=$DB_GROUPS (bulk head_count may differ from row count)"
fi
if [[ "$DB_ANIMALS" != "$API_ANIMALS" ]]; then
  fail "Animal count mismatch API=$API_ANIMALS DB=$DB_ANIMALS"
fi
echo "Animal counts match between API and Postgres."

# --- 5. Backend Cucumber BDD (inject, no HTTP) ---
if [[ "$SKIP_BACKEND_BDD" != true ]]; then
  log "Backend BDD (Cucumber per service)"
  echo "=== Installing gh-shared ==="
  (cd "$SERVICES_ROOT/gh-shared" && npm install --silent)
  if $RUN_SHARED_UNIT; then
    echo "=== Unit tests: gh-shared ==="
    (cd "$SERVICES_ROOT/gh-shared" && npm test)
  else
    echo "(Skipping gh-shared unit tests; use --with-shared-unit to include)"
  fi
  BACKEND_SERVICES=(gh-api-farms gh-api-people gh-api-animals gh-api-nutrition gh-api-inventory gh-api-tasks gh-api-finance)
  for svc in "${BACKEND_SERVICES[@]}"; do
    echo "=== BDD: $svc ==="
    (cd "$SERVICES_ROOT/$svc" && npm install --silent && npm run test:bdd)
  done
fi

# --- 6. Flutter BDD + live integration tests ---
if [[ "$SKIP_FLUTTER" != true ]]; then
  log "Flutter BDD (widget + domain)"
  (cd "$ROOT" && flutter test test/bdd/)

  log "Flutter live stack integration (real HTTP + Postgres)"
  (cd "$ROOT" && dart pub get && LIVE_STACK_TESTS=1 DATABASE_URL="$DB_URL" dart test test/integration/live_stack_test.dart)
fi

# --- 7. Optional full unit suite ---
if $WITH_UNIT; then
  log "Flutter unit + coverage tests"
  (cd "$ROOT" && flutter test)
fi

# --- 8. Optional Playwright browser BDD (@e2e on Flutter web) ---
if $WITH_PLAYWRIGHT; then
  log "Playwright BDD (Flutter web @e2e)"
  "$ROOT/scripts/run-e2e-playwright.sh"
fi

log "Comprehensive test pack finished successfully."
