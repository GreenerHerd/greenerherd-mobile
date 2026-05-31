import '../../core/config/app_config.dart';
import '../models/models.dart';
import '../mock/mock_data_store.dart';
import '../services/task_mapper.dart';
import '../services/tasks_api_client.dart';
import '../services/tasks_remote_gateway.dart';
import 'repositories.dart';

/// Loads farm tasks from `gh-api-tasks` with mock fallback for offline/manual tasks.
class HybridTaskRepository implements TaskRepository {
  HybridTaskRepository({
    required MockDataStore offlineStore,
    TasksRemoteGateway? gateway,
    String? farmId,
    String? bearerToken,
  })  : _offline = offlineStore,
        _farmId = farmId ?? 'farm-1',
        _api = gateway ??
            TasksApiClient(
              baseUrl: AppConfig.tasksApiBaseUrl,
              bearerToken: bearerToken ?? AppConfig.inventoryDevBearerToken,
            );

  final MockDataStore _offline;
  final String _farmId;
  final TasksRemoteGateway _api;

  /// Local-only manual tasks (not yet on server).
  static bool _isLocalOnlyId(String id) => id.startsWith('t-');

  @override
  Future<List<TaskItem>> listTasks({String? dueBucket}) async {
    final merged = <String, TaskItem>{};

    if (AppConfig.useTasksApi) {
      try {
        final rows = await _api.listTasks(_farmId);
        for (final row in rows) {
          final status = (row['status'] as String? ?? '').toUpperCase();
          if (status == 'COMPLETE' || status == 'DISMISSED') continue;
          final item = TaskMapper.fromWire(row);
          merged[item.id] = item;
        }
      } on TasksApiException {
        for (final t in _offline.tasks) {
          merged[t.id] = t;
        }
      }
    } else {
      for (final t in _offline.tasks) {
        merged[t.id] = t;
      }
    }

    for (final t in _offline.tasks.where((t) => _isLocalOnlyId(t.id))) {
      merged[t.id] = t;
    }

    var list = merged.values.toList()
      ..sort((a, b) => a.whenLabel.compareTo(b.whenLabel));

    if (dueBucket != null) {
      list = list.where((t) => t.dueBucket == dueBucket).toList();
    }
    return list;
  }

  @override
  Future<void> addTask(TaskItem task) async {
    _offline.addTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    if (_isLocalOnlyId(id)) {
      _offline.removeTask(id);
      return;
    }
    if (AppConfig.useTasksApi) {
      try {
        await _api.dismissTask(id);
        return;
      } on TasksApiException {
        // fall through
      }
    }
    _offline.removeTask(id);
  }

  @override
  Future<void> completeTask(String id) async {
    final inOffline = _offline.tasks.any((t) => t.id == id);
    if (inOffline || _isLocalOnlyId(id)) {
      _offline.removeTask(id);
      return;
    }
    if (AppConfig.useTasksApi) {
      try {
        await _api.completeTask(id);
        return;
      } on TasksApiException {
        // fall through
      }
    }
    _offline.removeTask(id);
  }

  @override
  Future<void> dismissTask(String id) => deleteTask(id);
}
