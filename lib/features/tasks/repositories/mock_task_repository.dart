import '../../../core/errors/app_exception.dart';
import '../../../core/mock/sat_demo_seed.dart';
import '../../../core/utils/mock_delay.dart';
import '../models/task.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  MockTaskRepository({this.delay}) {
    _tasks.addAll(SatDemoSeed.tasks());
  }

  final Duration? delay;
  final List<Task> _tasks = [];
  int _nextId = 100;

  @override
  Future<List<Task>> fetchTasks({bool mineOnly = false}) async {
    await mockDelay(delay: delay);
    final copy = [..._tasks]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (!mineOnly) return copy;
    return copy
        .where((task) => task.owner.toLowerCase().contains('meena'))
        .toList();
  }

  @override
  Future<Task> fetchTask(String id) async {
    await mockDelay(delay: delay);
    return _require(id);
  }

  @override
  Future<Task> createTask(CreateTaskInput input) async {
    await mockDelay(delay: delay);
    final task = Task(
      id: 'task-$_nextId',
      title: input.title,
      description: input.description,
      status: TaskStatus.pending,
      priority: input.priority,
      owner: input.owner,
      dueDate: input.dueDate,
      createdAt: DateTime.now(),
      projectName: input.projectName,
      customerName: input.customerName,
      vendorName: input.vendorName,
      reminderAt: input.reminderAt,
    );
    _nextId += 1;
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await mockDelay(delay: delay);
    final index = _indexOf(task.id);
    _tasks[index] = task;
    return task;
  }

  @override
  Future<Task> updateStatus(String id, TaskStatus status) async {
    await mockDelay(delay: delay);
    final index = _indexOf(id);
    final updated = _tasks[index].copyWith(status: status);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> sendReminder(String id) async {
    await mockDelay(delay: delay);
    _require(id);
  }

  @override
  Future<List<TaskAssignee>> fetchAssignees() async {
    await mockDelay(delay: delay);
    final seen = <String>{};
    return [
      for (final task in _tasks)
        if (seen.add(task.owner))
          TaskAssignee(id: 'emp-${task.owner}', name: task.owner),
    ];
  }

  Task _require(String id) {
    return _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => throw AppException('Task $id was not found'),
    );
  }

  int _indexOf(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw AppException('Task $id was not found');
    }
    return index;
  }
}
