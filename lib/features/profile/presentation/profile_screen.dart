import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/providers/auth_providers.dart';
import '../../settings/theme_mode_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _seedIfNeeded() {
    if (_seeded) return;
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return;
    _name.text = user.name;
    _phone.text = user.phone ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(authProvider.notifier)
          .updateProfile(name: _name.text, phone: _phone.text);
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.message != null && auth.status.name == 'error') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(auth.message!)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved to MongoDB.')),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _seedIfNeeded();
    final session = ref.watch(sessionProvider);
    final user = session?.user;
    final themeMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Updates persist via PATCH /api/v1/auth/me. Role and organization '
          'cannot be changed here.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: 'Email cannot be changed from the app',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    helperText: '10-digit Indian mobile',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: RoleCapabilities.displayLabel(user?.role),
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    helperText: 'Assigned by MD/ADMIN only',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Save profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Bespoke Obsidian'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref
                  .read(themeModeProvider.notifier)
                  .setMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Organization: single-tenant deployment. Company registration and '
          'cross-company isolation are deferred to a later phase.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
