import '../models/animal_lactation_cycle.dart';
import '../models/enums.dart';
import '../models/models.dart';

/// Applies milking-tab lactation cycle selection to an animal record.
class LactationCycleService {
  const LactationCycleService();

  Animal applyCycle(Animal animal, AnimalLactationCycle cycle) {
    var tags = animal.tags.where((t) => t != AnimalTagType.lactating).toList();

    if (LactationCycleCatalog.isLactating(cycle)) {
      tags = [...tags, AnimalTagType.lactating];
    }

    final isTwin = switch (cycle) {
      AnimalLactationCycle.lactatingTwin => true,
      AnimalLactationCycle.lactatingSingle => false,
      _ => animal.isTwin,
    };

    final months = LactationCycleCatalog.monthsSinceCalvingFor(cycle) ??
        (LactationCycleCatalog.isLactating(cycle)
            ? animal.monthsSinceCalving ?? 1
            : null);

    return animal.copyWith(
      tags: tags,
      lactationCycle: cycle,
      isTwin: isTwin,
      monthsSinceCalving: months,
      clearMonthsSinceCalving:
          !LactationCycleCatalog.isLactating(cycle) && months == null,
    );
  }

  AnimalLactationCycle? effectiveCycle(Animal animal) {
    if (animal.lactationCycle != null) return animal.lactationCycle;
    return LactationCycleCatalog.inferFromAnimal(
      species: animal.species,
      tags: animal.tags,
      isTwin: animal.isTwin,
      monthsSinceCalving: animal.monthsSinceCalving,
    );
  }
}
