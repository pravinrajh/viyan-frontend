import '../models/task.dart';

abstract class TaskRepository {
  /// [mineOnly] uses `GET /api/v1/tasks/my` (assigned to the signed-in employee).
  /// Otherwise uses `GET /api/v1/tasks` which the backend still scopes by role.
  Future<List<Task>> fetchTasks({bool mineOnly = false});
  Future<Task> fetchTask(String id);
  Future<Task> createTask(CreateTaskInput input);
  Future<Task> updateTask(Task task);
  Future<Task> updateStatus(String id, TaskStatus status);
  Future<void> sendReminder(String id);
  Future<List<TaskAssignee>> fetchAssignees();
}
