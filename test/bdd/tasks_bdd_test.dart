import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/core/providers/providers.dart';
import 'package:greenerherd_mobile/data/mock/mock_data_store.dart';
import 'package:greenerherd_mobile/data/models/enums.dart';
import 'package:greenerherd_mobile/data/models/models.dart';
import 'package:greenerherd_mobile/data/repositories/hybrid_task_repository.dart';
import 'package:greenerherd_mobile/data/services/tasks_remote_gateway.dart';
import 'package:greenerherd_mobile/features/tasks/tasks_screen.dart';

import 'support/bdd_harness.dart';

class FakeTasksGateway implements TasksRemoteGateway {
  FakeTasksGateway(this.rows);

  List<Map<String, dynamic>> rows;
  final List<String> completedIds = [];
  final List<String> dismissedIds = [];

  @override
  Future<List<Map<String, dynamic>>> listTasks(
    String farmId, {
    String? status,
    String? groupId,
  }) async {
    return rows
        .where((r) {
          final s = (r['status'] as String? ?? '').toUpperCase();
          if (s == 'COMPLETE' || s == 'DISMISSED') return false;
          return true;
        })
        .toList();
  }

  @override
  Future<void> completeTask(String taskId) async {
    completedIds.add(taskId);
    final i = rows.indexWhere((r) => r['id'] == taskId);
    if (i >= 0) {
      rows[i] = {...rows[i], 'status': 'COMPLETE'};
    }
  }

  @override
  Future<void> dismissTask(String taskId) async {
    dismissedIds.add(taskId);
    final i = rows.indexWhere((r) => r['id'] == taskId);
    if (i >= 0) {
      rows[i] = {...rows[i], 'status': 'DISMISSED'};
    }
  }
}

void main() {
  initBddTests();

  group('Feature: Farm tasks (scheduler integration)', () {
    late BddHarness harness;
    late MockDataStore store;
    late FakeTasksGateway gateway;
    late HybridTaskRepository tasks;

    setUp(() {
      harness = BddHarness();
      store = harness.store;
      gateway = FakeTasksGateway([]);
      tasks = HybridTaskRepository(
        offlineStore: store,
        gateway: gateway,
        farmId: 'farm-1',
      );
    });

    List<Override> taskOverrides() => [
          taskRepositoryProvider.overrideWithValue(tasks),
        ];

    void seedVaccinationTask() {
      gateway.rows = [
        {
          'id': 'task-vac-1',
          'title': 'Clostridium Vaccination Due',
          'description': 'Annual booster',
          'task_type': 'AUTO_VACCINATION',
          'status': 'PENDING',
          'due_date': '2020-01-01',
          'priority': 'HIGH',
        },
      ];
    }

    void seedFeedTask() {
      gateway.rows = [
        {
          'id': 'task-feed-1',
          'title': 'Buy more Alfalfa hay',
          'description': 'Low stock',
          'task_type': 'AUTO_HEALTH',
          'status': 'PENDING',
          'due_date': DateTime.now().toIso8601String().substring(0, 10),
          'priority': 'MEDIUM',
        },
      ];
    }

    bddAsyncDomainScenario(
      'Hybrid repository lists API tasks with due labels',
      tags: ['positive'],
      body: () async {
        seedVaccinationTask();
        final list = await tasks.listTasks();
        expect(
          list.any((t) => t.title == 'Clostridium Vaccination Due'),
          isTrue,
        );
        final item = list.firstWhere(
          (t) => t.title == 'Clostridium Vaccination Due',
        );
        expect(item.overdue, isTrue);
      },
    );

    bddAsyncDomainScenario(
      'Completing a task calls the tasks API',
      tags: ['positive'],
      body: () async {
        seedFeedTask();
        final list = await tasks.listTasks();
        final item = list.firstWhere((t) => t.title == 'Buy more Alfalfa hay');
        await tasks.completeTask(item.id);
        expect(gateway.completedIds, contains('task-feed-1'));
      },
    );

    bddAsyncDomainScenario(
      'Manual tasks remain available when API is empty',
      tags: ['positive'],
      body: () async {
        gateway.rows = [];
        store.addTask(
          const TaskItem(
            id: 't-local-1',
            title: 'Check water troughs',
            subtitle: 'Morning routine',
            type: TaskType.manual,
            whenLabel: 'Today',
            dueBucket: 'today',
            iconName: 'task',
            tone: TaskTone.primary,
          ),
        );
        final list = await tasks.listTasks();
        expect(list.any((t) => t.title == 'Check water troughs'), isTrue);
      },
    );

    bddScenario(
      'Tasks screen shows scheduler-generated title',
      tags: ['positive'],
      body: (tester) async {
        seedVaccinationTask();
        await harness.pumpScreen(
          tester,
          const TasksScreen(),
          overrides: taskOverrides(),
        );
        expect(find.text('Clostridium Vaccination Due'), findsOneWidget);
      },
    );
  });
}
