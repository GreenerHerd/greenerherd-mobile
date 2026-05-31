import '../models/enums.dart';

abstract final class OnboardingMapper {
  static String speciesWire(Species species) => switch (species) {
        Species.cattle => 'CATTLE',
        Species.goat => 'GOAT',
        Species.sheep => 'SHEEP',
      };

  static String purposeWire(SpeciesPurpose purpose) => switch (purpose) {
        SpeciesPurpose.milk => 'MILK',
        SpeciesPurpose.meat => 'MEAT',
        SpeciesPurpose.both => 'BOTH',
      };

  static String housingWire(HousingType housing) => switch (housing) {
        HousingType.indoorShade => 'INDOOR_SHADE',
        HousingType.pasture => 'PASTURE',
        _ => 'INDOOR_FANS',
      };
}
