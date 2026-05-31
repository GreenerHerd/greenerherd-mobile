import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/l10n/catalog_localization.dart';
import 'package:greenerherd_mobile/data/models/breed_reference.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';

void main() {
  test('resolveCatalogName prefers locale then English', () {
    const names = {
      'en': 'Soya beans',
      'ar': 'فول الصويا',
      'fr': 'Soja',
    };
    expect(
      resolveCatalogName(names, locale: const Locale('ar'), fallbackEn: 'Soya beans'),
      'فول الصويا',
    );
    expect(
      resolveCatalogName(names, locale: const Locale('fr'), fallbackEn: 'Soya beans'),
      'Soja',
    );
    expect(
      resolveCatalogName(names, locale: const Locale('ur'), fallbackEn: 'Soya beans'),
      'Soya beans',
    );
  });

  test('BreedReference.fromJson reads names map', () {
    final breed = BreedReference.fromJson({
      'id': 'b1',
      'species': 'CATTLE',
      'code': 'HOL',
      'name_en': 'Holstein',
      'names': {'en': 'Holstein', 'ar': 'هولشتاين'},
    });
    expect(breed.displayName(const Locale('ar')), 'هولشتاين');
    expect(breed.species, Species.cattle);
  });
}
