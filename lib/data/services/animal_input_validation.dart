import '../models/enums.dart';

/// Single validation failure with a stable [code] for tests and i18n keys later.
class AnimalValidationIssue {
  const AnimalValidationIssue({required this.code, required this.message});

  final AnimalValidationCode code;
  final String message;

  @override
  String toString() => message;
}

enum AnimalValidationCode {
  tagEmpty,
  tagDuplicate,
  weightMissing,
  weightNonPositive,
  weightExceedsSpeciesMax,
  weightNotANumber,
  dobInFuture,
  dobTooOld,
  bcsBelowMin,
  bcsAboveMax,
  bcsNotHalfStep,
  groupNameEmpty,
}

/// Client-side input rules for animals and groups (mirrors future API validation).
class AnimalInputValidation {
  const AnimalInputValidation({DateTime? referenceNow})
      : _referenceNow = referenceNow;

  final DateTime? _referenceNow;

  DateTime get _now {
    final ref = _referenceNow ?? DateTime.now();
    return DateTime(ref.year, ref.month, ref.day);
  }

  static const maxWeightKg = {
    Species.cattle: 1500.0,
    Species.goat: 180.0,
    Species.sheep: 180.0,
  };

  static const maxAgeYears = {
    Species.cattle: 30,
    Species.goat: 18,
    Species.sheep: 18,
  };

  /// Validates all fields for creating a new animal.
  List<AnimalValidationIssue> validateNewAnimal({
    required String tag,
    required String weightText,
    required DateTime? dob,
    required Species species,
    required Iterable<String> existingTags,
    double? bcs,
  }) {
    final issues = <AnimalValidationIssue>[
      ...validateTag(tag, existingTags: existingTags),
      ...validateWeightText(weightText, species: species),
      ...validateDateOfBirth(dob, species: species),
      ...validateBcs(bcs),
    ];
    return issues;
  }

  List<AnimalValidationIssue> validateTag(
    String tag, {
    Iterable<String> existingTags = const [],
  }) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.tagEmpty,
          message: 'Tag number is required',
        ),
      ];
    }
    final normalized = trimmed.toUpperCase();
    final duplicate = existingTags
        .map((t) => t.trim().toUpperCase())
        .any((t) => t == normalized);
    if (duplicate) {
      return [
        AnimalValidationIssue(
          code: AnimalValidationCode.tagDuplicate,
          message: 'Tag #$trimmed is already in use',
        ),
      ];
    }
    return const [];
  }

  List<AnimalValidationIssue> validateWeightText(
    String weightText, {
    required Species species,
  }) {
    final trimmed = weightText.trim();
    if (trimmed.isEmpty) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.weightMissing,
          message: 'Weight is required',
        ),
      ];
    }
    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.weightNotANumber,
          message: 'Enter a valid weight in kg',
        ),
      ];
    }
    return validateWeightKg(parsed, species: species);
  }

  List<AnimalValidationIssue> validateWeightKg(
    double weightKg, {
    required Species species,
  }) {
    if (weightKg <= 0) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.weightNonPositive,
          message: 'Weight must be greater than zero',
        ),
      ];
    }
    final max = maxWeightKg[species]!;
    if (weightKg > max) {
      return [
        AnimalValidationIssue(
          code: AnimalValidationCode.weightExceedsSpeciesMax,
          message:
              'Weight exceeds the maximum for ${species.name} (${max.toInt()} kg)',
        ),
      ];
    }
    return const [];
  }

  List<AnimalValidationIssue> validateDateOfBirth(
    DateTime? dob, {
    required Species species,
  }) {
    if (dob == null) return const [];
    final date = DateTime(dob.year, dob.month, dob.day);
    if (date.isAfter(_now)) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.dobInFuture,
          message: 'Birth date cannot be in the future',
        ),
      ];
    }
    final maxYears = maxAgeYears[species]!;
    final oldest = DateTime(_now.year - maxYears, _now.month, _now.day);
    if (date.isBefore(oldest)) {
      return [
        AnimalValidationIssue(
          code: AnimalValidationCode.dobTooOld,
          message:
              'Birth date is too far in the past for ${species.name} (max $maxYears years)',
        ),
      ];
    }
    return const [];
  }

  List<AnimalValidationIssue> validateBcs(double? bcs) {
    if (bcs == null) return const [];
    if (bcs < 1 || bcs > 5) {
      return [
        AnimalValidationIssue(
          code: bcs < 1
              ? AnimalValidationCode.bcsBelowMin
              : AnimalValidationCode.bcsAboveMax,
          message: 'Body condition score must be between 1 and 5',
        ),
      ];
    }
    final doubled = (bcs * 2).round();
    if ((doubled / 2 - bcs).abs() > 0.001) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.bcsNotHalfStep,
          message: 'Use half-point steps (e.g. 3.0 or 3.5)',
        ),
      ];
    }
    return const [];
  }

  List<AnimalValidationIssue> validateGroupName(String name) {
    if (normalizeGroupName(name).isEmpty) {
      return [
        const AnimalValidationIssue(
          code: AnimalValidationCode.groupNameEmpty,
          message: 'Group name is required',
        ),
      ];
    }
    return const [];
  }

  String? firstMessage(Iterable<AnimalValidationIssue> issues) {
    final list = issues.toList();
    return list.isEmpty ? null : list.first.message;
  }
}

/// Trims whitespace and capitalizes the first letter for herd/group names.
String normalizeGroupName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}
