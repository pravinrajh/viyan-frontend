import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatters.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../models/dashboard_summary.dart';

class BusinessOverviewSection extends StatelessWidget {
  const BusinessOverviewSection({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cards = <_Kpi>[
      _Kpi(
        label: 'Total Tasks',
        value: '${summary.tasks.total}',
        caption: '${summary.tasks.overdue} Overdue',
        tone: summary.tasks.overdue > 0 ? AppTheme.danger : AppTheme.info,
        icon: Icons.checklist_outlined,
      ),
      _Kpi(
        label: "Today's Meetings",
        value: '${summary.meetings.today}',
        caption: '${summary.meetings.upcoming} Upcoming',
        tone: AppTheme.info,
        icon: Icons.event_outlined,
      ),
      _Kpi(
        label: 'Pending Collections',
        value: CurrencyFormatters.inr(summary.collections.pending),
        caption:
            '${CurrencyFormatters.inr(summary.collections.overdue)} Overdue',
        tone: AppTheme.warning,
        icon: Icons.payments_outlined,
      ),
      _Kpi(
        label: 'Active Projects',
        value: '${summary.projects.active}',
        caption: '${summary.projects.atRisk} At Risk',
        tone: summary.projects.atRisk > 0 ? AppTheme.danger : AppTheme.success,
        icon: Icons.account_tree_outlined,
      ),
      _Kpi(
        label: 'Sales Pipeline',
        value: CurrencyFormatters.inr(summary.sales.pipelineValue),
        caption: '${summary.sales.converted} Deals Won',
        tone: AppTheme.info,
        icon: Icons.trending_up_outlined,
      ),
    ];

    final columns = width >= 1200
        ? 5
        : width >= 900
        ? 3
        : width >= 600
        ? 2
        : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                child: MetricCard(
                  label: card.label,
                  value: card.value,
                  caption: card.caption,
                  tone: card.tone,
                  icon: card.icon,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Kpi {
  const _Kpi({
    required this.label,
    required this.value,
    required this.caption,
    required this.tone,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final Color tone;
  final IconData icon;
}
