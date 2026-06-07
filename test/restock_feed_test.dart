import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/repositories/local_inventory_repository.dart';

void main() {
  group('restockFeed', () {
    late LocalInventoryRepository inventory;

    setUp(() => inventory = LocalInventoryRepository());

    test('adds purchased volume and updates unit cost and supplier', () async {
      final feed = await inventory.listFeed();
      final alfalfa = feed.firstWhere((f) => f.id == 'feed-alfalfa');
      expect(alfalfa.quantityKg, 120);
      expect(alfalfa.unitCost, 1.8);

      final updated = await inventory.restockFeed(
        feedId: alfalfa.id,
        purchasedVolumeKg: 100,
        unitCost: 2.0,
        supplierName: 'New supplier',
      );

      expect(updated.quantityKg, 220);
      expect(updated.purchasedVolumeKg, 100);
      expect(updated.unitCost, 2.0);
      expect(updated.supplierName, 'New supplier');
    });

    test('defaults supplier when not provided', () async {
      final alfalfa = (await inventory.getFeed('feed-alfalfa'))!;
      final updated = await inventory.restockFeed(
        feedId: alfalfa.id,
        purchasedVolumeKg: 50,
        unitCost: 1.9,
      );

      expect(updated.supplierName, alfalfa.supplierName);
      expect(updated.quantityKg, alfalfa.quantityKg + 50);
    });

    test('rejects unknown feed id', () async {
      expect(
        () => inventory.restockFeed(
          feedId: 'missing',
          purchasedVolumeKg: 10,
          unitCost: 1,
        ),
        throwsStateError,
      );
    });
  });
}
