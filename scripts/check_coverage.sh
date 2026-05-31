#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
flutter test --no-pub test/ test/bdd/ --coverage
python3 scripts/coverage_gate.py
