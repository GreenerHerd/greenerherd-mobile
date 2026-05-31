import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';

void main() {
  test('maps live API group and animal wire records', () {
    const groupWire = {
      'id': '5d3608ee-1e0f-49d6-bafb-116043e1046d',
      'farm_id': 'farm-1',
      'species': 'CATTLE',
      'name': 'Milking A',
      'purpose': 'MILK',
      'notes': 'Demo lactating group',
    };
    final group = AnimalMapper.groupFromWire(groupWire, headCount: 5);
    expect(group.name, 'Milking A');
    expect(group.purpose, GroupPurpose.milk);
    expect(group.headCount, 5);

    final animalWire = {
      'id': 'dbfb47b5-2127-4092-a151-6a65d8b3ac28',
      'farm_id': 'farm-1',
      'group_id': groupWire['id'],
      'species': 'CATTLE',
      'ear_tag': null,
      'name': 'CATTLE #1',
      'sex': 'FEMALE',
      'breed': 'Holstein',
      'age_range': '1_2Y',
      'status': 'ACTIVE',
      'tags': [],
    };
    final animal = AnimalMapper.fromWire(animalWire);
    expect(animal.tag, '');
    expect(animal.groupId, groupWire['id']);
    expect(animal.species, Species.cattle);
  });
}
