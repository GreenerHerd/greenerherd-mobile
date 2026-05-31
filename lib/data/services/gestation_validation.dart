import '../models/enums.dart';
import 'animal_lifecycle_service.dart';

/// Species-specific gestation month limits for pregnancy entry UIs.
class GestationValidation {
  GestationValidation._();

  /// Typical full-term gestation length in months (farmer-facing).
  static int maxGestationMonths(Species species) {
    final days = AnimalLifecycleService.gestationDays[species] ?? 283;
    return (days / 30).ceil().clamp(1, 12);
  }

  static String? validateGestMonths(Species species, int? months) {
    if (months == null) {
      return 'Enter months pregnant';
    }
    if (months < 1) {
      return 'Must be at least 1 month';
    }
    final max = maxGestationMonths(species);
    if (months > max) {
      return 'Maximum $max months for ${_speciesLabel(species)}';
    }
    return null;
  }

  static String _speciesLabel(Species species) => switch (species) {
        Species.cattle => 'cattle',
        Species.goat => 'goats',
        Species.sheep => 'sheep',
      };
}
