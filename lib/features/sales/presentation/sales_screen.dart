import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/auth/role_capabilities.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/sales_summary.dart';
import '../providers/sales_providers.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  static const _sources = [
    'WEBSITE',
    'REFERRAL',
    'PHONE',
    'EMAIL',
    'SOCIAL_MEDIA',
    'ADVERTISEMENT',
    'EVENT',
    'DIRECT',
    'OTHER',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(salesSummaryProvider);
    final role = ref.watch(sessionProvider)?.user.role;
    final canCreate = RoleCapabilities.can(role, AppCapability.createLeads);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncBody<SalesSummary>(
        value: async,
        loadingMessage: 'Loading sales pipeline...',
        onRetry: () => ref.read(salesSummaryProvider.notifier).refresh(),
        data: (summary) => ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sales / CRM',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (canCreate)
                  FilledButton.icon(
                    onPressed: () => _createLead(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New lead'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(summary.commentary),
            const SizedBox(height: 8),
            Text(
              'Lead conversion creates Customer + Opportunity only — not a Project.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: MetricCard(
                    label: 'Pipeline',
                    value: CurrencyFormatters.inr(summary.pipelineValue),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: MetricCard(
                    label: 'New leads',
                    value: '${summary.newLeads}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: MetricCard(
                    label: 'Converted',
                    value: '${summary.conversions}',
                    tone: AppTheme.success,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: MetricCard(
                    label: 'MTD',
                    value: CurrencyFormatters.inr(summary.monthToDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Pipeline leads',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...summary.leads.map(
              (lead) => Card(
                child: ListTile(
                  title: Text(lead.name),
                  subtitle: Text(
                    '${lead.source} · ${CurrencyFormatters.inr(lead.estimatedValue)} · follow-up ${DateFormatters.date(lead.followUpDate)}',
                  ),
                  trailing: StatusChip(
                    label: lead.status.label,
                    color: AppTheme.navy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createLead(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final company = TextEditingController();
    final phone = TextEditingController();
    final value = TextEditingController();
    var source = 'REFERRAL';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create lead'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Lead name',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: company,
                        decoration: const InputDecoration(
                          labelText: 'Company name (optional)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: source,
                        decoration: const InputDecoration(labelText: 'Source'),
                        items: _sources
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => source = v);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: value,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estimated value (INR)',
                        ),
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
            );
          },
        );
      },
    );

    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(salesSummaryProvider.notifier)
          .createLead(
            name: name.text,
            source: source,
            companyName: company.text,
            phone: phone.text,
            estimatedValue: double.tryParse(value.text.trim()),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead created in MongoDB.')),
      );
    } on AppException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      name.dispose();
      company.dispose();
      phone.dispose();
      value.dispose();
    }
  }
}
