import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/task_summary.dart';

class TodaysTasksSection extends StatelessWidget {
  const TodaysTasksSection({super.key, required this.tasks});

  final List<TaskSummary> tasks;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Top Priorities',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.tasks),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 4),
          if (tasks.isEmpty)
            const Text(
              'No priority tasks today.',
              style: TextStyle(color: AppTheme.mutedText),
            )
          else
            ...tasks.map((task) {
              final priorityColor = task.priority.toLowerCase() == 'critical'
                  ? AppTheme.danger
                  : task.priority.toLowerCase() == 'high'
                  ? AppTheme.warning
                  : AppTheme.info;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${task.projectName} · ${task.assignedEmployee} · ${task.dueLabel}',
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.end,
                        children: [
                          StatusChip(
                            label: task.priority,
                            color: priorityColor,
                          ),
                          StatusChip(
                            label: task.status,
                            color: AppTheme.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
