import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/services/nutrition_traffic_light.dart';

void main() {
  test('app smoke — traffic light helper', () {
    expect(nutritionTrafficLight(-41), NutritionTrafficLight.red);
  });
}
