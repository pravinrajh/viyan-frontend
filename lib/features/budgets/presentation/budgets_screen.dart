
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/budget.dart';
import '../providers/budget_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  Color _color(BudgetStatus status) => switch (status) {
        BudgetStatus.active => AppTheme.success,
        BudgetStatus.closed => AppTheme.info,
        BudgetStatus.cancelled => AppTheme.mutedText,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleBudgetsProvider);
    final canManage = ref.watch(canManageBudgetsProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New budget'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Budgets',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search budgets',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(budgetSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<Budget>>(
                value: async,
                emptyMessage: 'No budgets found.',
                emptyIcon: Icons.account_balance_wallet_outlined,
                loadingMessage: 'Loading budgets...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () => ref.read(budgetsProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(budgetsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final budget = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            budget.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${CurrencyFormatters.inr(budget.amount)} · '
                            '${DateFormatters.date(budget.periodStart)} – '
                            '${DateFormatters.date(budget.periodEnd)}',
                          ),
                          trailing: StatusChip(
                            label: budget.status.label,
                            color: _color(budget.status),
                          ),
                          onTap: () => _detail(context, ref, budget),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var start = DateTime.now();
    var end = DateTime.now().add(const Duration(days: 30));

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create budget'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (INR)'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Start ${DateFormatters.date(start)}'),
                  trailing: const Icon(Icons.event),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => start = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('End ${DateFormatters.date(end)}'),
                  trailing: const Icon(Icons.event),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: end,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => end = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final parsed = int.tryParse(amount.text.trim());
    if (name.text.trim().isEmpty || parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and amount are required.')),
      );
      return;
    }
    try {
      await ref.read(budgetsProvider.notifier).createBudget(
            CreateBudgetInput(
              name: name.text,
              amount: parsed,
              periodStart: start,
              periodEnd: end,
            ),
          );
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _detail(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final summaryAsync = ref.read(budgetSummaryProvider(budget.id).future);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => FutureBuilder<BudgetSummary>(
        future: summaryAsync,
        builder: (context, snapshot) {
          final summary = snapshot.data;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  budget.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('Budget ${CurrencyFormatters.inr(budget.amount)}'),
                if (summary?.actual != null)
                  Text('Actual ${CurrencyFormatters.inr(summary!.actual!)}'),
                if (summary?.variance != null)
                  Text(
                    'Variance ${CurrencyFormatters.inr(summary!.variance!)}',
                  ),
                const SizedBox(height: 16),
                if (ref.read(canManageBudgetsProvider))
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(budgetsProvider.notifier)
                            .deleteBudget(budget.id);
                        if (context.mounted) Navigator.pop(context);
                      } on AppException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    },
                    child: const Text('Delete budget'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
