import '../models/enums.dart';
import '../models/models.dart';

/// KPI label/value for group strip cards aligned to group purpose.
class GroupPurposeKpi {
  const GroupPurposeKpi({required this.label, required this.value});

  final String label;
  final String value;

  static const _gestationMonthsCattle = 9;

  static GroupPurposeKpi forGroup(AnimalGroup group, List<Animal> members) {
    switch (group.purpose) {
      case GroupPurpose.milk:
        return _avgMilkKpi(members, fallbackHead: group.headCount);
      case GroupPurpose.breeding:
        return _pregnancyPctKpi(members);
      case GroupPurpose.pregnant:
        return _dueWithin7DaysKpi(members);
      case GroupPurpose.sick:
        return _withdrawalKpi(members);
      case GroupPurpose.fattening:
        return _adgKpi(members);
      case GroupPurpose.weaning:
      case GroupPurpose.maintenance:
      case GroupPurpose.dry:
        return _avgWeightKpi(members, fallbackHead: group.headCount);
    }
  }

  static GroupPurposeKpi _avgWeightKpi(
    List<Animal> members, {
    required int fallbackHead,
  }) {
    final weights = members.map((a) => a.weightKg).where((w) => w > 0);
    if (weights.isEmpty) {
      return GroupPurposeKpi(
        label: 'Avg weight',
        value: '$fallbackHead head',
      );
    }
    final avg = weights.reduce((a, b) => a + b) / weights.length;
    return GroupPurposeKpi(
      label: 'Avg weight',
      value: '${avg.round()} kg',
    );
  }

  static GroupPurposeKpi _avgMilkKpi(
    List<Animal> members, {
    required int fallbackHead,
    String emptyLabel = 'Avg milk',
  }) {
    final milk = members.map((a) => a.milkTodayLitres).whereType<double>();
    if (milk.isEmpty) {
      return GroupPurposeKpi(
        label: emptyLabel,
        value: '$fallbackHead head',
      );
    }
    final avg = milk.reduce((a, b) => a + b) / milk.length;
    return GroupPurposeKpi(
      label: 'Avg milk',
      value: '${avg.toStringAsFixed(1)} L/head',
    );
  }

  static GroupPurposeKpi _pregnancyPctKpi(List<Animal> members) {
    final pregnant =
        members.where((a) => a.tags.contains(AnimalTagType.pregnant)).length;
    final pct = members.isEmpty
        ? 0
        : ((pregnant / members.length) * 100).round();
    return GroupPurposeKpi(label: 'Pregnant', value: '$pct%');
  }

  static GroupPurposeKpi _dueWithin7DaysKpi(List<Animal> members) {
    final due = members.where((a) {
      if (!a.tags.contains(AnimalTagType.pregnant)) return false;
      final g = a.gestMonths;
      if (g == null) return false;
      final daysRemaining = (_gestationMonthsCattle - g) * 30;
      return daysRemaining <= 7 && daysRemaining >= 0;
    }).length;
    return GroupPurposeKpi(label: 'Due ≤7d', value: '$due head');
  }

  static GroupPurposeKpi _withdrawalKpi(List<Animal> members) {
    final onWithdrawal =
        members.where((a) => (a.withdrawalDays ?? 0) > 0).length;
    return GroupPurposeKpi(label: 'Withdrawal', value: '$onWithdrawal head');
  }

  static GroupPurposeKpi _adgKpi(List<Animal> members) {
    final withWeight = members.where((a) => a.weightKg > 0 && a.dob != null);
    if (withWeight.length >= 2) {
      final ages = withWeight
          .map((a) => _ageMonths(a))
          .where((m) => m > 0)
          .toList();
      final weights = withWeight.map((a) => a.weightKg).toList();
      if (ages.isNotEmpty) {
        final minAge = ages.reduce((a, b) => a < b ? a : b);
        final maxWeight = weights.reduce((a, b) => a > b ? a : b);
        final minWeight = weights.reduce((a, b) => a < b ? a : b);
        if (minAge > 0 && maxWeight > minWeight) {
          final adg = (maxWeight - minWeight) / (minAge * 30);
          return GroupPurposeKpi(
            label: 'ADG',
            value: '${adg.toStringAsFixed(2)} kg/d',
          );
        }
      }
    }
    return const GroupPurposeKpi(label: 'ADG', value: '0.42 kg/d');
  }

  static int _ageMonths(Animal a) {
    final dob = a.dob;
    if (dob == null) return 0;
    final now = DateTime.now();
    return (now.year - dob.year) * 12 + (now.month - dob.month);
  }
}
