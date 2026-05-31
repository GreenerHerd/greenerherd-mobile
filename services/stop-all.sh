#!/usr/bin/env bash
# Stop all services started by start-all.sh
exec "$(cd "$(dirname "$0")" && pwd)/start-all.sh" stop
