import '../models/enums.dart';
import '../models/models.dart';

/// Maps `gh-api-animals` wire records to UI [Animal] / [AnimalGroup].
abstract final class AnimalMapper {
  static Animal fromWire(Map<String, dynamic> wire) {
    final species = SpeciesX.fromString(
      (wire['species'] as String? ?? 'CATTLE').toLowerCase(),
    );
    final sexWire = (wire['sex'] as String? ?? 'FEMALE').toUpperCase();
    final tags = <AnimalTagType>[];
    for (final t in wire['tags'] as List? ?? []) {
      final parsed = AnimalTagTypeX.fromWire(t.toString());
      if (parsed != null) tags.add(parsed);
    }
    if (wire['cull_flagged'] == true && !tags.contains(AnimalTagType.cull)) {
      tags.add(AnimalTagType.cull);
    }

    final statusWire = (wire['status'] as String? ?? 'ACTIVE').toUpperCase();
    final status = switch (statusWire) {
      'SOLD' => AnimalStatus.sold,
      'DECEASED' => AnimalStatus.deceased,
      'CULLED' => AnimalStatus.culled,
      _ => AnimalStatus.active,
    };

    final focusWire =
        (wire['production_focus'] as String? ?? 'BOTH').toUpperCase();
    final productionPurpose = switch (focusWire) {
      'MILK' => SpeciesPurpose.milk,
      'MEAT' => SpeciesPurpose.meat,
      _ => SpeciesPurpose.both,
    };

    return Animal(
      id: wire['id'] as String,
      tag: wire['ear_tag'] as String? ?? '',
      name: wire['name'] as String? ?? '',
      species: species,
      sex: sexWire == 'MALE' ? 'Male' : 'Female',
      breed: wire['breed'] as String? ??
          (wire['breed_ref'] is Map
              ? (wire['breed_ref']['name_en'] as String? ?? '')
              : ''),
      weightKg: (wire['current_weight_kg'] as num?)?.toDouble() ?? 0,
      ageLabel: ageLabelFromRange(wire['age_range'] as String?),
      dob: wire['dob'] == null
          ? null
          : DateTime.tryParse(wire['dob'] as String),
      groupId: wire['group_id'] as String? ?? '',
      tags: tags,
      status: status,
      weightIndicative: wire['weight_indicative'] == true,
      productionPurpose: productionPurpose,
      monthsSinceCalving: (wire['months_since_calving'] as num?)?.toInt(),
    );
  }

  static AnimalGroup groupFromWire(
    Map<String, dynamic> wire, {
    int headCount = 0,
  }) {
    final purposeWire = (wire['purpose'] as String? ?? 'MAINTENANCE').toUpperCase();
    final purpose = switch (purposeWire) {
      'MILK' => GroupPurpose.milk,
      'BREEDING' => GroupPurpose.breeding,
      'PREGNANT' => GroupPurpose.pregnant,
      'FATTENING' => GroupPurpose.fattening,
      'SICK' => GroupPurpose.sick,
      _ => GroupPurpose.maintenance,
    };

    return AnimalGroup(
      id: wire['id'] as String,
      name: wire['name'] as String? ?? 'Group',
      species: SpeciesX.fromString(
        (wire['species'] as String? ?? 'CATTLE').toLowerCase(),
      ),
      purpose: purpose,
      headCount: headCount,
      description: wire['notes'] as String?,
    );
  }

  static String ageLabelFromRange(String? range) {
    return switch (range) {
      '0_3M' => '0-3m',
      '3_6M' || '4_6M' => '4-6m',
      '6_12M' || '7_11M' => '7-11m',
      '1_2Y' => '1-2yr',
      '2_3Y' => '2-3yr',
      '3_5Y' => '3-5yr',
      '5PLUS_Y' => '5+yr',
      _ => '—',
    };
  }

  static Map<String, dynamic> toCreateBody(Animal animal, {bool purchased = false}) {
    return {
      'species': speciesWire(animal.species),
      'sex': animal.sex.toLowerCase() == 'male' ? 'MALE' : 'FEMALE',
      'breed': animal.breed,
      'ear_tag': animal.tag,
      'name': animal.name,
      if (animal.groupId.isNotEmpty) 'group_id': animal.groupId,
      'current_weight_kg': animal.weightKg,
      'tags': animal.tags.map(tagToWire).toList(),
      'production_focus': productionPurposeWire(animal.productionPurpose),
      if (purchased) 'origin': 'PURCHASED',
    };
  }

  static String productionPurposeWire(SpeciesPurpose purpose) =>
      switch (purpose) {
        SpeciesPurpose.milk => 'MILK',
        SpeciesPurpose.meat => 'MEAT',
        SpeciesPurpose.both => 'BOTH',
      };

  static String speciesWire(Species species) => switch (species) {
        Species.cattle => 'CATTLE',
        Species.goat => 'GOAT',
        Species.sheep => 'SHEEP',
      };

  static String groupPurposeWire(GroupPurpose purpose) => switch (purpose) {
        GroupPurpose.milk => 'MILK',
        GroupPurpose.breeding => 'BREEDING',
        GroupPurpose.pregnant => 'PREGNANT',
        GroupPurpose.fattening => 'FATTENING',
        GroupPurpose.sick => 'SICK',
        _ => 'MAINTENANCE',
      };

  static String ageRangeWireFromLabel(String label) => switch (label) {
        '0-3m' => '0_3M',
        '4-6m' => '4_6M',
        '7-11m' => '7_11M',
        '1-2yr' => '1_2Y',
        '2-3yr' => '2_3Y',
        '3-5yr' => '3_5Y',
        '5+yr' => '5PLUS_Y',
        _ => '1_2Y',
      };

  /// Estimates a date of birth from an age-range label by subtracting the
  /// midpoint of the range from today. Farmers can refine the DoB later.
  /// Handles both range labels ('1-2yr') and verbose labels ('4y 2m', '8m').
  static DateTime dobFromAgeLabel(String label, [DateTime? relativeTo]) {
    final now = relativeTo ?? DateTime.now();
    final parsed = _parseVerboseAgeDays(label);
    final days = parsed ?? _ageMidpointDays(label);
    return now.subtract(Duration(days: days));
  }

  /// Tries to parse verbose age strings like '4y 2m', '3y', '8m'.
  static int? _parseVerboseAgeDays(String label) {
    final re = RegExp(r'(\d+)\s*y(?:\s*(\d+)\s*m)?');
    final match = re.firstMatch(label);
    if (match != null) {
      final years = int.parse(match.group(1)!);
      final months = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      return years * 365 + months * 30;
    }
    final mOnly = RegExp(r'^(\d+)\s*m$').firstMatch(label);
    if (mOnly != null) {
      return int.parse(mOnly.group(1)!) * 30;
    }
    return null;
  }

  /// Midpoint in months for each age range label.
  static int ageMidpointMonths(String label) {
    final key = _normalizeAgeLabel(label);
    return switch (key) {
      '0-3m' => 1,
      '4-6m' => 5,
      '7-11m' => 9,
      '1-2yr' => 18,
      '2-3yr' => 30,
      '3-5yr' => 48,
      '5+yr' => 72,
      _ => 18,
    };
  }

  /// Dashboard buckets: 0–6m, 6–12m, 1–2y, 2–5y, 5y+.
  static int? dashboardAgeBucketIndex(String? ageLabel) {
    if (ageLabel == null || ageLabel.trim().isEmpty || ageLabel == '—') {
      return null;
    }
    final key = _normalizeAgeLabel(ageLabel);
    return switch (key) {
      '0-3m' || '4-6m' => 0,
      '7-11m' => 1,
      '1-2yr' => 2,
      '2-3yr' || '3-5yr' => 3,
      '5+yr' => 4,
      _ => null,
    };
  }

  /// Age in months for charts — prefers range label, then DoB, then verbose age text.
  static int ageMonthsForAnimal(Animal animal) {
    final fromLabel = dashboardAgeBucketIndex(animal.ageLabel);
    if (fromLabel != null) {
      return switch (fromLabel) {
        0 => 3,
        1 => 9,
        2 => 18,
        3 => 36,
        4 => 72,
        _ => 18,
      };
    }
    if (animal.dob != null) {
      final days = DateTime.now().difference(animal.dob!).inDays;
      return (days / 30.44).round().clamp(0, 240);
    }
    final verboseDays = _parseVerboseAgeDays(animal.ageLabel);
    if (verboseDays != null) {
      return (verboseDays / 30.44).round().clamp(0, 240);
    }
    return ageMidpointMonths(animal.ageLabel);
  }

  static String _normalizeAgeLabel(String label) =>
      label.toLowerCase().replaceAll(' ', '').replaceAll('–', '-');

  /// Midpoint in days for each age range label.
  static int _ageMidpointDays(String label) {
    final key = _normalizeAgeLabel(label);
    return switch (key) {
      '0-3m' => 42,
      '4-6m' => 150,
      '7-11m' => 270,
      '1-2yr' => 548,
      '2-3yr' => 913,
      '3-5yr' => 1461,
      '5+yr' => 2190,
      _ => 548,
    };
  }

  static String tagToWire(AnimalTagType tag) {
    return switch (tag) {
      AnimalTagType.readyToBreed => 'READY_TO_BREED',
      AnimalTagType.pregnant => 'PREGNANT',
      AnimalTagType.lactating => 'LACTATING',
      AnimalTagType.weaning => 'WEANING',
      AnimalTagType.cull => 'CULL',
      AnimalTagType.miscarriage => 'MISCARRIAGE',
      AnimalTagType.stillborn => 'STILLBORN',
      AnimalTagType.sick => 'SICK',
      _ => tag.name.toUpperCase(),
    };
  }
}
