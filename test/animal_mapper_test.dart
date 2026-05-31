import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';

void main() {
  test('maps cattle API row to Animal', () {
    final animal = AnimalMapper.fromWire({
      'id': 'a1',
      'species': 'CATTLE',
      'sex': 'FEMALE',
      'breed': 'Holstein',
      'ear_tag': '0421',
      'name': 'Bessie',
      'group_id': 'g1',
      'current_weight_kg': 580,
      'age_range': '1_2Y',
      'status': 'ACTIVE',
      'cull_flagged': false,
      'tags': ['LACTATING', 'PREGNANT'],
    });

    expect(animal.tag, '0421');
    expect(animal.species, Species.cattle);
    expect(animal.tags, contains(AnimalTagType.lactating));
    expect(animal.ageLabel, '1-2yr');
  });
}
