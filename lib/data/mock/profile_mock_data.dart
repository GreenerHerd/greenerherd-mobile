import '../../shared/widgets/gh_kv_list.dart';
import '../models/models.dart';

class MockWeightPoint {
  const MockWeightPoint({
    required this.monthLabel,
    required this.kg,
    this.yearLabel,
    this.deltaKg,
    this.isCurrent = false,
  });

  final String monthLabel;
  final int kg;
  final String? yearLabel;
  final int? deltaKg;
  final bool isCurrent;
}

class MockAiRecord {
  const MockAiRecord({
    required this.attemptNumber,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusPositive,
    required this.sire,
    required this.technician,
    required this.semenBatch,
    required this.resultDateLabel,
    this.statusNote,
  });

  final int attemptNumber;
  final String dateLabel;
  final String statusLabel;
  final bool statusPositive;
  final String sire;
  final String technician;
  final String semenBatch;
  final String resultDateLabel;
  final String? statusNote;
}

class MockMiscarriageRecord {
  const MockMiscarriageRecord({
    required this.dateLabel,
    required this.gestationDayLabel,
    required this.causeLabel,
    this.followUp,
  });

  final String dateLabel;
  final String gestationDayLabel;
  final String causeLabel;
  final String? followUp;
}

class MockBreedingSummary {
  const MockBreedingSummary({
    this.method,
    this.sire,
    this.provider,
    this.attemptLabel,
    this.attemptSubtitle,
  });

  final String? method;
  final String? sire;
  final String? provider;
  final String? attemptLabel;
  final String? attemptSubtitle;
}

class GroupBreedingDashboard {
  const GroupBreedingDashboard({
    required this.aiAttempts30d,
    required this.confirmedPregnant,
    required this.successRatePct,
    required this.miscarriages,
    required this.successThresholdNote,
    required this.providers,
    this.failedAiAlert,
  });

  final int aiAttempts30d;
  final int confirmedPregnant;
  final int successRatePct;
  final int miscarriages;
  final String successThresholdNote;
  final List<({String name, String detail, int ratePct})> providers;
  final ({String title, String body})? failedAiAlert;
}

abstract final class ProfileMockData {
  static bool isFemale(Animal animal) =>
      animal.sex.toUpperCase() == 'F' || animal.sex.toLowerCase() == 'female';

  static List<MockWeightPoint> weightHistoryChronological(Animal animal) {
    final current = animal.weightKg.round();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    final weights = [
      current - 40,
      current - 28,
      current - 16,
      current - 8,
      current,
    ];
    return List.generate(months.length, (i) {
      final kg = weights[i];
      final isLast = i == months.length - 1;
      return MockWeightPoint(
        monthLabel: months[i],
        kg: kg,
        yearLabel: '${months[i]} 2026',
        deltaKg: i == 0 ? null : kg - weights[i - 1],
        isCurrent: isLast,
      );
    });
  }

  static List<MockWeightPoint> weightHistoryNewestFirst(Animal animal) {
    final reversed = weightHistoryChronological(animal).reversed.toList();
    return List.generate(reversed.length, (i) {
      final pt = reversed[i];
      final prevKg = i > 0 ? reversed[i - 1].kg : null;
      return MockWeightPoint(
        monthLabel: pt.monthLabel,
        kg: pt.kg,
        yearLabel: '${pt.monthLabel} 2026',
        deltaKg: prevKg == null ? null : pt.kg - prevKg,
        isCurrent: i == 0,
      );
    });
  }

  static int weightGrowthPct(Animal animal) {
    final hist = weightHistoryChronological(animal);
    if (hist.length < 2) return 0;
    final first = hist.first.kg;
    final last = hist.last.kg;
    if (first <= 0) return 0;
    return (((last - first) / first) * 100).round();
  }

  static MockBreedingSummary? breedingSummary(String animalId) {
    switch (animalId) {
      case 'a1':
        return const MockBreedingSummary(
          method: 'Artificial insemination',
          sire: 'ISIS-7714 · Holstein',
          provider: 'Dr. Rashed · Tabuk Genetics',
          attemptLabel: '1 of 1',
          attemptSubtitle: 'Conceived first attempt',
        );
      case 'a2':
        return const MockBreedingSummary(
          method: 'Artificial insemination',
          sire: 'ISIS-7714 · Holstein',
          provider: 'Dr. Rashed · Tabuk Genetics',
          attemptLabel: '2 of 2',
          attemptSubtitle: 'Confirmed pregnant',
        );
      default:
        return null;
    }
  }

  static List<MockAiRecord> aiRecords(String animalId) {
    switch (animalId) {
      case 'a2':
        return const [
          MockAiRecord(
            attemptNumber: 2,
            dateLabel: '14 Mar 2026',
            statusLabel: 'Confirmed pregnant',
            statusPositive: true,
            sire: 'ISIS-7714 · Holstein',
            technician: 'Dr. Rashed',
            semenBatch: 'TG-2603-A',
            resultDateLabel: '28 Apr 2026',
          ),
          MockAiRecord(
            attemptNumber: 1,
            dateLabel: '02 Feb 2026',
            statusLabel: 'Open · returned to heat',
            statusPositive: false,
            sire: 'ISIS-7714 · Holstein',
            technician: 'Dr. Rashed',
            semenBatch: 'TG-2602-A',
            resultDateLabel: '24 Feb 2026',
            statusNote: 'Returned to heat at 22 d',
          ),
        ];
      case 'a1':
        return const [
          MockAiRecord(
            attemptNumber: 1,
            dateLabel: '22 Dec 2025',
            statusLabel: 'Confirmed pregnant',
            statusPositive: true,
            sire: 'ISIS-7714 · Holstein',
            technician: 'Dr. Rashed',
            semenBatch: 'TG-2598-A',
            resultDateLabel: '05 Feb 2026',
          ),
        ];
      default:
        return const [];
    }
  }

  static List<MockMiscarriageRecord> miscarriages(String animalId) {
    if (animalId == 'a6') {
      return const [
        MockMiscarriageRecord(
          dateLabel: '18 Jan 2026',
          gestationDayLabel: 'Day 142',
          causeLabel: 'Undetermined',
          followUp: 'Vet follow-up scheduled',
        ),
      ];
    }
    return const [];
  }

  static List<GhKvEntry> breedingHistoryKv(String animalId) {
    switch (animalId) {
      case 'a1':
        return const [
          GhKvEntry(label: '22 Dec 2025', value: 'AI · Confirmed', subtitle: 'Pregnancy ongoing'),
          GhKvEntry(label: '14 Mar 2024', value: 'Birth · 1 calf', subtitle: 'Yara #0512 · 36 kg'),
          GhKvEntry(
            label: '04 Jun 2023',
            value: 'AI · Confirmed',
            subtitle: 'Attempt 1',
          ),
          GhKvEntry(
            label: '14 Mar 2022',
            value: 'Born on farm',
            subtitle: 'Dam: Faten',
            isLast: true,
          ),
        ];
      case 'a2':
        return const [
          GhKvEntry(
            label: '14 Mar 2026',
            value: 'AI · Confirmed',
            subtitle: 'Attempt 2',
          ),
          GhKvEntry(
            label: '02 Feb 2026',
            value: 'AI · Open',
            subtitle: 'Returned to heat',
          ),
          GhKvEntry(
            label: '14 Mar 2024',
            value: 'Birth · 1 calf',
            subtitle: 'Prior lactation',
            isLast: true,
          ),
        ];
      default:
        return const [];
    }
  }

  static List<GhKvEntry> healthHistoryKv(String animalId) {
    if (animalId == 'a3') {
      return const [
        GhKvEntry(
          label: 'Mastitis · 22 Feb',
          value: 'Active',
          subtitle: 'Penicillin G · 5 ml IM daily',
          highlight: true,
        ),
        GhKvEntry(
          label: 'FMD vaccine · 14 Apr',
          value: 'Booster 12 May',
          subtitle: 'Withdrawal cleared',
        ),
        GhKvEntry(
          label: 'Ketosis · 4 May',
          value: 'Resolved',
          subtitle: 'Propylene glycol · 250 ml/day',
          isLast: true,
        ),
      ];
    }
    return const [
      GhKvEntry(
        label: 'Ketosis · 4 May',
        value: 'Active',
        subtitle: 'Propylene glycol · 250 ml/day',
        highlight: true,
      ),
      GhKvEntry(
        label: 'FMD vaccine · 14 Apr',
        value: 'Booster 12 May',
        subtitle: 'Withdrawal cleared',
      ),
      GhKvEntry(
        label: 'Mastitis · 22 Feb',
        value: 'Resolved',
        subtitle: 'Penicillin G · 5 ml IM',
        isLast: true,
      ),
    ];
  }

  static List<GhKvEntry> vaccinationKv(String animalId) {
    return const [
      GhKvEntry(label: 'FMD', value: '14 Apr 2026', subtitle: 'Booster due 12 May'),
      GhKvEntry(label: 'Brucellosis', value: '22 Sep 2025', subtitle: 'Annual'),
      GhKvEntry(label: 'Lumpy Skin', value: '03 Jul 2025', subtitle: 'Annual', isLast: true),
    ];
  }

  static List<GhKvEntry> animalTasksKv(String animalId) {
    switch (animalId) {
      case 'a1':
        return const [
          GhKvEntry(
            label: 'Pregnancy scan',
            value: 'Due 12 May',
            subtitle: 'Auto · 45-day check',
          ),
          GhKvEntry(
            label: 'Booster · FMD',
            value: 'Due 12 May',
            subtitle: 'Auto · 4 weeks',
          ),
          GhKvEntry(
            label: 'Move to pre-calving',
            value: 'Due 31 Aug',
            subtitle: 'Auto · 30 days before due',
            isLast: true,
          ),
        ];
      case 'a2':
        return const [
          GhKvEntry(
            label: 'Pregnancy scan',
            value: 'Due 12 May',
            subtitle: 'Auto · 45-day check',
          ),
          GhKvEntry(
            label: 'Udder check',
            value: 'Thu 11 May',
            subtitle: 'Manual · vet visit',
            isLast: true,
          ),
        ];
      default:
        return const [];
    }
  }

  static GroupBreedingDashboard? groupBreedingDashboard(String groupId) {
    if (groupId != 'g2') return null;
    return const GroupBreedingDashboard(
      aiAttempts30d: 14,
      confirmedPregnant: 9,
      successRatePct: 64,
      miscarriages: 1,
      successThresholdNote: 'Above 50% threshold',
      providers: [
        (name: 'Dr. Rashed · Tabuk', detail: '10 of 14 confirmed', ratePct: 71),
        (name: 'Al-Wafi Genetics', detail: '2 of 4 confirmed', ratePct: 50),
      ],
      failedAiAlert: (
        title: '2 failed AI on Khulud #0470',
        body: 'Consider finding an alternative AI provider for the next attempt.',
      ),
    );
  }

  static ({int pregnancyRatePct, int aiAttempts30d, int confirmed})? groupOverviewBreeding(
    String groupId,
  ) {
    if (groupId != 'g2') return null;
    return (pregnancyRatePct: 64, aiAttempts30d: 14, confirmed: 9);
  }
}
