import '../models/enums.dart';
import '../models/models.dart';
import 'animal_lifecycle_service.dart';
import 'gestation_validation.dart';

/// Derive due dates and gestation months from farmer-entered dates.
abstract final class GestationDates {
  GestationDates._();

  static DateTime dueDateFromGestMonths(
    Species species,
    int gestMonths,
    DateTime referenceDate,
  ) {
    final totalDays = AnimalLifecycleService.gestationDays[species] ?? 283;
    final elapsedDays = (gestMonths * 30).clamp(0, totalDays);
    final remaining = totalDays - elapsedDays;
    final day = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    return day.add(Duration(days: remaining));
  }

  static int gestMonthsFromDueDate(
    Species species,
    DateTime dueDate,
    DateTime referenceDate,
  ) {
    final totalDays = AnimalLifecycleService.gestationDays[species] ?? 283;
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final ref = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final daysRemaining = due.difference(ref).inDays;
    final elapsed = (totalDays - daysRemaining).clamp(0, totalDays);
    return (elapsed / 30)
        .ceil()
        .clamp(1, GestationValidation.maxGestationMonths(species));
  }

  static DateTime? effectiveDueDate(Animal animal, DateTime referenceDate) {
    if (animal.dueDate != null) return animal.dueDate;
    if (animal.gestMonths != null) {
      return dueDateFromGestMonths(
        animal.species,
        animal.gestMonths!,
        referenceDate,
      );
    }
    return null;
  }

  static int effectiveProlificacy(Animal animal) {
    if (animal.prolificacy != null) return animal.prolificacy!;
    if (animal.isTwin == true) return 2;
    return 2;
  }

  static String formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
