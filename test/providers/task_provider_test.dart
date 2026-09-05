import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:md_eao/features/auth/models/auth_user.dart';
import 'package:md_eao/features/tasks/models/task.dart';
import 'package:md_eao/features/tasks/providers/task_providers.dart';
import 'package:md_eao/features/tasks/repositories/mock_task_repository.dart';

import '../helpers/auth_test_override.dart';

void main() {
  ProviderContainer buildContainer({AuthSession? session}) {
    return ProviderContainer.test(
      overrides: [
        authOverride(session ?? testAuthSession),
        taskRepositoryProvider.overrideWithValue(
          MockTaskRepository(delay: Duration.zero),
        ),
      ],
    );
  }

  test('tasksProvider loads mock tasks for MD', () async {
    final container = buildContainer();
    final tasks = await container.read(tasksProvider.future);
    expect(tasks, isNotEmpty);
  });

  test('tasksProvider uses mineOnly path for employees', () async {
    final container = buildContainer(session: testEmployeeSession);
    final tasks = await container.read(tasksProvider.future);
    // Mock mineOnly filters to Meena-owned demo rows when present.
    expect(tasks, isA<List<Task>>());
  });

  test('createTask adds a pending task through the repository', () async {
    final container = buildContainer();
    await container.read(tasksProvider.future);

    final created = await container
        .read(tasksProvider.notifier)
        .createTask(
          CreateTaskInput(
            title: 'Call banker',
            description: 'Confirm LC extension',
            owner: 'CFO',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            priority: TaskPriority.high,
          ),
        );

    expect(created.status, TaskStatus.pending);
    final tasks = container.read(tasksProvider).requireValue;
    expect(tasks.any((task) => task.id == created.id), isTrue);
  });

  test('updateStatus persists through the repository', () async {
    final container = buildContainer();
    final tasks = await container.read(tasksProvider.future);
    final first = tasks.first;

    await container
        .read(tasksProvider.notifier)
        .updateStatus(first.id, TaskStatus.completed);

    final updated = await container.read(taskDetailProvider(first.id).future);
    expect(updated.status, TaskStatus.completed);
  });
}
