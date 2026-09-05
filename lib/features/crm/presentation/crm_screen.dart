import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/async_body.dart';
import '../models/crm_overview.dart';
import '../providers/crm_providers.dart';

class CrmScreen extends ConsumerWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(crmOverviewProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncBody<CrmOverview>(
        value: async,
        onRetry: () => ref.invalidate(crmOverviewProvider),
        data: (overview) => ListView(
          children: [
            Text(
              'CRM',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(overview.message),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
