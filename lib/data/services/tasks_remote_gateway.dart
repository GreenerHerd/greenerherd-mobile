/// Remote port for `gh-api-tasks` (enables fakes in BDD / tests).
abstract class TasksRemoteGateway {
  Future<List<Map<String, dynamic>>> listTasks(
    String farmId, {
    String? status,
    String? groupId,
  });

  Future<void> completeTask(String taskId);

  Future<void> dismissTask(String taskId);
}
