import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/services/group_nutrition_profile_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads known profile for seed group g1', () async {
    final profile = await GroupNutritionProfileResolver.resolve('g1');
    expect(profile, isNotNull);
    expect(profile!.request['species'], 'CATTLE');
    expect(profile.request['head_count'], 22);
    expect(profile.currentIntakeRatio, closeTo(0.76, 0.001));
  });

  test('builds request body with intake options', () {
    const profile = GroupNutritionProfile(
      request: {'species': 'CATTLE', 'head_count': 5},
      currentIntakeRatio: 0.9,
    );
    final body = profile.toRequestBody();
    expect(body['current_intake_ratio'], 0.9);
    expect(body['head_count'], 5);
  });
}
