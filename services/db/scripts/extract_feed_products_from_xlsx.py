#!/usr/bin/env python3
"""Extract feed products + eligibility rules from Generic_Products_Nutrition_Combined.xlsx."""

from __future__ import annotations

import argparse
import json
import uuid
from pathlib import Path

import openpyxl

SCRIPT_DIR = Path(__file__).resolve().parent
DB_DIR = SCRIPT_DIR.parent
OUT_DIR = DB_DIR / 'seeds'
SOURCES_DIR = DB_DIR / 'sources'
MOBILE_ASSETS_DIR = DB_DIR.parent.parent / 'assets' / 'data'
DEFAULT_XLSX = SOURCES_DIR / 'Generic_Products_Nutrition_Combined.xlsx'
FALLBACK_XLSX = (
    Path.home() / 'Downloads/Generic_Products_Nutrition_Combined.xlsx'
)

NS = uuid.UUID('8f4e3c21-9b2a-4f6d-a1e0-000000000001')
RULE_NS = uuid.UUID('8f4e3c21-9b2a-4f6d-a1e0-000000000002')

PRODUCT_NUMBER_START = 1001
RULE_NUMBER_START = 5001

SPECIES_MAP = {
    'all': 'ALL',
    'cattle': 'CATTLE',
    'sheep/goats': 'SMALL_RUMINANT',
    'sheep': 'SHEEP',
    'goat': 'GOAT',
    'goats': 'GOAT',
}

TYPE_MAP = {
    'fodder': 'FODDER',
    'concentrate': 'CONCENTRATE',
    'additive': 'ADDITIVE',
}

FOCUS_MAP = {
    'dairy': 'DAIRY',
    'meat': 'MEAT',
}


def sql_str(v: object | None) -> str:
    if v is None:
        return 'NULL'
    s = str(v).replace("'", "''")
    return f"'{s}'"


def sql_num(v: object | None) -> str:
    if v is None or v == '':
        return 'NULL'
    try:
        return str(float(v))
    except (TypeError, ValueError):
        return 'NULL'


def sql_int(v: object | None) -> str:
    if v is None or v == '':
        return 'NULL'
    try:
        return str(int(float(v)))
    except (TypeError, ValueError):
        return 'NULL'


def clean_text(v: object | None) -> str | None:
    if v is None:
        return None
    s = str(v).strip()
    return s if s else None


def map_species(raw: object | None) -> str:
    key = (str(raw).strip().lower() if raw else 'all')
    return SPECIES_MAP.get(key, 'ALL')


def map_type(raw: object | None) -> str:
    key = (str(raw).strip().lower() if raw else 'fodder')
    return TYPE_MAP.get(key, 'FODDER')


def map_focus(raw: object | None) -> str | None:
    s = clean_text(raw)
    if not s:
        return None
    return FOCUS_MAP.get(s.lower())


def product_uuid(product_number: int) -> str:
    return str(uuid.uuid5(NS, f'feed-product:{product_number}'))


def rule_uuid(rule_number: int) -> str:
    return str(uuid.uuid5(RULE_NS, f'feed-eligibility-rule:{rule_number}'))


def row_to_record(headers: list[str], row: tuple) -> dict:
    idx = {h: i for i, h in enumerate(headers)}

    def cell(name: str) -> object | None:
        i = idx.get(name)
        if i is None or i >= len(row):
            return None
        return row[i]

    return {
        'name_en': str(cell('Product Name')).strip(),
        'name_ar': clean_text(cell('Arabic Name')),
        'species_scope': map_species(cell('Species')),
        'feed_type': map_type(cell('Type')),
        'max_perc_feed': cell('max_perc_feed'),
        'max_perc_conc': cell('max_perc_conc'),
        'max_perc_weight': cell('max_perc_weight'),
        'max_feed_weight_kg': cell('max_feed_weight_kg'),
        'production_focus': map_focus(cell('prod_focus')),
        'sex_restriction': clean_text(cell('Sex')),
        'min_age_months': cell('min_age_months'),
        'max_age_months': cell('max_age_months'),
        'breeding_cycle': clean_text(cell('breeding_cycle')),
        'lactation_exclusion': clean_text(cell('lactation_exclusion')),
        'lactation_inclusion': clean_text(cell('Lactation_inclusion')),
        'dietary_needs': clean_text(cell('dietary_needs')),
        'dm_percent': cell('DM (%)'),
        'nem_mcal_kg': cell('NEm (Mcal/kg)'),
        'neg_mcal_kg': cell('NEg (Mcal/kg)'),
        'cp_percent': cell('CP (%)'),
        'crude_fat_percent': cell('Crude Fat (%)'),
        'ndf_percent': cell('NDF (%)'),
        'adf_percent': cell('ADF (%)'),
        'tdn_percent': cell('TDN (%)'),
        'de_mcal_kg': cell('DE (Mcal/kg)'),
        'me_mcal_kg': cell('ME (Mcal/kg)'),
        'me_mj_kg_dm': cell('ME (MJ/kg DM)'),
        'fiber_percent': cell('Fiber (%)'),
        'moisture_percent': cell('Moisture (%)'),
        'calcium_percent': cell('Calcium (%)'),
        'phosphorus_percent': cell('Phosphorus (%)'),
        'potassium_percent': cell('Potassium (%)'),
        'magnesium_percent': cell('Magnesium (%)'),
        'sodium_percent': cell('Sodium (%)'),
        'zinc_mg_kg': cell('Zinc (mg/kg)'),
        'copper_mg_kg': cell('Copper (mg/kg)'),
        'manganese_mg_kg': cell('Manganese (mg/kg)'),
        'iron_mg_kg': cell('Iron (mg/kg)'),
        'selenium_mg_kg': cell('Selenium (mg/kg)'),
        'biotin': clean_text(cell('Biotin')),
        'vitamin_a_iu_kg': cell('Vitamin A (IU/kg)'),
        'vitamin_b1_iu_kg': cell('Vitamin B1 (IU/kg)'),
        'vitamin_b2_iu_kg': cell('Vitamin B2 (IU/kg)'),
        'vitamin_b6_iu_kg': cell('Vitamin B6 (IU/kg)'),
        'vitamin_b12_iu_kg': cell('Vitamin B12 (IU/kg)'),
        'vitamin_d3_iu_kg': cell('Vitamin D3 (IU/kg)'),
        'vitamin_e_mg_kg': cell('Vitamin E (mg/kg)'),
        'source': clean_text(cell('Source')),
    }


NUTRITION_KEYS = [
    'dm_percent', 'nem_mcal_kg', 'neg_mcal_kg', 'cp_percent', 'crude_fat_percent',
    'ndf_percent', 'adf_percent', 'tdn_percent', 'de_mcal_kg', 'me_mcal_kg',
    'me_mj_kg_dm', 'fiber_percent', 'moisture_percent', 'calcium_percent',
    'phosphorus_percent', 'potassium_percent', 'magnesium_percent', 'sodium_percent',
    'zinc_mg_kg', 'copper_mg_kg', 'manganese_mg_kg', 'iron_mg_kg', 'selenium_mg_kg',
    'biotin', 'vitamin_a_iu_kg', 'vitamin_b1_iu_kg', 'vitamin_b2_iu_kg',
    'vitamin_b6_iu_kg', 'vitamin_b12_iu_kg', 'vitamin_d3_iu_kg', 'vitamin_e_mg_kg',
    'source',
]

ELIGIBILITY_KEYS = [
    'species_scope', 'max_perc_feed', 'max_perc_conc', 'max_perc_weight',
    'max_feed_weight_kg', 'production_focus', 'sex_restriction', 'min_age_months',
    'max_age_months', 'breeding_cycle', 'lactation_exclusion', 'lactation_inclusion',
    'dietary_needs',
]


def normalize_catalog(rows: list[dict]) -> tuple[list[dict], list[dict]]:
    """One feed_products row per (name_en, feed_type); one rule per spreadsheet row."""
    products_by_key: dict[tuple[str, str], dict] = {}
    rules: list[dict] = []
    product_number = PRODUCT_NUMBER_START
    rule_number = RULE_NUMBER_START

    for row in rows:
        key = (row['name_en'], row['feed_type'])
        if key not in products_by_key:
            products_by_key[key] = {
                'id': product_uuid(product_number),
                'product_number': product_number,
                'name_en': row['name_en'],
                'name_ar': row['name_ar'],
                'feed_type': row['feed_type'],
                **{k: row[k] for k in NUTRITION_KEYS},
            }
            product_number += 1

        product = products_by_key[key]
        rules.append({
            'id': rule_uuid(rule_number),
            'rule_number': rule_number,
            'product_id': product['id'],
            'product_number': product['product_number'],
            **{k: row[k] for k in ELIGIBILITY_KEYS},
        })
        rule_number += 1

    products = [products_by_key[k] for k in sorted(products_by_key.keys())]
    return products, rules


def product_to_sql(r: dict) -> str:
    vals = [
        f"'{r['id']}'::uuid",
        str(r['product_number']),
        sql_str(r['name_en']),
        sql_str(r['name_ar']),
        sql_str(r['feed_type']),
        sql_num(r['dm_percent']),
        sql_num(r['nem_mcal_kg']),
        sql_num(r['neg_mcal_kg']),
        sql_num(r['cp_percent']),
        sql_num(r['crude_fat_percent']),
        sql_num(r['ndf_percent']),
        sql_num(r['adf_percent']),
        sql_num(r['tdn_percent']),
        sql_num(r['de_mcal_kg']),
        sql_num(r['me_mcal_kg']),
        sql_num(r['me_mj_kg_dm']),
        sql_num(r['fiber_percent']),
        sql_num(r['moisture_percent']),
        sql_num(r['calcium_percent']),
        sql_num(r['phosphorus_percent']),
        sql_num(r['potassium_percent']),
        sql_num(r['magnesium_percent']),
        sql_num(r['sodium_percent']),
        sql_num(r['zinc_mg_kg']),
        sql_num(r['copper_mg_kg']),
        sql_num(r['manganese_mg_kg']),
        sql_num(r['iron_mg_kg']),
        sql_num(r['selenium_mg_kg']),
        sql_str(r['biotin']),
        sql_num(r['vitamin_a_iu_kg']),
        sql_num(r['vitamin_b1_iu_kg']),
        sql_num(r['vitamin_b2_iu_kg']),
        sql_num(r['vitamin_b6_iu_kg']),
        sql_num(r['vitamin_b12_iu_kg']),
        sql_num(r['vitamin_d3_iu_kg']),
        sql_num(r['vitamin_e_mg_kg']),
        sql_str(r['source']),
        'TRUE',
    ]
    return f"({', '.join(vals)})"


def rule_to_sql(r: dict) -> str:
    vals = [
        f"'{r['id']}'::uuid",
        str(r['rule_number']),
        f"'{r['product_id']}'::uuid",
        sql_str(r['species_scope']),
        sql_num(r['max_perc_feed']),
        sql_num(r['max_perc_conc']),
        sql_num(r['max_perc_weight']),
        sql_num(r['max_feed_weight_kg']),
        sql_str(r['production_focus']),
        sql_str(r['sex_restriction']),
        sql_int(r['min_age_months']),
        sql_int(r['max_age_months']),
        sql_str(r['breeding_cycle']),
        sql_str(r['lactation_exclusion']),
        sql_str(r['lactation_inclusion']),
        sql_str(r['dietary_needs']),
        'TRUE',
    ]
    return f"({', '.join(vals)})"


def public_rule(r: dict) -> dict:
    out = {k: r[k] for k in ['id', 'rule_number', 'product_id', *ELIGIBILITY_KEYS]}
    for k, v in list(out.items()):
        if isinstance(v, float):
            out[k] = round(v, 4)
    return out


def public_product(p: dict, rules: list[dict]) -> dict:
    product_rules = [public_rule(r) for r in rules if r['product_id'] == p['id']]
    out = {
        'id': p['id'],
        'product_number': p['product_number'],
        'name_en': p['name_en'],
        'name_ar': p['name_ar'],
        'feed_type': p['feed_type'],
        'eligibility_rules': product_rules,
    }
    for k in NUTRITION_KEYS:
        if k == 'source' and p.get(k) is None:
            continue
        v = p.get(k)
        if isinstance(v, float):
            out[k] = round(v, 4)
        else:
            out[k] = v
    return out


def build_upload_sql(products: list[dict], rules: list[dict]) -> str:
    if not products:
        return '-- No products to upload\n'

    prod_start = products[0]['product_number']
    prod_end = products[-1]['product_number']
    rule_start = rules[0]['rule_number']
    rule_end = rules[-1]['rule_number']

    product_update_cols = [
        'name_en', 'name_ar', 'feed_type',
        *NUTRITION_KEYS,
        'is_active',
    ]
    product_set = ',\n  '.join(f'{c} = EXCLUDED.{c}' for c in product_update_cols)

    rule_update_cols = ELIGIBILITY_KEYS + ['is_active']
    rule_set = ',\n  '.join(f'{c} = EXCLUDED.{c}' for c in rule_update_cols)

    lines = [
        '-- Generated by extract_feed_products_from_xlsx.py',
        '-- Upload standard feed catalogue (nutrition on feed_products, eligibility in rules)',
        '--',
        f'-- Products: {len(products)} (prod_id {prod_start}–{prod_end})',
        f'-- Rules: {len(rules)} (rule_number {rule_start}–{rule_end})',
        '-- Prerequisite: migrations/013_feed_product_eligibility_rules.sql',
        '',
        'BEGIN;',
        '',
        'INSERT INTO feed_products (',
        '  id, product_number, name_en, name_ar, feed_type,',
        '  dm_percent, nem_mcal_kg, neg_mcal_kg, cp_percent, crude_fat_percent,',
        '  ndf_percent, adf_percent, tdn_percent, de_mcal_kg, me_mcal_kg,',
        '  me_mj_kg_dm, fiber_percent, moisture_percent, calcium_percent,',
        '  phosphorus_percent, potassium_percent, magnesium_percent, sodium_percent,',
        '  zinc_mg_kg, copper_mg_kg, manganese_mg_kg, iron_mg_kg, selenium_mg_kg,',
        '  biotin, vitamin_a_iu_kg, vitamin_b1_iu_kg, vitamin_b2_iu_kg,',
        '  vitamin_b6_iu_kg, vitamin_b12_iu_kg, vitamin_d3_iu_kg, vitamin_e_mg_kg,',
        '  source, is_active',
        ') VALUES',
        ',\n'.join(product_to_sql(p) for p in products),
        'ON CONFLICT (product_number) DO UPDATE SET',
        f'  {product_set};',
        '',
        'INSERT INTO feed_product_eligibility_rules (',
        '  id, rule_number, product_id, species_scope,',
        '  max_perc_feed, max_perc_conc, max_perc_weight, max_feed_weight_kg,',
        '  production_focus, sex_restriction, min_age_months, max_age_months,',
        '  breeding_cycle, lactation_exclusion, lactation_inclusion, dietary_needs,',
        '  is_active',
        ') VALUES',
        ',\n'.join(rule_to_sql(r) for r in rules),
        'ON CONFLICT (rule_number) DO UPDATE SET',
        f'  {rule_set},',
        '  product_id = EXCLUDED.product_id;',
        '',
        'INSERT INTO feed_product_trans (product_id, locale, name)',
        'SELECT id, \'en\', name_en',
        'FROM feed_products',
        f'WHERE product_number BETWEEN {prod_start} AND {prod_end}',
        'ON CONFLICT (product_id, locale) DO UPDATE',
        '  SET name = EXCLUDED.name;',
        '',
        'INSERT INTO feed_product_trans (product_id, locale, name)',
        'SELECT id, \'ar\', name_ar',
        'FROM feed_products',
        f'WHERE product_number BETWEEN {prod_start} AND {prod_end}',
        '  AND name_ar IS NOT NULL',
        'ON CONFLICT (product_id, locale) DO UPDATE',
        '  SET name = EXCLUDED.name;',
        '',
        'COMMIT;',
        '',
    ]
    return '\n'.join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('xlsx', nargs='?', default=str(DEFAULT_XLSX))
    args = parser.parse_args()
    xlsx_path = Path(args.xlsx)
    if not xlsx_path.exists():
        xlsx_path = FALLBACK_XLSX
    if not xlsx_path.exists():
        raise SystemExit(f'Workbook not found: {args.xlsx}')

    wb = openpyxl.load_workbook(xlsx_path, read_only=True, data_only=True)
    ws = wb['Generic Products Nutrition']
    rows = list(ws.iter_rows(values_only=True))
    headers = [str(h).strip() if h else '' for h in rows[0]]

    raw_rows: list[dict] = []
    for row in rows[1:]:
        if not row or not row[0]:
            continue
        raw_rows.append(row_to_record(headers, row))

    products, rules = normalize_catalog(raw_rows)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MOBILE_ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    products_sql = [
        '-- Generated by extract_feed_products_from_xlsx.py',
        'TRUNCATE feed_product_eligibility_rules, feed_products CASCADE;',
        'INSERT INTO feed_products (',
        '  id, product_number, name_en, name_ar, feed_type,',
        '  dm_percent, nem_mcal_kg, neg_mcal_kg, cp_percent, crude_fat_percent,',
        '  ndf_percent, adf_percent, tdn_percent, de_mcal_kg, me_mcal_kg,',
        '  me_mj_kg_dm, fiber_percent, moisture_percent, calcium_percent,',
        '  phosphorus_percent, potassium_percent, magnesium_percent, sodium_percent,',
        '  zinc_mg_kg, copper_mg_kg, manganese_mg_kg, iron_mg_kg, selenium_mg_kg,',
        '  biotin, vitamin_a_iu_kg, vitamin_b1_iu_kg, vitamin_b2_iu_kg,',
        '  vitamin_b6_iu_kg, vitamin_b12_iu_kg, vitamin_d3_iu_kg, vitamin_e_mg_kg,',
        '  source, is_active',
        ') VALUES',
        ',\n'.join(product_to_sql(p) for p in products) + ';',
    ]
    sql_path = OUT_DIR / 'feed_products.sql'
    sql_path.write_text('\n'.join(products_sql), encoding='utf-8')

    rules_sql = [
        '-- Generated by extract_feed_products_from_xlsx.py',
        'INSERT INTO feed_product_eligibility_rules (',
        '  id, rule_number, product_id, species_scope,',
        '  max_perc_feed, max_perc_conc, max_perc_weight, max_feed_weight_kg,',
        '  production_focus, sex_restriction, min_age_months, max_age_months,',
        '  breeding_cycle, lactation_exclusion, lactation_inclusion, dietary_needs,',
        '  is_active',
        ') VALUES',
        ',\n'.join(rule_to_sql(r) for r in rules) + ';',
    ]
    rules_path = OUT_DIR / 'feed_product_eligibility_rules.sql'
    rules_path.write_text('\n'.join(rules_sql), encoding='utf-8')

    upload_path = OUT_DIR / 'upload_standard_feed_products.sql'
    upload_path.write_text(build_upload_sql(products, rules), encoding='utf-8')

    json_path = MOBILE_ASSETS_DIR / 'feed_products.json'
    json_path.write_text(
        json.dumps(
            {
                'products': [public_product(p, rules) for p in products],
                'meta': {
                    'total_products': len(products),
                    'total_rules': len(rules),
                    'product_number_start': products[0]['product_number'],
                    'product_number_end': products[-1]['product_number'],
                    'rule_number_start': rules[0]['rule_number'],
                    'rule_number_end': rules[-1]['rule_number'],
                },
            },
            indent=2,
            ensure_ascii=False,
        ),
        encoding='utf-8',
    )

    by_scope: dict[str, int] = {}
    by_type: dict[str, int] = {}
    for r in rules:
        by_scope[r['species_scope']] = by_scope.get(r['species_scope'], 0) + 1
    for p in products:
        by_type[p['feed_type']] = by_type.get(p['feed_type'], 0) + 1

    print(f'Wrote {len(products)} products -> {sql_path}')
    print(f'Wrote {len(rules)} eligibility rules -> {rules_path}')
    print(f'Wrote upload DML -> {upload_path}')
    print(f'Wrote mobile catalog -> {json_path}')
    print('Rules by species_scope:', by_scope)
    print('Products by feed_type:', by_type)


if __name__ == '__main__':
    main()
