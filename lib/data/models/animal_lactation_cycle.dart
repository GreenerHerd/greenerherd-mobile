import '../../core/l10n/gen/app_localizations.dart';
import 'enums.dart';

/// Farmer-selected lactation phase on the milking tab (persisted on [Animal]).
enum AnimalLactationCycle {
  cattleEarly,
  cattleMid,
  cattleLate,
  /// Still milking; transitioning toward dry-off at end of lactation.
  cattleClose,
  /// Dry cow in the pre-calving close-up period (close to dry-off before calving).
  cattlePreCalvingCloseToDryOff,
  cattleDry,
  nonLactating,
  lactatingSingle,
  lactatingTwin,
}

/// Catalog: species options, labels, nutrition feed-cycle hints, tag updates.
abstract final class LactationCycleCatalog {
  static const wireCattleEarly = 'CATTLE_EARLY';
  static const wireCattleMid = 'CATTLE_MID';
  static const wireCattleLate = 'CATTLE_LATE';
  static const wireCattleClose = 'CATTLE_CLOSE';
  static const wireCattlePreCalvingCloseToDryOff = 'CATTLE_PRECALVING_CLOSE_TO_DRYOFF';
  static const wireCattleDry = 'CATTLE_DRY';
  static const wireNonLactating = 'NON_LACTATING';
  static const wireLactatingSingle = 'LACTATING_SINGLE';
  static const wireLactatingTwin = 'LACTATING_TWIN';

  static List<AnimalLactationCycle> forSpecies(Species species) =>
      switch (species) {
        Species.cattle => [
            AnimalLactationCycle.cattleEarly,
            AnimalLactationCycle.cattleMid,
            AnimalLactationCycle.cattleLate,
            AnimalLactationCycle.cattleClose,
            AnimalLactationCycle.cattlePreCalvingCloseToDryOff,
            AnimalLactationCycle.cattleDry,
          ],
        Species.goat || Species.sheep => [
            AnimalLactationCycle.nonLactating,
            AnimalLactationCycle.lactatingSingle,
            AnimalLactationCycle.lactatingTwin,
          ],
      };

  static String wire(AnimalLactationCycle cycle) => switch (cycle) {
        AnimalLactationCycle.cattleEarly => wireCattleEarly,
        AnimalLactationCycle.cattleMid => wireCattleMid,
        AnimalLactationCycle.cattleLate => wireCattleLate,
        AnimalLactationCycle.cattleClose => wireCattleClose,
        AnimalLactationCycle.cattlePreCalvingCloseToDryOff =>
            wireCattlePreCalvingCloseToDryOff,
        AnimalLactationCycle.cattleDry => wireCattleDry,
        AnimalLactationCycle.nonLactating => wireNonLactating,
        AnimalLactationCycle.lactatingSingle => wireLactatingSingle,
        AnimalLactationCycle.lactatingTwin => wireLactatingTwin,
      };

  static AnimalLactationCycle? fromWire(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value) {
      wireCattleEarly => AnimalLactationCycle.cattleEarly,
      wireCattleMid => AnimalLactationCycle.cattleMid,
      wireCattleLate => AnimalLactationCycle.cattleLate,
      wireCattleClose => AnimalLactationCycle.cattleClose,
      wireCattlePreCalvingCloseToDryOff =>
          AnimalLactationCycle.cattlePreCalvingCloseToDryOff,
      wireCattleDry => AnimalLactationCycle.cattleDry,
      wireNonLactating => AnimalLactationCycle.nonLactating,
      wireLactatingSingle => AnimalLactationCycle.lactatingSingle,
      wireLactatingTwin => AnimalLactationCycle.lactatingTwin,
      _ => null,
    };
  }

  static String label(AnimalLactationCycle cycle, AppLocalizations l10n) =>
      switch (cycle) {
        AnimalLactationCycle.cattleEarly => l10n.lactationCycleEarly,
        AnimalLactationCycle.cattleMid => l10n.lactationCycleMid,
        AnimalLactationCycle.cattleLate => l10n.lactationCycleLate,
        AnimalLactationCycle.cattleClose => l10n.lactationCycleCloseLateLactation,
        AnimalLactationCycle.cattlePreCalvingCloseToDryOff =>
            l10n.lactationCycleCloseToDryOffPreCalving,
        AnimalLactationCycle.cattleDry => l10n.lactationCycleDry,
        AnimalLactationCycle.nonLactating => l10n.lactationCycleNone,
        AnimalLactationCycle.lactatingSingle => l10n.lactationCycleSingle,
        AnimalLactationCycle.lactatingTwin => l10n.lactationCycleTwin,
      };

  static bool isLactating(AnimalLactationCycle cycle) => switch (cycle) {
        AnimalLactationCycle.cattleDry ||
        AnimalLactationCycle.cattlePreCalvingCloseToDryOff ||
        AnimalLactationCycle.nonLactating =>
          false,
        _ => true,
      };

  static bool isPreCalvingDry(AnimalLactationCycle cycle) =>
      cycle == AnimalLactationCycle.cattlePreCalvingCloseToDryOff;

  static bool isTwinLactation(AnimalLactationCycle cycle) =>
      cycle == AnimalLactationCycle.lactatingTwin;

  /// Suggested months since calving for cattle nutrition resolution.
  static int? monthsSinceCalvingFor(AnimalLactationCycle cycle) =>
      switch (cycle) {
        AnimalLactationCycle.cattleEarly => 1,
        AnimalLactationCycle.cattleMid => 4,
        AnimalLactationCycle.cattleLate => 7,
        AnimalLactationCycle.cattleClose => 9,
        AnimalLactationCycle.cattlePreCalvingCloseToDryOff => null,
        _ => null,
      };

  /// Infer cycle from legacy tags when [lactationCycle] is unset.
  static AnimalLactationCycle? inferFromAnimal({
    required Species species,
    required List<AnimalTagType> tags,
    bool? isTwin,
    int? monthsSinceCalving,
  }) {
    final lactating = tags.contains(AnimalTagType.lactating);
    return switch (species) {
      Species.cattle => () {
          if (!lactating) {
            if (tags.contains(AnimalTagType.pregnant)) {
              return AnimalLactationCycle.cattlePreCalvingCloseToDryOff;
            }
            return AnimalLactationCycle.cattleDry;
          }
          final m = monthsSinceCalving ?? 2;
          if (m <= 1) return AnimalLactationCycle.cattleEarly;
          if (m <= 3) return AnimalLactationCycle.cattleMid;
          if (m <= 6) return AnimalLactationCycle.cattleLate;
          if (m <= 9) return AnimalLactationCycle.cattleClose;
          return AnimalLactationCycle.cattleLate;
        }(),
      Species.goat || Species.sheep => () {
          if (!lactating) return AnimalLactationCycle.nonLactating;
          if (isTwin == true) return AnimalLactationCycle.lactatingTwin;
          return AnimalLactationCycle.lactatingSingle;
        }(),
    };
  }

  static AnimalLactationCycle defaultAfterCalving({
    required Species species,
    required int prolificacy,
  }) =>
      switch (species) {
        Species.cattle => AnimalLactationCycle.cattleEarly,
        Species.goat || Species.sheep =>
          prolificacy >= 2
              ? AnimalLactationCycle.lactatingTwin
              : AnimalLactationCycle.lactatingSingle,
      };

  /// Default when joining or creating a milking-purpose group (user can change later).
  static AnimalLactationCycle defaultForMilkingGroup(Species species) =>
      switch (species) {
        Species.cattle => AnimalLactationCycle.cattleMid,
        Species.goat || Species.sheep => AnimalLactationCycle.lactatingSingle,
      };
}
