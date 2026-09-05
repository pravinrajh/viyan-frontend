import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatters.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../dashboard/models/dashboard_summary.dart';

/// Responsive KPI strip for the Reports dashboard — every figure is read
/// straight off the live [DashboardSummary] already fetched for the app,
/// never invented for the report view.
class ReportKpiGrid extends StatelessWidget {
  const ReportKpiGrid({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tasks = summary.tasks;
    final completionRate = tasks.total == 0
        ? 0
        : ((tasks.completed / tasks.total) * 100).round();

    final items = <MetricCard>[
      MetricCard(
        label: 'Task Completion',
        value: '$completionRate%',
        caption: '${tasks.completed} of ${tasks.total} tasks done',
        tone: completionRate >= 70 ? AppTheme.success : AppTheme.warning,
        icon: Icons.task_alt_outlined,
      ),
      MetricCard(
        label: 'Overdue Tasks',
        value: '${tasks.overdue}',
        caption: tasks.overdue == 0 ? 'Nothing overdue' : 'Needs attention',
        tone: tasks.overdue > 0 ? AppTheme.danger : AppTheme.success,
        icon: Icons.watch_later_outlined,
      ),
      MetricCard(
        label: 'Active Projects',
        value: '${summary.projects.active}',
        caption: '${summary.projects.atRisk} at risk',
        tone: summary.projects.atRisk > 0 ? AppTheme.warning : AppTheme.info,
        icon: Icons.account_tree_outlined,
      ),
      MetricCard(
        label: 'Sales Pipeline',
        value: CurrencyFormatters.inr(summary.sales.pipelineValue),
        caption: '${summary.sales.newLeads} new leads',
        tone: AppTheme.info,
        icon: Icons.trending_up_outlined,
      ),
      MetricCard(
        label: 'Weekly Cash Need',
        value: CurrencyFormatters.inr(summary.finance.weeklyRequirement),
        caption:
            'Balance ${CurrencyFormatters.inr(summary.finance.availableBalance)}',
        tone:
            summary.finance.availableBalance >= summary.finance.weeklyRequirement
            ? AppTheme.success
            : AppTheme.danger,
        icon: Icons.account_balance_wallet_outlined,
      ),
      MetricCard(
        label: 'Collections Pending',
        value: CurrencyFormatters.inr(summary.collections.pending),
        caption:
            '${CurrencyFormatters.inr(summary.collections.overdue)} overdue',
        tone: summary.collections.overdue > 0
            ? AppTheme.danger
            : AppTheme.warning,
        icon: Icons.payments_outlined,
      ),
      MetricCard(
        label: 'Meetings Today',
        value: '${summary.meetings.today}',
        caption: '${summary.meetings.upcoming} upcoming',
        tone: AppTheme.info,
        icon: Icons.event_outlined,
      ),
      MetricCard(
        label: 'Attention Items',
        value: '${summary.criticalActions.length}',
        caption: summary.criticalActions.isEmpty
            ? 'All clear today'
            : 'Open alerts',
        tone: summary.criticalActions.isEmpty
            ? AppTheme.success
            : AppTheme.warning,
        icon: Icons.notifications_active_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180
            ? 4
            : width >= 760
            ? 3
            : width >= 460
            ? 2
            : 1;
        const gap = 12.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items) SizedBox(width: cardWidth, child: item),
          ],
        );
      },
    );
  }
}
