enum AuthProvider { google, apple, facebook }

enum Species { cattle, goat, sheep }

enum AnimalStatus { active, sold, deceased, culled }

enum AnimalTagType {
  pregnant,
  lactating,
  readyToBreed,
  weaning,
  cull,
  sold,
  miscarriage,
  stillborn,
  sick,
  fattening,
}

enum GroupPurpose {
  milk,
  breeding,
  pregnant,
  fattening,
  maintenance,
  weaning,
  dry,
  sick,
}

enum UserRole { owner, manager, farmHand, vet }

enum TaskType { manual, autoBreeding, autoVaccination, autoHealth }

enum TaskTone { primary, warning, error, neutral, info }

enum FinanceEntryType { income, expense }

enum PreferredLang { en, ar, ur, fr }

enum HousingType { indoorFans, indoorShade, pasture }

enum SpeciesPurpose { milk, meat, both }

enum CalvingOutcome { bornLive, stillborn, miscarriage }

extension SpeciesX on Species {
  static Species fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cattle':
        return Species.cattle;
      case 'goat':
      case 'goats':
        return Species.goat;
      case 'sheep':
        return Species.sheep;
      default:
        return Species.cattle;
    }
  }

  String get wire => name;
}

extension AnimalTagTypeX on AnimalTagType {
  static AnimalTagType? fromWire(String? wire) {
    if (wire == null) return null;
    return _wireMap[wire.toUpperCase()];
  }

  static final _wireMap = <String, AnimalTagType>{
    'PREGNANT': AnimalTagType.pregnant,
    'LACTATING': AnimalTagType.lactating,
    'READY_TO_BREED': AnimalTagType.readyToBreed,
    'WEANING': AnimalTagType.weaning,
    'CULL': AnimalTagType.cull,
    'SOLD': AnimalTagType.sold,
    'MISCARRIAGE': AnimalTagType.miscarriage,
    'STILLBORN': AnimalTagType.stillborn,
    'SICK': AnimalTagType.sick,
    'FATTENING': AnimalTagType.fattening,
  };

  String get wire {
    switch (this) {
      case AnimalTagType.readyToBreed:
        return 'READY_TO_BREED';
      default:
        return name.toUpperCase();
    }
  }
}
