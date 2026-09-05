import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/app_user.dart';
import '../providers/user_providers.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionProvider)?.user.role;
    final canManage = RoleCapabilities.can(role, AppCapability.manageUsers);
    final async = ref.watch(usersProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Users',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canManage)
                FilledButton.icon(
                  onPressed: () => _showCreateUser(context, ref),
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Create user'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Roles: MD, ADMIN, MANAGER (Department Head), EMPLOYEE. '
            'Single-organization deployment — multi-company isolation is not in this phase.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search name or email',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: (value) {
              ref.read(userSearchProvider.notifier).setQuery(value);
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncBody<List<AppUser>>(
              value: async,
              emptyMessage: 'No users found.',
              loadingMessage: 'Loading users...',
              isEmpty: (items) => items.isEmpty,
              onRetry: () => ref.read(usersProvider.notifier).refresh(),
              data: (users) => ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(
                        '${user.email} · ${RoleCapabilities.displayLabel(user.role)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusChip(
                            label: user.status,
                            color: user.isActive
                                ? const Color(0xFF16845B)
                                : const Color(0xFFC83E4D),
                          ),
                          if (canManage) ...[
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                try {
                                  if (value == 'deactivate') {
                                    await ref
                                        .read(usersProvider.notifier)
                                        .deactivate(user.id);
                                  } else {
                                    await ref
                                        .read(usersProvider.notifier)
                                        .setStatus(user.id, value);
                                  }
                                } on AppException catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message)),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'ACTIVE',
                                  child: Text('Activate'),
                                ),
                                const PopupMenuItem(
                                  value: 'INACTIVE',
                                  child: Text('Deactivate status'),
                                ),
                                const PopupMenuItem(
                                  value: 'deactivate',
                                  child: Text('Soft deactivate'),
                                ),
                              ],
                            ),
                          ],
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

  Future<void> _showCreateUser(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController();
    var role = 'EMPLOYEE';

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create user'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (10-digit)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Temporary password',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'EMPLOYEE', child: Text('Employee')),
                          DropdownMenuItem(
                            value: 'MANAGER',
                            child: Text('Department Head (MANAGER)'),
                          ),
                          DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                          DropdownMenuItem(value: 'MD', child: Text('MD')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => role = value);
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
            );
          },
        );
      },
    );

    if (created != true || !context.mounted) return;
    try {
      await ref
          .read(usersProvider.notifier)
          .createUser(
            CreateUserInput(
              name: name.text,
              email: email.text,
              phone: phone.text,
              password: password.text,
              role: role,
            ),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User created in MongoDB.')));
    } on AppException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      name.dispose();
      email.dispose();
      phone.dispose();
      password.dispose();
    }
  }
}
