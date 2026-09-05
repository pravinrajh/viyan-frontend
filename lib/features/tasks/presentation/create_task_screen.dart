import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../projects/providers/project_providers.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _assignedToId;
  String? _projectId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskPriority _priority = TaskPriority.medium;
  bool _saving = false;
  bool _accessChecked = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final assignees =
          ref.read(taskAssigneesProvider).asData?.value ?? const [];
      final assignee = assignees.where((item) => item.id == _assignedToId);
      await ref
          .read(tasksProvider.notifier)
          .createTask(
            CreateTaskInput(
              title: _title.text.trim(),
              description: _description.text.trim(),
              owner: assignee.isEmpty ? '' : assignee.first.name,
              assignedToId: _assignedToId,
              projectId: _projectId,
              dueDate: _dueDate,
              priority: _priority,
            ),
          );
      if (mounted) context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(canCreateTasksProvider);
    if (!_accessChecked) {
      _accessChecked = true;
      if (!canCreate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You don't have permission to create tasks."),
            ),
          );
          context.pop();
        });
      }
    }

    if (!canCreate) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final assignees = ref.watch(taskAssigneesProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 12),
            assignees.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                'Unable to load employees. ${error.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Text(
                    'No active employees found. MD, ADMIN, or MANAGER can create tasks.',
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: items.any((item) => item.id == _assignedToId)
                      ? _assignedToId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Assigned employee',
                  ),
                  items: [
                    for (final item in items)
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          item.employeeCode.isEmpty
                              ? item.name
                              : '${item.name} (${item.employeeCode})',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _assignedToId = value),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            projects.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  initialValue: items.any((item) => item.id == _projectId)
                      ? _projectId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Project (optional)',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No project'),
                    ),
                    for (final item in items)
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                  ],
                  onChanged: (value) => setState(
                    () => _projectId = (value == null || value.isEmpty)
                        ? null
                        : value,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                for (final priority in TaskPriority.values)
                  DropdownMenuItem(
                    value: priority,
                    child: Text(priority.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Create task'),
            ),
          ],
        ),
      ),
    );
  }
}
