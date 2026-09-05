import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatters.dart';
import '../../../features/projects/providers/project_providers.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import 'task_status_style.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(taskDetailProvider(taskId));
    final projects = ref.watch(projectsProvider).asData?.value ?? const [];
    final names = {for (final project in projects) project.id: project.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: AsyncBody<Task>(
        value: async,
        loadingMessage: 'Loading task...',
        onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
        data: (task) {
          final projectName = task.projectName ?? names[task.projectId ?? ''];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (task.taskId.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(task.taskId),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              const SizedBox(height: 16),
              if (task.description.isNotEmpty) Text(task.description),
              const SizedBox(height: 16),
              Text('Assigned employee: ${task.owner}'),
              Text('Created by: ${task.createdBy}'),
              Text('Due: ${DateFormatters.date(task.dueDate)}'),
              Text('Created: ${DateFormatters.date(task.createdAt)}'),
              if (projectName != null && projectName.isNotEmpty)
                Text('Project: $projectName'),
              if (task.reminderAt != null)
                Text('Reminder: ${DateFormatters.dateTime(task.reminderAt!)}'),
              if (task.isOverdue)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('This task is overdue.'),
                ),
              const SizedBox(height: 24),
              Text(
                'Update status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final status in TaskStatusX.writable)
                    OutlinedButton(
                      onPressed: status == task.status
                          ? null
                          : () async {
                              try {
                                await ref
                                    .read(tasksProvider.notifier)
                                    .updateStatus(task.id, status);
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              }
                            },
                      child: Text(status.label),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  try {
                    await ref
                        .read(tasksProvider.notifier)
                        .sendReminder(task.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder time was saved on this task'),
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  }
                },
                child: const Text('Send reminder'),
              ),
            ],
          );
        },
      ),
    );
  }
}
