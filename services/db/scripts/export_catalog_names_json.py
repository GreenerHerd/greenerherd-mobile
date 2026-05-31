#!/usr/bin/env python3
"""Add `names` maps to breeds.json and feed_products.json from legacy name_* fields."""

from __future__ import annotations

import json
from pathlib import Path

MOBILE = Path(__file__).resolve().parents[3] / "assets" / "data"


def names_from_row(row: dict) -> dict[str, str]:
    names: dict[str, str] = {}
    en = (row.get("name_en") or "").strip()
    if en:
        names["en"] = en
    for loc, key in (("ar", "name_ar"), ("fr", "name_fr"), ("ur", "name_ur")):
        val = (row.get(key) or "").strip()
        if val:
            names[loc] = val
    if "fr" not in names and en:
        names["fr"] = en
    if "ur" not in names and en:
        names["ur"] = en
    return names


def patch_breeds() -> None:
    path = MOBILE / "breeds.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    for breed in data.get("breeds", []):
        breed["names"] = names_from_row(breed)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {path}")


def patch_feeds() -> None:
    path = MOBILE / "feed_products.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    for product in data.get("products", []):
        product["names"] = names_from_row(product)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {path}")


if __name__ == "__main__":
    patch_breeds()
    patch_feeds()
