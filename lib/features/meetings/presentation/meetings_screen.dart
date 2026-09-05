import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_providers.dart';
import '../../projects/providers/project_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/meeting.dart';
import '../providers/meeting_providers.dart';
import '../repositories/meeting_repository.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meetingsProvider);
    final role = ref.watch(sessionProvider)?.user.role;
    final canCreate = RoleCapabilities.can(role, AppCapability.createMeetings);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meetings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canCreate)
                FilledButton.icon(
                  onPressed: () => _createMeeting(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Schedule'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncBody<List<Meeting>>(
              value: async,
              emptyMessage: 'No meetings scheduled',
              emptyIcon: Icons.event_outlined,
              onRetry: () => ref.read(meetingsProvider.notifier).refresh(),
              data: (meetings) => ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return Card(
                    child: ListTile(
                      title: Text(meeting.title),
                      subtitle: Text(
                        '${DateFormatters.time(meeting.startAt)}–${DateFormatters.time(meeting.endAt)} · ${meeting.location}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusChip(
                            label: meeting.status,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          if (canCreate)
                            PopupMenuButton<String>(
                              onSelected: (status) async {
                                try {
                                  await ref
                                      .read(meetingsProvider.notifier)
                                      .updateStatus(meeting.id, status);
                                } on AppException catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message)),
                                  );
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'COMPLETED',
                                  child: Text('Mark completed'),
                                ),
                                PopupMenuItem(
                                  value: 'CANCELLED',
                                  child: Text('Cancel'),
                                ),
                                PopupMenuItem(
                                  value: 'IN_PROGRESS',
                                  child: Text('In progress'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createMeeting(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final location = TextEditingController();
    var start = DateTime.now().add(const Duration(hours: 1));
    start = DateTime(start.year, start.month, start.day, start.hour, 0);
    var end = start.add(const Duration(hours: 1));
    String? projectId;
    final projects =
        ref.read(projectsProvider).asData?.value ?? const [];
    final assignees =
        ref.read(taskAssigneesProvider).asData?.value ?? const [];
    final selected = <String>{};

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Schedule meeting'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: location,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Start ${DateFormatters.weekdayDate(start)} ${DateFormatters.time(start)}',
                        ),
                        trailing: const Icon(Icons.schedule),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: start,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date == null || !context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(start),
                          );
                          if (time == null) return;
                          setState(() {
                            start = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            end = start.add(const Duration(hours: 1));
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: projectId ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Project (optional)',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('None'),
                          ),
                          ...projects.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => projectId = (value == null || value.isEmpty)
                              ? null
                              : value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Participants',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      ...assignees.take(8).map(
                        (e) => CheckboxListTile(
                          dense: true,
                          value: selected.contains(e.id),
                          title: Text(e.name),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selected.add(e.id);
                              } else {
                                selected.remove(e.id);
                              }
                            });
                          },
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
          .read(meetingsProvider.notifier)
          .createMeeting(
            CreateMeetingInput(
              title: title.text,
              startAt: start,
              endAt: end,
              location: location.text,
              projectId: projectId,
              participantIds: selected.toList(),
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting created in MongoDB.')),
      );
    } on AppException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      title.dispose();
      location.dispose();
    }
  }
}
