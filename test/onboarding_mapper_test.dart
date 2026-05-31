import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';
import 'package:greenerherd_mobile/data/services/onboarding_mapper.dart';

void main() {
  test('OnboardingMapper species and purpose wire', () {
    expect(OnboardingMapper.speciesWire(Species.goat), 'GOAT');
    expect(OnboardingMapper.purposeWire(SpeciesPurpose.milk), 'MILK');
    expect(OnboardingMapper.housingWire(HousingType.pasture), 'PASTURE');
  });

  test('AnimalMapper purchased create body', () {
    const animal = Animal(
      id: 'a1',
      tag: 'T1',
      name: 'Cow',
      species: Species.cattle,
      sex: 'Female',
      breed: 'Holstein',
      weightKg: 400,
      ageLabel: '1-2yr',
      groupId: '',
    );
    final body = AnimalMapper.toCreateBody(animal, purchased: true);
    expect(body['origin'], 'PURCHASED');
    expect(body['species'], 'CATTLE');
  });
}
