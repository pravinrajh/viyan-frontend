import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/metric_card.dart';
import '../models/finance_summary.dart';
import '../providers/finance_providers.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(financeSummaryProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncBody<FinanceSummary>(
        value: async,
        loadingMessage: 'Loading finance summary...',
        onRetry: () => ref.invalidate(financeSummaryProvider),
        data: (summary) => ListView(
          children: [
            Text(
              'Finance',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 200,
                  child: MetricCard(
                    label: 'Net (income − expense)',
                    value: CurrencyFormatters.inr(summary.availableBalance),
                    tone: AppTheme.success,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: MetricCard(
                    label: 'Weekly requirement',
                    value: CurrencyFormatters.inr(summary.weeklyRequirement),
                    tone: AppTheme.danger,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: MetricCard(
                    label: 'Expected collections',
                    value: CurrencyFormatters.inr(summary.expectedCollections),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: MetricCard(
                    label: 'Payables',
                    value: CurrencyFormatters.inr(summary.payables),
                    tone: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(summary.commentary),
              ),
            ),
            if (summary.plannedPayments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Planned payments this week',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...summary.plannedPayments.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(item),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
