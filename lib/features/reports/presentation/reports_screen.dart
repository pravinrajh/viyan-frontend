import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../dashboard/models/dashboard_summary.dart';
import '../../dashboard/presentation/widgets/critical_actions_section.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/report_providers.dart';
import 'widgets/report_brief_card.dart';
import 'widgets/report_kpi_grid.dart';
import 'widgets/report_visual_insights.dart';

/// Executive Reports dashboard. Every KPI and chart is sourced from the
/// same live [DashboardSummary] the Command Center already fetches — no
/// separate reporting API, no invented numbers.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 900 ? 28.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
      child: AsyncBody<DashboardSummary>(
        value: async,
        emptyMessage: 'No business data available yet.',
        loadingMessage: 'Preparing your executive report...',
        isEmpty: (summary) => summary.isEmpty,
        onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardProvider.notifier).refresh();
            ref.invalidate(dailyReportProvider);
          },
          child: ListView(
            children: [
              _ReportHeader(
                onRefresh: () {
                  ref.read(dashboardProvider.notifier).refresh();
                  ref.invalidate(dailyReportProvider);
                },
              ),
              const SizedBox(height: 16),
              const ReportBriefCard(),
              const SizedBox(height: 20),
              Text(
                'BUSINESS AT A GLANCE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              ReportKpiGrid(summary: summary),
              const SizedBox(height: 24),
              ReportVisualInsights(summary: summary),
              const SizedBox(height: 20),
              Text(
                'ATTENTION NEEDED',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              CriticalActionsSection(actions: summary.criticalActions),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'As of ${DateFormatters.dateTime(DateTime.now())} · live business data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh report',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
