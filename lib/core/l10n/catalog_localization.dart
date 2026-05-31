import 'package:flutter/material.dart';

/// Supported catalog translation locales (matches DB `*_trans.locale`).
abstract final class CatalogLocales {
  static const en = 'en';
  static const ar = 'ar';
  static const fr = 'fr';
  static const ur = 'ur';

  static String fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return ar;
      case 'fr':
        return fr;
      case 'ur':
        return ur;
      default:
        return en;
    }
  }
}

/// Resolves a display name from a translation map (API `names` or bundled JSON).
String resolveCatalogName(
  Map<String, String> names, {
  required Locale locale,
  String? fallbackEn,
}) {
  final code = CatalogLocales.fromLocale(locale);
  return names[code] ??
      names[CatalogLocales.en] ??
      fallbackEn ??
      names.values.firstWhere((v) => v.isNotEmpty, orElse: () => '');
}

/// Parses `names` from API/JSON; falls back to legacy `name_en` / `name_ar` fields.
Map<String, String> parseCatalogNames(
  Map<String, dynamic> json, {
  String enKey = 'name_en',
  String? arKey = 'name_ar',
}) {
  final raw = json['names'];
  if (raw is Map) {
    return raw.map(
      (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
    )..removeWhere((_, v) => v.isEmpty);
  }
  final names = <String, String>{};
  final en = json[enKey]?.toString();
  if (en != null && en.isNotEmpty) names[CatalogLocales.en] = en;
  if (arKey != null) {
    final ar = json[arKey]?.toString();
    if (ar != null && ar.isNotEmpty) names[CatalogLocales.ar] = ar;
  }
  final fr = json['name_fr']?.toString();
  if (fr != null && fr.isNotEmpty) names[CatalogLocales.fr] = fr;
  final ur = json['name_ur']?.toString();
  if (ur != null && ur.isNotEmpty) names[CatalogLocales.ur] = ur;
  return names;
}
