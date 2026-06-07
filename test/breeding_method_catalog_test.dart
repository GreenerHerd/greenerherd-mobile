import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/breeding_methods.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/animal_lifecycle_service.dart';
import 'package:greenerherd_mobile/data/models/models.dart';

void main() {
  group('BreedingMethodCatalog', () {
    test('goats and sheep include sponges', () {
      for (final species in [Species.goat, Species.sheep]) {
        expect(
          BreedingMethodCatalog.forSpecies(species),
          contains(BreedingMethod.sponges),
        );
        expect(
          BreedingMethodCatalog.forSpecies(species),
          isNot(contains(BreedingMethod.embryonic)),
        );
      }
    });

    test('cattle includes embryo transfer but not sponges', () {
      final methods = BreedingMethodCatalog.forSpecies(Species.cattle);
      expect(methods, contains(BreedingMethod.embryonic));
      expect(methods, isNot(contains(BreedingMethod.sponges)));
    });

    test('wire round-trip includes sponges', () {
      expect(
        BreedingMethodCatalog.fromWire('SPONGES'),
        BreedingMethod.sponges,
      );
      expect(
        BreedingMethodCatalog.wire(BreedingMethod.sponges),
        'SPONGES',
      );
    });
  });

  group('AnimalLifecycleService breeding method', () {
    const lifecycle = AnimalLifecycleService();

    Animal goat({List<AnimalTagType> tags = const []}) => Animal(
          id: 'g1',
          tag: 'G1',
          name: 'Daisy',
          species: Species.goat,
          sex: 'F',
          breed: 'Boer',
          weightKg: 45,
          ageLabel: '2y',
          groupId: 'grp',
          tags: tags,
        );

    test('goat ready to breed requires fertility method', () {
      expect(
        () => lifecycle.markReadyToBreed(goat()),
        throwsStateError,
      );
    });

    test('goat ready to breed stores sponges method', () {
      final updated = lifecycle.markReadyToBreed(
        goat(),
        method: BreedingMethod.sponges,
      );
      expect(updated.tags, contains(AnimalTagType.readyToBreed));
      expect(updated.breedingMethod, BreedingMethod.sponges);
    });

    test('cattle ready to breed requires and stores method', () {
      const cow = Animal(
        id: 'c1',
        tag: 'C1',
        name: 'Bess',
        species: Species.cattle,
        sex: 'F',
        breed: 'Holstein',
        weightKg: 500,
        ageLabel: '4y',
        groupId: 'grp',
      );
      expect(() => lifecycle.markReadyToBreed(cow), throwsStateError);
      final updated = lifecycle.markReadyToBreed(
        cow,
        method: BreedingMethod.ai,
      );
      expect(updated.tags, contains(AnimalTagType.readyToBreed));
      expect(updated.breedingMethod, BreedingMethod.ai);
    });

    test('defaultForSpecies picks AI for cattle and natural for goats', () {
      expect(
        BreedingMethodCatalog.defaultForSpecies(Species.cattle),
        BreedingMethod.ai,
      );
      expect(
        BreedingMethodCatalog.defaultForSpecies(Species.goat),
        BreedingMethod.natural,
      );
    });
  });
}
