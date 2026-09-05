
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/sales_activity.dart';
import '../providers/sales_activity_providers.dart';

class SalesActivitiesScreen extends ConsumerWidget {
  const SalesActivitiesScreen({super.key});

  Color _statusColor(SalesActivityStatus status) => switch (status) {
        SalesActivityStatus.completed => AppTheme.success,
        SalesActivityStatus.cancelled => AppTheme.mutedText,
        SalesActivityStatus.pending => AppTheme.warning,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleSalesActivitiesProvider);
    final canManage = ref.watch(canManageSalesActivitiesProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New activity'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sales activities',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search activities',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(salesActivitySearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<SalesActivity>>(
                value: async,
                emptyMessage: 'No sales activities found.',
                emptyIcon: Icons.handshake_outlined,
                loadingMessage: 'Loading activities...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () =>
                    ref.read(salesActivitiesProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(salesActivitiesProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final activity = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            activity.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              activity.type.label,
                              if (activity.scheduledAt != null)
                                DateFormatters.date(activity.scheduledAt!),
                            ].join(' · '),
                          ),
                          trailing: StatusChip(
                            label: activity.status.label,
                            color: _statusColor(activity.status),
                          ),
                          onTap: canManage
                              ? () => _detail(context, ref, activity)
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
    final title = TextEditingController();
    final description = TextEditingController();
    var type = SalesActivityType.call;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create sales activity'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<SalesActivityType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    for (final t in SalesActivityType.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => type = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: description,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
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
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required.')),
      );
      return;
    }
    try {
      await ref.read(salesActivitiesProvider.notifier).createActivity(
            CreateSalesActivityInput(
              type: type,
              title: title.text,
              description: description.text,
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
    SalesActivity activity,
  ) async {
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
              activity.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('${activity.type.label} · ${activity.status.label}'),
            const SizedBox(height: 16),
            for (final status in SalesActivityStatus.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(salesActivitiesProvider.notifier)
                          .updateStatus(activity.id, status);
                      if (context.mounted) Navigator.pop(context);
                    } on AppException catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    }
                  },
                  child: Text('Mark ${status.label.toLowerCase()}'),
                ),
              ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(salesActivitiesProvider.notifier)
                      .deleteActivity(activity.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Delete activity'),
            ),
          ],
        ),
      ),
    );
  }
}
