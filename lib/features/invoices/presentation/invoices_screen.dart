
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/invoice.dart';
import '../providers/invoice_providers.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  Color _color(InvoiceStatus status) => switch (status) {
        InvoiceStatus.paid => AppTheme.success,
        InvoiceStatus.overdue => AppTheme.danger,
        InvoiceStatus.partiallyPaid => AppTheme.warning,
        InvoiceStatus.cancelled => AppTheme.mutedText,
        InvoiceStatus.issued => AppTheme.info,
        InvoiceStatus.draft => AppTheme.info,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleInvoicesProvider);
    final canManage = ref.watch(canManageInvoicesProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New invoice'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Invoices',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search invoices',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(invoiceSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<Invoice>>(
                value: async,
                emptyMessage: 'No invoices found.',
                emptyIcon: Icons.receipt_long_outlined,
                loadingMessage: 'Loading invoices...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () => ref.read(invoicesProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(invoicesProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final invoice = items[index];
                      final title = invoice.invoiceNumber.isNotEmpty
                          ? invoice.invoiceNumber
                          : invoice.invoiceId;
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${CurrencyFormatters.inr(invoice.amount)} · '
                            'paid ${CurrencyFormatters.inr(invoice.paidAmount)} · '
                            'bal ${CurrencyFormatters.inr(invoice.balance)}'
                            '${invoice.dueDate != null ? ' · due ${DateFormatters.date(invoice.dueDate!)}' : ''}',
                          ),
                          trailing: StatusChip(
                            label: invoice.status.label,
                            color: _color(invoice.status),
                          ),
                          onTap: canManage
                              ? () => _detail(context, ref, invoice)
                              : null,
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
    final customers = await ref
        .read(invoiceCustomersProvider.future)
        .catchError((_) => const <InvoiceCustomerOption>[]);
    if (!context.mounted) return;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? customerId = customers.isNotEmpty ? customers.first.id : null;
    DateTime? dueDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create invoice'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (customers.isEmpty)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Customer id',
                      ),
                      onChanged: (v) => customerId = v.trim(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: customerId,
                      decoration:
                          const InputDecoration(labelText: 'Customer'),
                      items: [
                        for (final c in customers)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name.isEmpty ? c.id : c.name),
                          ),
                      ],
                      onChanged: (v) => setState(() => customerId = v),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (INR)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      dueDate == null
                          ? 'Due date (optional)'
                          : 'Due ${DateFormatters.date(dueDate!)}',
                    ),
                    trailing: const Icon(Icons.event),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 1)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setState(() => dueDate = picked);
                    },
                  ),
                ],
              ),
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
    final amount = int.tryParse(amountCtrl.text.trim());
    if (customerId == null || customerId!.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer and amount are required.')),
      );
      return;
    }
    try {
      await ref.read(invoicesProvider.notifier).createInvoice(
            CreateInvoiceInput(
              customerId: customerId!,
              amount: amount,
              description: descCtrl.text,
              dueDate: dueDate,
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
    Invoice invoice,
  ) async {
    final amountCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              invoice.invoiceNumber.isNotEmpty
                  ? invoice.invoiceNumber
                  : invoice.invoiceId,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount ${CurrencyFormatters.inr(invoice.amount)} · '
              'Balance ${CurrencyFormatters.inr(invoice.balance)}',
            ),
            if (invoice.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(invoice.description),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Payment amount'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) return;
                try {
                  await ref.read(invoicesProvider.notifier).recordPayment(
                        invoice.id,
                        RecordInvoicePaymentInput(amount: amount),
                      );
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Record payment'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref.read(invoicesProvider.notifier).updateInvoice(
                        invoice.id,
                        const UpdateInvoiceInput(cancel: true),
                      );
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Cancel invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
