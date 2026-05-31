#!/usr/bin/env python3
"""Report app livestock combinations vs nutrition_requirements.json coverage."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
JSON_PATH = ROOT / 'assets/data/nutrition_requirements.json'

GROUP_PURPOSES = [
    'milk',
    'breeding',
    'pregnant',
    'fattening',
    'maintenance',
    'weaning',
    'dry',
    'sick',
]
SPECIES = ['CATTLE', 'GOAT', 'SHEEP']
PRODUCTION = ['MILK', 'MEAT', 'BOTH']

# Purposes with no dedicated masterfile row (use nearest profile).
APPROXIMATE_ONLY = {'sick', 'weaning', 'breeding'}

# Not in xlsx — resolver still picks a profile.
KNOWN_GAPS = [
    'CATTLE + MILK + MALE: no dairy bull row; resolver uses dairy heifer/dry stages',
    'GOAT/SHEEP young stock: only 4 life stages (no age/sex split in xlsx)',
    'SICK groups: no reduced-nutrient row in masterfile',
    'WEANING groups: no suckling/weaner row for small ruminants',
]


def main() -> None:
    data = json.loads(JSON_PATH.read_text())
    profiles = data['profiles']
    cycles = {p['feed_cycle'] for p in profiles if p.get('feed_cycle')}
    print(f'Profiles: {len(profiles)}')
    print(f'Unique feed_cycle codes: {len(cycles)}')
    print('\nFeed cycles in masterfile:')
    for c in sorted(cycles):
        n = sum(1 for p in profiles if p.get('feed_cycle') == c)
        print(f'  {c}: {n} profile(s)')

    print('\nApp group purposes — dedicated masterfile row?')
    for purpose in GROUP_PURPOSES:
        flag = 'approximate match only' if purpose in APPROXIMATE_ONLY else 'resolved via stage logic'
        print(f'  {purpose}: {flag}')

    print('\nKnown coverage gaps (documented):')
    for g in KNOWN_GAPS:
        print(f'  - {g}')


if __name__ == '__main__':
    main()
