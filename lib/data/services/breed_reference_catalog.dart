import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/breed_reference.dart';
import '../models/enums.dart';

class BreedReferenceCatalog {
  BreedReferenceCatalog._(this._bySpecies);

  final Map<Species, List<BreedReference>> _bySpecies;

  static BreedReferenceCatalog? _instance;

  static Future<BreedReferenceCatalog> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/data/breeds.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final breeds = (decoded['breeds'] as List<dynamic>)
        .map((e) => BreedReference.fromJson(e as Map<String, dynamic>))
        .toList();

    final bySpecies = <Species, List<BreedReference>>{};
    for (final breed in breeds) {
      bySpecies.putIfAbsent(breed.species, () => []).add(breed);
    }
    for (final list in bySpecies.values) {
      list.sort((a, b) => a.nameEn.compareTo(b.nameEn));
    }

    _instance = BreedReferenceCatalog._(bySpecies);
    return _instance!;
  }

  List<BreedReference> forSpecies(Species species) {
    return List.unmodifiable(_bySpecies[species] ?? const []);
  }

  BreedReference? resolve(Species species, String name) {
    final key = _normalize(name);
    for (final breed in forSpecies(species)) {
      if (_normalize(breed.nameEn) == key) return breed;
      for (final name in breed.names.values) {
        if (_normalize(name) == key) return breed;
      }
      if (_normalize(breed.code) == key) return breed;
    }
    return null;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
