import '../models/enums.dart';
import '../models/lactation_models.dart';
import '../models/models.dart';
import '../services/lactation_seed_builder.dart';

/// Al-Falah Farm seed data from design handoff data.js
abstract final class MockSeedData {
  static const farm = Farm(
    id: 'farm-1',
    name: 'Al-Falah Farm',
    location: 'Riyadh, KSA',
    currency: 'SAR',
    housing: HousingType.indoorFans,
    ownerName: 'Yusuf Al-Harbi',
  );

  static final users = <FarmUser>[
    const FarmUser(id: 'u1', name: 'Yusuf Al-Harbi', role: UserRole.owner, initials: 'YA'),
    const FarmUser(id: 'u2', name: 'Khaled Saleh', role: UserRole.manager, initials: 'KS'),
    const FarmUser(id: 'u3', name: 'Ahmad Bilal', role: UserRole.farmHand, initials: 'AB'),
    const FarmUser(id: 'u4', name: 'Dr. Rashed', role: UserRole.vet, initials: 'DR'),
  ];

  static final groups = <AnimalGroup>[
    const AnimalGroup(
      id: 'g1',
      name: 'Milking A',
      species: Species.cattle,
      purpose: GroupPurpose.milk,
      headCount: 22,
      managerId: 'u2',
      description:
          'Lactating Holstein/Jersey cows in 1st–3rd parity. Twice-daily milking, free-stall barn with fans.',
    ),
    const AnimalGroup(
      id: 'g2',
      name: 'Breeding',
      species: Species.cattle,
      purpose: GroupPurpose.breeding,
      headCount: 8,
      managerId: 'u2',
      description:
          'Heifers and open cows scheduled for AI. Heat detection and breeding records tracked here.',
    ),
    const AnimalGroup(
      id: 'g3',
      name: 'Pregnant',
      species: Species.cattle,
      purpose: GroupPurpose.pregnant,
      headCount: 6,
      managerId: 'u2',
      description:
          'Confirmed pregnant animals in dry-off or late gestation. Calving watch and nutrition adjusted.',
    ),
    const AnimalGroup(
      id: 'g4',
      name: 'Calves',
      species: Species.cattle,
      purpose: GroupPurpose.maintenance,
      headCount: 6,
      managerId: 'u3',
      description:
          'Weaning and young stock under 12 months. Separate feeding plan and health protocol.',
    ),
    const AnimalGroup(
      id: 'g5',
      name: 'Maintenance B',
      species: Species.goat,
      purpose: GroupPurpose.maintenance,
      headCount: 48,
      managerId: 'u3',
      description:
          'General goat herd — mixed ages on maintenance ration. FMD booster due this week.',
    ),
    const AnimalGroup(
      id: 'g6',
      name: 'Pregnant Does',
      species: Species.goat,
      purpose: GroupPurpose.pregnant,
      headCount: 22,
      managerId: 'u3',
      description: 'Does with confirmed pregnancy. Kidding pens reserved from week 140.',
    ),
    const AnimalGroup(
      id: 'g7',
      name: 'Fattening',
      species: Species.goat,
      purpose: GroupPurpose.fattening,
      headCount: 26,
      managerId: 'u3',
      description:
          'Goats on finishing ration for market weight. Weekly weigh-ins and feed conversion tracked.',
    ),
    const AnimalGroup(
      id: 'g8',
      name: 'Najdi flock',
      species: Species.sheep,
      purpose: GroupPurpose.maintenance,
      headCount: 32,
      managerId: 'u3',
      description:
          'Najdi breed flock on pasture rotation. Includes a small number of rams for breeding.',
    ),
    const AnimalGroup(
      id: 'g9',
      name: 'Sick bay',
      species: Species.sheep,
      purpose: GroupPurpose.sick,
      headCount: 14,
      managerId: 'u4',
      description:
          'Isolation group for treatment and recovery. Vet protocols and withdrawal periods enforced.',
    ),
  ];

  static List<Animal> animals() => [
        Animal(
          id: 'a1', tag: '0421', name: 'Bessie', species: Species.cattle, sex: 'F',
          breed: 'Holstein', weightKg: 412, ageLabel: '4y 2m',
          dob: DateTime(2022, 3, 14), groupId: 'g3',
          tags: [AnimalTagType.pregnant, AnimalTagType.lactating],
          milkTodayLitres: 18.4, withdrawalDays: 3, sire: 'Tornado', dam: 'Faten', bcs: 3.5,
        ),
        Animal(
          id: 'a2', tag: '0438', name: 'Mona', species: Species.cattle, sex: 'F',
          breed: 'Holstein', weightKg: 398, ageLabel: '5y 1m',
          dob: DateTime(2021, 4, 2), groupId: 'g1',
          tags: [AnimalTagType.lactating], milkTodayLitres: 22.1, sire: 'Tornado', dam: 'Hala',
          monthsSinceCalving: 5,
        ),
        Animal(
          id: 'a3', tag: '0444', name: 'Sara', species: Species.cattle, sex: 'F',
          breed: 'Jersey', weightKg: 344, ageLabel: '3y 6m',
          dob: DateTime(2022, 11, 4), groupId: 'g1',
          tags: [AnimalTagType.lactating], milkTodayLitres: 14.7, withdrawalDays: 3,
          monthsSinceCalving: 2,
        ),
        Animal(
          id: 'a4', tag: '0451', name: 'Hala', species: Species.cattle, sex: 'F',
          breed: 'Holstein', weightKg: 426, ageLabel: '6y 3m',
          dob: DateTime(2020, 2, 10), groupId: 'g1',
          tags: [AnimalTagType.lactating], milkTodayLitres: 19.8,
          monthsSinceCalving: 8,
        ),
        Animal(
          id: 'a5', tag: '0462', name: 'Noor', species: Species.cattle, sex: 'F',
          breed: 'Holstein', weightKg: 388, ageLabel: '3y 1m',
          dob: DateTime(2023, 4, 1), groupId: 'g2',
          tags: [AnimalTagType.readyToBreed], isHeifer: true,
        ),
        Animal(
          id: 'a8', tag: '0401', name: 'Sultan', species: Species.cattle, sex: 'M',
          breed: 'Holstein', weightKg: 520, ageLabel: '5y 4m',
          dob: DateTime(2020, 1, 12), groupId: 'g2',
          tags: const [],
          sire: 'Tornado',
        ),
        Animal(
          id: 'a6', tag: '0470', name: 'Khulud', species: Species.cattle, sex: 'F',
          breed: 'Jersey', weightKg: 360, ageLabel: '4y 9m',
          dob: DateTime(2021, 8, 4), groupId: 'g3',
          tags: [AnimalTagType.pregnant],
        ),
        Animal(
          id: 'a7', tag: '0512', name: 'Yara', species: Species.cattle, sex: 'F',
          breed: 'Holstein', weightKg: 96, ageLabel: '8m',
          dob: DateTime(2025, 9, 2), groupId: 'g4',
          tags: [AnimalTagType.weaning], dam: 'Bessie',
        ),
        Animal(
          id: 'c1', tag: 'S009', name: 'Najma', species: Species.sheep, sex: 'F',
          breed: 'Najdi', weightKg: 54, ageLabel: '3y 2m',
          dob: DateTime(2023, 3, 12), groupId: 'g9',
          tags: [AnimalTagType.sick],
        ),
        Animal(
          id: 'c2', tag: 'S012', name: '—', species: Species.sheep, sex: 'M',
          breed: 'Najdi', weightKg: 48, ageLabel: '2y 8m',
          dob: DateTime(2023, 9, 4), groupId: 'g8',
          tags: [AnimalTagType.cull],
        ),
        Animal(
          id: 'b2', tag: 'G022', name: '—', species: Species.goat, sex: 'M',
          breed: 'Aardi', weightKg: 45, ageLabel: '3y 1m',
          dob: DateTime(2023, 4, 1), groupId: 'g5',
          tags: [AnimalTagType.readyToBreed],
        ),
        Animal(
          id: 'b1', tag: 'G014', name: 'Layla', species: Species.goat, sex: 'F',
          breed: 'Aardi', weightKg: 38, ageLabel: '2y 0m',
          dob: DateTime(2024, 5, 4), groupId: 'g6',
          tags: [AnimalTagType.pregnant],
        ),
      ];

  static final tasks = <TaskItem>[
    const TaskItem(
      id: 't1', title: 'Check Bessie #0421 calving signs',
      subtitle: 'Auto · birth alert', type: TaskType.autoBreeding,
      whenLabel: 'Now', dueBucket: 'today', overdue: true,
      iconName: 'baby', tone: TaskTone.error, animalId: 'a1', assigneeId: 'u4',
    ),
    const TaskItem(
      id: 't2', title: 'Booster: FMD · Goats Maintenance B',
      subtitle: 'Auto · 7-day reminder', type: TaskType.autoVaccination,
      whenLabel: 'Today 14:00', dueBucket: 'today',
      iconName: 'syringe', tone: TaskTone.warning, groupId: 'g5', assigneeId: 'u3',
    ),
    const TaskItem(
      id: 't3', title: 'Pregnancy scan · 6 cattle',
      subtitle: 'Auto · 45-day check', type: TaskType.autoBreeding,
      whenLabel: 'Today 16:30', dueBucket: 'today',
      iconName: 'check', tone: TaskTone.primary, groupId: 'g2', assigneeId: 'u4',
    ),
    const TaskItem(
      id: 't4', title: 'Refill mineral block — Sheep pen 2',
      subtitle: 'Manual', type: TaskType.manual,
      whenLabel: 'Tomorrow', dueBucket: 'week',
      iconName: 'list', tone: TaskTone.neutral, groupId: 'g8', assigneeId: 'u3',
    ),
    const TaskItem(
      id: 't5', title: 'Order alfalfa hay (5 t)',
      subtitle: 'Manual · weekly recurring', type: TaskType.manual,
      whenLabel: 'Wed 10 May', dueBucket: 'week',
      iconName: 'wallet', tone: TaskTone.neutral, assigneeId: 'u1',
    ),
    const TaskItem(
      id: 't8', title: 'Record morning milking',
      subtitle: 'Manual · daily recurring', type: TaskType.manual,
      whenLabel: 'Daily 06:00', dueBucket: 'recurring',
      iconName: 'milk', tone: TaskTone.neutral, groupId: 'g1', assigneeId: 'u3',
    ),
  ];

  static final finance = FinanceSummary(
    income3mo: 84200,
    expense3mo: 41600,
    net3mo: 42600,
    livestockValue: 412800,
    monthly: [
      FinanceMonth(label: 'Mar', income: 24000, expense: 12200),
      FinanceMonth(label: 'Apr', income: 28000, expense: 14600),
      FinanceMonth(label: 'May', income: 32200, expense: 14800),
    ],
    recent: [
      FinanceEntry(
        id: 'f1', dateLabel: '8 May', category: 'Milk Sale',
        type: FinanceEntryType.income, amount: 1240,
        description: 'Daily collection · Tabuk Dairy',
      ),
      FinanceEntry(
        id: 'f2', dateLabel: '7 May', category: 'AI Visits',
        type: FinanceEntryType.expense, amount: 480,
        description: 'Dr. Rashed · 2 cows',
      ),
    ],
  );

  static final reports = <ReportDefinition>[
    const ReportDefinition(
      id: 'r1', name: 'Successful Births',
      description: 'Births in date range with offspring details',
      iconName: 'baby', countLabel: '14 events',
    ),
    const ReportDefinition(
      id: 'r2', name: 'Cull Report',
      description: 'Animals flagged with cull reasons',
      iconName: 'overdue', countLabel: '5 animals',
    ),
    const ReportDefinition(
      id: 'r3', name: 'Animal Sales',
      description: 'Sales with buyer and price',
      iconName: 'wallet', countLabel: '8 sales',
    ),
    const ReportDefinition(
      id: 'r4', name: 'Animal Purchases',
      description: 'Purchases with supplier and price',
      iconName: 'wallet', countLabel: '12 purchases',
    ),
    const ReportDefinition(
      id: 'r5', name: 'Eid Sacrifice Eligibility',
      description: 'Cattle ≥2y · Sheep/Goat ≥1y · healthy',
      iconName: 'check', countLabel: '38 eligible',
    ),
    const ReportDefinition(
      id: 'r6', name: 'Animal Traceability',
      description: 'Per-animal certificate · health, vaccinations',
      iconName: 'list', countLabel: 'Per animal',
    ),
    const ReportDefinition(
      id: 'r7', name: 'Vaccination History',
      description: 'Last 12 months of vaccinations',
      iconName: 'syringe', countLabel: '186 events',
    ),
    const ReportDefinition(
      id: 'r8', name: 'Unvaccinated / Overdue',
      description: 'Animals past recommended interval',
      iconName: 'overdue', countLabel: '11 overdue',
    ),
  ];

  static final inventory = <InventoryItem>[
    const InventoryItem(
      id: 'i1', name: 'Alfalfa hay', isFeed: true,
      quantity: 1200, unit: 'kg', lowStock: true,
      subtitle: 'SAR 2.40/kg · Exp 12 Jun',
    ),
    const InventoryItem(
      id: 'i2', name: 'Penicillin G', isFeed: false,
      quantity: 6, unit: 'vials', expiringSoon: true,
      subtitle: 'Withdrawal 72h milk',
    ),
  ];

  static NutritionGap nutritionGapFor(String groupId) {
    switch (groupId) {
      case 'g1':
        return const NutritionGap(
          groupId: 'g1',
          dryMatterActualKg: 194,
          dryMatterTargetKg: 202,
          energyActualMj: 1500,
          energyTargetMj: 2552,
          proteinActualKg: 16.3,
          proteinTargetKg: 22,
          ndfActualKg: 64,
          ndfTargetKg: 62,
          calciumActualKg: 3.2,
          calciumTargetKg: 4.0,
          phosphorusActualKg: 2.0,
          phosphorusTargetKg: 2.5,
          fixGapMessage:
              'Group is 41% below energy target. Greener Herd suggests adding 14 kg of barley concentrate to morning mix.',
          dailyCostPerHeadSar: 25,
          dailyCostChangePct: -4,
        );
      case 'g2':
        return const NutritionGap(
          groupId: 'g2',
          dryMatterActualKg: 88,
          dryMatterTargetKg: 92,
          energyActualMj: 2100,
          energyTargetMj: 2200,
        );
      case 'g3':
        return const NutritionGap(
          groupId: 'g3',
          dryMatterActualKg: 72,
          dryMatterTargetKg: 78,
          energyActualMj: 1650,
          energyTargetMj: 1800,
        );
      default:
        return NutritionGap(
          groupId: groupId,
          dryMatterActualKg: 48,
          dryMatterTargetKg: 52,
          energyActualMj: 900,
          energyTargetMj: 950,
        );
    }
  }

  static final feedRecommendations = <FeedRecommendation>[
    const FeedRecommendation(
      id: 'fr1', name: 'Alfalfa hay (premium)',
      supplier: 'Inventory', costPerDay: 42, isTopPick: true,
    ),
    const FeedRecommendation(
      id: 'fr2', name: 'Barley concentrate',
      supplier: 'Standard catalogue', costPerDay: 28,
    ),
  ];

  static final marketplace = <MarketplaceProduct>[
    const MarketplaceProduct(
      id: 'mp1', name: 'Imported alfalfa bales',
      supplier: 'Gulf Feed Co.', pricePerKg: 2.8,
    ),
  ];

  static const subscription = SubscriptionPlan(
    tier: 'trial',
    label: 'Professional trial',
    trialDaysLeft: 12,
    isActive: true,
  );

  /// BDD / demo lactation + milk history (Mona #0438 has full curve).
  static ({Map<String, LactationCycle> cycles, Map<String, List<MilkYieldRecord>> history})
      lactationSeed() {
    final now = DateTime.now();
    final cycles = <String, LactationCycle>{};
    final history = <String, List<MilkYieldRecord>>{};

    void seedCow({
      required String id,
      required int dimStart,
      required int weeksOfHistory,
      required int cycleNumber,
    }) {
      final calving = now.subtract(Duration(days: dimStart));
      final cycle = LactationSeedBuilder.cycleFor(
        animalId: id,
        cycleNumber: cycleNumber,
        calvingDate: calving,
      );
      cycles[id] = cycle;
      history[id] = LactationSeedBuilder.weeklyHistory(
        calvingDate: calving,
        toDate: now,
      );
      if (history[id]!.length > weeksOfHistory) {
        history[id] = history[id]!.sublist(history[id]!.length - weeksOfHistory);
      }
    }

    // Mona — primary BDD animal: mid-lactation, rich history
    seedCow(id: 'a2', dimStart: 128, weeksOfHistory: 18, cycleNumber: 3);
    seedCow(id: 'a3', dimStart: 95, weeksOfHistory: 14, cycleNumber: 2);
    seedCow(id: 'a4', dimStart: 72, weeksOfHistory: 12, cycleNumber: 4);

    return (cycles: cycles, history: history);
  }
}
