import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../models/critical_action.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/business_overview_section.dart';
import 'widgets/critical_actions_section.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/finance_collection_section.dart';
import 'widgets/projects_section.dart';
import 'widgets/todays_meetings_section.dart';
import 'widgets/todays_tasks_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 900 ? 28.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
      child: async.when(
        loading: () => const LoadingView(message: 'Loading business status...'),
        error: (error, _) => ErrorView(
          message: 'Unable to load business data.',
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        data: (summary) {
          if (summary.isEmpty) {
            return const EmptyView(message: 'No business data available.');
          }

          final wide = width >= 1100;
          final medium = width >= 800;
          final businessStatus = summary.criticalActions.isEmpty
              ? (summary.tasks.overdue > 0 || summary.projects.atRisk > 0
                    ? 'Attention Required'
                    : 'Healthy')
              : (summary.criticalActions.any(
                      (a) => a.priority == CriticalPriority.critical,
                    )
                    ? 'Critical'
                    : 'Attention Required');

          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: ListView(
              children: [
                DashboardHeader(
                  headline: summary.headline,
                  businessStatus: businessStatus,
                ),
                const SizedBox(height: 20),
                Text(
                  'CURRENT BUSINESS STATUS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                BusinessOverviewSection(summary: summary),
                const SizedBox(height: 20),
                Text(
                  'CRITICAL BOTTLENECKS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                CriticalActionsSection(actions: summary.criticalActions),
                const SizedBox(height: 20),
                Text(
                  'TASK MANAGEMENT',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TodaysTasksSection(tasks: summary.tasks.items),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TodaysMeetingsSection(
                          meetings: summary.meetings.items,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ProjectsSection(projects: summary.projects),
                      ),
                    ],
                  )
                else if (medium)
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TodaysTasksSection(
                              tasks: summary.tasks.items,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TodaysMeetingsSection(
                              meetings: summary.meetings.items,
                            ),
                          ),
                        ],
                      ),
                      ProjectsSection(projects: summary.projects),
                    ],
                  )
                else ...[
                  TodaysTasksSection(tasks: summary.tasks.items),
                  TodaysMeetingsSection(meetings: summary.meetings.items),
                  ProjectsSection(projects: summary.projects),
                ],
                const SizedBox(height: 8),
                Text(
                  'FINANCE · SALES & PIPELINE',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                FinanceCollectionSection(
                  finance: summary.finance,
                  collections: summary.collections,
                  actions: summary.criticalActions,
                ),
                const SizedBox(height: 16),
                Text(
                  'IMPROVEMENT PATHS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      summary.criticalActions.isEmpty
                          ? 'No critical bottlenecks today. Keep clearing overdue tasks and reviewing at-risk projects weekly.'
                          : 'Clear the critical items above first. Assign owners on overdue tasks, unblock at-risk projects, and close overdue CRM follow-ups.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
