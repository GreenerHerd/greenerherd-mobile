import '../../core/l10n/gen/app_localizations.dart';
import 'enums.dart';

/// Breeding / fertility methods aligned with [BreedingEvent.method] wire values.
enum BreedingMethod { natural, ai, embryonic, sponges }

abstract final class BreedingMethodCatalog {
  BreedingMethodCatalog._();

  static List<BreedingMethod> forSpecies(Species species) => switch (species) {
        Species.cattle => [
            BreedingMethod.natural,
            BreedingMethod.ai,
            BreedingMethod.embryonic,
          ],
        Species.goat || Species.sheep => [
            BreedingMethod.natural,
            BreedingMethod.ai,
            BreedingMethod.sponges,
          ],
      };

  /// All species require a method when marking ready to breed (drives task schedules).
  static bool requiresMethodOnReadyToBreed(Species species) => true;

  static BreedingMethod defaultForSpecies(Species species) => switch (species) {
        Species.cattle => BreedingMethod.ai,
        Species.goat || Species.sheep => BreedingMethod.natural,
      };

  static BreedingMethod resolveMethod({
    required Species species,
    BreedingMethod? explicit,
  }) =>
      explicit ?? defaultForSpecies(species);

  static BreedingMethod? fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return null;
    return switch (wire.toUpperCase()) {
      'NATURAL' || 'NAT' => BreedingMethod.natural,
      'AI' => BreedingMethod.ai,
      'EMBRYONIC' || 'ET' => BreedingMethod.embryonic,
      'SPONGES' || 'SPONGE' => BreedingMethod.sponges,
      _ => null,
    };
  }

  static String wire(BreedingMethod method) => switch (method) {
        BreedingMethod.natural => 'NATURAL',
        BreedingMethod.ai => 'AI',
        BreedingMethod.embryonic => 'EMBRYONIC',
        BreedingMethod.sponges => 'SPONGES',
      };

  static String label(BreedingMethod method, AppLocalizations l10n) =>
      switch (method) {
        BreedingMethod.natural => l10n.breedingMethodNatural,
        BreedingMethod.ai => l10n.breedingMethodAi,
        BreedingMethod.embryonic => l10n.breedingMethodEmbryonic,
        BreedingMethod.sponges => l10n.breedingMethodSponges,
      };
}
