import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/services/task_mapper.dart';

void main() {
  test('maps API task to TaskItem with overdue flag', () {
    final item = TaskMapper.fromWire({
      'id': 'task-1',
      'title': 'Low inventory: Alfalfa',
      'description': 'Reorder soon',
      'task_type': 'AUTO_HEALTH',
      'status': 'PENDING',
      'due_date': '2020-01-01',
      'priority': 'HIGH',
      'group_id': 'g1',
    });

    expect(item.id, 'task-1');
    expect(item.overdue, isTrue);
    expect(item.tone, TaskTone.error);
    expect(item.type, TaskType.autoHealth);
    expect(item.groupId, 'g1');
  });
}
