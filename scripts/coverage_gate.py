#!/usr/bin/env python3
"""Fail if in-scope Dart line coverage is below TARGET (default 85%)."""
import os
import sys

TARGET = float(os.environ.get("COVERAGE_TARGET", "85"))
LCOV = os.path.join(os.path.dirname(__file__), "..", "coverage", "lcov.info")
if len(sys.argv) > 1:
    LCOV = sys.argv[1]


def in_scope(path: str) -> bool:
    if not path.endswith(".dart"):
        return False
    if ".g.dart" in path or "l10n/gen/" in path:
        return False
    if path.endswith("lib/core/persistence/tables.dart"):
        return False
    if path.startswith("lib/features/") or path.startswith("lib/shared/"):
        return False
    return path.startswith("lib/data/") or path.startswith("lib/core/")


def main() -> int:
    lf = lh = 0
    current = None
    with open(LCOV) as f:
        for line in f:
            line = line.strip()
            if line.startswith("SF:"):
                current = line[3:]
            elif current and in_scope(current) and line.startswith("LF:"):
                lf += int(line[3:])
            elif current and in_scope(current) and line.startswith("LH:"):
                lh += int(line[3:])
            elif line == "end_of_record":
                current = None
    if lf == 0:
        print("No in-scope lines in lcov.info", file=sys.stderr)
        return 1
    pct = 100 * lh / lf
    print(f"In-scope coverage: {pct:.1f}% ({lh}/{lf} lines), target {TARGET:.0f}%")
    if pct + 0.05 < TARGET:
        print(f"FAIL: need {int(TARGET / 100 * lf) - lh} more covered lines", file=sys.stderr)
        return 1
    print("PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
