#!/usr/bin/env python3
"""Extract vaccines + medicines from seed SQL into mobile medicine_products.json."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
MOBILE_JSON = SCRIPT_DIR.parent.parent.parent / 'assets' / 'data' / 'medicine_products.json'
DEFAULT_SQL = SCRIPT_DIR.parent / 'sources' / 'seed_vaccines_medicines_1.sql'

MEDICINE_NUMBER_BASE = 2000
VACCINE_NUMBER_BASE = 3000

CATEGORY_TYPE = {
    'antibiotic': 'ANTIBIOTIC',
    'anthelmintic': 'ANTHELMINTIC',
    'nsaid': 'NSAID',
    'corticosteroid': 'CORTICOSTEROID',
    'vaccine': 'VACCINE',
    'mineral supplement': 'MINERAL_SUPPLEMENT',
    'vitamin': 'VITAMIN',
    'vitamin/mineral': 'VITAMIN_MINERAL',
    'vitamin complex': 'VITAMIN_COMPLEX',
    'probiotic': 'PROBIOTIC',
    'toxin binder': 'TOXIN_BINDER',
    'rehydration solution': 'REHYDRATION',
    'energy supplement': 'ENERGY_SUPPLEMENT',
    'alkalizer': 'ALKALIZER',
    'antidiarrheal': 'ANTIDIARRHEAL',
    'laxative': 'LAXATIVE',
    'anti-bloat': 'ANTI_BLOAT',
    'hormone': 'HORMONE',
    'antiseptic': 'ANTISEPTIC',
    'disinfectant': 'DISINFECTANT',
    'other': 'OTHER',
}

# Localized category labels (for validation / optional UI).
CATEGORY_I18N = {
    'ANTIBIOTIC': {'en': 'Antibiotic', 'fr': 'Antibiotique', 'ar': 'مضاد حيوي', 'ur': 'اینٹی بائیوٹک'},
    'VACCINE': {'en': 'Vaccine', 'fr': 'Vaccin', 'ar': 'لقاح', 'ur': 'ویکسین'},
    'ANTHELMINTIC': {'en': 'Anthelmintic', 'fr': 'Anthelminthique', 'ar': 'مضاد ديدان', 'ur': 'کِرمیائی دوا'},
    'NSAID': {'en': 'NSAID', 'fr': 'AINS', 'ar': 'مضاد التهاب غير ستероيدي', 'ur': 'NSAID'},
}

# Known product name translations (extend as catalogue grows).
NAME_OVERRIDES: dict[str, dict[str, str]] = {
    'Penicillin G': {
        'ar': 'بنسلين G',
        'ur': 'پینسلن G',
    },
    'Oxytetracycline': {
        'fr': 'Oxytétracycline',
        'ar': 'أوكسي تتراسيكلين',
        'ur': 'آکسی ٹیٹراسائیکلین',
    },
    'Ivermectin': {
        'fr': 'Ivermectine',
        'ar': 'إيفرمكتين',
        'ur': 'آئیورمیکٹن',
    },
    'Flunixin Meglumine': {
        'fr': 'Flunixine méglumine',
        'ar': 'فلونيكسين',
        'ur': 'فلونیکسین میگلومین',
    },
    'Clostridial 8-way (CDT+)': {
        'fr': 'Clostridial 8-valent (CDT+)',
        'ar': 'لقاح الكلوستريديا 8-way',
        'ur': 'کلوستریڈial 8-way (CDT+)',
    },
    'FMD Vaccine (O A Asia-1)': {
        'fr': 'Vaccin FMD (O A Asia-1)',
        'ar': 'لقاح الحمى القلاعية (O A Asia-1)',
        'ur': 'FMD ویکسین (O A Asia-1)',
    },
    'PPR Vaccine': {
        'fr': 'Vaccin PPR',
        'ar': 'لقاح PPR',
        'ur': 'PPR ویکسین',
    },
}

PHRASE_I18N = {
    'Bacterial infections': {
        'fr': 'Infections bactériennes',
        'ar': 'العدوى البكتيرية',
        'ur': 'بیکٹیریل انفیکشن',
    },
    'Respiratory infections': {
        'fr': 'Infections respiratoires',
        'ar': 'التهابات الجهاز التنفسي',
        'ur': 'سانس کی انفیکشن',
    },
    'Respiratory tract infections': {
        'fr': 'Infections des voies respiratoires',
        'ar': 'التهابات الجهاز التنفسي',
        'ur': 'سانس کی نالی کی انفیکشن',
    },
    'Internal and external parasites': {
        'fr': 'Parasites internes et externes',
        'ar': 'الطفيليات الداخلية والخارجية',
        'ur': 'اندرونی اور بیرونی پرازیت',
    },
    'Internal external parasites': {
        'fr': 'Parasites internes et externes',
        'ar': 'الطفيليات الداخلية والخارجية',
        'ur': 'اندرونی اور بیرونی پرازیت',
    },
    'Internal parasites': {
        'fr': 'Parasites internes',
        'ar': 'الطفيليات الداخلية',
        'ur': 'اندرونی پرازیت',
    },
    'Pain, fever, inflammation': {
        'fr': 'Douleur, fièvre, inflammation',
        'ar': 'الألم والحمى والالتهاب',
        'ur': 'درد، بukhār، سوزش',
    },
    'Pain fever inflammation': {
        'fr': 'Douleur, fièvre, inflammation',
        'ar': 'الألم والحمى والالتهاب',
        'ur': 'درد، بukhār، سوزش',
    },
    'Pain inflammation': {
        'fr': 'Douleur et inflammation',
        'ar': 'الألم والالتهاب',
        'ur': 'درد اور سوزش',
    },
    'Foot and Mouth Disease': {
        'fr': 'Fièvre aphteuse',
        'ar': 'مرض الحمى القلاعية',
        'ur': 'منہ اور کھر کی بیماری',
    },
    'Allergic reactions': {
        'fr': 'Réactions allergiques',
        'ar': 'تفاعلات حساسية',
        'ur': 'الرجک ردعمل',
    },
    'Copper deficiency': {
        'fr': 'Carence en cuivre',
        'ar': 'نقص النحاس',
        'ur': 'تانبے ki کمی',
    },
    'Organophosphate poisoning': {
        'fr': 'Intoxication aux organophosphorés',
        'ar': 'تسمم organophosphate',
        'ur': 'آرگینو فاسفیٹ زہریلا پن',
    },
    'Sedation analgesia': {
        'fr': 'Sédation et analgésie',
        'ar': 'تخدير وتسكين',
        'ur': 'بے ہوشی اور درد کش',
    },
    'General anesthesia': {
        'fr': 'Anesthésie générale',
        'ar': 'تخدير عام',
        'ur': 'عام بے ہوشی',
    },
    'Mastitis': {
        'fr': 'Mammite',
        'ar': 'التهاب الضرع',
        'ur': 'تھن کی سوزش',
    },
}

VACCINE_INSTRUCTION_I18N = {
    'SC injection annual vaccination': {
        'fr': 'injection SC, vaccination annuelle',
        'ar': 'حقن تحت الجلد، تطعيم سنوي',
        'ur': 'SC انجیکشن، سالانہ ویکسینیشن',
    },
    'SC injection wet season vaccination': {
        'fr': 'injection SC, vaccination saison humide',
        'ar': 'حقن تحت الجلد، تطعيم موسم الأمطار',
        'ur': 'SC انجیکشن، بارش کے موسم کی ویکسینیشن',
    },
    'IM injection annual vaccination': {
        'fr': 'injection IM, vaccination annuelle',
        'ar': 'حقن عضل، تطعيم سنوي',
        'ur': 'IM انجیکشن، سالانہ ویکسینیشن',
    },
    'annual vaccination': {
        'fr': 'vaccination annuelle',
        'ar': 'تطعيم سنوي',
        'ur': 'سالانہ ویکسینیشن',
    },
}

TOKEN_I18N: dict[str, dict[str, str]] = {
    'respiratory': {'fr': 'respiratoire', 'ar': 'تنفسي', 'ur': 'سانس'},
    'infections': {'fr': 'infections', 'ar': 'عدوى', 'ur': 'انفیکشن'},
    'infection': {'fr': 'infection', 'ar': 'عدوى', 'ur': 'انفیکشن'},
    'bacterial': {'fr': 'bactériennes', 'ar': 'بكتيرية', 'ur': 'بیکٹیریل'},
    'parasites': {'fr': 'parasites', 'ar': 'طفيليات', 'ur': 'پرازیت'},
    'internal': {'fr': 'internes', 'ar': 'داخلية', 'ur': 'اندرونی'},
    'external': {'fr': 'externes', 'ar': 'خارجية', 'ur': 'بیرونی'},
    'pneumonia': {'fr': 'pneumonie', 'ar': 'التهاب رئوي', 'ur': 'نمonia'},
    'pain': {'fr': 'douleur', 'ar': 'ألم', 'ur': 'درد'},
    'fever': {'fr': 'fièvre', 'ar': 'حمى', 'ur': 'بukhār'},
    'inflammation': {'fr': 'inflammation', 'ar': 'التهاب', 'ur': 'سوزش'},
    'deficiency': {'fr': 'carence', 'ar': 'نقص', 'ur': 'کمی'},
    'poisoning': {'fr': 'intoxication', 'ar': 'تسمم', 'ur': 'زہریلا پن'},
    'allergic': {'fr': 'allergiques', 'ar': 'حساسية', 'ur': 'الرجک'},
    'reactions': {'fr': 'réactions', 'ar': 'تفاعلات', 'ur': 'ردعمل'},
    'sedation': {'fr': 'sédation', 'ar': 'تخدير', 'ur': 'بے ہوشی'},
    'analgesia': {'fr': 'analgésie', 'ar': 'تسكين', 'ur': 'درد کش'},
    'anesthesia': {'fr': 'anesthésie', 'ar': 'تخدير', 'ur': 'بے ہوشی'},
    'general': {'fr': 'générale', 'ar': 'عام', 'ur': 'عام'},
    'severe': {'fr': 'graves', 'ar': 'شديدة', 'ur': 'شدید'},
    'prevention': {'fr': 'prévention', 'ar': 'وقاية', 'ur': 'روک تھام'},
    'support': {'fr': 'soutien', 'ar': 'دعم', 'ur': 'مدد'},
    'diarrhea': {'fr': 'diarrhée', 'ar': 'إسهال', 'ur': 'اسہال'},
    'mastitis': {'fr': 'mammite', 'ar': 'التهاب الضرع', 'ur': 'تھن کی سوزش'},
    'arthritis': {'fr': 'arthrite', 'ar': 'التهاب مفاصل', 'ur': 'گٹھیا'},
    'lameness': {'fr': 'boiterie', 'ar': 'عرج', 'ur': 'لنگڑاپن'},
    'foot': {'fr': 'pied', 'ar': 'قدم', 'ur': 'کھر'},
    'rot': {'fr': 'pourriture', 'ar': 'تعفن', 'ur': 'سڑن'},
    'tract': {'fr': 'voies', 'ar': 'مسالك', 'ur': 'نali'},
    'and': {'fr': 'et', 'ar': 'و', 'ur': 'aur'},
    'the': {'fr': 'le', 'ar': 'ال', 'ur': ''},
}


def parse_sql_values_block(sql_text: str, table: str) -> list[list[str]]:
    """Parse INSERT INTO {table} ... VALUES rows into string columns."""
    marker = f'INSERT INTO {table}'
    start = sql_text.find(marker)
    if start < 0:
        raise ValueError(f'Missing {marker} in SQL file')
    values_idx = sql_text.find('VALUES', start)
    end = sql_text.find('-- =', values_idx)
    if end < 0:
        end = len(sql_text)
    block = sql_text[values_idx:end]

    rows: list[list[str]] = []
    i = block.find('(')
    while i >= 0:
        depth = 0
        j = i
        in_quote = False
        while j < len(block):
            ch = block[j]
            if ch == "'" and not in_quote:
                in_quote = True
            elif ch == "'" and in_quote:
                if j + 1 < len(block) and block[j + 1] == "'":
                    j += 1
                else:
                    in_quote = False
            elif not in_quote:
                if ch == '(':
                    depth += 1
                elif ch == ')':
                    depth -= 1
                    if depth == 0:
                        inner = block[i + 1 : j]
                        rows.append(split_sql_fields(inner))
                        break
            j += 1
        i = block.find('(', j + 1)
    return rows


def split_sql_fields(inner: str) -> list[str]:
    fields: list[str] = []
    buf: list[str] = []
    in_quote = False
    k = 0
    while k < len(inner):
        ch = inner[k]
        if ch == "'" and not in_quote:
            in_quote = True
        elif ch == "'" and in_quote:
            if k + 1 < len(inner) and inner[k + 1] == "'":
                buf.append("'")
                k += 1
            else:
                in_quote = False
        elif ch == ',' and not in_quote:
            fields.append(''.join(buf).strip())
            buf = []
        else:
            buf.append(ch)
        k += 1
    fields.append(''.join(buf).strip())
    return [clean_sql_field(f) for f in fields]


def clean_sql_field(raw: str) -> str:
    raw = raw.strip()
    if raw.upper() == 'TRUE':
        return 'true'
    if raw.upper() == 'FALSE':
        return 'false'
    if '::mena_restriction_level' in raw:
        if "'" in raw:
            return raw.split("'")[1]
        return raw.split('::')[0]
    return raw


def parse_species(raw: str) -> list[str]:
    text = raw.lower()
    found: list[str] = []
    for sp in ('cattle', 'sheep', 'goat'):
        if sp in text:
            found.append(sp)
    return found or ['cattle', 'sheep', 'goat']


def infer_unit(route: str, category: str) -> str:
    r = route.lower()
    if 'oral' in r and 'feed' in r:
        return 'g'
    if 'oral' in r:
        return 'dose'
    if category.lower() == 'vaccine':
        return 'dose'
    if 'pour-on' in r:
        return 'ml'
    if any(x in r for x in ('im', 'iv', 'sc', 'intramuscular', 'subcutaneous')):
        return 'ml'
    return 'dose'


def category_to_type(category: str, kind: str) -> str:
    if kind == 'vaccine':
        return 'VACCINE'
    key = category.strip().lower()
    return CATEGORY_TYPE.get(key, re.sub(r'[^A-Z0-9]+', '_', category.upper()).strip('_'))


def translate_name(en: str) -> dict[str, str]:
    names = {'en': en}
    override = NAME_OVERRIDES.get(en, {})
    fr = override.get('fr', en.replace(' Vaccine', ' Vaccin') if 'Vaccine' in en else en)
    ar = override.get('ar', en)
    ur = override.get('ur', en)
    names['fr'] = fr
    names['ar'] = ar
    names['ur'] = ur
    return names


def translate_with_glossary(en: str, lang: str) -> str:
    """Best-effort token translation for purpose strings."""
    parts = re.split(r'(\W+)', en)
    out: list[str] = []
    for part in parts:
        key = part.lower().strip()
        if key in TOKEN_I18N:
            out.append(TOKEN_I18N[key].get(lang, part))
        else:
            out.append(part)
    text = ''.join(out)
    return ' '.join(text.split())


def translate_purpose(en: str) -> dict[str, str]:
    if en in PHRASE_I18N:
        return {'en': en, **PHRASE_I18N[en]}

    for key, trans in PHRASE_I18N.items():
        if en.startswith(key):
            suffix = en[len(key) :].strip()
            base = {'en': en, **trans}
            if suffix:
                for loc in ('fr', 'ar', 'ur'):
                    suffix_loc = translate_with_glossary(suffix, loc)
                    base[loc] = f'{base[loc]} {suffix_loc}'.strip()
            return base

    if ' — ' in en:
        disease, instr = en.split(' — ', 1)
        instr = instr.strip()
        if instr in VACCINE_INSTRUCTION_I18N:
            trans = VACCINE_INSTRUCTION_I18N[instr]
            disease_i18n = translate_name(disease.strip())
            return {
                'en': en,
                'fr': f'{disease_i18n["fr"]} — {trans["fr"]}',
                'ar': f'{disease_i18n["ar"]} — {trans["ar"]}',
                'ur': f'{disease_i18n["ur"]} — {trans["ur"]}',
            }

    return {
        'en': en,
        'fr': translate_with_glossary(en, 'fr'),
        'ar': translate_with_glossary(en, 'ar'),
        'ur': translate_with_glossary(en, 'ur'),
    }


def build_withdrawals(species_list: list[str], meat: int, milk: int) -> list[dict]:
    return [
        {'species': sp, 'meat_days': meat, 'milk_days': milk}
        for sp in species_list
    ]


def validate_product(p: dict) -> list[str]:
    errors: list[str] = []
    if not p.get('names', {}).get('en'):
        errors.append('missing English name')
    for loc in ('en', 'fr', 'ar', 'ur'):
        if loc not in p.get('names', {}):
            errors.append(f'missing names.{loc}')
        if loc not in p.get('purpose_names', {}):
            errors.append(f'missing purpose_names.{loc}')
    if not p.get('withdrawal_periods'):
        errors.append('no withdrawal periods')
    if p.get('meat_withdrawal_days', 0) < 0 or p.get('milk_withdrawal_days', 0) < 0:
        errors.append('negative withdrawal')
    return errors


def parse_vaccines(rows: list[list[str]]) -> list[dict]:
    products: list[dict] = []
    for row in rows:
        (
            vid,
            name,
            species,
            _age,
            _preg,
            diseases,
            instructions,
            dosage,
            meat,
            milk,
            mena,
            _banned,
        ) = row[:12]
        vid_i = int(vid)
        meat_i = int(float(meat))
        milk_i = int(float(milk))
        species_list = parse_species(species)
        purpose_en = diseases.strip()
        if instructions.strip():
            purpose_en = f'{purpose_en} — {instructions.strip()}'
        product = {
            'product_number': VACCINE_NUMBER_BASE + vid_i,
            'source_id': vid_i,
            'catalog_kind': 'vaccine',
            'names': translate_name(name.strip()),
            'medicine_type': 'VACCINE',
            'purpose': purpose_en[:500],
            'purpose_names': translate_purpose(purpose_en[:500]),
            'default_unit': 'dose',
            'target_species': species.strip(),
            'dosage': dosage.strip(),
            'route_of_administration': instructions.split()[0] if instructions else 'SC',
            'requires_vet_prescription': False,
            'meat_withdrawal_days': meat_i,
            'milk_withdrawal_days': milk_i,
            'mena_restrictions': mena,
            'withdrawal_periods': build_withdrawals(species_list, meat_i, milk_i),
        }
        products.append(product)
    return products


def parse_medicines(rows: list[list[str]]) -> list[dict]:
    products: list[dict] = []
    for row in rows:
        (
            mid,
            name,
            active,
            category,
            species,
            used_for,
            _age,
            _preg,
            rx,
            _period,
            _freq,
            dosage,
            meat,
            milk,
            mena,
            route,
        ) = row[:16]
        mid_i = int(mid)
        meat_i = int(float(meat))
        milk_i = int(float(milk))
        species_list = parse_species(species)
        med_type = category_to_type(category, 'medicine')
        purpose_en = used_for.strip()
        product = {
            'product_number': MEDICINE_NUMBER_BASE + mid_i,
            'source_id': mid_i,
            'catalog_kind': 'medicine',
            'names': translate_name(name.strip()),
            'medicine_type': med_type,
            'purpose': purpose_en[:500],
            'purpose_names': translate_purpose(purpose_en[:500]),
            'default_unit': infer_unit(route, category),
            'active_ingredient': active.strip(),
            'target_species': species.strip(),
            'dosage': dosage.strip(),
            'route_of_administration': route.strip(),
            'requires_vet_prescription': rx.lower() == 'true',
            'meat_withdrawal_days': meat_i,
            'milk_withdrawal_days': milk_i,
            'mena_restrictions': mena,
            'withdrawal_periods': build_withdrawals(species_list, meat_i, milk_i),
        }
        products.append(product)
    return products


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--sql', type=Path, default=DEFAULT_SQL)
    parser.add_argument('--out', type=Path, default=MOBILE_JSON)
    args = parser.parse_args()

    if not args.sql.is_file():
        print(f'SQL file not found: {args.sql}', file=sys.stderr)
        return 1

    sql_text = args.sql.read_text(encoding='utf-8')
    vaccine_rows = parse_sql_values_block(sql_text, 'vaccines')
    medicine_rows = parse_sql_values_block(sql_text, 'medicines')

    vaccines = parse_vaccines(vaccine_rows)
    medicines = parse_medicines(medicine_rows)
    products = medicines + vaccines

    errors: list[str] = []
    numbers: set[int] = set()
    for p in products:
        pn = p['product_number']
        if pn in numbers:
            errors.append(f'duplicate product_number {pn}')
        numbers.add(pn)
        errors.extend(f"{pn}: {e}" for e in validate_product(p))

    if errors:
        print('Validation errors:', file=sys.stderr)
        for e in errors[:20]:
            print(f'  - {e}', file=sys.stderr)
        if len(errors) > 20:
            print(f'  ... and {len(errors) - 20} more', file=sys.stderr)
        return 1

    payload = {
        'version': 1,
        'source': args.sql.name,
        'product_count': len(products),
        'medicine_count': len(medicines),
        'vaccine_count': len(vaccines),
        'products': products,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(
        f'Wrote {len(products)} products '
        f'({len(medicines)} medicines, {len(vaccines)} vaccines) → {args.out}'
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
