import '../../data/models/enums.dart';

class GroupFeedEntry {
  const GroupFeedEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.costSar,
    required this.weightKg,
    this.headCount,
    this.mealTypeId,
  });

  final String id;
  final String title;
  final String subtitle;
  final double costSar;
  final double weightKg;
  final int? headCount;
  final String? mealTypeId;
}

class GroupVaccinationRecord {
  const GroupVaccinationRecord({
    required this.name,
    required this.dateLabel,
    required this.cycleLabel,
  });

  final String name;
  final String dateLabel;
  final String cycleLabel;
}

class GroupTreatmentRecord {
  const GroupTreatmentRecord({
    required this.title,
    required this.progressLabel,
    required this.detail,
  });

  final String title;
  final String progressLabel;
  final String detail;
}

class GroupHealthAlert {
  const GroupHealthAlert({
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final String title;
  final String body;
  final String actionLabel;
}

class GroupTaskPreview {
  const GroupTaskPreview({required this.count, required this.label});

  final int count;
  final String label;
}

abstract final class GroupMockExtras {
  static List<GroupFeedEntry> feedEntries(String groupId) {
    if (groupId != 'g1') return [];
    return const [
      GroupFeedEntry(
        id: 'feed-demo-1',
        title: 'Morning Mix · alfalfa + barley',
        subtitle: '148 kg · 6.7 kg/head',
        costSar: 412,
        weightKg: 148,
        headCount: 22,
      ),
      GroupFeedEntry(
        id: 'feed-demo-2',
        title: 'Afternoon · corn silage',
        subtitle: '46 kg · 2.1 kg/head',
        costSar: 138,
        weightKg: 46,
        headCount: 22,
      ),
    ];
  }

  static GroupHealthAlert? healthAlert(String groupId) {
    if (groupId != 'g1') return null;
    return const GroupHealthAlert(
      title: 'FMD booster due Fri',
      body: '14 head · last vaccinated 14 Apr · 4-week interval reached.',
      actionLabel: 'Schedule vaccination',
    );
  }

  static List<GroupVaccinationRecord> vaccinations(String groupId) {
    if (groupId != 'g1') return [];
    return const [
      GroupVaccinationRecord(
        name: 'FMD',
        dateLabel: '14 Apr 2026',
        cycleLabel: 'Booster Fri 12 May',
      ),
      GroupVaccinationRecord(
        name: 'Brucellosis',
        dateLabel: '22 Sep 2025',
        cycleLabel: 'Annual cycle',
      ),
    ];
  }

  static List<GroupTreatmentRecord> treatments(String groupId) {
    if (groupId != 'g1') return [];
    return const [
      GroupTreatmentRecord(
        title: 'Mastitis · Sara #0444',
        progressLabel: 'day 3 of 5',
        detail: 'Penicillin G · 5ml IM',
      ),
    ];
  }

  static GroupTaskPreview tasksPreview(String groupId) {
    if (groupId == 'g1') {
      return const GroupTaskPreview(count: 4, label: 'Tasks · 7 days');
    }
    return const GroupTaskPreview(count: 0, label: 'Tasks · 7 days');
  }

  /// Mock 30-day milk totals (litres) for sparkline.
  static List<double> milkTrend30Day(String groupId) {
    if (groupId != 'g1') {
      return List.generate(30, (i) => 40.0 + (i % 7) * 2);
    }
    return [
      52, 54, 51, 49, 48, 46, 44, 42, 40, 38, 36, 35, 34, 33, 32, 33, 35,
      38, 42, 45, 48, 50, 52, 54, 55, 56, 57, 56, 57, 56.6,
    ];
  }

  static int displaySickCount(String groupId, int actual) {
    if (groupId == 'g1') return actual > 0 ? actual : 2;
    return actual;
  }

  static int displayWithdrawalCount(String groupId, int actual) {
    if (groupId == 'g1' && actual < 3) return 3;
    return actual;
  }

  static String purposeLabel(GroupPurpose purpose) => switch (purpose) {
        GroupPurpose.milk => 'Milking',
        GroupPurpose.breeding => 'Breeding',
        GroupPurpose.pregnant => 'Pregnant',
        GroupPurpose.fattening => 'Fattening',
        GroupPurpose.maintenance => 'Maintenance',
        GroupPurpose.weaning => 'Weaning',
        GroupPurpose.dry => 'Dry',
        GroupPurpose.sick => 'Sick bay',
      };
}
