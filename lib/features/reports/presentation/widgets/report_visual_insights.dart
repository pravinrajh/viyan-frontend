import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatters.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/donut_chart.dart';
import '../../../../shared/widgets/metric_bar_chart.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../dashboard/models/dashboard_summary.dart';

/// Chart section of the Reports dashboard — task/project health as donuts,
/// finance and sales pipeline as bar comparisons. All values come straight
/// off the live [DashboardSummary].
class ReportVisualInsights extends StatelessWidget {
  const ReportVisualInsights({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final taskStatusChart = _ChartCard(
      title: 'Task Status',
      child: DonutChart(
        centerLabel: 'tasks',
        segments: [
          DonutSegment(
            label: 'Pending',
            value: summary.tasks.pending.toDouble(),
            color: AppTheme.warning,
          ),
          DonutSegment(
            label: 'In Progress',
            value: summary.tasks.inProgress.toDouble(),
            color: AppTheme.info,
          ),
          DonutSegment(
            label: 'Completed',
            value: summary.tasks.completed.toDouble(),
            color: AppTheme.success,
          ),
          DonutSegment(
            label: 'Overdue',
            value: summary.tasks.overdue.toDouble(),
            color: AppTheme.danger,
          ),
        ],
      ),
    );

    final projectHealthChart = _ChartCard(
      title: 'Project Health',
      child: DonutChart(
        centerLabel: 'projects',
        segments: [
          DonutSegment(
            label: 'Active',
            value: summary.projects.active.toDouble(),
            color: AppTheme.info,
          ),
          DonutSegment(
            label: 'Completed',
            value: summary.projects.completed.toDouble(),
            color: AppTheme.success,
          ),
          DonutSegment(
            label: 'At Risk',
            value: summary.projects.atRisk.toDouble(),
            color: AppTheme.danger,
          ),
        ],
      ),
    );

    final cashChart = _ChartCard(
      title: 'Cash Snapshot',
      child: MetricBarChart(
        valueFormatter: CurrencyFormatters.inr,
        bars: [
          BarDatum(
            label: 'Balance',
            value: summary.finance.availableBalance,
            color: AppTheme.success,
          ),
          BarDatum(
            label: 'Weekly Need',
            value: summary.finance.weeklyRequirement,
            color: AppTheme.warning,
          ),
          BarDatum(
            label: 'Planned',
            value: summary.finance.plannedPayments,
            color: AppTheme.navy,
          ),
        ],
      ),
    );

    final salesFunnelChart = _ChartCard(
      title: 'Sales Funnel',
      child: MetricBarChart(
        valueFormatter: (v) => v.toStringAsFixed(0),
        bars: [
          BarDatum(
            label: 'New',
            value: summary.sales.newLeads.toDouble(),
            color: AppTheme.gold,
          ),
          BarDatum(
            label: 'Qualified',
            value: summary.sales.qualifiedLeads.toDouble(),
            color: AppTheme.info,
          ),
          BarDatum(
            label: 'Converted',
            value: summary.sales.converted.toDouble(),
            color: AppTheme.success,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 860;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPERATIONAL HEALTH',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            _ChartPair(
              sideBySide: sideBySide,
              left: taskStatusChart,
              right: projectHealthChart,
            ),
            const SizedBox(height: 20),
            Text(
              'FINANCIAL & SALES',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            _ChartPair(
              sideBySide: sideBySide,
              left: cashChart,
              right: salesFunnelChart,
            ),
          ],
        );
      },
    );
  }
}

/// Lays two chart cards side by side on wide screens, stacked on narrow ones.
class _ChartPair extends StatelessWidget {
  const _ChartPair({
    required this.sideBySide,
    required this.left,
    required this.right,
  });

  final bool sideBySide;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (sideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
    }
    return Column(children: [left, const SizedBox(height: 16), right]);
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
