import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatters.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/critical_action.dart';
import '../../models/section_summaries.dart';

class FinanceCollectionSection extends StatelessWidget {
  const FinanceCollectionSection({
    super.key,
    required this.finance,
    required this.collections,
    this.actions = const [],
  });

  final DashboardFinanceSummary finance;
  final DashboardCollectionSummary collections;
  final List<CriticalAction> actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sideBySide = width >= 900;
    final recommendation = actions.isNotEmpty ? actions.first : null;

    final collectionsCard = AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Collections Overview',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.collections),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 8),
          _AmountRow(
            label: 'Pending',
            value: CurrencyFormatters.inr(collections.pending),
            color: AppTheme.warning,
          ),
          _AmountRow(
            label: 'Overdue',
            value: CurrencyFormatters.inr(collections.overdue),
            color: AppTheme.danger,
          ),
          _AmountRow(
            label: 'Expected this week',
            value: CurrencyFormatters.inr(collections.expectedThisWeek),
            color: AppTheme.success,
          ),
          const SizedBox(height: 12),
          const Text(
            'Overdue Aging',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ColoredBox(
                    color: AppTheme.warning,
                    child: SizedBox(height: 10),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ColoredBox(
                    color: AppTheme.gold,
                    child: SizedBox(height: 10),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ColoredBox(
                    color: AppTheme.danger,
                    child: SizedBox(height: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '0–30 · 31–60 · 61–90 days',
            style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
          ),
        ],
      ),
    );

    final aiCard = AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGold.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.gold, size: 18),
                SizedBox(width: 8),
                Text(
                  'AI Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation?.title ?? 'Review pending collections this week',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              recommendation?.subtitle ??
                  '${CurrencyFormatters.inr(collections.overdue)} is overdue. Ask the assistant for a recovery plan.',
              style: const TextStyle(
                color: AppTheme.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => context.go(AppRoutes.assistant),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.navy,
              ),
              child: const Text('Take Action'),
            ),
            if (actions.length > 1) ...[
              const SizedBox(height: 14),
              const Text(
                'Other recommendations',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(height: 8),
              ...actions
                  .skip(1)
                  .take(3)
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              action.title,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );

    final snapshot = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Business Snapshot'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = width >= 1100
                ? 3
                : width >= 700
                ? 2
                : 1;
            const gap = 12.0;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            final items = [
              MetricCard(
                label: 'Cash Position',
                value: CurrencyFormatters.inr(finance.availableBalance),
                caption: 'Available balance',
                tone: AppTheme.success,
                icon: Icons.account_balance_wallet_outlined,
              ),
              MetricCard(
                label: 'Weekly Requirement',
                value: CurrencyFormatters.inr(finance.weeklyRequirement),
                caption: 'Cash needed this week',
                tone: AppTheme.warning,
                icon: Icons.savings_outlined,
              ),
              MetricCard(
                label: 'Planned Payments',
                value: CurrencyFormatters.inr(finance.plannedPayments),
                caption: 'Committed outflows',
                icon: Icons.receipt_long_outlined,
              ),
              MetricCard(
                label: 'Collections',
                value: CurrencyFormatters.inr(collections.pending),
                caption:
                    '${CurrencyFormatters.inr(collections.overdue)} overdue',
                tone: AppTheme.warning,
                icon: Icons.payments_outlined,
              ),
              MetricCard(
                label: 'Expected Collections',
                value: CurrencyFormatters.inr(collections.expectedThisWeek),
                caption: 'This week',
                tone: AppTheme.info,
                icon: Icons.schedule_outlined,
              ),
            ];
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final item in items)
                  SizedBox(width: cardWidth, child: item),
              ],
            );
          },
        ),
      ],
    );

    if (sideBySide) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: collectionsCard),
              const SizedBox(width: 16),
              Expanded(child: aiCard),
            ],
          ),
          const SizedBox(height: 16),
          snapshot,
        ],
      );
    }

    return Column(children: [collectionsCard, aiCard, snapshot]);
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.mutedText, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
