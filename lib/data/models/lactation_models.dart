import 'package:equatable/equatable.dart';

/// Stage within a dairy lactation (days in milk).
enum LactationStage {
  fresh, // 0–30 DIM
  peak, // 31–90
  mid, // 91–200
  late, // 201–305
  dry,
}

class LactationCycle extends Equatable {
  const LactationCycle({
    required this.id,
    required this.animalId,
    required this.cycleNumber,
    required this.calvingDate,
    this.dryOffDate,
  });

  final String id;
  final String animalId;
  final int cycleNumber;
  final DateTime calvingDate;
  final DateTime? dryOffDate;

  int daysInMilk(DateTime onDate) {
    if (onDate.isBefore(calvingDate)) return 0;
    final end = dryOffDate ?? onDate;
    final capped = onDate.isBefore(end) ? onDate : end;
    return capped.difference(calvingDate).inDays;
  }

  LactationStage stageOn(DateTime onDate) {
    if (dryOffDate != null && !onDate.isBefore(dryOffDate!)) {
      return LactationStage.dry;
    }
    final dim = daysInMilk(onDate);
    if (dim <= 30) return LactationStage.fresh;
    if (dim <= 90) return LactationStage.peak;
    if (dim <= 200) return LactationStage.mid;
    if (dim <= 305) return LactationStage.late;
    return LactationStage.dry;
  }

  String get stageLabel => switch (stageOn(DateTime.now())) {
        LactationStage.fresh => 'Fresh (early lactation)',
        LactationStage.peak => 'Peak lactation',
        LactationStage.mid => 'Mid lactation',
        LactationStage.late => 'Late lactation',
        LactationStage.dry => 'Dry period',
      };

  @override
  List<Object?> get props => [id, animalId, cycleNumber];
}

class MilkYieldRecord extends Equatable {
  const MilkYieldRecord({
    required this.date,
    required this.litres,
    required this.lactationDay,
    this.milkingSession,
  });

  final DateTime date;
  final double litres;
  /// Days in milk for the active lactation on [date].
  final int lactationDay;
  final String? milkingSession;

  @override
  List<Object?> get props => [date, litres, lactationDay];
}
