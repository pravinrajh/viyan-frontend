import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../features/projects/providers/project_providers.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import 'task_status_style.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(visibleTasksProvider);
    final projects = ref.watch(projectsProvider).asData?.value ?? const [];
    final role = ref.watch(sessionProvider)?.user.role ?? '';
    final scoped = role.toUpperCase() == 'EMPLOYEE';
    final canCreate = ref.watch(canCreateTasksProvider);
    final names = {for (final project in projects) project.id: project.name};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.taskNew),
              backgroundColor: AppTheme.navy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New task'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: scoped
                    ? 'Search your tasks'
                    : 'Search title, owner, project',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(taskSearchProvider.notifier).setQuery(value),
            ),
          ),
          if (scoped)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing only tasks assigned to you.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: filter == null,
                  onSelected: () =>
                      ref.read(taskFilterProvider.notifier).setFilter(null),
                ),
                for (final status in TaskStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: filter == status,
                    onSelected: () =>
                        ref.read(taskFilterProvider.notifier).setFilter(status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncBody<List<Task>>(
              value: tasks,
              emptyMessage: scoped
                  ? 'No tasks are assigned to your account yet.'
                  : 'No tasks found.',
              emptyIcon: Icons.checklist_outlined,
              loadingMessage: 'Loading tasks...',
              isEmpty: (items) => items.isEmpty,
              onRetry: () => ref.read(tasksProvider.notifier).refresh(),
              data: (items) => RefreshIndicator(
                onRefresh: () => ref.read(tasksProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final task = items[index];
                    final projectName =
                        task.projectName ?? names[task.projectId ?? ''];
                    return AppSurfaceCard(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.go(AppRoutes.taskDetail(task.id)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      if (task.taskId.isNotEmpty) task.taskId,
                                      if (task.owner.isNotEmpty) task.owner,
                                      if (projectName != null &&
                                          projectName.isNotEmpty)
                                        projectName,
                                      DateFormatters.date(task.dueDate),
                                      if (task.isOverdue) 'overdue',
                                    ].join(' · '),
                                    style: const TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.end,
                                children: [
                                  StatusChip(
                                    label: task.status.label,
                                    color: taskStatusColor(task.status),
                                  ),
                                  StatusChip(
                                    label: task.priority.label,
                                    color: taskPriorityColor(task.priority),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
