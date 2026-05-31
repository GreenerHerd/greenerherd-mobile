/** BCP-47 language codes supported for catalog translations. */
export type CatalogLocale = 'en' | 'ar' | 'fr' | 'ur';

export const CATALOG_LOCALES: CatalogLocale[] = ['en', 'ar', 'fr', 'ur'];

export function normalizeCatalogLocale(raw?: string | null): CatalogLocale {
  const code = (raw ?? 'en').toLowerCase().split('-')[0];
  if (code === 'ar' || code === 'fr' || code === 'ur') return code;
  return 'en';
}

export type CatalogNames = Partial<Record<CatalogLocale, string>>;

/** Build a names map from legacy inline columns on a master row. */
export function namesFromLegacyRow(row: {
  name_en: string;
  name_ar?: string | null;
  name_fr?: string | null;
  name_ur?: string | null;
}): CatalogNames {
  const names: CatalogNames = { en: row.name_en };
  if (row.name_ar?.trim()) names.ar = row.name_ar.trim();
  if (row.name_fr?.trim()) names.fr = row.name_fr.trim();
  if (row.name_ur?.trim()) names.ur = row.name_ur.trim();
  return names;
}

export function mergeTransRows(
  base: CatalogNames,
  rows: Array<{ locale: string; name: string }>,
): CatalogNames {
  const out: CatalogNames = { ...base };
  for (const row of rows) {
    const loc = normalizeCatalogLocale(row.locale);
    if (row.name?.trim()) out[loc] = row.name.trim();
  }
  if (!out.en) {
    const first = Object.values(out).find(Boolean);
    if (first) out.en = first;
  }
  return out;
}

export function resolveCatalogName(
  names: CatalogNames,
  locale: CatalogLocale,
  fallbackEn?: string,
): string {
  return (
    names[locale] ??
    names.en ??
    fallbackEn ??
    Object.values(names).find((v) => v?.trim()) ??
    ''
  );
}

export function publicNames(names: CatalogNames): Record<string, string> {
  const out: Record<string, string> = {};
  for (const loc of CATALOG_LOCALES) {
    const v = names[loc];
    if (v?.trim()) out[loc] = v.trim();
  }
  return out;
}
