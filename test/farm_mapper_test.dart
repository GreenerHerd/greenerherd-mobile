import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/farm_mapper.dart';
import 'package:greenerherd_mobile/data/services/people_mapper.dart';

void main() {
  test('FarmMapper maps housing and currency', () {
    final farm = FarmMapper.fromWire(
      {
        'id': 'farm-1',
        'name': 'Al-Falah Farm',
        'country': 'SA',
        'preferred_currency': 'SAR',
        'housing_type': 'INDOOR_FANS',
      },
      ownerName: 'Yusuf',
    );
    expect(farm.id, 'farm-1');
    expect(farm.currency, 'SAR');
    expect(farm.housing, HousingType.indoorFans);
    expect(farm.ownerName, 'Yusuf');
  });

  test('PeopleMapper maps nested member view', () {
    final user = PeopleMapper.fromMemberWire({
      'farm_user': {'farm_role': 'MANAGER', 'user_id': 'u2'},
      'user': {'id': 'u2', 'name': 'Khaled Saleh'},
    });
    expect(user.id, 'u2');
    expect(user.role, UserRole.manager);
    expect(user.initials, 'KS');
  });
}
