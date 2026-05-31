/// Standard feed-cycle codes aligned with the nutrition masterfile.
abstract final class NutritionFeedCycle {
  // Dairy cattle
  static const dryFarOff = 'DRY_FAR_OFF';
  static const closeUp = 'CLOSE_UP';
  static const fresh = 'FRESH';
  static const earlyLactation = 'EARLY_LACTATION';
  static const midLactation = 'MID_LACTATION';
  static const lateLactation = 'LATE_LACTATION';
  static const heifer6Mo = 'HEIFER_6MO';
  static const heifer12Mo = 'HEIFER_12MO';
  static const heifer18Mo = 'HEIFER_18MO';
  static const heifer24MoCloseUp = 'HEIFER_24MO_CLOSE_UP';

  // Beef cattle
  static const midGestation = 'MID_GESTATION';
  static const lateGestation = 'LATE_GESTATION';
  static const growing = 'GROWING';
  static const bullMaintenance = 'BULL_MAINTENANCE';

  // Small ruminant (goat / sheep)
  static const maintenance = 'MAINTENANCE';
  static const lactating = 'LACTATING';
  static const pregnant = 'PREGNANT';
  static const fattening = 'FATTENING';

  /// App purposes with no dedicated masterfile row — use nearest profile + this label.
  static const weaning = 'WEANING';
  static const sick = 'SICK';
  static const breeding = 'BREEDING';
}
