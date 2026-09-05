import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/auth/role_capabilities.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/project_summary.dart';
import '../providers/project_providers.dart';
import '../repositories/project_repository.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  static const _types = [
    ('RESIDENTIAL', 'Real Estate'),
    ('COMMERCIAL', 'Commercial / Construction'),
    ('INFRASTRUCTURE', 'Infrastructure'),
    ('LAND_DEVELOPMENT', 'Land'),
    ('INTERNAL', 'Interior / Internal'),
    ('OTHER', 'Other'),
  ];

  static const _statuses = [
    'PLANNING',
    'ACTIVE',
    'ON_HOLD',
    'COMPLETED',
    'CANCELLED',
    'AT_RISK',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectsProvider);
    final role = ref.watch(sessionProvider)?.user.role ?? '';
    final scoped = role == 'EMPLOYEE' || role == 'MANAGER';
    final canCreate = RoleCapabilities.can(role, AppCapability.createProjects);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Projects',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canCreate)
                FilledButton.icon(
                  onPressed: () => _createProject(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New project'),
                ),
            ],
          ),
          Text(
            scoped
                ? 'Showing projects where you are manager or member.'
                : 'Organization projects (MD/ADMIN see all).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncBody<List<ProjectSummary>>(
              value: async,
              emptyMessage: scoped
                  ? 'No projects are assigned to your account yet.'
                  : 'No projects found.',
              emptyIcon: Icons.account_tree_outlined,
              loadingMessage: 'Loading projects...',
              isEmpty: (projects) => projects.isEmpty,
              onRetry: () => ref.read(projectsProvider.notifier).refresh(),
              data: (projects) => ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final riskColor = switch (project.risk) {
                    'high' => AppTheme.danger,
                    'medium' => AppTheme.warning,
                    _ => AppTheme.success,
                  };
                  final subtitle = [
                    _typeLabel(project.type),
                    if (project.location.isNotEmpty) project.location,
                    if (project.customerName.isNotEmpty) project.customerName,
                  ].join(' · ');
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              StatusChip(
                                label: _label(project.status),
                                color: riskColor,
                              ),
                              if (canCreate)
                                PopupMenuButton<String>(
                                  onSelected: (status) async {
                                    try {
                                      await ref
                                          .read(projectsProvider.notifier)
                                          .updateStatus(project.id, status);
                                    } on AppException catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error.message)),
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => _statuses
                                      .map(
                                        (s) => PopupMenuItem(
                                          value: s,
                                          child: Text(_label(s)),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (subtitle.isNotEmpty) Text(subtitle),
                          Text(
                            [
                              if (project.owner.isNotEmpty)
                                'PM: ${project.owner}',
                              'due ${DateFormatters.date(project.dueDate)}',
                            ].join(' · '),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Budget ${CurrencyFormatters.inr(project.budget)} · Spent ${CurrencyFormatters.inr(project.actualExpense)}',
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: project.progressFraction,
                            color: project.risk == 'high'
                                ? AppTheme.warning
                                : AppTheme.navy,
                            backgroundColor: AppTheme.navy.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${project.progressPercent}% complete'),
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

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final location = TextEditingController();
    final budget = TextEditingController();
    var type = 'RESIDENTIAL';
    String? managerId;
    final assignees =
        ref.read(taskAssigneesProvider).asData?.value ?? const <TaskAssignee>[];

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create project'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Type (API value)',
                        ),
                        items: _types
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.$1,
                                child: Text('${t.$2} (${t.$1})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: managerId,
                        decoration: const InputDecoration(
                          labelText: 'Project manager (employee)',
                        ),
                        items: assignees
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => managerId = value),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: location,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: budget,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget (INR whole rupees)',
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
    if (managerId == null || managerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a project manager.')),
      );
      return;
    }
    try {
      await ref
          .read(projectsProvider.notifier)
          .createProject(
            CreateProjectInput(
              name: name.text,
              projectType: type,
              managerId: managerId!,
              location: location.text,
              budget: double.tryParse(budget.text.trim()) ?? 0,
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project created in MongoDB.')),
      );
    } on AppException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      name.dispose();
      location.dispose();
      budget.dispose();
    }
  }
}

String _typeLabel(String value) {
  for (final entry in ProjectsScreen._types) {
    if (entry.$1 == value) return entry.$2;
  }
  return _label(value);
}

String _label(String value) {
  if (value.isEmpty) return value;
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}
