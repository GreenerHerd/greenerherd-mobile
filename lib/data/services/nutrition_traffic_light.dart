/// Nutrition deviation traffic light per harness: ±10% green, 10–30% orange, >30% red.
enum NutritionTrafficLight { green, orange, red }

NutritionTrafficLight nutritionTrafficLight(double deviationPercent) {
  final a = deviationPercent.abs();
  if (a <= 10) return NutritionTrafficLight.green;
  if (a <= 30) return NutritionTrafficLight.orange;
  return NutritionTrafficLight.red;
}
