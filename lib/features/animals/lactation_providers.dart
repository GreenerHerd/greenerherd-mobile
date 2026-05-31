import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/lactation_models.dart';

final lactationCycleProvider =
    FutureProvider.family<LactationCycle?, String>((ref, animalId) {
  return ref.watch(lactationRepositoryProvider).activeCycle(animalId);
});

final milkHistoryProvider =
    FutureProvider.family<List<MilkYieldRecord>, String>((ref, animalId) {
  return ref.watch(lactationRepositoryProvider).milkHistory(animalId);
});
