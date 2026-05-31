import '../../data/models/enums.dart';
import '../../data/models/models.dart';

class GroupKpis {
  const GroupKpis({
    required this.headCount,
    required this.maleCount,
    required this.femaleCount,
    required this.pregnant,
    required this.sick,
    required this.lactating,
    required this.avgMilkLitres,
    required this.todayTotalMilkLitres,
    required this.onWithdrawal,
    required this.avgWeightKg,
    required this.needsAttention,
  });

  final int headCount;
  final int maleCount;
  final int femaleCount;
  final int pregnant;
  final int sick;
  final int lactating;
  final double? avgMilkLitres;
  final double? todayTotalMilkLitres;
  final int onWithdrawal;
  final double avgWeightKg;
  final bool needsAttention;

  factory GroupKpis.from(AnimalGroup group, List<Animal> members) {
    final males = members.where((a) => a.sex.toUpperCase() == 'M').length;
    final milk = members
        .map((a) => a.milkTodayLitres)
        .whereType<double>()
        .toList();
    final weights = members.map((a) => a.weightKg).toList();

    return GroupKpis(
      headCount: members.length,
      maleCount: males,
      femaleCount: members.length - males,
      pregnant: members
          .where((a) => a.tags.contains(AnimalTagType.pregnant))
          .length,
      sick: members.where((a) => a.tags.contains(AnimalTagType.sick)).length,
      lactating: members
          .where((a) => a.tags.contains(AnimalTagType.lactating))
          .length,
      avgMilkLitres:
          milk.isEmpty ? null : milk.reduce((a, b) => a + b) / milk.length,
      todayTotalMilkLitres:
          milk.isEmpty ? null : milk.reduce((a, b) => a + b),
      onWithdrawal: members.where((a) => (a.withdrawalDays ?? 0) > 0).length,
      avgWeightKg: weights.isEmpty
          ? 0
          : weights.reduce((a, b) => a + b) / weights.length,
      needsAttention: group.needsAttention(members),
    );
  }
}
