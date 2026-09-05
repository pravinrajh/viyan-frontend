
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/reminder.dart';
import '../providers/reminder_providers.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Color _color(ReminderStatus status) => switch (status) {
        ReminderStatus.completed => AppTheme.success,
        ReminderStatus.cancelled || ReminderStatus.failed => AppTheme.danger,
        ReminderStatus.triggered || ReminderStatus.processing => AppTheme.warning,
        ReminderStatus.scheduled => AppTheme.info,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibleRemindersProvider);
    final canManage = ref.watch(canManageRemindersProvider);
    final scope = ref.watch(reminderScopeProvider);

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New reminder'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reminders',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final value in ReminderListScope.values)
                  FilterChip(
                    label: Text(value.name),
                    selected: scope == value,
                    onSelected: (_) => ref
                        .read(reminderScopeProvider.notifier)
                        .setScope(value),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search reminders',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(reminderSearchProvider.notifier).setQuery(v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncBody<List<Reminder>>(
                value: async,
                emptyMessage: 'No reminders found.',
                emptyIcon: Icons.alarm_outlined,
                loadingMessage: 'Loading reminders...',
                isEmpty: (items) => items.isEmpty,
                onRetry: () => ref.read(remindersProvider.notifier).refresh(),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(remindersProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final reminder = items[index];
                      return AppSurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            reminder.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            DateFormatters.dateTime(reminder.scheduledAt),
                          ),
                          trailing: StatusChip(
                            label: reminder.status.label,
                            color: _color(reminder.status),
                          ),
                          onTap: canManage
                              ? () => _detail(context, ref, reminder)
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
    var scheduledAt = DateTime.now().add(const Duration(hours: 1));

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create reminder'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormatters.dateTime(scheduledAt)),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: scheduledAt,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 1)),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (time == null) return;
                    setState(() {
                      scheduledAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
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
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required.')),
      );
      return;
    }
    try {
      await ref.read(remindersProvider.notifier).createReminder(
            CreateReminderInput(
              title: title.text,
              description: description.text,
              scheduledAt: scheduledAt,
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
    Reminder reminder,
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
              reminder.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(DateFormatters.dateTime(reminder.scheduledAt)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(remindersProvider.notifier)
                      .complete(reminder.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Complete'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref.read(remindersProvider.notifier).snooze(
                        reminder.id,
                        DateTime.now().add(const Duration(hours: 1)),
                      );
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Snooze 1 hour'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(remindersProvider.notifier)
                      .cancel(reminder.id);
                  if (context.mounted) Navigator.pop(context);
                } on AppException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Cancel reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
