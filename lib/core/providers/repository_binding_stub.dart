import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repositories.dart';

AnimalRepository wrapAnimalRepository(
  Ref ref,
  AnimalRepository inner,
  String farmId,
) =>
    inner;

GroupRepository wrapGroupRepository(
  Ref ref,
  GroupRepository inner,
  String farmId,
) =>
    inner;

TaskRepository wrapTaskRepository(
  Ref ref,
  TaskRepository inner,
  String farmId,
) =>
    inner;
