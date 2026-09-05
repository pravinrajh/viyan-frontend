import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/role_capabilities.dart';
import '../core/constants/app_routes.dart';
import '../features/assistant/presentation/assistant_screen.dart';
import '../features/auth/models/auth_user.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/crm/presentation/crm_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/finance/presentation/finance_screen.dart';
import '../features/invoices/presentation/invoices_screen.dart';
import '../features/land/presentation/land_screen.dart';
import '../features/md_notes/presentation/md_notes_screen.dart';
import '../features/meetings/presentation/meetings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/sales/presentation/sales_screen.dart';
import '../features/sales_activities/presentation/sales_activities_screen.dart';
import '../features/tasks/presentation/create_task_screen.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/users/presentation/users_screen.dart';
import '../features/vendors/presentation/vendors_screen.dart';
import '../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final path = state.uri.path;
      final onAuthPage = path == AppRoutes.login || path == AppRoutes.register;
      if (auth.status == AuthStatus.initial) return null;
      if (auth.isAuthenticated) {
        if (onAuthPage) return AppRoutes.dashboard;
        final role = auth.session?.user.role;
        return _capabilityRedirect(path, role);
      }
      if (!onAuthPage) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.dashboard),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.assistant,
            builder: (context, state) => const AssistantScreen(),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CreateTaskScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) =>
                    TaskDetailScreen(taskId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.meetings,
            builder: (context, state) => const MeetingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.projects,
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: AppRoutes.finance,
            builder: (context, state) => const FinanceScreen(),
          ),
          GoRoute(
            path: AppRoutes.collections,
            redirect: (context, state) => AppRoutes.invoices,
          ),
          GoRoute(
            path: AppRoutes.invoices,
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: AppRoutes.vendors,
            builder: (context, state) => const VendorsScreen(),
          ),
          GoRoute(
            path: AppRoutes.land,
            builder: (context, state) => const LandScreen(),
          ),
          GoRoute(
            path: AppRoutes.mdNotes,
            builder: (context, state) => const MdNotesScreen(),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: AppRoutes.reminders,
            builder: (context, state) => const RemindersScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.sales,
            builder: (context, state) => const SalesScreen(),
            routes: [
              GoRoute(
                path: 'activities',
                builder: (context, state) => const SalesActivitiesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.crm,
            builder: (context, state) => const CrmScreen(),
          ),
          GoRoute(
            path: AppRoutes.users,
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Default-deny route guard: every shell route must map to a capability.
/// Exposed (not private) so tests can verify redirect behavior per role.
@visibleForTesting
String? capabilityRedirect(String path, String? role) =>
    _capabilityRedirect(path, role);

String? _capabilityRedirect(String path, String? role) {
  AppCapability? required;
  if (path.startsWith(AppRoutes.dashboard)) {
    required = AppCapability.viewDashboard;
  } else if (path.startsWith(AppRoutes.assistant)) {
    required = AppCapability.viewAssistant;
  } else if (path == AppRoutes.taskNew) {
    required = AppCapability.createTasks;
  } else if (path.startsWith(AppRoutes.tasks)) {
    required = AppCapability.viewTasks;
  } else if (path.startsWith(AppRoutes.meetings)) {
    required = AppCapability.viewMeetings;
  } else if (path.startsWith(AppRoutes.projects)) {
    required = AppCapability.viewProjects;
  } else if (path.startsWith(AppRoutes.users)) {
    required = AppCapability.viewUsers;
  } else if (path.startsWith(AppRoutes.finance)) {
    required = AppCapability.viewFinance;
  } else if (path.startsWith(AppRoutes.salesActivities) ||
      path.startsWith(AppRoutes.sales)) {
    required = AppCapability.viewSales;
  } else if (path.startsWith(AppRoutes.crm)) {
    required = AppCapability.viewCrm;
  } else if (path.startsWith(AppRoutes.invoices) ||
      path.startsWith(AppRoutes.collections)) {
    required = AppCapability.viewInvoices;
  } else if (path.startsWith(AppRoutes.vendors)) {
    required = AppCapability.viewVendors;
  } else if (path.startsWith(AppRoutes.land)) {
    required = AppCapability.viewLand;
  } else if (path.startsWith(AppRoutes.mdNotes)) {
    required = AppCapability.viewMdNotes;
  } else if (path.startsWith(AppRoutes.budgets)) {
    required = AppCapability.viewBudgets;
  } else if (path.startsWith(AppRoutes.reminders)) {
    required = AppCapability.viewReminders;
  } else if (path.startsWith(AppRoutes.reports)) {
    required = AppCapability.viewReports;
  } else if (path.startsWith(AppRoutes.notifications)) {
    required = AppCapability.viewNotifications;
  } else if (path.startsWith(AppRoutes.profile)) {
    required = AppCapability.viewProfile;
  }
  if (required == null) return null;
  if (RoleCapabilities.can(role, required)) return null;
  return AppRoutes.dashboard;
}
