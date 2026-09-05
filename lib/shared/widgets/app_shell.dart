import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/auth/role_capabilities.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/settings/theme_mode_provider.dart';

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.capability,
  });

  final String label;
  final IconData icon;
  final String path;
  final AppCapability capability;
}

class _NavGroup {
  const _NavGroup(this.title, this.items);
  final String title;
  final List<_NavItem> items;
}

const _navGroups = <_NavGroup>[
  _NavGroup('MAIN', [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      path: AppRoutes.dashboard,
      capability: AppCapability.viewDashboard,
    ),
    _NavItem(
      label: 'Viyan',
      icon: Icons.auto_awesome_outlined,
      path: AppRoutes.assistant,
      capability: AppCapability.viewAssistant,
    ),
    _NavItem(
      label: 'Tasks',
      icon: Icons.checklist_outlined,
      path: AppRoutes.tasks,
      capability: AppCapability.viewTasks,
    ),
    _NavItem(
      label: 'Projects',
      icon: Icons.account_tree_outlined,
      path: AppRoutes.projects,
      capability: AppCapability.viewProjects,
    ),
    _NavItem(
      label: 'Sales',
      icon: Icons.trending_up_outlined,
      path: AppRoutes.sales,
      capability: AppCapability.viewSales,
    ),
    _NavItem(
      label: 'Finance',
      icon: Icons.account_balance_outlined,
      path: AppRoutes.finance,
      capability: AppCapability.viewFinance,
    ),
    _NavItem(
      label: 'Meetings',
      icon: Icons.event_outlined,
      path: AppRoutes.meetings,
      capability: AppCapability.viewMeetings,
    ),
    _NavItem(
      label: 'Team',
      icon: Icons.manage_accounts_outlined,
      path: AppRoutes.users,
      capability: AppCapability.viewUsers,
    ),
    _NavItem(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      path: AppRoutes.notifications,
      capability: AppCapability.viewNotifications,
    ),
  ]),
  _NavGroup('MORE', [
    _NavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      path: AppRoutes.invoices,
      capability: AppCapability.viewInvoices,
    ),
    _NavItem(
      label: 'Vendors',
      icon: Icons.storefront_outlined,
      path: AppRoutes.vendors,
      capability: AppCapability.viewVendors,
    ),
    _NavItem(
      label: 'Land',
      icon: Icons.map_outlined,
      path: AppRoutes.land,
      capability: AppCapability.viewLand,
    ),
    _NavItem(
      label: 'MD Notes',
      icon: Icons.sticky_note_2_outlined,
      path: AppRoutes.mdNotes,
      capability: AppCapability.viewMdNotes,
    ),
    _NavItem(
      label: 'Budgets',
      icon: Icons.pie_chart_outline,
      path: AppRoutes.budgets,
      capability: AppCapability.viewBudgets,
    ),
    _NavItem(
      label: 'Reminders',
      icon: Icons.alarm_outlined,
      path: AppRoutes.reminders,
      capability: AppCapability.viewReminders,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      path: AppRoutes.profile,
      capability: AppCapability.viewProfile,
    ),
    _NavItem(
      label: 'Reports',
      icon: Icons.insights_outlined,
      path: AppRoutes.reports,
      capability: AppCapability.viewReports,
    ),
  ]),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    final session = ref.watch(sessionProvider);
    final userName = session?.user.name ?? '';
    final role = session?.user.role;
    final groups = _visibleGroups(role);

    final showFab = location != AppRoutes.assistant &&
        RoleCapabilities.forRole(role).contains(AppCapability.viewAssistant);

    if (isWide) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            _Sidebar(
              location: location,
              userName: userName,
              role: role,
              groups: groups,
              onSignOut: () => ref.read(authProvider.notifier).logout(),
            ),
            Expanded(child: child),
          ],
        ),
        floatingActionButton: showFab ? const _ViyanFab() : null,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: showFab ? const _ViyanFab() : null,
      appBar: AppBar(
        title: Text(_pageTitle(location, groups)),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: _Sidebar(
          location: location,
          userName: userName,
          role: role,
          groups: groups,
          onSignOut: () => ref.read(authProvider.notifier).logout(),
          inDrawer: true,
        ),
      ),
      body: child,
    );
  }
}

/// Persistent floating launcher for Viyan, shown on every screen except the
/// assistant screen itself so the AI is always one tap away.
class _ViyanFab extends StatelessWidget {
  const _ViyanFab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.obsidianGold : AppTheme.primary;
    return FloatingActionButton(
      heroTag: 'viyan-fab',
      tooltip: 'Ask Viyan',
      backgroundColor: accent,
      foregroundColor: Colors.white,
      onPressed: () => context.go(AppRoutes.assistant),
      child: const Icon(Icons.auto_awesome),
    );
  }
}

List<_NavGroup> _visibleGroups(String? role) {
  final caps = RoleCapabilities.forRole(role);
  bool allowed(AppCapability capability) {
    if (caps.contains(capability)) return true;
    if (capability == AppCapability.viewInvoices &&
        caps.contains(AppCapability.viewCollections)) {
      return true;
    }
    return false;
  }

  return _navGroups
      .map(
        (group) => _NavGroup(
          group.title,
          group.items
              .where((item) => allowed(item.capability))
              .toList(growable: false),
        ),
      )
      .where((group) => group.items.isNotEmpty)
      .toList(growable: false);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.userName,
    required this.role,
    required this.groups,
    required this.onSignOut,
    this.inDrawer = false,
  });

  final String location;
  final String userName;
  final String? role;
  final List<_NavGroup> groups;
  final VoidCallback onSignOut;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.obsidianSurface : AppTheme.surface;
    final accent = isDark ? AppTheme.obsidianGold : AppTheme.primary;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final muted = isDark ? Colors.white70 : AppTheme.mutedText;
    final groupLabel = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppTheme.mutedText.withValues(alpha: 0.85);

    return SafeArea(
      child: SizedBox(
        width: inDrawer ? null : 248,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            border: inDrawer
                ? null
                : Border(
                    right: BorderSide(
                      color: isDark ? AppTheme.obsidianBorder : AppTheme.border,
                    ),
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    _BrandMark(accent: accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.appSubtitle,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final group in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                        child: Text(
                          group.title,
                          style: TextStyle(
                            color: groupLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      for (final item in group.items)
                        _NavTile(
                          item: item,
                          selected: _isSelected(location, item.path),
                          accent: accent,
                          isDark: isDark,
                        ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? null
                        : Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: accent.withValues(alpha: 0.2),
                        child: Text(
                          _initials(userName),
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              RoleCapabilities.displayLabel(role),
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSignOut,
                icon: Icon(Icons.logout, color: muted, size: 18),
                label: Text(
                  'Sign out',
                  style: TextStyle(color: muted),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSelected(String location, String path) {
  if (path == AppRoutes.sales) {
    return location == AppRoutes.sales ||
        location.startsWith('${AppRoutes.sales}/');
  }
  return location == path || location.startsWith('$path/');
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.auto_awesome, color: accent, size: 18),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.accent,
    required this.isDark,
  });

  final _NavItem item;
  final bool selected;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final idle = isDark ? Colors.white70 : AppTheme.mutedText;
    final label = isDark
        ? (selected ? accent : Colors.white)
        : (selected ? accent : AppTheme.ink);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).maybePop();
            context.go(item.path);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border(left: BorderSide(color: accent, width: 3))
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: selected ? accent : idle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: label,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _pageTitle(String location, List<_NavGroup> groups) {
  for (final group in groups) {
    for (final item in group.items) {
      if (_isSelected(location, item.path)) return item.label;
    }
  }
  return AppConstants.appName;
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'U';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
