import 'package:equatable/equatable.dart';
import 'breeding_methods.dart';
import 'enums.dart';

class Farm extends Equatable {
  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.currency,
    required this.housing,
    required this.ownerName,
  });

  final String id;
  final String name;
  final String location;
  final String currency;
  final HousingType housing;
  final String ownerName;

  @override
  List<Object?> get props => [id, name];
}

class FarmUser extends Equatable {
  const FarmUser({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
  });

  final String id;
  final String name;
  final UserRole role;
  final String initials;

  @override
  List<Object?> get props => [id];
}

class AnimalGroup extends Equatable {
  const AnimalGroup({
    required this.id,
    required this.name,
    required this.species,
    required this.purpose,
    required this.headCount,
    this.managerId,
    this.description,
  });

  final String id;
  final String name;
  final Species species;
  final GroupPurpose purpose;
  final int headCount;
  final String? managerId;
  final String? description;

  bool needsAttention(List<Animal> members) => members.any(
        (a) =>
            a.groupId == id &&
            (a.tags.contains(AnimalTagType.sick) ||
                a.tags.contains(AnimalTagType.cull) ||
                a.tags.contains(AnimalTagType.miscarriage)),
      );

  @override
  List<Object?> get props => [id];
}

class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.tag,
    required this.name,
    required this.species,
    required this.sex,
    required this.breed,
    required this.weightKg,
    required this.ageLabel,
    this.dob,
    required this.groupId,
    this.tags = const [],
    this.milkTodayLitres,
    this.withdrawalDays,
    this.sire,
    this.dam,
    this.bcs,
    this.isHeifer,
    this.isTwin,
    this.gestMonths,
    this.dueDate,
    this.prolificacy,
    this.status = AnimalStatus.active,
    this.weightIndicative = false,
    this.photoPath,
    this.productionPurpose = SpeciesPurpose.both,
    this.deathReason,
    this.cullType,
    this.cullReason,
    this.breedingMethod,
    this.illnessNote,
    this.treatmentNote,
  });

  final String id;
  final String tag;
  final String name;
  final Species species;
  final String sex;
  final String breed;
  final double weightKg;
  final String ageLabel;
  final DateTime? dob;
  final String groupId;
  final List<AnimalTagType> tags;
  final double? milkTodayLitres;
  final int? withdrawalDays;
  final String? sire;
  final String? dam;
  final double? bcs;
  final bool? isHeifer;
  final bool? isTwin;
  final int? gestMonths;
  final DateTime? dueDate;
  /// Expected litter size when pregnant (typically 2–4 for small ruminants).
  final int? prolificacy;
  final AnimalStatus status;
  final bool weightIndicative;
  final String? photoPath;
  final SpeciesPurpose productionPurpose;
  final String? deathReason;
  final String? cullType;
  final String? cullReason;
  final BreedingMethod? breedingMethod;
  final String? illnessNote;
  final String? treatmentNote;

  bool get cullFlagged => tags.contains(AnimalTagType.cull);

  bool get isSick => tags.contains(AnimalTagType.sick);

  /// Combined illness + medicine text for health tab display.
  String? get activeTreatmentSummary {
    if (!isSick) return null;
    final parts = <String>[];
    if (illnessNote != null && illnessNote!.trim().isNotEmpty) {
      parts.add(illnessNote!.trim());
    }
    if (treatmentNote != null && treatmentNote!.trim().isNotEmpty) {
      parts.add(treatmentNote!.trim());
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  /// Display label for cull/death reason when structured fields exist.
  String? get cullReasonLabel {
    if (cullType != null &&
        cullType!.isNotEmpty &&
        cullReason != null &&
        cullReason!.isNotEmpty) {
      return '$cullType · $cullReason';
    }
    return deathReason;
  }

  /// True when key data fields are missing — feeds the farmer maturity report.
  bool get hasIncompleteData => missingFields.isNotEmpty;

  List<String> get missingFields {
    final gaps = <String>[];
    if (tag.isEmpty || tag.startsWith('GRP-') || tag.startsWith('NEW-')) {
      gaps.add('tag');
    }
    if (dob == null) gaps.add('date of birth');
    if (breed.isEmpty || breed == '—') gaps.add('breed');
    if (weightKg <= 0) gaps.add('weight');
    return gaps;
  }

  Animal copyWith({
    List<AnimalTagType>? tags,
    AnimalStatus? status,
    String? groupId,
    double? milkTodayLitres,
    int? withdrawalDays,
    String? photoPath,
    double? weightKg,
    double? bcs,
    int? gestMonths,
    bool? isTwin,
    DateTime? dueDate,
    int? prolificacy,
    SpeciesPurpose? productionPurpose,
    String? deathReason,
    String? cullType,
    String? cullReason,
    BreedingMethod? breedingMethod,
    String? illnessNote,
    String? treatmentNote,
    String? tag,
    String? name,
    String? breed,
    String? sex,
    String? ageLabel,
    DateTime? dob,
    String? sire,
    String? dam,
    bool? weightIndicative,
    bool? isHeifer,
    bool clearCullReasonFields = false,
    bool clearBreedingMethod = false,
    bool clearDob = false,
    bool clearSire = false,
    bool clearDam = false,
    bool clearGestMonths = false,
    bool clearDueDate = false,
    bool clearProlificacy = false,
    bool clearIllnessNote = false,
    bool clearTreatmentNote = false,
  }) {
    return Animal(
      id: id,
      tag: tag ?? this.tag,
      name: name ?? this.name,
      species: species,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      weightKg: weightKg ?? this.weightKg,
      ageLabel: ageLabel ?? this.ageLabel,
      dob: clearDob ? null : (dob ?? this.dob),
      groupId: groupId ?? this.groupId,
      tags: tags ?? this.tags,
      milkTodayLitres: milkTodayLitres ?? this.milkTodayLitres,
      withdrawalDays: withdrawalDays ?? this.withdrawalDays,
      sire: clearSire ? null : (sire ?? this.sire),
      dam: clearDam ? null : (dam ?? this.dam),
      bcs: bcs ?? this.bcs,
      isHeifer: isHeifer ?? this.isHeifer,
      isTwin: isTwin ?? this.isTwin,
      gestMonths: clearGestMonths ? null : (gestMonths ?? this.gestMonths),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      prolificacy:
          clearProlificacy ? null : (prolificacy ?? this.prolificacy),
      status: status ?? this.status,
      weightIndicative: weightIndicative ?? this.weightIndicative,
      photoPath: photoPath ?? this.photoPath,
      productionPurpose: productionPurpose ?? this.productionPurpose,
      deathReason: clearCullReasonFields
          ? null
          : (deathReason ?? this.deathReason),
      cullType: clearCullReasonFields ? null : (cullType ?? this.cullType),
      cullReason:
          clearCullReasonFields ? null : (cullReason ?? this.cullReason),
      breedingMethod: clearBreedingMethod
          ? null
          : (breedingMethod ?? this.breedingMethod),
      illnessNote:
          clearIllnessNote ? null : (illnessNote ?? this.illnessNote),
      treatmentNote:
          clearTreatmentNote ? null : (treatmentNote ?? this.treatmentNote),
    );
  }

  @override
  List<Object?> get props => [
        id,
        tags,
        status,
        groupId,
        deathReason,
        cullType,
        cullReason,
        breedingMethod,
      ];
}

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.whenLabel,
    required this.dueBucket,
    this.overdue = false,
    required this.iconName,
    required this.tone,
    this.animalId,
    this.groupId,
    this.assigneeId,
    this.actionKind,
    this.feedProductName,
    this.feedPurchaseSource,
    this.feedCatalogProductNumber,
    this.feedMarketplaceProductId,
    this.feedSupplierName,
    this.feedDryMatterPercent,
    this.feedCrudeProteinPercent,
    this.feedNemMcalPerKg,
  });

  final String id;
  final String title;
  final String subtitle;
  final TaskType type;
  final String whenLabel;
  final String dueBucket;
  final bool overdue;
  final String iconName;
  final TaskTone tone;
  final String? animalId;
  final String? groupId;
  final String? assigneeId;
  /// e.g. `buy_feed` for inventory purchase tasks from nutrition gap flow.
  final String? actionKind;
  final String? feedProductName;
  /// `standard` or `marketplace`.
  final String? feedPurchaseSource;
  final int? feedCatalogProductNumber;
  final String? feedMarketplaceProductId;
  final String? feedSupplierName;
  final double? feedDryMatterPercent;
  final double? feedCrudeProteinPercent;
  final double? feedNemMcalPerKg;

  @override
  List<Object?> get props => [id];
}

class FinanceSummary extends Equatable {
  const FinanceSummary({
    required this.income3mo,
    required this.expense3mo,
    required this.net3mo,
    required this.livestockValue,
    required this.monthly,
    required this.recent,
  });

  final double income3mo;
  final double expense3mo;
  final double net3mo;
  final double livestockValue;
  final List<FinanceMonth> monthly;
  final List<FinanceEntry> recent;

  @override
  List<Object?> get props => [income3mo, expense3mo];
}

class FinanceMonth extends Equatable {
  const FinanceMonth({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;

  @override
  List<Object?> get props => [label];
}

class FinanceEntry extends Equatable {
  const FinanceEntry({
    required this.id,
    required this.dateLabel,
    required this.category,
    required this.type,
    required this.amount,
    required this.description,
  });

  final String id;
  final String dateLabel;
  final String category;
  final FinanceEntryType type;
  final double amount;
  final String description;

  @override
  List<Object?> get props => [id];
}

class ReportDefinition extends Equatable {
  const ReportDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.countLabel,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;
  final String countLabel;

  @override
  List<Object?> get props => [id];
}

class InventoryItem extends Equatable {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.isFeed,
    required this.quantity,
    required this.unit,
    this.lowStock = false,
    this.expiringSoon = false,
    this.subtitle,
  });

  final String id;
  final String name;
  final bool isFeed;
  final double quantity;
  final String unit;
  final bool lowStock;
  final bool expiringSoon;
  final String? subtitle;

  @override
  List<Object?> get props => [id];
}

class NutritionGap extends Equatable {
  const NutritionGap({
    required this.groupId,
    required this.dryMatterActualKg,
    required this.dryMatterTargetKg,
    required this.energyActualMj,
    required this.energyTargetMj,
    this.proteinActualKg,
    this.proteinTargetKg,
    this.ndfActualKg,
    this.ndfTargetKg,
    this.calciumActualKg,
    this.calciumTargetKg,
    this.phosphorusActualKg,
    this.phosphorusTargetKg,
    this.fixGapMessage,
    this.dailyCostPerHeadSar,
    this.dailyCostChangePct,
    this.optimizerPass,
    this.profileCode,
    this.planDryMatterKg,
    this.needsMarketSupplement = false,
  });

  final String groupId;
  final double dryMatterActualKg;
  final double dryMatterTargetKg;
  final double energyActualMj;
  final double energyTargetMj;
  final double? proteinActualKg;
  final double? proteinTargetKg;
  final double? ndfActualKg;
  final double? ndfTargetKg;
  final double? calciumActualKg;
  final double? calciumTargetKg;
  final double? phosphorusActualKg;
  final double? phosphorusTargetKg;
  final String? fixGapMessage;
  final double? dailyCostPerHeadSar;
  final double? dailyCostChangePct;
  final String? optimizerPass;
  final String? profileCode;
  final double? planDryMatterKg;
  final bool needsMarketSupplement;

  double _deviationPct(double actual, double target) {
    if (target == 0) return 0;
    return ((actual - target) / target) * 100;
  }

  double get energyDeviationPct => _deviationPct(energyActualMj, energyTargetMj);

  double get dryMatterDeviationPct =>
      _deviationPct(dryMatterActualKg, dryMatterTargetKg);

  double get proteinDeviationPct {
    if (proteinActualKg == null || proteinTargetKg == null) return 0;
    return _deviationPct(proteinActualKg!, proteinTargetKg!);
  }

  double get ndfDeviationPct {
    if (ndfActualKg == null || ndfTargetKg == null) return 0;
    return _deviationPct(ndfActualKg!, ndfTargetKg!);
  }

  String get gapBadgeLabel {
    if (energyDeviationPct.abs() <= 10 && dryMatterDeviationPct.abs() <= 10) {
      return 'On target';
    }
    if (energyDeviationPct < -10 &&
        energyDeviationPct.abs() >= dryMatterDeviationPct.abs()) {
      return 'Energy gap';
    }
    if (dryMatterDeviationPct < -10) return 'Dry matter gap';
    if (energyDeviationPct > 10) return 'Energy surplus';
    return 'Review nutrition';
  }

  bool get hasGap => gapBadgeLabel != 'On target';

  /// Actual intake unknown until today's feed is logged on the nutrition tab.
  NutritionGap withNoLoggedFeedToday() {
    return NutritionGap(
      groupId: groupId,
      dryMatterActualKg: 0,
      dryMatterTargetKg: dryMatterTargetKg,
      energyActualMj: 0,
      energyTargetMj: energyTargetMj,
      proteinActualKg: proteinActualKg != null ? 0 : null,
      proteinTargetKg: proteinTargetKg,
      ndfActualKg: ndfActualKg != null ? 0 : null,
      ndfTargetKg: ndfTargetKg,
      calciumActualKg: calciumTargetKg != null ? 0 : calciumActualKg,
      calciumTargetKg: calciumTargetKg,
      phosphorusActualKg: phosphorusTargetKg != null ? 0 : phosphorusActualKg,
      phosphorusTargetKg: phosphorusTargetKg,
      fixGapMessage: fixGapMessage,
      dailyCostPerHeadSar: dailyCostPerHeadSar,
      dailyCostChangePct: dailyCostChangePct,
      optimizerPass: optimizerPass,
      profileCode: profileCode,
      planDryMatterKg: planDryMatterKg,
      needsMarketSupplement: needsMarketSupplement,
    );
  }

  @override
  List<Object?> get props => [groupId];
}

class FeedRecommendation extends Equatable {
  const FeedRecommendation({
    required this.id,
    required this.name,
    required this.supplier,
    required this.costPerDay,
    this.isTopPick = false,
    this.added = false,
    this.kgPerDay = 0,
    this.feedType,
  });

  final String id;
  final String name;
  final String supplier;
  final double costPerDay;
  final bool isTopPick;
  final bool added;
  final double kgPerDay;
  final String? feedType;

  FeedRecommendation copyWith({bool? added, double? kgPerDay}) {
    return FeedRecommendation(
      id: id,
      name: name,
      supplier: supplier,
      costPerDay: costPerDay,
      isTopPick: isTopPick,
      added: added ?? this.added,
      kgPerDay: kgPerDay ?? this.kgPerDay,
      feedType: feedType,
    );
  }

  @override
  List<Object?> get props => [id, added, kgPerDay];
}

class PurchaseRecord extends Equatable {
  const PurchaseRecord({
    required this.id,
    required this.purchaseDate,
    required this.totalAmount,
    required this.animalIds,
    this.supplierName,
    this.totalWeightKg,
    this.species,
    this.sex,
    this.breed,
    this.ageRangeLabel,
    this.notes,
  });

  final String id;
  final DateTime purchaseDate;
  final double totalAmount;
  final List<String> animalIds;
  final String? supplierName;
  final double? totalWeightKg;
  final Species? species;
  final String? sex;
  final String? breed;
  final String? ageRangeLabel;
  final String? notes;

  @override
  List<Object?> get props => [id];
}

class SaleRecord extends Equatable {
  const SaleRecord({
    required this.id,
    required this.saleDate,
    required this.totalAmount,
    required this.animalIds,
    this.buyerName,
    this.totalWeightKg,
    this.salePurpose,
    this.notes,
  });

  final String id;
  final DateTime saleDate;
  final double totalAmount;
  final List<String> animalIds;
  final String? buyerName;
  final double? totalWeightKg;
  final String? salePurpose;
  final String? notes;

  @override
  List<Object?> get props => [id];
}

class VaccinationEvent extends Equatable {
  const VaccinationEvent({
    required this.id,
    required this.name,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? notes;

  bool get isActive =>
      DateTime.now().difference(createdAt).inHours < 48;

  @override
  List<Object?> get props => [id];
}

class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.farmId,
    required this.role,
    required this.displayName,
    required this.accessToken,
  });

  final String userId;
  final String farmId;
  final UserRole role;
  final String displayName;
  final String accessToken;

  @override
  List<Object?> get props => [userId, farmId];
}

class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.tier,
    required this.label,
    required this.trialDaysLeft,
    required this.isActive,
  });

  final String tier;
  final String label;
  final int trialDaysLeft;
  final bool isActive;

  @override
  List<Object?> get props => [tier];
}

class MarketplaceProduct extends Equatable {
  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.supplier,
    required this.pricePerKg,
  });

  final String id;
  final String name;
  final String supplier;
  final double pricePerKg;

  @override
  List<Object?> get props => [id];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalAnimals,
    required this.bySpecies,
    required this.pregnant,
    required this.readyToBreed,
    required this.sick,
    required this.cullFlagged,
    required this.lactating,
    required this.tasksOverdue,
    required this.tasksToday,
    required this.tasksThisWeek,
  });

  final int totalAnimals;
  final Map<Species?, int> bySpecies;
  final int pregnant;
  final int readyToBreed;
  final int sick;
  final int cullFlagged;
  final int lactating;
  final int tasksOverdue;
  final int tasksToday;
  final int tasksThisWeek;

  @override
  List<Object?> get props => [totalAnimals];
}
