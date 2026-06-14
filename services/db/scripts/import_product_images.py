#!/usr/bin/env python3
"""Merge product_image_url from Products.zip JS sources into mobile JSON assets."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
MOBILE_ASSETS = SCRIPT_DIR.parent.parent.parent / 'assets' / 'data'
ZIP_DIR = SCRIPT_DIR.parent.parent.parent / '.tmp' / 'products_zip'

QUALITY_SUFFIX = re.compile(r'\s*\((good|medium|poor)\s+quality\)\s*$', re.I)

NAME_ALIASES = {
    'corn cracked': 'corn',
    'cottonseed meal': 'cotton meal',
    'oats grain': 'oats',
    'sugar beet pulp dried': 'beet pulp',
    'ponicum fresh': 'ponicum',
    'ponicum hay': 'ponicum',
    'alfalfa hay good quality': 'alfalfa hay',
    'alfalfa hay medium quality': 'alfalfa hay',
    'alfalfa hay poor quality': 'alfalfa hay',
    'clover hay good quality': 'clover hay',
    'clover hay medium quality': 'clover hay',
    'clover hay poor quality': 'clover hay',
    'rhodes hay good quality': 'rhodes hay',
    'rhodes hay medium quality': 'rhodes hay',
    'rhodes hay poor quality': 'rhodes hay',
    'wheat whole': 'wheat',
    'alfa alfa': 'alfalfa',
}


def load_js_array(path: Path, var_name: str) -> list[dict]:
    text = path.read_text(encoding='utf-8')
    match = re.search(rf'const {var_name}\s*=\s*(\[.*\])\s*;', text, re.DOTALL)
    if not match:
        raise ValueError(f'Could not parse {path}')
    return json.loads(match.group(1))


def norm_name(value: str | None) -> str:
    if not value:
        return ''
    s = value.lower().strip()
    s = re.sub(r'^generic\s*-\s*', '', s)
    s = QUALITY_SUFFIX.sub('', s).strip()
    s = re.sub(r'[^a-z0-9]+', ' ', s)
    return ' '.join(s.split())


def build_image_lookup(items: list[dict]) -> dict[str, str]:
    lookup: dict[str, str] = {}
    for item in items:
        url = item.get('product_image_url')
        if not url:
            continue
        for key in (
            norm_name(item.get('product_name')),
            norm_name(item.get('Product name arabic')),
        ):
            if key and key not in lookup:
                lookup[key] = url
    return lookup


def resolve_image(name: str, lookup: dict[str, str]) -> str | None:
    key = norm_name(name)
    key = NAME_ALIASES.get(key, key)
    if key in lookup:
        return lookup[key]
    for alias, target in NAME_ALIASES.items():
        if key == alias and target in lookup:
            return lookup[target]
    tokens = [t for t in key.split() if len(t) > 2]
    if not tokens:
        return None
    best_url: str | None = None
    best_len = 0
    for candidate, url in lookup.items():
        if all(token in candidate for token in tokens[:2]):
            if len(candidate) > best_len:
                best_len = len(candidate)
                best_url = url
    return best_url


def main() -> int:
    std_js = ZIP_DIR / 'standardProducts.js'
    mp_js = ZIP_DIR / 'marketplaceCatalog.js'
    if not std_js.exists() or not mp_js.exists():
        print(
            'Extract Products.zip to .tmp/products_zip first.',
            file=sys.stderr,
        )
        return 1

    std_zip = load_js_array(std_js, 'standardProducts')
    mp_zip = load_js_array(mp_js, 'marketplaceCatalog')
    std_lookup = build_image_lookup(std_zip)
    mp_lookup = build_image_lookup(mp_zip)

    feed_path = MOBILE_ASSETS / 'feed_products.json'
    mp_path = MOBILE_ASSETS / 'marketplace_feed_products.json'

    feed_data = json.loads(feed_path.read_text(encoding='utf-8'))
    mp_data = json.loads(mp_path.read_text(encoding='utf-8'))

    std_by_number: dict[int, str] = {}
    std_updated = 0
    for product in feed_data['products']:
        url = resolve_image(product.get('name_en', ''), std_lookup)
        if url:
            if product.get('product_image_url') != url:
                product['product_image_url'] = url
                std_updated += 1
            num = product.get('product_number')
            if num is not None:
                std_by_number[int(num)] = url

    mp_updated = 0
    mp_from_std = 0
    mp_from_zip = 0
    for product in mp_data['products']:
        url = product.get('product_image_url')
        if not url:
            std_num = product.get('standard_product_number')
            if std_num is not None and int(std_num) in std_by_number:
                url = std_by_number[int(std_num)]
                mp_from_std += 1
            else:
                url = resolve_image(product.get('name_en', ''), mp_lookup)
                if not url:
                    url = resolve_image(product.get('name_en', ''), std_lookup)
                if url:
                    mp_from_zip += 1
        if url and product.get('product_image_url') != url:
            product['product_image_url'] = url
            mp_updated += 1

    feed_path.write_text(
        json.dumps(feed_data, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )
    mp_path.write_text(
        json.dumps(mp_data, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )

    std_with = sum(1 for p in feed_data['products'] if p.get('product_image_url'))
    mp_with = sum(1 for p in mp_data['products'] if p.get('product_image_url'))
    print(f'Standard: {std_with}/{len(feed_data["products"])} with product_image_url')
    print(f'Marketplace: {mp_with}/{len(mp_data["products"])} with product_image_url')
    print(f'Updated standard rows: {std_updated}')
    print(f'Updated marketplace rows: {mp_updated} (from std: {mp_from_std}, zip: {mp_from_zip})')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
