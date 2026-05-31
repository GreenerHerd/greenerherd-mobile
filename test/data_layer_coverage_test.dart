import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_commerce_repository.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_finance_repository.dart';
import 'package:greenerherd_mobile/data/services/animal_mapper.dart';
import 'package:greenerherd_mobile/data/services/auth_mapper.dart';
import 'package:greenerherd_mobile/data/services/farm_mapper.dart';
import 'package:greenerherd_mobile/data/services/onboarding_mapper.dart';
import 'package:greenerherd_mobile/data/services/people_mapper.dart';

import 'bdd/finance_api_bdd_test.dart';

void main() {
  group('Data layer mappers', () {
    test('AuthMapper extracts farm id from token', () {
      const token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidTEiLCJmYXJtX2lkcyI6WyJmYXJtLTEiXSwicm9sZSI6Ik9XTkVSIiwiaWF0IjoxNzc5MTI1NzQzLCJleHAiOjE4MTA2NjE3NDN9.hayjIR_PDypFhMbZd5MXugEJhaemeh5fBBGNX1yoPBo';
      expect(AuthMapper.primaryFarmIdFromToken(token), 'farm-1');
    });

    test('FarmMapper maps wire farm', () {
      final farm = FarmMapper.fromWire({
        'id': 'farm-1',
        'name': 'Test',
        'country': 'SA',
        'preferred_currency': 'SAR',
        'housing_type': 'PASTURE',
      });
      expect(farm.housing, HousingType.pasture);
    });

    test('PeopleMapper maps member list', () {
      final users = PeopleMapper.fromMemberList([
        {
          'farm_user': {'farm_role': 'MANAGER', 'user_id': 'u2'},
          'user': {'id': 'u2', 'name': 'Khaled'},
        },
      ]);
      expect(users.first.role, UserRole.manager);
    });

    test('OnboardingMapper wires', () {
      expect(OnboardingMapper.speciesWire(Species.sheep), 'SHEEP');
    });

    test('AnimalMapper group purpose wires', () {
      expect(AnimalMapper.groupPurposeWire(GroupPurpose.milk), 'MILK');
    });
  });

  test('Commerce and finance share fake gateway', () async {
    final store = MockDataStore(seedDemoHerd: true);
    final gateway = FakeFinanceGateway();
    final finance = HybridFinanceRepository(
      offlineStore: store,
      gateway: gateway,
      farmId: 'farm-1',
    );
    final commerce = HybridCommerceRepository(
      offlineStore: store,
      gateway: gateway,
      farmId: 'farm-1',
    );
    await commerce.recordPurchase(
      PurchaseRecord(
        id: 'p1',
        purchaseDate: DateTime.now(),
        totalAmount: 100,
        animalIds: const [],
      ),
    );
    final summary = await finance.getSummary();
    expect(summary.income3mo, greaterThan(0));
  });
}
