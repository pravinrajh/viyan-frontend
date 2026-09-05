import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/features/tasks/models/task.dart';

void main() {
  test('Task round-trips through JSON', () {
    final task = Task(
      id: 'task-1',
      title: 'Review pack',
      description: 'Board numbers',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      owner: 'EA',
      dueDate: DateTime.utc(2026, 8, 18),
      createdAt: DateTime.utc(2026, 8, 10),
    );

    final decoded = Task.fromJson(task.toJson());

    expect(decoded.id, task.id);
    expect(decoded.title, task.title);
    expect(decoded.status, TaskStatus.inProgress);
    expect(decoded.priority, TaskPriority.high);
    expect(decoded.owner, 'EA');
  });

  test('completed tasks are not overdue', () {
    final task = Task(
      id: 'task-2',
      title: 'Done',
      description: 'Done',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      owner: 'HR',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    expect(task.isOverdue, isFalse);
  });

  test('Task parses live GET /api/v1/tasks payload', () {
    final task = Task.fromJson({
      'id': '6a873d0aae502ed8e76cc1a9',
      'taskId': 'TASK-SEED-007',
      'title': 'Archive completed snag list for Block A',
      'description': 'Mark closed items and store signed PDF.',
      'status': 'COMPLETED',
      'priority': 'MEDIUM',
      'assignedTo': {
        'id': '6a873d0aae502ed8e76cc19e',
        'name': 'Raj Iyer',
        'employeeCode': 'EMP-SEED-02',
      },
      'createdBy': '6a873d0aae502ed8e76cc199',
      'projectId': '6a873d0aae502ed8e76cc1a0',
      'dueDate': '2026-08-10T10:00:00.000Z',
      'createdAt': '2026-08-20T17:44:42.104Z',
      'isOverdue': false,
    });

    expect(task.id, '6a873d0aae502ed8e76cc1a9');
    expect(task.taskId, 'TASK-SEED-007');
    expect(task.status, TaskStatus.completed);
    expect(task.priority, TaskPriority.medium);
    expect(task.owner, 'Raj Iyer');
    expect(task.assignedToId, '6a873d0aae502ed8e76cc19e');
    expect(task.projectId, '6a873d0aae502ed8e76cc1a0');
    expect(task.isOverdue, isFalse);
  });
}
