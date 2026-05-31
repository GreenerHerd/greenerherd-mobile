#!/usr/bin/env bash
# Start all GreenerHerd API services in the background and write stdout/stderr to logs/.
#
# Usage:
#   ./start-all.sh              Start (skip if already running)
#   ./start-all.sh --install    npm install in each service first
#   ./start-all.sh --force      Restart even if PID file says running
#   ./start-all.sh status       Show PIDs and health
#   ./start-all.sh stop         Stop all services started by this script
#   ./start-all.sh restart      stop then start
#
# Logs:  services/logs/<service>.log
# PIDs:   services/logs/pids/<service>.pid
# Archive: previous logs moved to services/logs/archive/<timestamp>/ on each start

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$ROOT/logs"
PID_DIR="$LOG_DIR/pids"
ARCHIVE_DIR="$LOG_DIR/archive"

if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/.env"
  set +a
elif [[ -f "$ROOT/db/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/db/.env"
  set +a
fi

export JWT_SECRET="${JWT_SECRET:-dev-secret-change-me}"
export DATABASE_URL="${DATABASE_URL:-postgres://greenerherd:greenerherd@localhost:5432/greenerherd}"
export TASKS_API_BASE_URL="${TASKS_API_BASE_URL:-http://localhost:3004}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# name|port|directory (under services/)
SERVICES=(
  "gh-api-auth|3001|gh-api-auth"
  "gh-api-farms|3002|gh-api-farms"
  "gh-api-nutrition|3003|gh-api-nutrition"
  "gh-api-tasks|3004|gh-api-tasks"
  "gh-api-inventory|3005|gh-api-inventory"
  "gh-api-animals|3006|gh-api-animals"
  "gh-api-people|3007|gh-api-people"
  "gh-api-finance|3008|gh-api-finance"
)

INSTALL=false
FORCE=false
CMD="${1:-start}"

for arg in "$@"; do
  case "$arg" in
    --install) INSTALL=true ;;
    --force) FORCE=true ;;
    start|stop|status|restart) CMD="$arg" ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
  esac
done

mkdir -p "$LOG_DIR" "$PID_DIR" "$ARCHIVE_DIR"

is_running() {
  local name="$1"
  local pidfile="$PID_DIR/${name}.pid"
  if [[ ! -f "$pidfile" ]]; then
    return 1
  fi
  local pid
  pid="$(cat "$pidfile")"
  if kill -0 "$pid" 2>/dev/null; then
    return 0
  fi
  rm -f "$pidfile"
  return 1
}

stop_one() {
  local name="$1"
  local pidfile="$PID_DIR/${name}.pid"
  if [[ -f "$pidfile" ]]; then
    local pid
    pid="$(cat "$pidfile")"
    if kill -0 "$pid" 2>/dev/null; then
      echo "Stopping $name (pid $pid)…"
      kill "$pid" 2>/dev/null || true
      sleep 0.5
      kill -9 "$pid" 2>/dev/null || true
    fi
    rm -f "$pidfile"
  fi
}

stop_all() {
  echo "Stopping GreenerHerd API services…"
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r name _ _ <<<"$entry"
    stop_one "$name"
  done
  echo "Done."
}

health_check() {
  local port="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -sf "http://127.0.0.1:${port}/health" >/dev/null 2>&1
    return $?
  fi
  return 1
}

status_all() {
  printf "%-20s %6s  %-8s  %-8s\n" "SERVICE" "PORT" "PID" "HEALTH"
  printf "%-20s %6s  %-8s  %-8s\n" "-------" "----" "---" "------"
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r name port _ <<<"$entry"
    local pid="-"
    local health="down"
    if is_running "$name"; then
      pid="$(cat "$PID_DIR/${name}.pid")"
      if health_check "$port"; then
        health="ok"
      else
        health="no /health"
      fi
    fi
    printf "%-20s %6s  %-8s  %-8s\n" "$name" "$port" "$pid" "$health"
  done
  echo ""
  echo "Logs: $LOG_DIR/*.log"
}

archive_logs() {
  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)"
  local dest="$ARCHIVE_DIR/$stamp"
  local moved=false
  shopt -s nullglob
  local files=("$LOG_DIR"/*.log)
  shopt -u nullglob
  if [[ ${#files[@]} -gt 0 ]]; then
    mkdir -p "$dest"
    for f in "${files[@]}"; do
      mv "$f" "$dest/"
      moved=true
    done
  fi
  if $moved; then
    echo "Archived previous logs → $dest"
  fi
}

start_one() {
  local name="$1"
  local port="$2"
  local dir="$3"
  local svc_root="$ROOT/$dir"
  local logfile="$LOG_DIR/${name}.log"
  local pidfile="$PID_DIR/${name}.pid"

  if is_running "$name" && [[ "$FORCE" != true ]]; then
    echo "Skip $name (already running, pid $(cat "$pidfile")). Use --force to restart."
    return 0
  fi

  if is_running "$name" && [[ "$FORCE" == true ]]; then
    stop_one "$name"
  fi

  if [[ ! -d "$svc_root" ]]; then
    echo "ERROR: missing directory $svc_root" >&2
    exit 1
  fi

  if $INSTALL || [[ ! -d "$svc_root/node_modules" ]]; then
    echo "npm install → $dir"
    (cd "$svc_root" && npm install --silent)
  fi

  {
    echo "================================================================================"
    echo "GreenerHerd $name — started $(date -Iseconds)"
    echo "Port: $port  CWD: $svc_root"
    echo "JWT_SECRET=***  DATABASE_URL=${DATABASE_URL}  LOG_LEVEL=${LOG_LEVEL}"
    echo "================================================================================"
  } >>"$logfile"

  (
    cd "$svc_root"
    export PORT="$port"
    export JWT_SECRET DATABASE_URL TASKS_API_BASE_URL LOG_LEVEL
    exec npm run dev
  ) >>"$logfile" 2>&1 &

  local pid=$!
  echo "$pid" >"$pidfile"
  echo "Started $name on :$port (pid $pid) → $logfile"
}

start_all() {
  archive_logs
  echo "Starting GreenerHerd API services…"
  echo "JWT_SECRET=${JWT_SECRET}"
  echo "DATABASE_URL=${DATABASE_URL}"
  echo ""
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r name port dir <<<"$entry"
    start_one "$name" "$port" "$dir"
  done
  echo ""
  echo "Waiting for services to boot…"
  sleep 5
  local retries=0
  while [[ $retries -lt 3 ]]; do
    local all_ok=true
    for entry in "${SERVICES[@]}"; do
      IFS='|' read -r _ port _ <<<"$entry"
      if ! health_check "$port"; then
        all_ok=false
        break
      fi
    done
    if $all_ok; then break; fi
    retries=$((retries + 1))
    sleep 2
  done
  status_all
}

case "$CMD" in
  stop) stop_all ;;
  status) status_all ;;
  restart) stop_all; echo ""; start_all ;;
  start|*) start_all ;;
esac
