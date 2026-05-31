import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/cull_reasons.dart';

void main() {
  test('CullReasonCatalog lists four types with reasons', () {
    expect(CullReasonCatalog.types, [
      'Health',
      'Fertility',
      'Performance',
      'Management',
    ]);
    expect(
      CullReasonCatalog.reasonsFor('Health'),
      contains('Mastitis'),
    );
    expect(
      CullReasonCatalog.reasonsFor('Fertility'),
      contains('Not in Calf'),
    );
    expect(
      CullReasonCatalog.reasonsFor('Performance'),
      contains('Milk yield'),
    );
    expect(
      CullReasonCatalog.reasonsFor('Management'),
      contains('Meat price'),
    );
  });

  test('CullReasonSelection label combines type and reason', () {
    const selection = CullReasonSelection(
      type: 'Health',
      reason: 'Lameness',
    );
    expect(selection.label, 'Health · Lameness');
  });
}
