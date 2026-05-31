import 'package:flutter/material.dart';

import 'gen/app_localizations.dart';

/// Human-readable language names for the picker (native script where applicable).
String localeDisplayName(AppLocalizations l10n, String languageCode) =>
    switch (languageCode) {
      'ar' => l10n.languageArabic,
      'fr' => l10n.languageFrench,
      'ur' => l10n.languageUrdu,
      _ => l10n.languageEnglish,
    };

/// RTL locales used in the app.
bool isRtlLocale(Locale locale) =>
    locale.languageCode == 'ar' || locale.languageCode == 'ur';
