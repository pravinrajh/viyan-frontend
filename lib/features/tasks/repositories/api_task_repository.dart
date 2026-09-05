import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/task.dart';
import 'task_repository.dart';

/// Live tasks from MD_EAO_BACKEND `GET /api/v1/tasks`.
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._client);

  final ApiClient _client;

  static const _pageSize = 100;

  @override
  Future<List<Task>> fetchTasks({bool mineOnly = false}) async {
    final tasks = <Task>[];
    var page = 1;
    var totalPages = 1;
    final path = mineOnly ? ApiEndpoints.tasksMy : ApiEndpoints.tasks;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        path,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          tasks.add(Task.fromJson(item));
        } catch (_) {}
      }

      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return tasks;
  }

  @override
  Future<Task> fetchTask(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.task(id));
    return Task.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Task> createTask(CreateTaskInput input) async {
    final assignedTo = input.assignedToId?.trim() ?? '';
    if (assignedTo.isEmpty) {
      throw const AppException('Select an assigned employee.');
    }
    final body = <String, dynamic>{
      'title': input.title,
      'assignedTo': assignedTo,
      'priority': input.priority.apiValue,
      'dueDate': input.dueDate.toUtc().toIso8601String(),
    };
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    final projectId = input.projectId?.trim();
    if (projectId != null && projectId.isNotEmpty) {
      body['projectId'] = projectId;
    }
    if (input.reminderAt != null) {
      body['reminderAt'] = input.reminderAt!.toUtc().toIso8601String();
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.tasks,
      data: body,
    );
    return Task.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Task> updateTask(Task task) async {
    final body = <String, dynamic>{
      'title': task.title,
      'description': task.description,
      'priority': task.priority.apiValue,
      'dueDate': task.dueDate.toUtc().toIso8601String(),
    };
    if (task.assignedToId != null && task.assignedToId!.isNotEmpty) {
      body['assignedTo'] = task.assignedToId;
    }
    if (task.projectId != null) {
      body['projectId'] = task.projectId;
    }
    if (task.reminderAt != null) {
      body['reminderAt'] = task.reminderAt!.toUtc().toIso8601String();
    }
    final response = await _client.patch<dynamic>(
      ApiEndpoints.task(task.id),
      data: body,
    );
    return Task.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Task> updateStatus(String id, TaskStatus status) async {
    if (status == TaskStatus.overdue) {
      throw const AppException('Overdue is not a status that can be set.');
    }
    final response = await _client.patch<dynamic>(
      ApiEndpoints.taskStatus(id),
      data: {'status': status.apiValue},
    );
    return Task.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> sendReminder(String id) async {
    final task = await fetchTask(id);
    var reminderAt = DateTime.now().toUtc();
    if (reminderAt.isAfter(task.dueDate.toUtc())) {
      reminderAt = task.dueDate.toUtc();
    }
    await _client.patch<dynamic>(
      ApiEndpoints.task(id),
      data: {'reminderAt': reminderAt.toIso8601String()},
    );
  }

  @override
  Future<List<TaskAssignee>> fetchAssignees() async {
    final assignees = <TaskAssignee>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.employees,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          final assignee = TaskAssignee.fromJson(item);
          if (assignee.id.isEmpty || assignee.name.isEmpty) continue;
          if (_string(item['status']).toUpperCase() == 'INACTIVE') continue;
          assignees.add(assignee);
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return assignees;
  }

  static String _string(Object? value) {
    return value is String ? value : '';
  }
}
