#!/usr/bin/env python3
"""Extract notification task definitions from Notification_Events.xlsx."""

from __future__ import annotations

import argparse
import json
import re
import uuid
from pathlib import Path

import openpyxl

SCRIPT_DIR = Path(__file__).resolve().parent
DB_DIR = SCRIPT_DIR.parent
OUT_DIR = DB_DIR / 'seeds'
SOURCES_DIR = DB_DIR / 'sources'
MOBILE_ASSETS_DIR = DB_DIR.parent.parent / 'assets' / 'data'
DEFAULT_XLSX = SOURCES_DIR / 'Notification_Events.xlsx'
FALLBACK_XLSX = Path.home() / 'Documents/GreenerHerd/Claude/Notification Events.xlsx'

NS = uuid.UUID('a1b2c3d4-e5f6-4789-a012-000000000007')

SPECIES_MAP = {
    'all': 'ALL',
    'cattle': 'CATTLE',
    'cow': 'CATTLE',
    'cows': 'CATTLE',
    'sheep': 'SHEEP',
    'goat': 'GOAT',
    'goats': 'GOAT',
    'sheep/goats': 'SMALL_RUMINANT',
    'goat and sheep': 'SMALL_RUMINANT',
    'goats and sheep': 'SMALL_RUMINANT',
    'sheep, goats, cows': 'ALL',
    'sheep, goats': 'SMALL_RUMINANT',
}

PRIORITY_MAP = {
    'high': 'HIGH',
    'medium': 'MEDIUM',
    'low': 'LOW',
}


def sql_str(v: object | None) -> str:
    if v is None:
        return 'NULL'
    s = str(v).replace("'", "''")
    return f"'{s}'"


def sql_bool(v: bool) -> str:
    return 'TRUE' if v else 'FALSE'


def sql_array(items: list[str]) -> str:
    if not items:
        return "ARRAY[]::TEXT[]"
    inner = ', '.join(sql_str(x) for x in items)
    return f"ARRAY[{inner}]"


def clean_text(v: object | None) -> str | None:
    if v is None:
        return None
    s = str(v).strip()
    return s if s else None


def map_species(raw: object | None) -> str | None:
    if raw is None:
        return None
    key = str(raw).strip().lower()
    if not key:
        return None
    if key in SPECIES_MAP:
        return SPECIES_MAP[key]
    if 'cattle' in key and ('sheep' in key or 'goat' in key):
        return 'ALL'
    if 'sheep' in key or 'goat' in key:
        return 'SMALL_RUMINANT'
    return 'ALL'


def map_priority(raw: object | None) -> str | None:
    if raw is None:
        return None
    return PRIORITY_MAP.get(str(raw).strip().lower())


def map_action_by(raw: object | None) -> str | None:
    if raw is None:
        return None
    s = str(raw).strip().lower()
    if s == 'user':
        return 'USER'
    if s == 'system':
        return 'SYSTEM'
    return None


def parse_channels(raw: object | None) -> list[str]:
    if raw is None:
        return []
    text = str(raw).lower()
    channels: list[str] = []
    if 'app' in text or 'in-app' in text or 'in - app' in text:
        channels.append('IN_APP')
    if 'phone' in text or 'push' in text:
        channels.append('PUSH')
    return channels


def stable_id(task_id: int) -> str:
    return str(uuid.uuid5(NS, f'notification-task-{task_id}'))


def header_index(headers: tuple) -> dict[str, int]:
    out: dict[str, int] = {}
    for i, h in enumerate(headers):
        if h is None:
            continue
        key = re.sub(r'\s+', ' ', str(h).strip().lower())
        out[key] = i
    return out


def col(row: tuple, idx: dict[str, int], *names: str) -> object | None:
    for name in names:
        key = name.lower()
        if key in idx:
            return row[idx[key]]
    return None


def row_to_record(row: tuple, idx: dict[str, int], go_live: bool) -> dict | None:
    task_id_raw = col(row, idx, 'taskid')
    if task_id_raw is None:
        return None
    try:
        task_id = int(float(task_id_raw))
    except (TypeError, ValueError):
        return None

    task_name = clean_text(
        col(
            row,
            idx,
            'task name (max 40 characters)',
            'task name',
        ),
    )
    expanded = clean_text(col(row, idx, 'expanded detail'))
    notification_text = clean_text(
        col(
            row,
            idx,
            'reminder/notifcation text (max 80 characters)',
            'reminder/notification text (max 80 characters)',
        ),
    )

    if not task_name and not expanded and not notification_text:
        return None

    if not task_name:
        task_name = notification_text or expanded or f'Task {task_id}'
    if len(task_name) > 120:
        task_name = task_name[:117] + '...'

    category = clean_text(col(row, idx, 'category'))
    if category and category.lower() == 'medical':
        category = 'Medical'

    return {
        'id': stable_id(task_id),
        'task_id': task_id,
        'category': category or 'General',
        'country_code': None,
        'species': map_species(col(row, idx, 'species')),
        'current_state': clean_text(col(row, idx, 'current state')),
        'source': clean_text(col(row, idx, 'source')),
        'notification_text': notification_text,
        'task_name': task_name,
        'notification_text_ar': clean_text(
            col(row, idx, 'reminder text (arabic)', 'reminder text (arabic)'),
        ),
        'task_name_ar': clean_text(
            col(row, idx, 'task name (arabic)', 'description (arabic)'),
        ),
        'expanded_detail': expanded,
        'expanded_detail_ar': clean_text(col(row, idx, 'expanded detail (arabic)')),
        'level': clean_text(col(row, idx, 'level')),
        'trigger_event': clean_text(col(row, idx, 'event/action')),
        'trigger_criteria': clean_text(col(row, idx, 'criteria')),
        'due_date_rule': clean_text(col(row, idx, 'due date')),
        'action_by': map_action_by(col(row, idx, 'action by')),
        'priority': map_priority(col(row, idx, 'priority')),
        'frequency': clean_text(col(row, idx, 'frequency')),
        'system_action': clean_text(col(row, idx, 'system action')),
        'channels': parse_channels(col(row, idx, 'channel')),
        'go_live': go_live,
        'is_active': True,
        'default_enabled': True,
        'notes': clean_text(col(row, idx, 'notes')),
    }


def parse_sheet(ws, go_live: bool) -> list[dict]:
    rows = list(ws.iter_rows(values_only=True))
    if not rows:
        return []
    idx = header_index(rows[0])
    records: list[dict] = []
    seen: set[int] = set()
    for row in rows[1:]:
        rec = row_to_record(row, idx, go_live)
        if not rec or rec['task_id'] in seen:
            continue
        seen.add(rec['task_id'])
        records.append(rec)
    return records


def to_sql(records: list[dict]) -> str:
    lines = [
        '-- Generated by extract_notification_tasks_from_xlsx.py',
        'TRUNCATE notification_task_definitions CASCADE;',
        '',
    ]
    for r in sorted(records, key=lambda x: x['task_id']):
        lines.append(
            'INSERT INTO notification_task_definitions (\n'
            '  id, task_id, category, country_code, species, current_state, source,\n'
            '  notification_text, task_name, notification_text_ar, task_name_ar,\n'
            '  expanded_detail, expanded_detail_ar, level, trigger_event, trigger_criteria,\n'
            '  due_date_rule, action_by, priority, frequency, system_action, channels,\n'
            '  go_live, is_active, default_enabled, notes\n'
            ') VALUES (\n'
            f"  '{r['id']}', {r['task_id']}, {sql_str(r['category'])}, NULL, "
            f"{sql_str(r['species'])}, {sql_str(r['current_state'])}, {sql_str(r['source'])},\n"
            f"  {sql_str(r['notification_text'])}, {sql_str(r['task_name'])}, "
            f"{sql_str(r['notification_text_ar'])}, {sql_str(r['task_name_ar'])},\n"
            f"  {sql_str(r['expanded_detail'])}, {sql_str(r['expanded_detail_ar'])}, "
            f"{sql_str(r['level'])}, {sql_str(r['trigger_event'])}, {sql_str(r['trigger_criteria'])},\n"
            f"  {sql_str(r['due_date_rule'])}, {sql_str(r['action_by'])}, {sql_str(r['priority'])}, "
            f"{sql_str(r['frequency'])}, {sql_str(r['system_action'])}, {sql_array(r['channels'])},\n"
            f"  {sql_bool(r['go_live'])}, {sql_bool(r['is_active'])}, {sql_bool(r['default_enabled'])}, "
            f"{sql_str(r['notes'])}\n"
            ');',
        )
    return '\n'.join(lines) + '\n'


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('xlsx', nargs='?', default=str(DEFAULT_XLSX))
    args = parser.parse_args()
    path = Path(args.xlsx)
    if not path.exists():
        path = FALLBACK_XLSX
    if not path.exists():
        raise SystemExit(f'Workbook not found: {args.xlsx}')

    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    go_live = parse_sheet(wb['Tasks - Go-Live'], go_live=True)
    full = parse_sheet(wb['Tasks'], go_live=False)

    by_id = {r['task_id']: r for r in full}
    for r in go_live:
        by_id[r['task_id']] = r
    records = list(by_id.values())

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MOBILE_ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    sql_path = OUT_DIR / 'notification_task_definitions.sql'
    json_path = MOBILE_ASSETS_DIR / 'notification_task_definitions.json'

    sql_path.write_text(to_sql(records), encoding='utf-8')
    json_path.write_text(
        json.dumps({'definitions': records}, indent=2, ensure_ascii=False) + '\n',
        encoding='utf-8',
    )

    print(f'Wrote {len(records)} definitions → {sql_path}')
    print(f'Wrote JSON → {json_path}')


if __name__ == '__main__':
    main()
