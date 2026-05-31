import '../models/breeding_methods.dart';
import '../models/cull_reasons.dart';
import '../models/enums.dart';
import '../models/models.dart';
import 'gestation_dates.dart';
import 'reproduction_status_rules.dart';

/// Client-side lifecycle rules mirroring future server validation.
class AnimalLifecycleService {
  const AnimalLifecycleService();

  static const gestationDays = {
    Species.cattle: 283,
    Species.goat: 150,
    Species.sheep: 147,
  };

  Animal flagForCull(
    Animal animal, {
    required CullReasonSelection selection,
  }) {
    if (animal.status != AnimalStatus.active) {
      throw StateError('Cannot cull non-active animal');
    }
    final tags = {...animal.tags}..add(AnimalTagType.cull);
    return animal.copyWith(
      tags: tags.toList(),
      cullType: selection.type,
      cullReason: selection.reason,
    );
  }

  Animal clearCullFlag(Animal animal) {
    final tags = animal.tags.where((t) => t != AnimalTagType.cull).toList();
    return animal.copyWith(
      tags: tags,
      clearCullReasonFields: true,
    );
  }

  Animal markSold(Animal animal) {
    if (animal.status == AnimalStatus.sold) {
      throw StateError('Animal already sold');
    }
    if (animal.status != AnimalStatus.active) {
      throw StateError('Cannot sell non-active animal');
    }
    final tags = animal.tags
        .where((t) => t != AnimalTagType.cull)
        .toList();
    if (!tags.contains(AnimalTagType.sold)) {
      tags.add(AnimalTagType.sold);
    }
    return animal.copyWith(
      tags: tags,
      status: AnimalStatus.sold,
      groupId: '',
    );
  }

  Animal undoSale(Animal animal) {
    if (animal.status != AnimalStatus.sold) {
      throw StateError('Animal is not sold');
    }
    final tags = animal.tags.where((t) => t != AnimalTagType.sold).toList();
    return animal.copyWith(tags: tags, status: AnimalStatus.active);
  }

  /// Females, or male sheep/goats (rams, bucks) at breeding age.
  bool canHaveReadyToBreedTag(Animal animal) =>
      ReproductionStatusRules.canMarkReadyToBreedForAnimal(animal);

  Animal markReadyToBreed(
    Animal animal, {
    BreedingMethod? method,
  }) {
    if (!canHaveReadyToBreedTag(animal)) {
      throw StateError('This animal cannot be marked ready to breed');
    }
    if (animal.tags.contains(AnimalTagType.pregnant)) {
      throw StateError('Cannot mark pregnant animal ready to breed');
    }
    if (BreedingMethodCatalog.requiresMethodOnReadyToBreed(animal.species) &&
        method == null) {
      throw StateError('Fertility method required for goats and sheep');
    }
    final tags = {...animal.tags}..add(AnimalTagType.readyToBreed);
    return animal.copyWith(tags: tags.toList(), breedingMethod: method);
  }

  /// When a group is created with breeding purpose, eligible animals are ready to breed.
  Animal applyBreedingGroupPurpose(Animal animal, GroupPurpose purpose) {
    if (purpose != GroupPurpose.breeding) return animal;
    if (animal.tags.contains(AnimalTagType.pregnant)) return animal;
    if (animal.tags.contains(AnimalTagType.readyToBreed)) return animal;
    if (!canHaveReadyToBreedTag(animal)) return animal;
    final method = BreedingMethodCatalog.requiresMethodOnReadyToBreed(
      animal.species,
    )
        ? BreedingMethod.natural
        : null;
    return markReadyToBreed(animal, method: method);
  }

  Animal clearReadyToBreed(Animal animal) {
    final tags =
        animal.tags.where((t) => t != AnimalTagType.readyToBreed).toList();
    return animal.copyWith(tags: tags, clearBreedingMethod: true);
  }

  Animal markPregnant(
    Animal animal, {
    int? gestMonths,
    DateTime? dueDate,
    int prolificacy = 2,
    BreedingMethod? method,
  }) {
    if (gestMonths == null && dueDate == null) {
      throw ArgumentError('Either gestMonths or dueDate is required');
    }
    final now = DateTime.now();
    final resolvedDueDate = dueDate ??
        GestationDates.dueDateFromGestMonths(animal.species, gestMonths!, now);
    final resolvedGestMonths = gestMonths ??
        GestationDates.gestMonthsFromDueDate(
          animal.species,
          resolvedDueDate,
          now,
        );
    final tags = animal.tags
        .where((t) => t != AnimalTagType.readyToBreed)
        .toList()
      ..add(AnimalTagType.pregnant);
    return animal.copyWith(
      tags: tags,
      gestMonths: resolvedGestMonths,
      dueDate: resolvedDueDate,
      prolificacy: prolificacy,
      isTwin: prolificacy >= 2,
      breedingMethod: method ?? animal.breedingMethod,
    );
  }

  Animal recordCalvingOutcome(Animal animal, CalvingOutcome outcome) {
    var tags = animal.tags
        .where((t) => t != AnimalTagType.pregnant)
        .toList();
    switch (outcome) {
      case CalvingOutcome.bornLive:
        if (!tags.contains(AnimalTagType.lactating)) {
          tags = [...tags, AnimalTagType.lactating];
        }
        return animal.copyWith(
          tags: _uniqueTags(tags),
          monthsSinceCalving: 0,
          isHeifer: false,
          clearGestMonths: true,
          clearDueDate: true,
        );
      case CalvingOutcome.stillborn:
        if (!tags.contains(AnimalTagType.stillborn)) {
          tags = [...tags, AnimalTagType.stillborn];
        }
      case CalvingOutcome.miscarriage:
        if (!tags.contains(AnimalTagType.miscarriage)) {
          tags = [...tags, AnimalTagType.miscarriage];
        }
    }
    return animal.copyWith(
      tags: _uniqueTags(tags),
      clearGestMonths: true,
      clearDueDate: true,
    );
  }

  List<AnimalTagType> _uniqueTags(List<AnimalTagType> tags) {
    final seen = <AnimalTagType>{};
    return [for (final t in tags) if (seen.add(t)) t];
  }

  Animal recordTreatment(
    Animal animal, {
    required String illnessNote,
    String? treatmentNote,
  }) {
    final tags = {...animal.tags}..add(AnimalTagType.sick);
    final illness = illnessNote.trim().isEmpty ? 'Under treatment' : illnessNote.trim();
    final medicine = treatmentNote?.trim();
    return animal.copyWith(
      tags: tags.toList(),
      illnessNote: illness,
      treatmentNote: medicine == null || medicine.isEmpty ? null : medicine,
      clearTreatmentNote: medicine == null || medicine.isEmpty,
    );
  }

  Animal markCured(Animal animal) {
    final tags = animal.tags.where((t) => t != AnimalTagType.sick).toList();
    return animal.copyWith(
      tags: tags,
      clearIllnessNote: true,
      clearTreatmentNote: true,
    );
  }

  /// Records death, clears group membership, and stores cull type/reason.
  Animal markDeceased(
    Animal animal, {
    required CullReasonSelection selection,
  }) {
    if (animal.status != AnimalStatus.active) {
      throw StateError('Cannot record death for non-active animal');
    }
    final tags = animal.tags
        .where(
          (t) =>
              t != AnimalTagType.sick &&
              t != AnimalTagType.cull &&
              t != AnimalTagType.readyToBreed &&
              t != AnimalTagType.pregnant,
        )
        .toList();
    return animal.copyWith(
      status: AnimalStatus.deceased,
      groupId: '',
      tags: tags,
      cullType: selection.type,
      cullReason: selection.reason,
      deathReason: selection.label,
      milkTodayLitres: 0,
      withdrawalDays: 0,
    );
  }

  bool canRecordMilk(Animal animal) =>
      animal.tags.contains(AnimalTagType.lactating) ||
      (animal.milkTodayLitres != null && animal.milkTodayLitres! > 0);

  bool milkBlockedByWithdrawal(Animal animal) =>
      (animal.withdrawalDays ?? 0) > 0;

  Animal recordMilk(Animal animal, double litresToday) {
    if (litresToday < 0) {
      throw StateError('Milk volume cannot be negative');
    }
    if (milkBlockedByWithdrawal(animal)) {
      throw StateError('Milk recording blocked during withdrawal period');
    }
    var tags = animal.tags.toList();
    if (litresToday > 0 && !tags.contains(AnimalTagType.lactating)) {
      tags = [...tags, AnimalTagType.lactating];
    }
    return animal.copyWith(
      tags: tags,
      milkTodayLitres: litresToday,
    );
  }
}
