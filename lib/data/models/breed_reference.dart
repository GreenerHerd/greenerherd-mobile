import 'package:flutter/material.dart';

import '../../core/l10n/catalog_localization.dart';
import 'enums.dart';

class BreedReference {
  const BreedReference({
    required this.id,
    required this.species,
    required this.code,
    required this.nameEn,
    required this.names,
    this.nameAr,
    this.origin,
    this.primaryPurpose,
    this.color,
    this.milkProductionKgYear,
    this.heatTolerance,
    this.diseaseResistance,
    this.birthEase,
    this.knownFor,
  });

  final String id;
  final Species species;
  final String code;
  final String nameEn;
  final Map<String, String> names;
  final String? nameAr;
  final String? origin;
  final String? primaryPurpose;
  final String? color;
  final String? milkProductionKgYear;
  final String? heatTolerance;
  final String? diseaseResistance;
  final String? birthEase;
  final String? knownFor;

  String displayName(Locale locale) =>
      resolveCatalogName(names, locale: locale, fallbackEn: nameEn);

  factory BreedReference.fromJson(Map<String, dynamic> json) {
    String? optString(dynamic value) =>
        value?.toString();

    final names = parseCatalogNames(json);
    final nameEn = names[CatalogLocales.en] ?? json['name_en'] as String;

    return BreedReference(
      id: json['id'] as String,
      species: _speciesFromApi(json['species'] as String),
      code: json['code'] as String,
      nameEn: nameEn,
      names: names,
      nameAr: names[CatalogLocales.ar] ?? optString(json['name_ar']),
      origin: optString(json['origin']),
      primaryPurpose: optString(json['primary_purpose']),
      color: optString(json['color']),
      milkProductionKgYear: optString(json['milk_production_kg_year']),
      heatTolerance: optString(json['heat_tolerance']),
      diseaseResistance: optString(json['disease_resistance']),
      birthEase: optString(json['birth_ease']),
      knownFor: optString(json['known_for']),
    );
  }
}

Species _speciesFromApi(String value) {
  return switch (value) {
    'CATTLE' => Species.cattle,
    'GOAT' => Species.goat,
    'SHEEP' => Species.sheep,
    _ => Species.cattle,
  };
}
