import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/task.dart';
import '../repositories/api_task_repository.dart';
import '../repositories/task_repository.dart';

/// Tasks always use the live Node.js API (Bearer token from auth).
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return ApiTaskRepository(ref.watch(apiClientProvider));
});

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskStatus?>(
  TaskFilterNotifier.new,
);

class TaskFilterNotifier extends Notifier<TaskStatus?> {
  @override
  TaskStatus? build() => null;

  void setFilter(TaskStatus? status) => state = status;
}

final taskSearchProvider = NotifierProvider<TaskSearchNotifier, String>(
  TaskSearchNotifier.new,
);

class TaskSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    // Re-fetch when the signed-in user changes (prevents MD list leaking to Employee).
    final _ = auth.session?.user.id;
    final role = auth.session?.user.role;
    final mineOnly = (role ?? '').toUpperCase() == 'EMPLOYEE';
    return ref.read(taskRepositoryProvider).fetchTasks(mineOnly: mineOnly);
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      state = const AsyncData([]);
      return;
    }
    final role = auth.session?.user.role;
    final mineOnly = (role ?? '').toUpperCase() == 'EMPLOYEE';
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).fetchTasks(mineOnly: mineOnly),
    );
  }

  Future<Task> createTask(CreateTaskInput input) async {
    final created = await ref.read(taskRepositoryProvider).createTask(input);
    await refresh();
    return created;
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    await ref.read(taskRepositoryProvider).updateStatus(id, status);
    ref.invalidate(taskDetailProvider(id));
    await refresh();
  }

  Future<void> sendReminder(String id) {
    return ref.read(taskRepositoryProvider).sendReminder(id);
  }
}

final taskDetailProvider = FutureProvider.family<Task, String>((ref, id) {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    throw StateError('Not authenticated');
  }
  return ref.watch(taskRepositoryProvider).fetchTask(id);
});

final taskAssigneesProvider = FutureProvider<List<TaskAssignee>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return const [];
  return ref.watch(taskRepositoryProvider).fetchAssignees();
});

final visibleTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final query = ref.watch(taskSearchProvider).trim().toLowerCase();
  final tasks = ref.watch(tasksProvider);
  return tasks.whenData((items) {
    var visible = items;
    if (filter != null) {
      visible = visible.where((task) {
        if (filter == TaskStatus.overdue) return task.isOverdue;
        return task.status == filter;
      }).toList();
    }
    if (query.isNotEmpty) {
      visible = visible
          .where(
            (task) =>
                task.title.toLowerCase().contains(query) ||
                task.owner.toLowerCase().contains(query) ||
                (task.projectName?.toLowerCase().contains(query) ?? false) ||
                (task.customerName?.toLowerCase().contains(query) ?? false) ||
                task.taskId.toLowerCase().contains(query),
          )
          .toList();
    }
    return visible;
  });
});

/// Whether the signed-in role may create/assign tasks (backend: MD/ADMIN/MANAGER).
final canCreateTasksProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.createTasks);
});
